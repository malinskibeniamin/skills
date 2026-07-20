#!/bin/bash
set -eo pipefail
_lib="$(dirname "$0")/_hook-lib.sh"; if [ -f "$_lib" ]; then source "$_lib"; else _m="${TMPDIR:-/tmp}/frontend-skills-broken.${CLAUDE_SESSION_ID:-fs}"; [ -f "$_m" ] || { echo "[frontend-skills] _hook-lib.sh unavailable - run: /plugin install frontend-skills --force" >&2; touch "$_m" 2>/dev/null; }; exit 0; fi

# TaskCompleted: block marking a task complete while the session's shared
# test status (written by typecheck-stop.sh after the last verify run) says
# FAIL. Same signal quality-gate-stop enforces at Stop, but caught at the
# moment of the false "done" claim — cheaper than a full Stop-block round
# trip. Conservative on purpose: no test status recorded → allow.

input=$(cat 2>/dev/null || echo '{}')

status=$(hook_stop_get_test_status)
[ "$status" = "FAIL" ] || exit 0

subject=$(echo "$input" | jq -r '.task.subject // .subject // empty' 2>/dev/null | head -c 120)
reason="Blocked completing task${subject:+ \"$subject\"}: last recorded test run FAILED (session shared-test-status). Re-run the tests green before marking work complete."
_hook_log_entry "block" "task-completed-red-tests" task-completed-gate
escaped=$(_safe_json_escape "$reason")
echo "{\"decision\":\"block\",\"reason\":$escaped}" >&2
exit 2
