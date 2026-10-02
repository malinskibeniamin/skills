#!/bin/bash
set -euo pipefail

[ "$#" -gt 0 ] || {
  echo "usage: codeowners-teams.sh <repository-path>" >&2
  exit 2
}

plugin_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
owners=$(python3 "$plugin_root/scripts/codeowners-reviewers.py" --teams-only "$@")
if [ -n "$owners" ]; then
  printf '%s\n' "$owners" | sed 's/^/@/'
fi
