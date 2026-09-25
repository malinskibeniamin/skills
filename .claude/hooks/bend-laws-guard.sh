#!/bin/bash
set -euo pipefail
_hook_input=$(cat)
# Every rule needs a .bend path, so skip hook-lib init for all other payloads.
case "$_hook_input" in
  *.bend*) ;;
  *) exit 0 ;;
esac
_lib="$(dirname "$0")/_hook-lib.sh"; if [ -f "$_lib" ]; then source "$_lib"; else _m="${TMPDIR:-/tmp}/frontend-skills-broken.${CLAUDE_SESSION_ID:-fs}"; [ -f "$_m" ] || { echo "[frontend-skills] _hook-lib.sh unavailable - run: /plugin install frontend-skills --force" >&2; touch "$_m" 2>/dev/null; }; exit 0; fi
source "$(dirname "$0")/checks/bend-laws-guard.lib.sh"
if [ "$(printf '%s' "$_hook_input" | jq -r '.tool_name // empty' 2>/dev/null || true)" = "Bash" ]; then
  hook_parse_bash
  run_bend_laws_bash_check
else
  export HOOK_ALLOW_MISSING_FILE=1
  hook_parse_edit_write
  run_bend_laws_edit_check
fi
exit $?
