#!/usr/bin/env bash
# discover-repos.sh <folder> [<folder> ...]
# Takes one or more folder paths (typically the VS Code workspace folders)
# and emits a JSON array of absolute paths for those that are git repos.
# Folders that cannot be resolved or are not git repos are dropped from the
# array, but each drop is reported on stderr so callers can diagnose
# path-format / bash-flavor mismatches instead of seeing a silent `[]`.
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

(( $# >= 1 )) || fail "usage: discover-repos.sh <folder> [<folder> ...]"

is_repo() {
  # A git repo has a .git dir OR a .git file (worktrees).
  [[ -e "$1/.git" ]]
}

repos=()
for folder in "$@"; do
  resolved="$(normalize_path "$folder")"
  if [[ ! -d "$resolved" ]]; then
    printf 'ship-it: discover: skipping %q — not found (resolved: %s)\n' \
      "$folder" "$resolved" >&2
    continue
  fi
  abs="$(cd "$resolved" && pwd)"
  if ! is_repo "$abs"; then
    printf 'ship-it: discover: skipping %q — not a git repo (resolved: %s)\n' \
      "$folder" "$abs" >&2
    continue
  fi
  repos+=("$abs")
done

json_string_array repos
printf '\n'
