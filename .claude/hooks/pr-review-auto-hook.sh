#!/bin/bash
set -euo pipefail

# Disabled by default; avoid loading Bun on ordinary hook calls.
home="${PR_REVIEW_AUTO_HOME:-${XDG_STATE_HOME:-$HOME/.local/state}/frontend-skills/pr-review-auto}"
[ -f "$home/state.json" ] || exit 0
[ "${PR_REVIEW_AUTO_RUN:-0}" != "1" ] || exit 0
root=$(cd "$(dirname "$0")/../.." && pwd)
if ! command -v bun >/dev/null 2>&1; then
  echo "PR auto-review: bun is missing; activity tracking unavailable" >&2
  exit 0
fi
# Errors are visible without blocking an unrelated interactive turn.
bun "$root/scripts/pr-review-auto.ts" hook --agent "${1:-claude}" >&2 || true
