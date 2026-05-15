#!/usr/bin/env bash
# stage-and-commit.sh <repo-path> <commit-message> <files-json>
# files-json: a flat JSON array of paths. "[]" stages all changes (tracked + untracked).
# Emits {"sha":"...","subject":"..."}.
# Limitation: paths must not contain embedded double quotes or backslashes.
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

repo="${1:-}"
message="${2:-}"
files_json="${3:-[]}"
require_repo "$repo"
[[ -n "$message" ]] || fail "commit message is required"

files=()
parse_json_string_array "$files_json" files

if (( ${#files[@]} == 0 )); then
  git_in "$repo" add -A
else
  git_in "$repo" add -- "${files[@]}"
fi

# Pass the message via a temp file to preserve multiline bodies and avoid
# per-shell quoting rules (particularly important on Windows).
tmp_msg="$(mktemp -t ship-it-msg.XXXXXX)"
trap 'rm -f "$tmp_msg"' EXIT
printf '%s\n' "$message" > "$tmp_msg"

git_in "$repo" commit -F "$tmp_msg" >/dev/null

sha="$(git_in "$repo" rev-parse HEAD)"
subject="$(git_in "$repo" log -1 --pretty=%s)"

printf '{"sha":%s,"subject":%s}\n' \
  "$(json_string "$sha")" "$(json_string "$subject")"
