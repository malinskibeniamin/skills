# Intent detection records endpoint and repository facts without workflow coaching.

INTENT_SCRIPT="$REPO_ROOT/shared/intent-detect.sh"

run_file_eval "$INTENT_SCRIPT" "intent-detect.sh exists"
run_executable_eval "$INTENT_SCRIPT" "intent-detect.sh is executable"
run_content_eval "$INTENT_SCRIPT" "ENDPOINT:" "intent detection exposes the requested endpoint"
run_content_eval "$INTENT_SCRIPT" "PR-CONTEXT" "intent detection exposes an explicit PR identity"
run_content_eval "$INTENT_SCRIPT" "SCOPE-LOCK" "intent detection exposes current feature-branch state"

if grep -qE 'RISK:|\[BROWSER\]|\[CI-FIX\]|\[LIFECYCLE\]|\[TDD\]|quality:gate' "$INTENT_SCRIPT"; then
  echo "  FAIL  intent detection contains prompt coaching"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: intent prompt coaching"
else
  echo "  PASS  intent detection omits risk and workflow coaching"
  PASS=$((PASS + 1))
fi

_sid="intent-eval-$$"
_dir="/tmp/hook-session-${_sid}"
rm -rf "$_dir"
_out=$(printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"fix the auth regression","session_id":"intent-eval-'$$'"}' \
  | CLAUDE_SESSION_ID="$_sid" "$INTENT_SCRIPT")
if [ "$(cat "$_dir/task-endpoint" 2>/dev/null)" = "local" ] \
  && printf '%s' "$_out" | jq -e '.hookSpecificOutput.additionalContext | contains("[ENDPOINT:local]")' >/dev/null 2>&1; then
  echo "  PASS  local action records and emits only its endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  local action records and emits its endpoint"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: local endpoint context"
fi

touch "$_dir/task-completed"
_out=$(printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"fix another auth regression","session_id":"intent-eval-'$$'"}' \
  | CLAUDE_SESSION_ID="$_sid" "$INTENT_SCRIPT")
if printf '%s' "$_out" | jq -e '.hookSpecificOutput.additionalContext | contains("[ENDPOINT:local]")' >/dev/null 2>&1; then
  echo "  PASS  a completed task resets endpoint injection for the next task"
  PASS=$((PASS + 1))
else
  echo "  FAIL  completed task suppresses the next matching endpoint"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: endpoint reset between tasks"
fi

_pr_sid="intent-pr-eval-$$"
_pr_dir="/tmp/hook-session-${_pr_sid}"
rm -rf "$_pr_dir"
_out=$(printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"create a draft PR","session_id":"intent-pr-eval-'$$'"}' \
  | CLAUDE_SESSION_ID="$_pr_sid" "$INTENT_SCRIPT")
if [ "$(cat "$_pr_dir/task-endpoint" 2>/dev/null)" = "pr" ] \
  && printf '%s' "$_out" | jq -e '.hookSpecificOutput.additionalContext | contains("[ENDPOINT:pr]")' >/dev/null 2>&1; then
  echo "  PASS  PR action records and emits only its endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  PR action records and emits its endpoint"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: PR endpoint context"
fi

_artifact_sid="intent-artifact-eval-$$"
rm -rf "/tmp/hook-session-${_artifact_sid}"
printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"review this fix and report findings","session_id":"intent-artifact-eval-'$$'"}' \
  | CLAUDE_SESSION_ID="$_artifact_sid" "$INTENT_SCRIPT" >/dev/null
if [ ! -e "/tmp/hook-session-${_artifact_sid}/task-endpoint" ]; then
  echo "  PASS  review artifact does not become action work"
  PASS=$((PASS + 1))
else
  echo "  FAIL  review artifact became action work"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: review artifact endpoint"
fi

run_hook_eval "$INTENT_SCRIPT" \
  '{"hook_event_name":"PostToolUse","prompt":"fix the bug"}' 0 \
  "non-UserPromptSubmit event exits cleanly"

rm -rf "$_dir" "$_pr_dir" "/tmp/hook-session-${_artifact_sid}"
