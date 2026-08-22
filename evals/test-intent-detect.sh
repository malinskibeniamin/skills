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
if [ "$(cat "$_dir/task-endpoint" 2>/dev/null)" = "push" ] \
  && printf '%s' "$_out" | jq -e '.hookSpecificOutput.additionalContext | contains("[ENDPOINT:push]")' >/dev/null 2>&1; then
  echo "  PASS  implementation action records and emits push endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  implementation action records and emits push endpoint"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: implementation push endpoint context"
fi

touch "$_dir/task-completed"
_out=$(printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"fix another auth regression","session_id":"intent-eval-'$$'"}' \
  | CLAUDE_SESSION_ID="$_sid" "$INTENT_SCRIPT")
if printf '%s' "$_out" | jq -e '.hookSpecificOutput.additionalContext | contains("[ENDPOINT:push]")' >/dev/null 2>&1; then
  echo "  PASS  a completed task resets endpoint injection for the next task"
  PASS=$((PASS + 1))
else
  echo "  FAIL  completed task suppresses the next matching endpoint"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: endpoint reset between tasks"
fi

_rebase_sid="intent-rebase-eval-$$"
_rebase_dir="/tmp/hook-session-${_rebase_sid}"
rm -rf "$_rebase_dir"
_out=$(printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"rebase this branch onto origin/main","session_id":"intent-rebase-eval-'$$'"}' \
  | CLAUDE_SESSION_ID="$_rebase_sid" "$INTENT_SCRIPT")
if [ "$(cat "$_rebase_dir/task-endpoint" 2>/dev/null)" = "push" ] \
  && printf '%s' "$_out" | jq -e '.hookSpecificOutput.additionalContext | contains("[ENDPOINT:push]")' >/dev/null 2>&1; then
  echo "  PASS  rebase action includes its force-with-lease push endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  rebase action omits its push endpoint"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: rebase push endpoint"
fi

_upgrade_sid="intent-upgrade-eval-$$"
_upgrade_dir="/tmp/hook-session-${_upgrade_sid}"
rm -rf "$_upgrade_dir"
printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"fix locally; do not commit or push","session_id":"intent-upgrade-eval-'$$'"}' \
  | CLAUDE_SESSION_ID="$_upgrade_sid" "$INTENT_SCRIPT" >/dev/null
_out=$(printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"switch endpoint permissions to allow commit and --force-with-lease push","session_id":"intent-upgrade-eval-'$$'"}' \
  | CLAUDE_SESSION_ID="$_upgrade_sid" "$INTENT_SCRIPT")
if [ "$(cat "$_upgrade_dir/task-endpoint" 2>/dev/null)" = "push" ] \
  && printf '%s' "$_out" | jq -e '.hookSpecificOutput.additionalContext | contains("[ENDPOINT:push]")' >/dev/null 2>&1; then
  echo "  PASS  explicit delivery follow-up upgrades a stale local endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  explicit delivery follow-up leaves a stale local endpoint"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: stale local endpoint upgrade"
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

rm -rf "$_dir" "$_rebase_dir" "$_upgrade_dir" "$_pr_dir" "/tmp/hook-session-${_artifact_sid}"
