#!/usr/bin/env bash
# detect-root-branch.sh <repo-path>
# Emits {"branch":"...","isRoot":bool,"defaultBranch":"..."}.
# defaultBranch resolution order:
#   1. gh repo view --json defaultBranchRef (if gh available)
#   2. parse refs/remotes/origin/HEAD
#   3. probe origin/main
#   4. probe origin/master
#   5. empty string
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

repo="${1:-}"
require_repo "$repo"

branch="$(git_in "$repo" rev-parse --abbrev-ref HEAD)"
default_branch=""

if command -v gh >/dev/null 2>&1; then
  if out="$(gh_in "$repo" repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null)"; then
    default_branch="$(printf '%s' "$out" | tr -d '[:space:]')"
  fi
fi

if [[ -z "$default_branch" ]]; then
  if head_ref="$(git_in_quiet "$repo" symbolic-ref refs/remotes/origin/HEAD)"; then
    default_branch="${head_ref#refs/remotes/origin/}"
  fi
fi

if [[ -z "$default_branch" ]]; then
  if git_in_quiet "$repo" show-ref --verify --quiet refs/remotes/origin/main; then
    default_branch="main"
  elif git_in_quiet "$repo" show-ref --verify --quiet refs/remotes/origin/master; then
    default_branch="master"
  fi
fi

is_root="false"
if [[ -n "$default_branch" && "$branch" == "$default_branch" ]]; then
  is_root="true"
fi

printf '{"branch":%s,"isRoot":%s,"defaultBranch":%s}\n' \
  "$(json_string "$branch")" "$is_root" "$(json_string "$default_branch")"
