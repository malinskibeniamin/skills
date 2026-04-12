# Evals for hook scripts (SubagentStart, SubagentStop)

HOOKS_DIR="$REPO_ROOT/.claude/hooks"
SHARED_DIR="$REPO_ROOT/shared"

# ── Hook scripts exist and are executable ────────────────────────
run_file_eval "$SHARED_DIR/subagent-start.sh" "subagent-start.sh exists"
run_executable_eval "$SHARED_DIR/subagent-start.sh" "subagent-start.sh is executable"
run_file_eval "$SHARED_DIR/subagent-stop.sh" "subagent-stop.sh exists"
run_executable_eval "$SHARED_DIR/subagent-stop.sh" "subagent-stop.sh is executable"

# ── Symlinks exist in .claude/hooks ──────────────────────────────
if [ -L "$HOOKS_DIR/subagent-start.sh" ]; then
  echo "  PASS  .claude/hooks/subagent-start.sh is a symlink"
  PASS=$((PASS + 1))
else
  echo "  FAIL  .claude/hooks/subagent-start.sh is not a symlink"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: .claude/hooks/subagent-start.sh is not a symlink"
fi

if [ -L "$HOOKS_DIR/subagent-stop.sh" ]; then
  echo "  PASS  .claude/hooks/subagent-stop.sh is a symlink"
  PASS=$((PASS + 1))
else
  echo "  FAIL  .claude/hooks/subagent-stop.sh is not a symlink"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: .claude/hooks/subagent-stop.sh is not a symlink"
fi

# ── settings.json has SubagentStart and SubagentStop entries ─────
run_content_eval "$REPO_ROOT/.claude/settings.json" "SubagentStart" "settings.json has SubagentStart hook"
run_content_eval "$REPO_ROOT/.claude/settings.json" "SubagentStop" "settings.json has SubagentStop hook"

# ── SubagentStop: non-reviewer agent passes through (exit 0) ────
run_hook_eval "$SHARED_DIR/subagent-stop.sh" \
  '{"agent_type":"verifier","session_id":"test-eval","last_assistant_message":"all good"}' \
  0 \
  "subagent-stop passes through non-reviewer agents"

# ── SubagentStop: valid findings JSON accepted (exit 0) ──────────
VALID_FINDINGS='{"agent_type":"code-reviewer","session_id":"test-eval","last_assistant_message":"```json\n{\"reviewer\":\"code-reviewer\",\"status\":\"APPROVED\",\"findings\":[],\"testing_gaps\":[],\"simplification_opportunities\":[]}\n```"}'
run_hook_eval "$SHARED_DIR/subagent-stop.sh" \
  "$VALID_FINDINGS" \
  0 \
  "subagent-stop accepts valid findings JSON"

# ── SubagentStop: missing JSON block rejected (exit 2) ───────────
run_hook_eval "$SHARED_DIR/subagent-stop.sh" \
  '{"agent_type":"self-reviewer","session_id":"test-eval","last_assistant_message":"Looks good, no issues found."}' \
  2 \
  "subagent-stop rejects reviewer output without JSON block"

# ── SubagentStop: invalid status enum rejected (exit 2) ──────────
INVALID_STATUS='{"agent_type":"code-reviewer","session_id":"test-eval","last_assistant_message":"```json\n{\"reviewer\":\"code-reviewer\",\"status\":\"LGTM\",\"findings\":[]}\n```"}'
run_hook_eval "$SHARED_DIR/subagent-stop.sh" \
  "$INVALID_STATUS" \
  2 \
  "subagent-stop rejects invalid status enum"

# ── SubagentStop: missing required finding fields rejected (exit 2)
MISSING_FIELDS='{"agent_type":"code-reviewer","session_id":"test-eval","last_assistant_message":"```json\n{\"reviewer\":\"code-reviewer\",\"status\":\"NEEDS_CHANGES\",\"findings\":[{\"title\":\"bug\"}]}\n```"}'
run_hook_eval "$SHARED_DIR/subagent-stop.sh" \
  "$MISSING_FIELDS" \
  2 \
  "subagent-stop rejects findings with missing required fields"

# ── SubagentStart: emits context on stderr (exit 0) ─────────────
run_hook_eval "$SHARED_DIR/subagent-start.sh" \
  '{"agent_type":"self-reviewer","session_id":"test-eval"}' \
  0 \
  "subagent-start exits 0 for reviewer agent"

# ── SubagentStart: emits context with branch info ────────────────
run_hook_eval "$SHARED_DIR/subagent-start.sh" \
  '{"agent_type":"code-reviewer","session_id":"test-eval"}' \
  0 \
  "subagent-start exits 0 for code-reviewer" \
  "Branch Context"
