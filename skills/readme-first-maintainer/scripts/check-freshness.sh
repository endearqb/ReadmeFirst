#!/usr/bin/env bash
# check-freshness.sh: check README and architecture timestamp freshness.
# Read-only. Exit 1 when missing, invalid or stale stamps are found.

set -euo pipefail

show_help() {
  cat <<'HELP'
Usage: check-freshness.sh [DIRECTORY] [DAYS]

Checks non-root README.md files and .ai/architecture/*.md files.
Accepted timestamp examples:
  > 更新于:2026-08-02
  > 更新于:2026-08-02 · 核验基线 abc1234

A document is STALE when a later code commit in its directory is more than
DAYS after the recorded date (default: 60). GNU and BSD/macOS date are supported.
HELP
}

if [[ "${1:-}" == "--help" ]]; then
  show_help
  exit 0
fi

ROOT="${1:-.}"
DAYS="${2:-60}"
[[ "$DAYS" =~ ^[0-9]+$ ]] || {
  echo "check-freshness: DAYS must be a non-negative integer" >&2
  exit 2
}
command -v git >/dev/null 2>&1 || {
  echo "check-freshness: git is required" >&2
  exit 2
}

cd "$ROOT" || exit 2
THRESHOLD=$((DAYS * 86400))

parse_date_epoch() {
  local value=$1
  if date -d "$value" +%s >/dev/null 2>&1; then
    date -d "$value" +%s
  elif date -j -f '%Y-%m-%d' "$value" +%s >/dev/null 2>&1; then
    date -j -f '%Y-%m-%d' "$value" +%s
  else
    return 1
  fi
}

FOUND=0
while IFS= read -r -d '' doc; do
  stamp=$(grep -m1 -E '^> 更新于:[0-9]{4}-[0-9]{2}-[0-9]{2}' "$doc" 2>/dev/null || true)
  if [[ -z "$stamp" ]]; then
    echo "NO-STAMP: $doc"
    FOUND=1
    continue
  fi

  stamp_date=$(sed -E 's/.*更新于:([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1/' <<< "$stamp")
  stamp_epoch=$(parse_date_epoch "$stamp_date" 2>/dev/null || echo 0)
  if [[ "$stamp_epoch" -eq 0 ]]; then
    echo "INVALID-STAMP: $doc -> $stamp_date"
    FOUND=1
    continue
  fi

  # A repository without history can still validate stamps but cannot calculate
  # relative staleness.
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    continue
  fi

  doc_path=${doc#./}
  dir_path=$(dirname "$doc_path")
  code_epoch=$(git log -1 --format=%ct -- "$dir_path" ":(exclude)$doc_path" 2>/dev/null || true)
  code_epoch=${code_epoch:-0}
  if [[ "$code_epoch" =~ ^[0-9]+$ && "$code_epoch" -ne 0 ]]; then
    diff=$((code_epoch - stamp_epoch))
    if [[ "$diff" -gt "$THRESHOLD" ]]; then
      echo "STALE(${DAYS}d): $doc (stamp $stamp_date, code updated later)"
      FOUND=1
    fi
  fi
done < <(
  find . \
    -type f \
    \( \
      \( -name 'README.md' -not -path './README.md' \) \
      -o -path './.ai/architecture/*.md' \
    \) \
    -not -path './.git/*' \
    -not -path './node_modules/*' \
    -not -path './dist/*' \
    -not -path './build/*' \
    -not -path './coverage/*' \
    -print0
)

if [[ "$FOUND" -eq 0 ]]; then
  echo "check-freshness: clean"
fi
exit "$FOUND"
