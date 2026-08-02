#!/usr/bin/env bash
# check-paths.sh: verify repository-relative Markdown links and path references.
# Read-only. Exit 1 when dead references are found.

set -euo pipefail

show_help() {
  cat <<'HELP'
Usage: check-paths.sh [DIRECTORY]

Checks Markdown files below DIRECTORY (default: current directory):
  1. relative Markdown links, resolved from the source document;
  2. inline backtick repository paths, treated as lower-confidence candidates.

Fenced code blocks, URLs, anchors, template placeholders, build/cache folders,
optional README First install destinations, plans/done and changes/archive are
excluded. Findings are printed as:

  DEAD: path/to/file.md:LINE -> referenced/path
HELP
}

if [[ "${1:-}" == "--help" ]]; then
  show_help
  exit 0
fi

ROOT="${1:-.}"
command -v python3 >/dev/null 2>&1 || {
  echo "check-paths: python3 is required" >&2
  exit 2
}

python3 - "$ROOT" <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import unquote

root = Path(sys.argv[1]).resolve()
if not root.is_dir():
    print(f"check-paths: root does not exist: {root}", file=sys.stderr)
    raise SystemExit(2)

EXCLUDED_DIRS = {
    ".git",
    "node_modules",
    "dist",
    "build",
    "coverage",
    ".cache",
    ".next",
    "out",
    "tmp",
    "logs",
    "vendor",
    "__pycache__",
}
PLACEHOLDER_PARTS = {
    "YYYY-MM",
    "YYYY-MM-DD",
    "NNNN",
    "<target>",
    "<profile-id>",
    "<skill-name>",
    "<pack>",
    "<capability-pack>",
}
OPTIONAL_PREFIXES = (
    ".ai/profiles/",
    ".ai/plans/",
    ".ai/changes/archive/",
    "skills/<",
    "extensions/<",
)
SCHEMES = (
    "http://",
    "https://",
    "mailto:",
    "tel:",
    "data:",
    "javascript:",
    "skills://",
)
LINK_RE = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")
INLINE_CODE_RE = re.compile(r"`([^`\n]+)`")
PATHISH_RE = re.compile(r"^(?:\.?\.?/|/)?[A-Za-z0-9_.@+\-]+(?:/[A-Za-z0-9_.@+\-]+)+(?:/)?(?:#[^\s]+)?$")
INSTALL_RE = re.compile(
    r"^\s*install_skill_path\s*:\s*['\"]?([^'\"\s]+)", re.MULTILINE
)


def is_excluded(path: Path) -> bool:
    try:
        rel = path.relative_to(root)
    except ValueError:
        return True
    return any(part in EXCLUDED_DIRS for part in rel.parts)


def markdown_files() -> list[Path]:
    return sorted(
        path
        for path in root.rglob("*.md")
        if path.is_file() and not path.is_symlink() and not is_excluded(path)
    )


def collect_install_paths(files: list[Path]) -> set[str]:
    paths: set[str] = set()
    for path in files:
        rel = path.relative_to(root).as_posix()
        if not (
            (rel.startswith("extensions/") and rel.endswith("/PROFILE.md"))
            or rel.startswith(".ai/profiles/")
        ):
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (OSError, UnicodeError):
            continue
        for match in INSTALL_RE.finditer(text):
            paths.add(match.group(1).rstrip("/"))
    return paths


def strip_optional_title(raw: str) -> str:
    raw = raw.strip()
    if raw.startswith("<") and ">" in raw:
        return raw[1 : raw.index(">")]
    # Markdown allows: (path "title"). Keep the first token unless escaped spaces
    # or angle brackets are used; documentation paths in this repository do not
    # rely on escaped spaces.
    if " " in raw:
        raw = raw.split(" ", 1)[0]
    return raw.strip("<>")


def should_skip(raw: str, install_paths: set[str]) -> bool:
    value = raw.strip()
    lower = value.lower()
    if not value or value.startswith("#") or lower.startswith(SCHEMES):
        return True
    if any(part in value for part in PLACEHOLDER_PARTS):
        return True
    if value.startswith(OPTIONAL_PREFIXES):
        return True
    normalized = value.split("#", 1)[0].split("?", 1)[0].rstrip("/")
    for install in install_paths:
        if normalized == install or normalized.startswith(install + "/"):
            return True
    return False


def resolve_reference(
    source: Path, raw: str, *, root_fallback: bool = False
) -> Path | None:
    value = unquote(raw).split("#", 1)[0].split("?", 1)[0]
    if not value:
        return source
    if value.startswith("/"):
        candidates = [root / value.lstrip("/")]
    else:
        candidates = [source.parent / value]
        if root_fallback:
            candidates.append(root / value.lstrip("./"))

    first_valid: Path | None = None
    for candidate in candidates:
        try:
            resolved = candidate.resolve(strict=False)
            resolved.relative_to(root)
        except (OSError, ValueError):
            continue
        if first_valid is None:
            first_valid = resolved
        if resolved.exists():
            return resolved
    return first_valid


def source_lines_without_fences(text: str):
    fenced = False
    fence_char = ""
    for line_number, line in enumerate(text.splitlines(), 1):
        stripped = line.lstrip()
        if stripped.startswith("```") or stripped.startswith("~~~"):
            current = stripped[:3]
            if not fenced:
                fenced = True
                fence_char = current
            elif current == fence_char:
                fenced = False
                fence_char = ""
            continue
        if not fenced:
            yield line_number, line


files = markdown_files()
install_paths = collect_install_paths(files)
findings: set[tuple[str, int, str]] = set()

for source in files:
    try:
        text = source.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as exc:
        print(f"check-paths: cannot read {source}: {exc}", file=sys.stderr)
        raise SystemExit(2)

    rel_source = source.relative_to(root).as_posix()
    for line_number, line in source_lines_without_fences(text):
        for match in LINK_RE.finditer(line):
            raw = strip_optional_title(match.group(1))
            if should_skip(raw, install_paths):
                continue
            target = resolve_reference(source, raw)
            if target is None or not target.exists():
                findings.add((rel_source, line_number, raw))

        for match in INLINE_CODE_RE.finditer(line):
            raw = match.group(1).strip()
            if not PATHISH_RE.fullmatch(raw) or should_skip(raw, install_paths):
                continue
            target = resolve_reference(source, raw, root_fallback=True)
            if target is not None and target.exists():
                continue
            # Inline paths are examples surprisingly often. Report only if the
            # root segment already exists, which makes the reference likely to
            # describe this repository rather than a target-project template.
            normalized = raw.lstrip("./").lstrip("/")
            first = normalized.split("/", 1)[0]
            if first and (root / first).exists():
                findings.add((rel_source, line_number, raw))

if findings:
    for source, line_number, raw in sorted(findings):
        print(f"DEAD: {source}:{line_number} -> {raw}")
    raise SystemExit(1)

print("check-paths: clean")
PY
