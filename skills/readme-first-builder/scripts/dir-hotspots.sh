#!/usr/bin/env bash
# dir-hotspots.sh: output directory heat × complexity candidates.
# Read-only. Heat is unique commits touching a directory in the last 90 days.

set -euo pipefail

show_help() {
  cat <<'HELP'
Usage: dir-hotspots.sh [DIRECTORY]

Outputs tab-separated rows:
  directory  heat  complexity  recommendation

Heat:
  unique commits in the last 90 days touching any file under the directory.
Complexity:
  recursive relevant-file count + total lines/200 + internal max depth
  + 2 × large files (>500 lines).

Build, dependency, cache, coverage, log and VCS directories are excluded.
HELP
}

if [[ "${1:-}" == "--help" ]]; then
  show_help
  exit 0
fi

ROOT="${1:-.}"
cd "$ROOT" || exit 2

TMP_ROOT="${TMPDIR:-/tmp}"
HEAT=$(mktemp "$TMP_ROOT/readme-first-heat.XXXXXX")
PAIRS=$(mktemp "$TMP_ROOT/readme-first-commit-dirs.XXXXXX")
trap 'rm -f "$HEAT" "$PAIRS"' EXIT

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git log --since='90 days ago' --pretty=format:'@@%H' --name-only --no-renames 2>/dev/null \
    | awk '
      /^@@/ { commit=substr($0, 3); next }
      NF && commit != "" {
        path=$0
        sub(/^\.\//, "", path)
        n=split(path, parts, "/")
        if (n < 2) next
        dir=""
        for (i=1; i<n; i++) {
          dir=(dir == "" ? parts[i] : dir "/" parts[i])
          print commit "\t" dir
        }
      }
    ' | sort -u > "$PAIRS"

  awk -F '\t' '{ count[$2]++ } END { for (d in count) print count[d] "\t" d }' \
    "$PAIRS" | sort -k2,2 > "$HEAT"
else
  : > "$HEAT"
fi

is_relevant_file() {
  case "$1" in
    *.md|*.py|*.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs|*.sh|*.bash|*.zsh|*.yaml|*.yml|*.json|*.toml|*.sql|*.go|*.rs|*.java|*.cs|*.vue|*.svelte)
      return 0 ;;
    *) return 1 ;;
  esac
}

OUTPUT_COUNT=0
while IFS= read -r -d '' dir; do
  [[ "$dir" == "." ]] && continue

  file_count=0
  total_lines=0
  max_depth=0
  large_files=0

  while IFS= read -r -d '' file; do
    is_relevant_file "$file" || continue
    file_count=$((file_count + 1))
    lines=$(wc -l < "$file" 2>/dev/null || echo 0)
    lines=${lines//[[:space:]]/}
    [[ "$lines" =~ ^[0-9]+$ ]] || lines=0
    total_lines=$((total_lines + lines))
    [[ "$lines" -gt 500 ]] && large_files=$((large_files + 1))

    rel=${file#"$dir"/}
    slash_only=${rel//[^\/]/}
    depth=${#slash_only}
    [[ "$depth" -gt "$max_depth" ]] && max_depth=$depth
  done < <(
    find "$dir" \
      \( -type d \( \
        -name .git -o -name node_modules -o -name .cache -o -name dist \
        -o -name build -o -name coverage -o -name tmp -o -name logs \
        -o -name .next -o -name out -o -name vendor \
      \) -prune \) \
      -o -type f -print0 2>/dev/null
  )

  [[ "$file_count" -eq 0 ]] && continue

  complexity=$((file_count + total_lines / 200 + max_depth + large_files * 2))
  normalized=${dir#./}
  heat=$(awk -F '\t' -v d="$normalized" '$2 == d { print $1; found=1 } END { if (!found) print 0 }' "$HEAT")

  if [[ "$heat" -ge 5 && "$complexity" -ge 10 ]]; then
    recommendation='P0-build'
  elif [[ "$heat" -ge 5 ]]; then
    recommendation='short-README'
  elif [[ "$complexity" -ge 10 ]]; then
    recommendation='watch'
  else
    recommendation='skip'
  fi

  printf '%s\t%s\t%s\t%s\n' "$dir" "$heat" "$complexity" "$recommendation"
  OUTPUT_COUNT=$((OUTPUT_COUNT + 1))
done < <(
  find . -type d \
    -not -path './.git' -not -path './.git/*' \
    -not -path './node_modules' -not -path './node_modules/*' \
    -not -path './.cache' -not -path './.cache/*' \
    -not -path './dist' -not -path './dist/*' \
    -not -path './build' -not -path './build/*' \
    -not -path './coverage' -not -path './coverage/*' \
    -not -path './tmp' -not -path './tmp/*' \
    -not -path './logs' -not -path './logs/*' \
    -not -path './.next' -not -path './.next/*' \
    -not -path './out' -not -path './out/*' \
    -not -path './vendor' -not -path './vendor/*' \
    -print0
)

[[ "$OUTPUT_COUNT" -gt 0 ]] || exit 1
