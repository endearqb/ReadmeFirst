#!/usr/bin/env python3
"""Validate README First v2.2 Profile → Skill bindings.

This is a structural validator, not a security or correctness scanner. It checks
frontmatter fields, standard risk-domain names, safe repository-relative paths,
and whether the referenced SKILL.md exists and declares the expected name.
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path

VERSION = "1.0.0"
ALLOWED_RISK_DOMAINS = {
    "database",
    "transaction",
    "concurrency",
    "http-network",
    "cache-overload",
    "runtime-resources",
    "authentication-authorization",
    "security-privacy",
    "migration-release",
    "external-side-effects",
}
REQUIRED_FIELDS = {
    "profile_id",
    "profile_version",
    "skill_name",
    "canonical_skill_path",
    "install_skill_path",
    "risk_domains",
}
KEBAB_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
SEMVER_RE = re.compile(
    r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)"
    r"(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$"
)
WINDOWS_DRIVE_RE = re.compile(r"^[A-Za-z]:")


@dataclass(frozen=True)
class Profile:
    path: Path
    fields: dict[str, str | list[str]]
    canonical: bool


def parse_frontmatter(path: Path) -> dict[str, str | list[str]]:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        raise ValueError("missing opening YAML frontmatter delimiter")

    try:
        end = next(i for i in range(1, len(lines)) if lines[i].strip() == "---")
    except StopIteration as exc:
        raise ValueError("missing closing YAML frontmatter delimiter") from exc

    fields: dict[str, str | list[str]] = {}
    active_list: str | None = None
    for raw in lines[1:end]:
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        if re.match(r"^\s+-\s+", raw):
            if active_list is None:
                raise ValueError(f"list item without a key: {raw.strip()}")
            value = re.sub(r"^\s+-\s+", "", raw).strip().strip('"\'')
            target = fields.setdefault(active_list, [])
            if not isinstance(target, list):
                raise ValueError(f"field {active_list!r} mixes scalar and list values")
            target.append(value)
            continue

        if ":" not in raw:
            raise ValueError(f"unsupported frontmatter line: {raw.strip()}")
        key, value = raw.split(":", 1)
        key = key.strip()
        value = value.strip()
        if not key:
            raise ValueError("empty frontmatter key")
        if value:
            fields[key] = value.strip('"\'')
            active_list = None
        else:
            fields[key] = []
            active_list = key
    return fields


def parse_skill_name(path: Path) -> str | None:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    try:
        end = next(i for i in range(1, len(lines)) if lines[i].strip() == "---")
    except StopIteration:
        return None
    for line in lines[1:end]:
        if line.startswith("name:"):
            return line.split(":", 1)[1].strip().strip("\"'")
    return None


def discover(root: Path) -> list[Profile]:
    profiles: list[Profile] = []
    for path in sorted(root.glob("extensions/*/PROFILE.md")):
        profiles.append(Profile(path, parse_frontmatter(path), True))
    profile_dir = root / ".ai" / "profiles"
    if profile_dir.exists():
        for path in sorted(profile_dir.glob("*.md")):
            profiles.append(Profile(path, parse_frontmatter(path), False))
    return profiles


def scalar(profile: Profile, key: str) -> str:
    value = profile.fields.get(key, "")
    return value if isinstance(value, str) else ""


def safe_repo_path(value: str) -> bool:
    if not value or "\\" in value or WINDOWS_DRIVE_RE.match(value):
        return False
    path = Path(value)
    return not path.is_absolute() and ".." not in path.parts and "." not in path.parts


def validate_profile(root: Path, profile: Profile) -> list[str]:
    errors: list[str] = []
    rel = profile.path.relative_to(root)
    missing = sorted(REQUIRED_FIELDS - profile.fields.keys())
    if missing:
        return [f"{rel}: missing fields: {', '.join(missing)}"]

    profile_id = scalar(profile, "profile_id")
    version = scalar(profile, "profile_version")
    skill_name = scalar(profile, "skill_name")
    canonical_path = scalar(profile, "canonical_skill_path")
    install_path = scalar(profile, "install_skill_path")
    domains = profile.fields.get("risk_domains", [])

    if not KEBAB_RE.fullmatch(profile_id):
        errors.append(f"{rel}: profile_id must be lowercase kebab-case")
    if not SEMVER_RE.fullmatch(version):
        errors.append(f"{rel}: profile_version must be semantic version text")
    if not KEBAB_RE.fullmatch(skill_name):
        errors.append(f"{rel}: skill_name must be lowercase kebab-case")

    if not isinstance(domains, list) or not domains:
        errors.append(f"{rel}: risk_domains must be a non-empty list")
    else:
        unknown = sorted(set(domains) - ALLOWED_RISK_DOMAINS)
        duplicates = sorted({item for item in domains if domains.count(item) > 1})
        if unknown:
            errors.append(f"{rel}: unknown risk domains: {', '.join(unknown)}")
        if duplicates:
            errors.append(f"{rel}: duplicate risk domains: {', '.join(duplicates)}")

    for key, value in (
        ("canonical_skill_path", canonical_path),
        ("install_skill_path", install_path),
    ):
        if not safe_repo_path(value):
            errors.append(f"{rel}: {key} must be a safe repository-relative path")

    expected_skill_path = canonical_path if profile.canonical else install_path
    if expected_skill_path and safe_repo_path(expected_skill_path):
        skill_file = root / expected_skill_path / "SKILL.md"
        if not skill_file.is_file():
            errors.append(f"{rel}: missing referenced Skill: {skill_file.relative_to(root)}")
        else:
            declared = parse_skill_name(skill_file)
            if declared != skill_name:
                errors.append(
                    f"{rel}: referenced Skill name {declared!r} does not match "
                    f"skill_name {skill_name!r}"
                )

    if profile.canonical:
        extension_dir = profile.path.parent.name
        if extension_dir != profile_id:
            errors.append(
                f"{rel}: extension directory {extension_dir!r} must match "
                f"profile_id {profile_id!r}"
            )
        expected_suffix = (Path("skill") / skill_name).as_posix()
        if canonical_path and not Path(canonical_path).as_posix().endswith(expected_suffix):
            errors.append(f"{rel}: canonical_skill_path should end with {expected_suffix}")
    else:
        if profile.path.stem != profile_id:
            errors.append(f"{rel}: local Profile filename must match profile_id {profile_id!r}")
        if install_path and Path(install_path).name != skill_name:
            errors.append(
                f"{rel}: install_skill_path should end with skill_name {skill_name!r}"
            )

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", nargs="?", default=".", help="repository root")
    parser.add_argument("--version", action="version", version=VERSION)
    args = parser.parse_args()

    root = Path(args.root).resolve()
    if not root.is_dir():
        print(f"check-profiles: root does not exist: {root}", file=sys.stderr)
        return 2

    try:
        profiles = discover(root)
    except (OSError, UnicodeError, ValueError) as exc:
        print(f"check-profiles: parse error: {exc}", file=sys.stderr)
        return 1

    errors = [
        error
        for profile in profiles
        for error in validate_profile(root, profile)
    ]
    if errors:
        for error in errors:
            print(f"PROFILE-ERROR: {error}")
        return 1

    print(f"check-profiles: clean ({len(profiles)} profile(s))")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
