#!/usr/bin/env bash
# push.sh <repo-path>
# Pushes current branch to origin, setting upstream if missing.
# Emits {"branch":"...","upstream":"...","pushed":true}.
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

repo="${1:-}"
require_repo "$repo"

branch="$(git_in "$repo" rev-parse --abbrev-ref HEAD)"
[[ "$branch" != "HEAD" ]] || fail "cannot push from a detached HEAD"

upstream=""
if upstream_raw="$(git_in_quiet "$repo" rev-parse --abbrev-ref --symbolic-full-name '@{u}')"; then
  upstream="$upstream_raw"
fi

if [[ -z "$upstream" ]]; then
  git_in "$repo" push --set-upstream origin "$branch" >&2
  upstream="origin/$branch"
else
  git_in "$repo" push >&2
fi

printf '{"branch":%s,"upstream":%s,"pushed":true}\n' \
  "$(json_string "$branch")" "$(json_string "$upstream")"
