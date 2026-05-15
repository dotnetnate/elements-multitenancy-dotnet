#!/usr/bin/env bash
# Shared helpers for ship-it scripts.
# Source from siblings via: source "$(dirname "$0")/_lib.sh"
# Requires: bash, printf, sed, git. gh optional per-script.

# Abort with a message on stderr and non-zero exit.
fail() {
  local msg="${1:-unknown error}"
  local code="${2:-1}"
  printf 'ship-it: %s\n' "$msg" >&2
  exit "$code"
}

# Verify a command exists on PATH. Fail if not.
require_cmd() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    fail "required command not found: $name"
  fi
}

# Normalize a path so it is understood by the current bash flavor.
# - If `cygpath` is available (Git Bash / Cygwin / MSYS2), use it to convert.
# - Otherwise apply a best-effort fallback: `C:\x` or `C:/x` -> `/c/x`.
# - Backslashes are converted to forward slashes.
# Prints the normalized path on stdout. Never fails; returns input unchanged
# if no normalization rule applies.
normalize_path() {
  local p="${1:-}"
  [[ -n "$p" ]] || { printf '%s' ""; return 0; }
  if command -v cygpath >/dev/null 2>&1; then
    # -u forces unix-style; suppress errors and fall through if cygpath rejects input.
    local converted
    if converted="$(cygpath -u -- "$p" 2>/dev/null)"; then
      printf '%s' "$converted"
      return 0
    fi
  fi
  # Fallback: convert backslashes to slashes, then rewrite drive-letter prefix.
  p="${p//\\//}"
  if [[ "$p" =~ ^([A-Za-z]):(/.*)?$ ]]; then
    local drive="${BASH_REMATCH[1],,}"
    local rest="${BASH_REMATCH[2]:-/}"
    p="/${drive}${rest}"
  fi
  printf '%s' "$p"
}

# Verify a directory is a git repository.
# Accepts Windows-style paths (L:\repo, L:/repo) by normalizing first.
require_repo() {
  local raw="${1:-}"
  [[ -n "$raw" ]] || fail "repo path is required"
  local repo
  repo="$(normalize_path "$raw")"
  [[ -d "$repo" ]] || fail "repo path does not exist: $raw (resolved: $repo)"
  git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || fail "not a git repository: $raw (resolved: $repo)"
}

# Escape a string for safe embedding in JSON (between double quotes).
# Handles: backslash, double quote, newline, carriage return, tab, and
# other C0 control characters (emitted as \u00XX).
json_escape() {
  local s="$1"
  local out=""
  local i ch code
  local len=${#s}
  for (( i=0; i<len; i++ )); do
    ch="${s:i:1}"
    case "$ch" in
      '\')  out+='\\' ;;
      '"')  out+='\"' ;;
      $'\n') out+='\n' ;;
      $'\r') out+='\r' ;;
      $'\t') out+='\t' ;;
      *)
        # ASCII < 0x20 → \u00XX, everything else passes through (UTF-8 bytes included).
        printf -v code '%d' "'$ch"
        if (( code < 32 )); then
          printf -v out '%s\\u%04x' "$out" "$code"
        else
          out+="$ch"
        fi
        ;;
    esac
  done
  printf '%s' "$out"
}

# Emit a JSON string literal (with surrounding quotes) from a raw value.
json_string() {
  printf '"%s"' "$(json_escape "$1")"
}

# Emit a JSON array of strings from a bash array passed by name.
# Usage: json_string_array arr_name
json_string_array() {
  local -n _arr="$1"
  local first=1
  printf '['
  local item
  for item in "${_arr[@]}"; do
    if (( first )); then first=0; else printf ','; fi
    json_string "$item"
  done
  printf ']'
}

# Run git scoped to a repo; stdout forwarded, stderr forwarded, exit code preserved.
git_in() {
  local repo="$1"; shift
  git -C "$repo" "$@"
}

# Quiet variant: suppresses stderr; returns exit code.
git_in_quiet() {
  local repo="$1"; shift
  git -C "$repo" "$@" 2>/dev/null
}

# Run gh from inside a repo directory.
gh_in() {
  local repo="$1"; shift
  ( cd "$repo" && gh "$@" )
}

# Parse a simple flat JSON array of strings — e.g. '["a","b","c"]' or '[]'.
# Populates the caller's array variable with the items.
# Limitation: values must not contain embedded double quotes or backslashes.
# Usage: parse_json_string_array '["a","b"]' out_arr
parse_json_string_array() {
  local input="$1"
  local -n _out="$2"
  _out=()
  # Strip whitespace, leading [, trailing ].
  local s="${input#"${input%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  [[ "$s" == "[]" ]] && return 0
  [[ "${s:0:1}" == "[" ]] || fail "expected JSON array, got: $input"
  [[ "${s: -1}" == "]" ]] || fail "expected JSON array, got: $input"
  s="${s:1:${#s}-2}"
  # Split on '","' then strip the leading '"' on first and trailing '"' on last.
  local IFS=$'\x1f'
  # Replace the delimiter '","' with a unit-separator to allow safe splitting.
  local rewritten
  rewritten="$(printf '%s' "$s" | sed 's/","/\x1f/g')"
  local item
  while IFS= read -r item; do
    item="${item#\"}"
    item="${item%\"}"
    [[ -z "$item" ]] && continue
    _out+=("$item")
  done < <(printf '%s\n' "$rewritten" | tr $'\x1f' '\n')
}
