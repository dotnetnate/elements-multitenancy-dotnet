#!/usr/bin/env bash
# find-open-prs.sh <repo-path>
# Emits {"branch":"...","count":N,"urls":[...],"ghAvailable":bool}.
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

repo="${1:-}"
require_repo "$repo"

branch="$(git_in "$repo" rev-parse --abbrev-ref HEAD)"

if ! command -v gh >/dev/null 2>&1; then
  printf '{"branch":%s,"count":0,"urls":[],"ghAvailable":false}\n' \
    "$(json_string "$branch")"
  exit 0
fi

urls=()
if out="$(gh_in "$repo" pr list --head "$branch" --state open --json url -q '.[].url' 2>/dev/null)"; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && urls+=("$line")
  done <<< "$out"
fi

count="${#urls[@]}"
printf '{"branch":%s,"count":%d,"urls":%s,"ghAvailable":true}\n' \
  "$(json_string "$branch")" "$count" "$(json_string_array urls)"
