# Evals for endpoint-aware execution and deterministic turn completion.

HOOKS_DIR="$REPO_ROOT/.claude/hooks"
INTENT="$HOOKS_DIR/intent-detect.sh"
COMPLETION="$HOOKS_DIR/completion-contract-stop.sh"
MANIFEST="$REPO_ROOT/skill-manifest.json"

run_file_eval "$COMPLETION" "completion-contract-stop.sh exists"
run_executable_eval "$COMPLETION" "completion-contract-stop.sh is executable"
run_content_eval "$REPO_ROOT/CLAUDE.md" "## Execution contract" "CLAUDE.md defines the execution contract"
run_content_eval "$REPO_ROOT/CLAUDE.md" "[Bb]uild, fix, implement" "ordinary implementation continues without approval"
run_content_eval "$REPO_ROOT/CLAUDE.md" "🟢 done —" "CLAUDE.md defines visible done status"
run_content_eval "$REPO_ROOT/CLAUDE.md" "human.*browser|human-owned.*browser" "CLAUDE.md protects human browser sessions"
if grep -q '\[BROWSER\]' "$INTENT"; then
  echo "  FAIL  intent hook coaches browser workflow"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: intent browser coaching"
else
  echo "  PASS  browser safety stays ambient instead of prompt-injected"
  PASS=$((PASS + 1))
fi
if grep -q "@claude review" "$INTENT"; then
  echo "  FAIL  PR intent still injects an unsolicited reviewer request"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: PR intent injects @claude review"
else
  echo "  PASS  PR intent contains no automatic @claude review"
  PASS=$((PASS + 1))
fi
run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "single owner" "lifecycle uses a single owner"
run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "continue immediately" "lifecycle does not pause ordinary implementation"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "inline" "grilling runs plan hats inline"
run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" "one CI status snapshot" "PR endpoint takes one CI snapshot"
run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" 'Do not run `/visual-recap` or `/make-pr-easy-to-review` unless the user explicitly requests' "PR endpoint avoids unsolicited review artifacts"
run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" "do not block merely" "PR endpoint does not invent a review approval stop"
run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" 'Commit-only skips remote and `gh` preflight' "commit endpoint has no push prerequisites"
run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" "Explicit commit-only intent stops here" "commit endpoint does not push"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "commit\\|push\\|pr\\|ship" "lifecycle enforces only external endpoints"
run_content_eval "$HOOKS_DIR/lifecycle-stop.sh" "Requested PR endpoint is complete" "PR endpoint does not start an unrequested CI fix loop"
run_content_eval "$HOOKS_DIR/session-env.sh" 'CAPTURE_TYPECHECK_BASELINE:-0' "session start launches no default background typecheck"
run_content_eval "$HOOKS_DIR/enforce-toolchain.sh" "join or stop it before final status" "sleep guidance requires background cleanup"

_cc_session="completion-contract-eval-$$"
_cc_dir="/tmp/hook-session-${_cc_session}"
rm -rf "$_cc_dir"
mkdir -p "$_cc_dir"

_intent_out=$(
  printf '%s' '{"hook_event_name":"UserPromptSubmit","session_id":"completion-contract-eval-'$$'","prompt":"implement the dark mode toggle"}' \
    | CLAUDE_SESSION_ID="$_cc_session" "$INTENT"
)
if [ "$(cat "$_cc_dir/task-endpoint" 2>/dev/null)" = "local" ]; then
  echo "  PASS  implementation prompt records local endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  implementation prompt records local endpoint"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: implementation endpoint missing"
fi

_plan_session="completion-contract-plan-eval-$$"
_plan_dir="/tmp/hook-session-${_plan_session}"
rm -rf "$_plan_dir"
printf '%s' '{"hook_event_name":"UserPromptSubmit","session_id":"completion-contract-plan-eval-'$$'","prompt":"plan the implementation of dark mode"}' \
  | CLAUDE_SESSION_ID="$_plan_session" "$INTENT" >/dev/null
if [ ! -e "$_plan_dir/task-endpoint" ]; then
  echo "  PASS  plan-only prompt remains an artifact endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  plan-only prompt remains an artifact endpoint"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: plan-only prompt became an action"
fi

_plan_action_session="completion-contract-plan-action-eval-$$"
_plan_action_dir="/tmp/hook-session-${_plan_action_session}"
rm -rf "$_plan_action_dir"
printf '%s' '{"hook_event_name":"UserPromptSubmit","session_id":"completion-contract-plan-action-eval-'$$'","prompt":"plan how to implement dark mode"}' \
  | CLAUDE_SESSION_ID="$_plan_action_session" "$INTENT" >/dev/null
if [ ! -e "$_plan_action_dir/task-endpoint" ]; then
  echo "  PASS  plan containing an action verb remains an artifact endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  plan containing an action verb remains an artifact endpoint"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: plan containing action verb became local work"
fi

_review_fix_session="completion-contract-review-fix-eval-$$"
_review_fix_dir="/tmp/hook-session-${_review_fix_session}"
rm -rf "$_review_fix_dir"
printf '%s' '{"hook_event_name":"UserPromptSubmit","session_id":"completion-contract-review-fix-eval-'$$'","prompt":"review this fix and report findings"}' \
  | CLAUDE_SESSION_ID="$_review_fix_session" "$INTENT" >/dev/null
if [ ! -e "$_review_fix_dir/task-endpoint" ]; then
  echo "  PASS  review containing an action noun remains an artifact endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  review containing an action noun remains an artifact endpoint"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: review containing action noun became local work"
fi

_plow_session="completion-contract-plow-eval-$$"
_plow_dir="/tmp/hook-session-${_plow_session}"
rm -rf "$_plow_dir"
printf '%s' '{"hook_event_name":"UserPromptSubmit","session_id":"completion-contract-plow-eval-'$$'","prompt":"do not stop; keep going until done"}' \
  | CLAUDE_SESSION_ID="$_plow_session" "$INTENT" >/dev/null
if [ "$(cat "$_plow_dir/task-endpoint" 2>/dev/null)" = "ship" ]; then
  echo "  PASS  plow-ahead wording records ship endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  plow-ahead wording records ship endpoint"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: plow-ahead endpoint missing"
fi

_negative_session="completion-contract-negative-eval-$$"
_negative_dir="/tmp/hook-session-${_negative_session}"
rm -rf "$_negative_dir"
printf '%s' '{"hook_event_name":"UserPromptSubmit","session_id":"completion-contract-negative-eval-'$$'","prompt":"fix the toggle locally; do not commit, push, or create a PR"}' \
  | CLAUDE_SESSION_ID="$_negative_session" "$INTENT" >/dev/null
if [ "$(cat "$_negative_dir/task-endpoint" 2>/dev/null)" = "local" ]; then
  echo "  PASS  negated delivery verbs preserve local endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  negated delivery verbs preserve local endpoint"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: negated delivery verb escalated endpoint"
fi

_negative_plan_session="completion-contract-negative-plan-eval-$$"
_negative_plan_dir="/tmp/hook-session-${_negative_plan_session}"
rm -rf "$_negative_plan_dir"
printf '%s' '{"hook_event_name":"UserPromptSubmit","session_id":"completion-contract-negative-plan-eval-'$$'","prompt":"explain the approach; do not implement or change files"}' \
  | CLAUDE_SESSION_ID="$_negative_plan_session" "$INTENT" >/dev/null
if [ ! -e "$_negative_plan_dir/task-endpoint" ]; then
  echo "  PASS  negated action verbs preserve artifact endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  negated action verbs preserve artifact endpoint"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: negated action became local work"
fi

_conflict_session="completion-contract-conflict-eval-$$"
_conflict_dir="/tmp/hook-session-${_conflict_session}"
rm -rf "$_conflict_dir"
printf '%s' '{"hook_event_name":"UserPromptSubmit","session_id":"completion-contract-conflict-eval-'$$'","prompt":"make a PR but do not push anything"}' \
  | CLAUDE_SESSION_ID="$_conflict_session" "$INTENT" >/dev/null
if [ ! -e "$_conflict_dir/task-endpoint" ]; then
  echo "  PASS  contradictory delivery request does not authorize push"
  PASS=$((PASS + 1))
else
  echo "  FAIL  contradictory delivery request does not authorize push"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: contradictory request authorized delivery"
fi

_history_session="completion-contract-history-eval-$$"
_history_dir="/tmp/hook-session-${_history_session}"
rm -rf "$_history_dir"
printf '%s' '{"hook_event_name":"UserPromptSubmit","session_id":"completion-contract-history-eval-'$$'","prompt":"show me the last commit and explain whether it was pushed"}' \
  | CLAUDE_SESSION_ID="$_history_session" "$INTENT" >/dev/null
if [ ! -e "$_history_dir/task-endpoint" ]; then
  echo "  PASS  commit history question remains an artifact endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  commit history question remains an artifact endpoint"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: commit history question became an action"
fi

_review_session="completion-contract-review-eval-$$"
_review_dir="/tmp/hook-session-${_review_session}"
rm -rf "$_review_dir"
_review_out=$(
  printf '%s' '{"hook_event_name":"UserPromptSubmit","session_id":"completion-contract-review-eval-'$$'","prompt":"review pull request #123 and report findings"}' \
    | CLAUDE_SESSION_ID="$_review_session" "$INTENT"
)
if [ ! -e "$_review_dir/task-endpoint" ] \
  && printf '%s' "$_review_out" | grep -q "gh pr diff 123" \
  && ! printf '%s' "$_review_out" | grep -q "gh pr checkout 123"; then
  echo "  PASS  pull request review remains an artifact endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  pull request review remains an artifact endpoint"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: PR review became PR creation"
fi

_stop_exit=0
printf '%s' '{"session_id":"completion-contract-eval-'$$'","last_assistant_message":"I inspected the component."}' \
  | CLAUDE_SESSION_ID="$_cc_session" "$COMPLETION" >/tmp/completion-contract-out 2>/tmp/completion-contract-err \
  || _stop_exit=$?
if [ "$_stop_exit" -eq 2 ] && grep -qi "silent" /tmp/completion-contract-out /tmp/completion-contract-err; then
  echo "  PASS  action turn rejects a silent stop"
  PASS=$((PASS + 1))
else
  echo "  FAIL  action turn rejects a silent stop"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: silent stop was allowed"
fi

_fresh_stop_session="completion-contract-fresh-stop-eval-$$"
_fresh_stop_dir="/tmp/hook-session-${_fresh_stop_session}"
mkdir -p "$_fresh_stop_dir"
printf 'local\n' > "$_fresh_stop_dir/task-endpoint"
_fresh_stop_exit=0
printf '%s' '{"session_id":"completion-contract-fresh-stop-eval-'$$'","last_assistant_message":"Implemented it."}' \
  | HOOK_STOP_BLOCK_CAP_GUARD=1 CLAUDE_SESSION_ID="$_fresh_stop_session" "$COMPLETION" \
    >/tmp/completion-contract-out 2>/tmp/completion-contract-err \
  || _fresh_stop_exit=$?
if [ "$_fresh_stop_exit" -eq 2 ] && grep -qi "silent" /tmp/completion-contract-out /tmp/completion-contract-err; then
  echo "  PASS  fresh session emits a deterministic silent-stop block"
  PASS=$((PASS + 1))
else
  echo "  FAIL  fresh session emits a deterministic silent-stop block"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: fresh session silent-stop block exited $_fresh_stop_exit without guidance"
fi

run_hook_eval "$COMPLETION" \
  '{"session_id":"completion-contract-eval-'$$'","last_assistant_message":"Summary.\n\n🟢 done — focused tests pass"}' \
  0 \
  "action turn accepts done status with evidence"

_empty_status_exit=0
printf '%s' '{"session_id":"completion-contract-eval-'$$'","last_assistant_message":"🟢 done —  "}' \
  | CLAUDE_SESSION_ID="$_cc_session" "$COMPLETION" >/tmp/completion-contract-out 2>/tmp/completion-contract-err \
  || _empty_status_exit=$?
if [ "$_empty_status_exit" -eq 2 ]; then
  echo "  PASS  done status requires non-whitespace evidence"
  PASS=$((PASS + 1))
else
  echo "  FAIL  done status requires non-whitespace evidence"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: empty completion evidence accepted"
fi

_pr_out=$(
  printf '%s' '{"hook_event_name":"UserPromptSubmit","session_id":"completion-contract-eval-'$$'","prompt":"make a PR for this"}' \
    | CLAUDE_SESSION_ID="$_cc_session" "$INTENT"
)
if [ "$(cat "$_cc_dir/task-endpoint" 2>/dev/null)" = "pr" ] \
  && printf '%s' "$_pr_out" | grep -q "ENDPOINT:pr" \
  && grep -qi "PR: verify, commit, push" "$REPO_ROOT/CLAUDE.md"; then
  echo "  PASS  make a PR authorizes commit and push prerequisites"
  PASS=$((PASS + 1))
else
  echo "  FAIL  make a PR authorizes commit and push prerequisites"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: PR endpoint is not composite"
fi

mkdir -p "$_cc_dir/active-subagents"
printf 'Explore\n' > "$_cc_dir/active-subagents/agent-eval"
_active_exit=0
printf '%s' '{"session_id":"completion-contract-eval-'$$'","last_assistant_message":"🟢 done — tests pass"}' \
  | CLAUDE_SESSION_ID="$_cc_session" "$COMPLETION" >/tmp/completion-contract-out 2>/tmp/completion-contract-err \
  || _active_exit=$?
if [ "$_active_exit" -eq 2 ] && grep -qi "active.*subagent" /tmp/completion-contract-out /tmp/completion-contract-err; then
  echo "  PASS  active subagent prevents final completion"
  PASS=$((PASS + 1))
else
  echo "  FAIL  active subagent prevents final completion"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: active subagent survived final completion"
fi

_agent_session="completion-contract-agent-eval-$$"
_agent_dir="/tmp/hook-session-${_agent_session}"
mkdir -p "$_agent_dir/active-subagents"
printf 'Explore\n' > "$_agent_dir/active-subagents/agent-eval"
_agent_exit=0
printf '%s' '{"session_id":"completion-contract-agent-eval-'$$'","last_assistant_message":"Here is the requested plan."}' \
  | CLAUDE_SESSION_ID="$_agent_session" "$COMPLETION" >/tmp/completion-contract-out 2>/tmp/completion-contract-err \
  || _agent_exit=$?
if [ "$_agent_exit" -eq 2 ] && grep -qi "active.*subagent" /tmp/completion-contract-out /tmp/completion-contract-err; then
  echo "  PASS  active subagent blocks artifact-only completion"
  PASS=$((PASS + 1))
else
  echo "  FAIL  active subagent blocks artifact-only completion"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: artifact turn left active subagent"
fi

if jq -e '.. | objects | select(.asyncRewake == true)' "$MANIFEST" >/dev/null 2>&1; then
  echo "  FAIL  manifest still contains delayed asyncRewake behavior"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: asyncRewake remains configured"
else
  echo "  PASS  manifest contains no delayed asyncRewake behavior"
  PASS=$((PASS + 1))
fi

rm -rf "$_cc_dir" "$_plan_dir" "$_plan_action_dir" "$_review_fix_dir" "$_plow_dir" "$_negative_dir" "$_negative_plan_dir" "$_conflict_dir" "$_history_dir" "$_review_dir" "$_agent_dir" "$_fresh_stop_dir" /tmp/completion-contract-out /tmp/completion-contract-err
