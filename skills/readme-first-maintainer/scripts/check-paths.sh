#!/usr/bin/env bash
# check-paths.sh: 提取 Markdown 中反引号路径与相对链接,验证存在性。
# 只读脚本,退出码非零表示发现失效路径。
# 用法: ./check-paths.sh [目录] [--help]

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: check-paths.sh [DIRECTORY]

Extracts backtick-quoted paths and relative markdown links from *.md files
under DIRECTORY (default: current directory), then checks whether each
referenced path exists. Prints a list of dead references to stdout and
exits with non-zero status if any are found.

Template placeholders (YYYY-MM, NNNN, angle-bracket placeholders, etc.)
are ignored.
EOF
}

if [ "${1:-}" = "--help" ]; then
  show_help
  exit 0
fi

ROOT="${1:-.}"
cd "$ROOT" || exit 2

TMPDIR="${TMPDIR:-/tmp}"
REFS=$(mktemp "$TMPDIR/check-paths-refs.XXXXXX")
trap 'rm -f "$REFS"' EXIT

# Extract backtick-quoted paths (with extension or trailing slash), skipping archives.
grep -rnoE --include='*.md' --exclude-dir='.git' --exclude-dir='node_modules' \
  '`[A-Za-z0-9_./@-]+\.[a-zA-Z0-9]{1,4}`|`[A-Za-z0-9_./@-]+/`' . \
  | grep -v '/\.ai/plans/done/' \
  | grep -v '/\.ai/changes/archive/' \
  | sed 's/`//g' \
  | sort -u > "$REFS" || true

FOUND=0
while IFS=: read -r file _ path; do
  # Skip placeholders and URLs.
  case "$path" in
    *YYYY-MM* | *NNNN* | *'<"* | *">'* | http* | mailto*) continue ;;
  esac

  dir=${file%/*}
  target="$dir/$path"
  target=${target%/}

  if [ ! -e "$target" ] && [ ! -e "./$path" ]; then
    echo "DEAD: $file -> $path"
    FOUND=1
  fi
done < "$REFS"

if [ "$FOUND" -eq 0 ]; then
  echo "check-paths: clean"
fi

exit "$FOUND"
