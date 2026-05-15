#!/usr/bin/env bash
# create-branch.sh <repo-path> <branch-name>
# Creates and checks out a new branch. Emits {"baseBranch":"...","newBranch":"..."}.
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

repo="${1:-}"
new_branch="${2:-}"
require_repo "$repo"
[[ -n "$new_branch" ]] || fail "usage: create-branch.sh <repo-path> <branch-name>"

# Refuse if branch already exists locally.
if git_in_quiet "$repo" show-ref --verify --quiet "refs/heads/$new_branch"; then
  fail "branch already exists: $new_branch"
fi

base_branch="$(git_in_quiet "$repo" rev-parse --abbrev-ref HEAD || printf 'HEAD')"

git_in "$repo" checkout -b "$new_branch" >/dev/null

printf '{"baseBranch":%s,"newBranch":%s}\n' \
  "$(json_string "$base_branch")" "$(json_string "$new_branch")"
