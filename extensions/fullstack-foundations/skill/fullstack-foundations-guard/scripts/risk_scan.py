#!/usr/bin/env python3
"""Heuristic full-stack risk candidate scanner; no third-party packages.

Hits are investigation candidates, not confirmed vulnerabilities. Verify data
flow, configuration, trust boundaries, tests and deployment before reporting.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass
from pathlib import Path

VERSION = "1.0.1"
RANK = {"low": 1, "medium": 2, "high": 3}
EXTENSIONS = {
    ".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs", ".sql", ".prisma",
    ".json", ".yaml", ".yml", ".env", ".toml",
}
EXCLUDED_DIRS = {
    ".git", "node_modules", "dist", "build", "coverage", ".next", ".cache",
    "vendor", "tmp", "logs", "venv", ".venv", "__pycache__",
}
JS_EXTENSIONS = {".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs"}


@dataclass(frozen=True)
class Rule:
    id: str
    severity: str
    area: str
    message: str
    pattern: re.Pattern[str]
    extensions: frozenset[str] | None = None
    redact: bool = False


@dataclass(frozen=True)
class Candidate:
    rule_id: str
    severity: str
    area: str
    path: str
    line: int
    message: str
    snippet: str


def rule(rule_id: str, severity: str, area: str, message: str, pattern: str,
         extensions: set[str] | None = None, redact: bool = False) -> Rule:
    return Rule(rule_id, severity, area, message, re.compile(pattern, re.IGNORECASE),
                frozenset(extensions) if extensions else None, redact)


RULES = (
    rule("SEC001", "high", "Security", "TLS verification appears disabled.",
         r"rejectUnauthorized\s*:\s*false"),
    rule("SEC002", "high", "Security", "Potential interpolated or unsafe SQL.",
         r"(?:\bquery\s*\(\s*`[^`\n]*\$\{|\$queryRawUnsafe\s*\(|"
         r"\$executeRawUnsafe\s*\(|\bORDER\s+BY\s+\$\{)", JS_EXTENSIONS),
    rule("SEC003", "high", "Security", "Potential interpolated shell command.",
         r"\b(?:exec|execSync)\s*\(\s*`[^`\n]*\$\{", JS_EXTENSIONS),
    rule("SEC004", "high", "Security",
         "Likely hard-coded secret; verify and rotate if real.",
         r"\b(?:api[_-]?key|client[_-]?secret|password|access[_-]?token|"
         r"refresh[_-]?token)\b\s*[:=]\s*['\"][^'\"\n]{8,}['\"]", redact=True),
    rule("SEC005", "high", "Security",
         "Sensitive auth/session data may be in browser storage.",
         r"(?:localStorage|sessionStorage)\.(?:setItem|getItem)\s*\(\s*"
         r"['\"][^'\"\n]*(?:token|auth|session|password|secret)[^'\"\n]*['\"]",
         JS_EXTENSIONS),
    rule("SEC006", "high", "Security",
         "Sensitive data may be logged; inspect redaction.",
         r"(?:console\.|logger\.)[^\n]*(?:password|token|authorization|"
         r"cookie|secret|身份证|手机号)", JS_EXTENSIONS, True),
    rule("HTTP001", "high", "HTTP",
         "Wildcard CORS appears combined with credentials.",
         r"(?:origin\s*:\s*['\"]\*['\"][^\n]{0,160}credentials\s*:\s*true|"
         r"credentials\s*:\s*true[^\n]{0,160}origin\s*:\s*['\"]\*['\"])",
         JS_EXTENSIONS | {".json", ".yaml", ".yml"}),
    rule("NODE001", "high", "Node",
         "Synchronous I/O/process work may block a request path.",
         r"\b(?:readFileSync|writeFileSync|execSync|spawnSync|pbkdf2Sync|"
         r"scryptSync)\s*\(", JS_EXTENSIONS),
    rule("NODE002", "medium", "Node",
         "Promise.all over a mapped collection may be unbounded.",
         r"Promise\.all\s*\([^\n]{0,120}\.map\s*\(", JS_EXTENSIONS),
    rule("DB001", "medium", "Database",
         "SELECT * is present; verify bounds and output mapping.",
         r"\bSELECT\s+\*\s+FROM\b", JS_EXTENSIONS | {".sql"}),
    rule("DB002", "medium", "Database",
         "OFFSET pagination is present; check worst-case depth.",
         r"\bOFFSET\s+(?:\$?\d+|\?|:[A-Za-z_]\w*)", JS_EXTENSIONS | {".sql"}),
    rule("DB003", "high", "Database",
         "Destructive schema operation; verify compatibility and recovery.",
         r"\b(?:DROP\s+(?:TABLE|COLUMN)|TRUNCATE\s+TABLE)\b",
         {".sql", ".prisma", ".ts", ".js"}),
    rule("AUTH001", "medium", "Authorization",
         "Body spreading into a write may permit mass assignment.",
         r"(?:create|update|insert|save)\s*\([^\n]{0,100}\.\.\.\s*"
         r"(?:req\.body|request\.body|body)\b", JS_EXTENSIONS),
    rule("OPS001", "medium", "Observability",
         "Empty catch or swallowed rejection may hide failure.",
         r"catch\s*(?:\([^)]*\))?\s*\{\s*\}|"
         r"\.catch\s*\([^\n]*=>\s*\{?\s*\}?\s*\)", JS_EXTENSIONS),
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", nargs="?", default=".")
    parser.add_argument("--format", choices=("markdown", "json"), default="markdown")
    parser.add_argument("--fail-on", choices=("none", "low", "medium", "high"), default="none")
    parser.add_argument("--max-file-bytes", type=int, default=1_000_000)
    parser.add_argument("--max-candidates", type=int, default=2_000)
    parser.add_argument("--version", action="version", version=VERSION)
    return parser.parse_args()


def is_excluded(relative: Path) -> bool:
    # Inspect only repository-relative parent directories. Using absolute
    # path.parts incorrectly excluded every repository cloned below /tmp.
    return any(part in EXCLUDED_DIRS for part in relative.parts[:-1])


def should_scan(path: Path, relative: Path, max_bytes: int) -> bool:
    if path.is_symlink() or not path.is_file() or is_excluded(relative):
        return False
    suffix = path.suffix.lower()
    if suffix not in EXTENSIONS and path.name.lower() not in {".env", "dockerfile"}:
        return False
    try:
        return path.stat().st_size <= max_bytes
    except OSError:
        return False


def sorted_candidates(hits: list[Candidate]) -> list[Candidate]:
    return sorted(hits, key=lambda item: (-RANK[item.severity], item.path,
                                          item.line, item.rule_id))


def scan(root: Path, max_bytes: int, max_candidates: int) -> list[Candidate]:
    hits: list[Candidate] = []
    for path in sorted(root.rglob("*")):
        try:
            relative = path.relative_to(root)
        except ValueError:
            continue
        if not should_scan(path, relative, max_bytes):
            continue
        try:
            lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
        except OSError:
            continue
        extension = path.suffix.lower()
        for line_number, line in enumerate(lines, 1):
            for current in RULES:
                if current.extensions and extension not in current.extensions:
                    continue
                if not current.pattern.search(line):
                    continue
                snippet = "<redacted candidate>" if current.redact else line.strip()[:240]
                hits.append(Candidate(current.id, current.severity, current.area,
                                      relative.as_posix(), line_number,
                                      current.message, snippet))
                if len(hits) >= max_candidates:
                    return sorted_candidates(hits)
    return sorted_candidates(hits)


def emit_markdown(root: Path, hits: list[Candidate], truncated: bool) -> None:
    print("# Full-stack Risk Candidates\n")
    print(f"- Root: `{root}`")
    print(f"- Candidates: {len(hits)}")
    print(f"- Truncated: {'yes' if truncated else 'no'}\n")
    print("> Candidates require verification; no hits is not proof of safety.\n")
    for item in hits:
        print(f"## [{item.severity.upper()}][{item.rule_id}][{item.area}] "
              f"`{item.path}:{item.line}`\n")
        print(f"{item.message}\n")
        print(f"```text\n{item.snippet}\n```\n")


def main() -> int:
    args = parse_args()
    root = Path(args.root).resolve()
    if not root.is_dir() or args.max_file_bytes <= 0 or args.max_candidates <= 0:
        print("risk_scan: invalid root or numeric limits", file=sys.stderr)
        return 2

    hits = scan(root, args.max_file_bytes, args.max_candidates)
    truncated = len(hits) >= args.max_candidates
    note = "Candidates require verification; no hits is not proof of safety."
    if args.format == "json":
        print(json.dumps({
            "scanner": "fullstack-foundations-guard",
            "version": VERSION,
            "root": str(root),
            "candidate_count": len(hits),
            "truncated": truncated,
            "candidates": [asdict(item) for item in hits],
            "disclaimer": note,
        }, ensure_ascii=False, indent=2))
    else:
        emit_markdown(root, hits, truncated)

    return int(args.fail_on != "none" and any(
        RANK[item.severity] >= RANK[args.fail_on] for item in hits
    ))


if __name__ == "__main__":
    raise SystemExit(main())
