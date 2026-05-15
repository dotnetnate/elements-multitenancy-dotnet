#!/usr/bin/env bash
# assess-changes.sh <repo-path>
# Emits {"unborn":bool,"hasChanges":bool,"branch":"...","files":[{"path":"...","status":"XY"}]}
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

repo="${1:-}"
require_repo "$repo"

branch="$(git_in_quiet "$repo" rev-parse --abbrev-ref HEAD || printf 'HEAD')"

unborn="false"
if git_in_quiet "$repo" symbolic-ref -q HEAD >/dev/null; then
  if ! git_in_quiet "$repo" rev-parse --verify -q HEAD >/dev/null; then
    unborn="true"
  fi
fi

# Porcelain v1 with NUL separators; each record is "XY path\0".
# Rename records include a second path "XY orig\0new\0"; we keep only the new path.
# We must pipe git output directly into read -d '' — command substitution strips NUL bytes.

has_changes="false"
first=1
files_json='['

# Read NUL-delimited records into an array.
records=()
while IFS= read -r -d '' rec; do
  records+=("$rec")
done < <(git_in "$repo" status --porcelain=v1 -z || true)

skip_next=0
for rec in "${records[@]}"; do
  if (( skip_next )); then
    skip_next=0
    continue
  fi
  # First two chars are status codes; char 3 is a space; rest is path.
  code="${rec:0:2}"
  path="${rec:3}"
  # Rename/copy entries: code begins with R or C; next record is the original path.
  case "${code:0:1}" in
    R|C) skip_next=1 ;;
  esac
  has_changes="true"
  if (( first )); then first=0; else files_json+=','; fi
  files_json+="{\"path\":$(json_string "$path"),\"status\":$(json_string "$code")}"
done
files_json+=']'

printf '{"unborn":%s,"hasChanges":%s,"branch":%s,"files":%s}\n' \
  "$unborn" "$has_changes" "$(json_string "$branch")" "$files_json"
