#!/usr/bin/env bash
# Regression tests for README First read-only maintenance scripts.

set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PATHS="$ROOT/skills/readme-first-maintainer/scripts/check-paths.sh"
FRESHNESS="$ROOT/skills/readme-first-maintainer/scripts/check-freshness.sh"
HOTSPOTS="$ROOT/skills/readme-first-maintainer/scripts/dir-hotspots.sh"
BUILDER_HOTSPOTS="$ROOT/skills/readme-first-builder/scripts/dir-hotspots.sh"
PROFILES="$ROOT/skills/readme-first-maintainer/scripts/check-profiles.py"
RISK_SCAN="$ROOT/extensions/fullstack-foundations/skill/fullstack-foundations-guard/scripts/risk_scan.py"

fail() {
  echo "test-maintainer-scripts: FAIL: $*" >&2
  exit 1
}

for tool in git python3 grep sed awk find sort mktemp; do
  command -v "$tool" >/dev/null 2>&1 || fail "missing required test tool: $tool"
done

for script in "$PATHS" "$FRESHNESS" "$HOTSPOTS" "$BUILDER_HOTSPOTS"; do
  [[ -f "$script" ]] || fail "missing script: $script"
  bash -n "$script" || fail "bash syntax error: $script"
done
python3 -m py_compile "$PROFILES" "$RISK_SCAN"
cmp -s "$HOTSPOTS" "$BUILDER_HOTSPOTS" \
  || fail "builder and maintainer dir-hotspots.sh must remain identical"

TMP=$(mktemp -d "${TMPDIR:-/tmp}/readme-first-tests.XXXXXX")
trap 'rm -rf "$TMP"' EXIT

# check-paths.sh: valid links, inline paths and fenced examples.
mkdir -p "$TMP/paths-clean/docs"
cat > "$TMP/paths-clean/README.md" <<'MD'
# Fixture

[Guide](./docs/guide.md)

Inline repository path: `docs/guide.md`.

```md
[Example only](./does-not-exist-in-fenced-code.md)
```
MD
printf '# Guide\n' > "$TMP/paths-clean/docs/guide.md"
output=$($PATHS "$TMP/paths-clean")
[[ "$output" == *"check-paths: clean"* ]] || fail "clean path fixture did not pass"

mkdir -p "$TMP/paths-dead/docs"
cat > "$TMP/paths-dead/README.md" <<'MD'
# Fixture

[Missing](docs/missing.md)
MD
if output=$($PATHS "$TMP/paths-dead" 2>&1); then
  fail "dead Markdown link was not rejected"
fi
[[ "$output" == *"DEAD: README.md:3 -> docs/missing.md"* ]] \
  || fail "dead path output was not precise: $output"

# check-freshness.sh: clean, stale and missing-stamp fixtures.
mkdir -p "$TMP/fresh/docs/module" "$TMP/fresh/src"
(
  cd "$TMP/fresh"
  git init -q
  git config user.email test@example.com
  git config user.name test
  printf 'export const value = 1;\n' > src/index.ts
  cat > docs/module/README.md <<'MD'
# Module

> 更新于:2099-01-01
MD
  git add .
  git commit -qm 'initial'
)
output=$($FRESHNESS "$TMP/fresh" 60)
[[ "$output" == *"check-freshness: clean"* ]] || fail "fresh stamp did not pass"

mkdir -p "$TMP/stale/docs/module/src"
(
  cd "$TMP/stale"
  git init -q
  git config user.email test@example.com
  git config user.name test
  cat > docs/module/README.md <<'MD'
# Module

> 更新于:2000-01-01
MD
  printf 'export const value = 1;\n' > docs/module/src/index.ts
  git add .
  git commit -qm 'initial'
)
if output=$($FRESHNESS "$TMP/stale" 60 2>&1); then
  fail "stale stamp was not rejected"
fi
[[ "$output" == *"STALE(60d): ./docs/module/README.md"* ]] \
  || fail "stale output was not precise: $output"

mkdir -p "$TMP/no-stamp/docs/module"
printf '# Module\n' > "$TMP/no-stamp/docs/module/README.md"
if output=$($FRESHNESS "$TMP/no-stamp" 60 2>&1); then
  fail "missing stamp was not rejected"
fi
[[ "$output" == *"NO-STAMP: ./docs/module/README.md"* ]] \
  || fail "missing-stamp output was not precise: $output"

# dir-hotspots.sh: one commit touching multiple files counts once.
mkdir -p "$TMP/hotspots/src"
(
  cd "$TMP/hotspots"
  git init -q
  git config user.email test@example.com
  git config user.name test
  printf 'a\n' > src/a.ts
  printf 'b\n' > src/b.ts
  git add .
  git commit -qm 'touch two files in one commit'
  printf 'c\n' > src/c.ts
  git add .
  git commit -qm 'second commit'
)
output=$($HOTSPOTS "$TMP/hotspots")
heat=$(awk -F '\t' '$1 == "./src" { print $2 }' <<< "$output")
[[ "$heat" == "2" ]] || fail "hotspot heat must count unique commits, got: ${heat:-missing}"

# check-profiles.py: positive and negative fixtures.
mkdir -p "$TMP/profile-valid/extensions/demo/skill/demo-skill"
cat > "$TMP/profile-valid/extensions/demo/PROFILE.md" <<'MD'
---
profile_id: demo
profile_version: "1.0.0"
status: reference
skill_name: demo-skill
canonical_skill_path: extensions/demo/skill/demo-skill
install_skill_path: skills/demo-skill
risk_domains:
  - database
  - concurrency
---
# Demo
MD
cat > "$TMP/profile-valid/extensions/demo/skill/demo-skill/SKILL.md" <<'MD'
---
name: demo-skill
description: Demo skill used only by the fixture and long enough for routing.
---
# Demo Skill
MD
output=$(python3 "$PROFILES" "$TMP/profile-valid")
[[ "$output" == *"check-profiles: clean (1 profile(s))"* ]] \
  || fail "valid Profile did not pass: $output"

cp -R "$TMP/profile-valid" "$TMP/profile-invalid"
sed -i 's/  - concurrency/  - invented-domain/' \
  "$TMP/profile-invalid/extensions/demo/PROFILE.md"
if output=$(python3 "$PROFILES" "$TMP/profile-invalid" 2>&1); then
  fail "unknown risk domain was not rejected"
fi
[[ "$output" == *"unknown risk domains: invented-domain"* ]] \
  || fail "Profile failure output was not useful: $output"

# risk_scan.py: a repository below /tmp must still be scanned.
mkdir -p "$TMP/risk-repo/src" "$TMP/risk-repo/node_modules/example"
cat > "$TMP/risk-repo/src/bad.ts" <<'TS'
const options = { rejectUnauthorized: false };
localStorage.setItem('accessToken', token);
await Promise.all(items.map(loadOne));
TS
cat > "$TMP/risk-repo/node_modules/example/ignored.ts" <<'TS'
const password = 'not-a-real-secret';
TS
json_output=$(python3 "$RISK_SCAN" "$TMP/risk-repo" --format json)
python3 - "$json_output" <<'PY'
import json
import sys
payload = json.loads(sys.argv[1])
ids = {item["rule_id"] for item in payload["candidates"]}
required = {"SEC001", "SEC005", "NODE002"}
missing = required - ids
if missing:
    raise SystemExit(f"missing candidate rules: {sorted(missing)}")
if any(item["path"].startswith("node_modules/") for item in payload["candidates"]):
    raise SystemExit("excluded dependency directory was scanned")
PY
if python3 "$RISK_SCAN" "$TMP/risk-repo" --format json --fail-on high >/dev/null 2>&1; then
  fail "--fail-on high did not return non-zero"
fi

printf 'test-maintainer-scripts: all tests passed\n'
