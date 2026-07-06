#!/usr/bin/env bash
# check-freshness.sh: 检查 README 与 architecture 文件的时效戳或相对新鲜度。
# 只读脚本,退出码非零表示发现过期文档。
# 用法: ./check-freshness.sh [目录] [阈值天数] [--help]

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: check-freshness.sh [DIRECTORY] [DAYS]

Checks freshness of README.md and .ai/architecture/*.md files.
For each doc it:
  - reports docs without a timestamp line;
  - reports docs whose timestamp is older than the latest code commit in
    their directory by more than DAYS (default: 60).

Timestamps are read from lines like:
  > 更新于:YYYY-MM-DD · commit <short-sha>
EOF
}

if [ "${1:-}" = "--help" ]; then
  show_help
  exit 0
fi

ROOT="${1:-.}"
DAYS="${2:-60}"
SECONDS=$((DAYS * 86400))

cd "$ROOT" || exit 2

FOUND=0

find . -type f \( -name 'README.md' -not -path './README.md' -o -path './.ai/architecture/*.md' \) \
  -not -path './node_modules/*' -not -path './.git/*' | while read -r doc; do

  dir=$(dirname "$doc")
  stamp=$(grep -m1 -E '^> 更新于:' "$doc" 2>/dev/null || true)

  if [ -z "$stamp" ]; then
    echo "NO-STAMP: $doc"
    FOUND=1
    continue
  fi

  stamp_date=$(echo "$stamp" | sed -E 's/.*更新于:([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1/')
  stamp_epoch=$(date -d "$stamp_date" +%s 2>/dev/null || echo 0)

  # Latest commit in the directory, excluding the doc itself.
  code_epoch=$(git log -1 --format=%ct -- "$dir" ':(exclude)'"$doc" 2>/dev/null || echo 0)

  if [ "$stamp_epoch" -ne 0 ] && [ "$code_epoch" -ne 0 ]; then
    diff=$((code_epoch - stamp_epoch))
    if [ "$diff" -gt "$SECONDS" ]; then
      echo "STALE($DAYS>d): $doc (stamp $stamp_date, code updated since)"
      FOUND=1
    fi
  fi
done

exit "$FOUND"
