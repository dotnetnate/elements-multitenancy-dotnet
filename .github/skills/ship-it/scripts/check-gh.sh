#!/usr/bin/env bash
# check-gh.sh
# Emits {"available":bool,"version":"..."}. Never exits non-zero.
set -uo pipefail
source "$(dirname "$0")/_lib.sh"

if ! command -v gh >/dev/null 2>&1; then
  printf '{"available":false,"version":""}\n'
  exit 0
fi

# `gh --version` first line: "gh version 2.52.0 (2024-07-24)"
version="$(gh --version 2>/dev/null | head -n 1 || true)"
printf '{"available":true,"version":%s}\n' "$(json_string "$version")"
