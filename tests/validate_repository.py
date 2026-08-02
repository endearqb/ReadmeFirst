#!/usr/bin/env python3
"""Validate README First repository-level contracts without third-party packages."""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SEMVER_RE = re.compile(
    r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)"
    r"(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$"
)
PROFILE_MARKER = "<!-- README First protocol v{version} -->"
TRAINING_FILES = [
    "01-javascript-typescript-browser.md",
    "02-http-cors-cache-retries.md",
    "03-nodejs-runtime.md",
    "04-postgresql-modeling-indexes.md",
    "05-transactions-concurrency-idempotency.md",
    "06-cache-overload-backpressure.md",
    "07-security-privacy.md",
    "08-observability-testing-migrations.md",
    "09-labs-and-capstone.md",
    "10-team-rollout-checklists-sources.md",
]
REQUIRED_PATHS = [
    "AGENTS.md",
    "README.md",
    "VERSION",
    "migrations/v2.1-to-v2.2.md",
    ".ai/architecture/profiles-and-extensions.md",
    ".ai/decisions/0005-risk-domain-profiles-and-capability-packs.md",
    ".ai/changes/2026-08-02.md",
    "extensions/README.md",
    "extensions/profile-template.md",
    "extensions/fullstack-foundations/PROFILE.md",
    "extensions/fullstack-foundations/README.md",
    "extensions/fullstack-foundations/skill/fullstack-foundations-guard/SKILL.md",
    "extensions/fullstack-foundations/skill/fullstack-foundations-guard/references/training-handbook.md",
    "extensions/fullstack-foundations/skill/fullstack-foundations-guard/scripts/risk_scan.py",
    "skills/readme-first-builder/SKILL.md",
    "skills/readme-first-builder/references/agents-md-template.md",
    "skills/readme-first-builder/scripts/dir-hotspots.sh",
    "skills/readme-first-maintainer/SKILL.md",
    "skills/readme-first-maintainer/scripts/check-paths.sh",
    "skills/readme-first-maintainer/scripts/check-freshness.sh",
    "skills/readme-first-maintainer/scripts/check-profiles.py",
    "skills/readme-first-maintainer/scripts/dir-hotspots.sh",
    "tests/test-maintainer-scripts.sh",
    "tests/check-python-syntax.sh",
    "tests/validate_repository.py",
    ".github/workflows/validate.yml",
]


def read(path: str | Path) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def frontmatter(path: Path) -> dict[str, str]:
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0].strip() != "---":
        return {}
    try:
        end = next(i for i in range(1, len(lines)) if lines[i].strip() == "---")
    except StopIteration:
        return {}
    result: dict[str, str] = {}
    for line in lines[1:end]:
        if line and not line.startswith(" ") and ":" in line:
            key, value = line.split(":", 1)
            result[key.strip()] = value.strip().strip("\"'")
    return result


def normalized_builder_template(text: str) -> str:
    marker_index = text.find("<!-- README First protocol v")
    if marker_index < 0:
        return text.strip() + "\n"
    return text[marker_index:].strip() + "\n"


def main() -> int:
    errors: list[str] = []

    for relative in REQUIRED_PATHS:
        if not (ROOT / relative).is_file():
            errors.append(f"missing required file: {relative}")

    if errors:
        for error in errors:
            print(f"REPOSITORY-ERROR: {error}")
        return 1

    version = read("VERSION").strip()
    if not SEMVER_RE.fullmatch(version):
        errors.append(f"VERSION is not semantic version text: {version!r}")

    expected_marker = PROFILE_MARKER.format(version=version)
    agents = read("AGENTS.md").strip() + "\n"
    if not agents.startswith(expected_marker + "\n"):
        errors.append("AGENTS.md version marker does not match VERSION")

    builder_template = normalized_builder_template(
        read("skills/readme-first-builder/references/agents-md-template.md")
    )
    if agents != builder_template:
        errors.append("root AGENTS.md and builder offline template are not synchronized")

    builder_hotspots = ROOT / "skills/readme-first-builder/scripts/dir-hotspots.sh"
    maintainer_hotspots = ROOT / "skills/readme-first-maintainer/scripts/dir-hotspots.sh"
    if builder_hotspots.read_bytes() != maintainer_hotspots.read_bytes():
        errors.append("builder and maintainer dir-hotspots.sh differ")

    skill_paths = sorted((ROOT / "skills").glob("*/SKILL.md")) + sorted(
        (ROOT / "extensions").glob("*/skill/*/SKILL.md")
    )
    skill_names: set[str] = set()
    for path in skill_paths:
        fields = frontmatter(path)
        relative = path.relative_to(ROOT)
        name = fields.get("name", "")
        description = fields.get("description", "")
        if not name:
            errors.append(f"{relative}: missing top-level Skill name")
        elif name != path.parent.name:
            errors.append(
                f"{relative}: Skill name {name!r} does not match directory {path.parent.name!r}"
            )
        elif name in skill_names:
            errors.append(f"duplicate Skill name: {name}")
        else:
            skill_names.add(name)
        if len(description) < 40:
            errors.append(f"{relative}: description is too short to route reliably")

    expected_skills = {
        "readme-first-builder",
        "readme-first-maintainer",
        "fullstack-foundations-guard",
    }
    if skill_names != expected_skills:
        errors.append(
            f"unexpected Skill set: expected {sorted(expected_skills)}, got {sorted(skill_names)}"
        )

    profile_check = subprocess.run(
        [
            sys.executable,
            str(ROOT / "skills/readme-first-maintainer/scripts/check-profiles.py"),
            str(ROOT),
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    if profile_check.returncode != 0:
        errors.append(
            "Profile binding validation failed: "
            + (profile_check.stdout + profile_check.stderr).strip()
        )

    training_root = (
        ROOT
        / "extensions/fullstack-foundations/skill/fullstack-foundations-guard/references/training"
    )
    actual_training = sorted(path.name for path in training_root.glob("*.md"))
    if actual_training != TRAINING_FILES:
        errors.append(
            f"training chapter set mismatch: expected {TRAINING_FILES}, got {actual_training}"
        )
    training_index = read(
        "extensions/fullstack-foundations/skill/fullstack-foundations-guard/references/training-handbook.md"
    )
    for filename in TRAINING_FILES:
        if f"training/{filename}" not in training_index:
            errors.append(f"training index does not link training/{filename}")
        chapter = training_root / filename
        if chapter.is_file() and len(chapter.read_text(encoding="utf-8").splitlines()) < 25:
            errors.append(f"training chapter is unexpectedly thin: {filename}")

    migration = read("migrations/v2.1-to-v2.2.md")
    for required in ("v2.1", "v2.2", expected_marker, ".ai/profiles/"):
        if required not in migration:
            errors.append(f"migration guide is missing required concept: {required}")

    root_readme = read("README.md")
    for command in (
        "bash tests/test-maintainer-scripts.sh",
        "python3 tests/validate_repository.py",
    ):
        if command not in root_readme:
            errors.append(f"README validation section is missing command: {command}")

    probes = sorted(
        path.relative_to(ROOT).as_posix()
        for path in ROOT.rglob("*")
        if path.is_file() and "tool-probe" in path.name
    )
    if probes:
        errors.append(f"temporary connector probe files remain: {probes}")

    if errors:
        for error in errors:
            print(f"REPOSITORY-ERROR: {error}")
        return 1

    print(
        "validate-repository: clean "
        f"(version {version}, {len(skill_names)} skills, "
        f"{len(TRAINING_FILES)} training chapters, profile bindings valid)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
