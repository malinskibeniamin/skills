# Intent detection records endpoint and repository facts without workflow coaching.

INTENT_SCRIPT="$REPO_ROOT/shared/intent-detect.sh"

run_file_eval "$INTENT_SCRIPT" "intent-detect.sh exists"
run_executable_eval "$INTENT_SCRIPT" "intent-detect.sh is executable"
run_content_eval "$INTENT_SCRIPT" "task-endpoint" "intent detection records the requested endpoint"
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
  && ! printf '%s' "$_out" | grep -q '\[ENDPOINT:'; then
  echo "  PASS  implementation action records push without developer-context injection"
  PASS=$((PASS + 1))
else
  echo "  FAIL  implementation action injects immutable endpoint context"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: implementation endpoint developer context"
fi

printf 'local\n' > "$_dir/task-endpoint"
touch "$_dir/task-completed"
_out=$(printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"fix another auth regression","session_id":"intent-eval-'$$'"}' \
  | CLAUDE_SESSION_ID="$_sid" "$INTENT_SCRIPT")
if [ "$(cat "$_dir/task-endpoint" 2>/dev/null)" = "push" ] \
  && [ ! -e "$_dir/task-completed" ] \
  && ! printf '%s' "$_out" | grep -q '\[ENDPOINT:'; then
  echo "  PASS  a completed task resets lifecycle state for the next task"
  PASS=$((PASS + 1))
else
  echo "  FAIL  completed task does not reset lifecycle state"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: lifecycle state reset between tasks"
fi

_rebase_sid="intent-rebase-eval-$$"
_rebase_dir="/tmp/hook-session-${_rebase_sid}"
rm -rf "$_rebase_dir"
_out=$(printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"rebase this branch onto origin/main","session_id":"intent-rebase-eval-'$$'"}' \
  | CLAUDE_SESSION_ID="$_rebase_sid" "$INTENT_SCRIPT")
if [ "$(cat "$_rebase_dir/task-endpoint" 2>/dev/null)" = "push" ] \
  && ! printf '%s' "$_out" | grep -q '\[ENDPOINT:'; then
  echo "  PASS  rebase action records its force-with-lease push endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  rebase action omits or injects its push endpoint"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: rebase push endpoint"
fi

_upgrade_sid="intent-upgrade-eval-$$"
_upgrade_dir="/tmp/hook-session-${_upgrade_sid}"
rm -rf "$_upgrade_dir"
printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"fix locally; do not commit or push","session_id":"intent-upgrade-eval-'$$'"}' \
  | CLAUDE_SESSION_ID="$_upgrade_sid" "$INTENT_SCRIPT" >/dev/null
_out=$(printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"I stopped without confirming commit/push. [ENDPOINT:local] blocked delivery. Please unblock yourself and force-with-lease push.","session_id":"intent-upgrade-eval-'$$'"}' \
  | CLAUDE_SESSION_ID="$_upgrade_sid" "$INTENT_SCRIPT")
if [ "$(cat "$_upgrade_dir/task-endpoint" 2>/dev/null)" = "push" ] \
  && ! printf '%s' "$_out" | grep -q '\[ENDPOINT:'; then
  echo "  PASS  explicit delivery follow-up upgrades a stale local endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  explicit delivery follow-up leaves a stale local endpoint"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: stale local endpoint upgrade"
fi

_standing_sid="intent-standing-eval-$$"
_standing_dir="/tmp/hook-session-${_standing_sid}"
rm -rf "$_standing_dir"
_out=$(printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"do not ask me for permission again before you commit, rebase, or push","session_id":"intent-standing-eval-'$$'"}' \
  | CLAUDE_SESSION_ID="$_standing_sid" "$INTENT_SCRIPT")
if [ "$(cat "$_standing_dir/task-endpoint" 2>/dev/null)" = "push" ] \
  && ! printf '%s' "$_out" | grep -q '\[ENDPOINT:'; then
  echo "  PASS  standing git authorization is not parsed as a delivery negation"
  PASS=$((PASS + 1))
else
  echo "  FAIL  standing git authorization is parsed as a delivery negation"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: standing authorization negation parsing"
fi

_override_negative_sid="intent-override-negative-eval-$$"
_override_negative_dir="/tmp/hook-session-${_override_negative_sid}"
rm -rf "$_override_negative_dir"
_out=$(printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"fix this, but please unblock yourself and do not push; keep this local","session_id":"intent-override-negative-eval-'$$'"}' \
  | CLAUDE_SESSION_ID="$_override_negative_sid" "$INTENT_SCRIPT")
if [ "$(cat "$_override_negative_dir/task-endpoint" 2>/dev/null)" = "local" ] \
  && ! printf '%s' "$_out" | jq -e '.hookSpecificOutput.additionalContext | contains("[ENDPOINT:local]")' >/dev/null 2>&1; then
  echo "  PASS  explicit no-push intent stays internal instead of becoming developer context"
  PASS=$((PASS + 1))
else
  echo "  FAIL  explicit no-push intent becomes developer context"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: local endpoint context injection"
fi

_override_review_sid="intent-override-review-eval-$$"
_override_review_dir="/tmp/hook-session-${_override_review_sid}"
rm -rf "$_override_review_dir"
_out=$(printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"review this transcript: please unblock yourself and force-with-lease push","session_id":"intent-override-review-eval-'$$'"}' \
  | CLAUDE_SESSION_ID="$_override_review_sid" "$INTENT_SCRIPT")
if [ ! -s "$_override_review_dir/task-endpoint" ] \
  && ! printf '%s' "$_out" | jq -e '.hookSpecificOutput.additionalContext | contains("[ENDPOINT:push]")' >/dev/null 2>&1; then
  echo "  PASS  artifact review does not execute quoted unblock wording"
  PASS=$((PASS + 1))
else
  echo "  FAIL  artifact review executes quoted unblock wording"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: quoted unblock artifact execution"
fi

_pr_sid="intent-pr-eval-$$"
_pr_dir="/tmp/hook-session-${_pr_sid}"
rm -rf "$_pr_dir"
_out=$(printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"create a draft PR","session_id":"intent-pr-eval-'$$'"}' \
  | CLAUDE_SESSION_ID="$_pr_sid" "$INTENT_SCRIPT")
if [ "$(cat "$_pr_dir/task-endpoint" 2>/dev/null)" = "pr" ] \
  && ! printf '%s' "$_out" | grep -q '\[ENDPOINT:'; then
  echo "  PASS  PR action records its endpoint without developer-context injection"
  PASS=$((PASS + 1))
else
  echo "  FAIL  PR action omits or injects its endpoint"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: PR endpoint lifecycle state"
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

rm -rf "$_dir" "$_rebase_dir" "$_upgrade_dir" "$_standing_dir" "$_override_negative_dir" "$_override_review_dir" "$_pr_dir" "/tmp/hook-session-${_artifact_sid}"
