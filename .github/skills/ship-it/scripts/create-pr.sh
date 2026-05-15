#!/usr/bin/env bash
# create-pr.sh <repo-path> <title> <body> <base-branch>
# Creates a GitHub pull request via gh. Emits {"url":"..."}.
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

repo="${1:-}"
title="${2:-}"
body="${3:-}"
base="${4:-}"
require_repo "$repo"
require_cmd gh
[[ -n "$title" ]] || fail "pr title is required"
[[ -n "$base" ]]  || fail "base branch is required"

tmp_body="$(mktemp -t ship-it-body.XXXXXX)"
trap 'rm -f "$tmp_body"' EXIT
printf '%s\n' "$body" > "$tmp_body"

# gh prints the URL on the last line of stdout on success.
out="$(gh_in "$repo" pr create --title "$title" --body-file "$tmp_body" --base "$base")"

# Extract the last GitHub URL from output.
url="$(printf '%s\n' "$out" | awk '/^https:\/\/github\.com\// {u=$0} END {print u}')"
[[ -n "$url" ]] || fail "could not parse PR URL from gh output: $out"

printf '{"url":%s}\n' "$(json_string "$url")"
