#!/usr/bin/env bash
# dir-hotspots.sh: 输出目录热度 × 复杂度双因子数据表。
# 只读脚本,退出码非零表示无可用数据(非错误)。
# 用法: ./dir-hotspots.sh [目录] [--help]

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: dir-hotspots.sh [DIRECTORY]

Outputs a tab-separated table of directory heat vs. complexity:

  directory | heat | complexity | recommendation

Heat      = number of commits touching the directory in the last 90 days.
Complexity = heuristic score based on file count, total lines, max depth,
             and number of large files (>500 lines).

Build/cache/dependency directories are excluded.
EOF
}

if [ "${1:-}" = "--help" ]; then
  show_help
  exit 0
fi

ROOT="${1:-.}"
cd "$ROOT" || exit 2

TMPDIR="${TMPDIR:-/tmp}"
HEAT=$(mktemp "$TMPDIR/dir-hotspots-heat.XXXXXX")
trap 'rm -f "$HEAT"' EXIT

# Heat: commits touching files in each directory over last 90 days.
git log --since="90 days ago" --name-only --pretty=format: \
  | grep -v '^$' \
  | xargs -n1 dirname 2>/dev/null \
  | sort \
  | uniq -c \
  | sort -rn > "$HEAT" || true

# Complexity and recommendation per directory (only directories with files).
find . -type d \
  -not -path './.git/*' \
  -not -path './node_modules/*' \
  -not -path './.cache/*' \
  -not -path './dist/*' \
  -not -path './build/*' \
  -not -path './coverage/*' \
  -not -path './tmp/*' \
  -not -path './logs/*' \
  -print0 | while IFS= read -r -d '' dir; do

  file_count=$(find "$dir" -maxdepth 1 -type f 2>/dev/null | wc -l)
  [ "$file_count" -eq 0 ] && continue

  total_lines=$(find "$dir" -type f \( -name '*.md' -o -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.sh' -o -name '*.yaml' -o -name '*.yml' -o -name '*.json' \) -print0 2>/dev/null | xargs -0 wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo 0)
  depth=$(echo "$dir" | tr -cd '/' | wc -c)
  large_files=$(find "$dir" -type f \( -name '*.md' -o -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.sh' -o -name '*.yaml' -o -name '*.yml' -o -name '*.json' \) -print0 2>/dev/null | xargs -0 wc -l 2>/dev/null | awk '$1 > 500 {c++} END {print c+0}' || echo 0)

  # Normalize complexity to a small integer score.
  complexity=$((file_count + total_lines / 200 + depth + large_files * 2))

  # Heat lookup.
  heat=$(grep -E "^[[:space:]]+[0-9]+ ${dir#./}$" "$HEAT" | awk '{print $1}' || echo 0)
  heat=${heat:-0}

  # Recommendation.
  if [ "$heat" -ge 5 ] && [ "$complexity" -ge 10 ]; then
    rec="P0-build"
  elif [ "$heat" -ge 5 ] && [ "$complexity" -lt 10 ]; then
    rec="short-README"
  elif [ "$heat" -lt 5 ] && [ "$complexity" -ge 10 ]; then
    rec="watch"
  else
    rec="skip"
  fi

  printf '%s\t%s\t%s\t%s\n' "$dir" "$heat" "$complexity" "$rec"
done
