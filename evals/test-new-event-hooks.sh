# Evals for the 2026 w13–w29 event adoption: Setup, UserPromptExpansion,
# CwdChanged, ConfigChange, TaskCompleted, StopFailure, PermissionDenied,
# Notification — plus the codex-notify adapter and execpolicy mirror.

HOOKS_DIR="$REPO_ROOT/.claude/hooks"
export HOOK_METRICS_DISABLED=0
export HOOK_METRICS_DIR
HOOK_METRICS_DIR=$(mktemp -d)

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

# PermissionDenied retry: plainly read-only single command → retry under
# hookSpecificOutput with the event name (top-level retry is ignored).
_out=$(echo '{"tool_input":{"command":"git status"}}' | "$HOOKS_DIR/permission-denied-retry.sh" 2>/dev/null)
if printf '%s' "$_out" | jq -e '.hookSpecificOutput.hookEventName == "PermissionDenied" and .hookSpecificOutput.retry == true' >/dev/null 2>&1; then
  echo "  PASS  permission-denied-retry emits structural retry schema"
  PASS=$((PASS + 1))
else
  echo "  FAIL  permission-denied-retry schema wrong: $_out"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: permission-denied retry schema"
fi
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
if tail -5 "$HOOK_METRICS_DIR/skill-fires.jsonl" 2>/dev/null | grep -q '"skill":"eval-fixture-skill","session":"eval-new-events-'"$$"'","source":"expansion"'; then
  echo "  PASS  skill-fire-log records expansion source"
  PASS=$((PASS + 1))
else
  echo "  FAIL  skill-fire-log expansion entry missing from metrics"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: skill-fire expansion telemetry"
fi

# CwdChanged rebinds the session worktree AND re-registers watches from the
# new root (SessionStart watchPaths were absolute under the old PWD)
_cwd_fixture=$(mktemp -d)
(cd "$_cwd_fixture" && git init -q . 2>/dev/null)
touch "$_cwd_fixture/api.proto"
_out=$(echo "{\"new_cwd\":\"$_cwd_fixture\"}" | "$HOOKS_DIR/cwd-changed.sh" 2>/dev/null); _rc=$?
if [ "$_rc" = "0" ]; then
  echo "  PASS  cwd-changed exits clean"
  PASS=$((PASS + 1))
else
  echo "  FAIL  cwd-changed exit=$_rc"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: cwd-changed exit"
fi
if grep -q "$(basename "$_cwd_fixture")" "$_eval_session_dir/bound-worktree" 2>/dev/null; then
  echo "  PASS  cwd-changed rebinds bound-worktree"
  PASS=$((PASS + 1))
else
  echo "  FAIL  cwd-changed did not rebind bound-worktree"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: cwd-changed rebind"
fi
if printf '%s' "$_out" | jq -e '.hookSpecificOutput.hookEventName == "CwdChanged" and (.hookSpecificOutput.watchPaths | map(endswith("api.proto")) | any)' >/dev/null 2>&1; then
  echo "  PASS  cwd-changed re-registers watchPaths from new root"
  PASS=$((PASS + 1))
else
  echo "  FAIL  cwd-changed watchPaths missing new-root schema file: $_out"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: cwd-changed watchPaths"
fi
rm -rf "$_cwd_fixture"

# StopFailure telemetry reads the runtime .error field
for _cat in rate_limit max_output_tokens; do
  run_hook_eval "$HOOKS_DIR/stop-failure-telemetry.sh" \
    "{\"hook_event_name\":\"StopFailure\",\"error\":\"$_cat\"}" 0 \
    "stop-failure-telemetry exits 0 on $_cat"
  if tail -3 "$HOOK_METRICS_DIR/stop-failures.jsonl" 2>/dev/null | grep -q "\"category\":\"$_cat\""; then
    echo "  PASS  stop-failure-telemetry records $_cat from .error"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  stop-failure-telemetry did not record $_cat"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: stop-failure $_cat"
  fi
done

# Setup event dispatches on the runtime .trigger field
_setup_stale="/tmp/hook-session-eval-setup-stale-$$"
_setup_active="/tmp/hook-session-eval-setup-active-$$"
mkdir -p "$_setup_stale"
mkdir -p "$_setup_active"
echo "recent" > "$_setup_active/violations"
touch -t 202601010000 "$_setup_stale"
touch -t 202601010000 "$_setup_active"
run_hook_eval "$HOOKS_DIR/setup-init.sh" '{"trigger":"maintenance"}' 0 \
  "setup-init maintenance exits 0"
if [ ! -d "$_setup_stale" ]; then
  echo "  PASS  setup-init maintenance sweeps stale session dirs (trigger parsed)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  setup-init maintenance left stale session dir (trigger not parsed?)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: setup-init trigger dispatch"
  rm -rf "$_setup_stale"
fi
if [ -d "$_setup_active" ]; then
  echo "  PASS  setup-init maintenance keeps sessions with recent state"
  PASS=$((PASS + 1))
else
  echo "  FAIL  setup-init maintenance deleted a session with recent state"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: setup-init recent session state"
fi
rm -rf "$_setup_active"
# init in a fixture with package.json + fake bun on PATH → install invoked
_setup_fix=$(mktemp -d)
_setup_bin=$(mktemp -d)
printf '#!/bin/bash\ntouch "%s/bun-ran"\nexit 0\n' "$_setup_fix" > "$_setup_bin/bun"
chmod +x "$_setup_bin/bun"
echo '{}' > "$_setup_fix/package.json"
(cd "$_setup_fix" && echo '{"trigger":"init"}' | PATH="$_setup_bin:$PATH" "$HOOKS_DIR/setup-init.sh" >/dev/null 2>&1)
if [ -f "$_setup_fix/bun-ran" ]; then
  echo "  PASS  setup-init init installs dependencies (trigger parsed)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  setup-init init never invoked bun install"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: setup-init init"
fi
rm -rf "$_setup_fix" "$_setup_bin"

# codex-notify adapter (argument-style invocation, not stdin)
rm -f "$HOOK_METRICS_DIR/"*-codex-*.json
"$HOOKS_DIR/codex-notify.sh" '{"type":"agent-turn-complete","thread-id":"t-eval","cwd":"/tmp"}' </dev/null
_codex_summary=$(ls "$HOOK_METRICS_DIR/"*-codex-*.json 2>/dev/null | tail -1)
jq 'del(.shadow_blocks, .shadow_warns, .shadow_nudges) | .schema_version = 3' \
  "$_codex_summary" > "$_codex_summary.tmp" && mv "$_codex_summary.tmp" "$_codex_summary"
_long_last=$(printf 'verified %.0s' {1..40})
"$HOOKS_DIR/codex-notify.sh" \
  "$(jq -nc --arg last "${_long_last}
🟢 done — verified" \
    '{type:"agent-turn-complete","thread-id":"t-eval",cwd:"/tmp","last-assistant-message":$last}')" \
  </dev/null
if tail -5 "$HOOK_METRICS_DIR/codex-turns.jsonl" 2>/dev/null | grep -q '"thread":"t-eval"'; then
  echo "  PASS  codex-notify logs agent-turn-complete"
  PASS=$((PASS + 1))
else
  echo "  FAIL  codex-notify entry missing"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: codex-notify telemetry"
fi
# The consumer contract: a schema-v4 summary /hook-audit's *.json pass reads
_codex_summary=$(ls "$HOOK_METRICS_DIR/"*-codex-*.json 2>/dev/null | tail -1)
if [ -n "$_codex_summary" ] \
  && jq -e '.schema_version == 4 and .source == "codex" and .turns == 2
    and .outcome == "completed" and .harness_version and .run_kind and .model
    and (.shadow_blocks | type == "object") and (.shadow_warns | type == "object")
    and (.shadow_nudges | type == "object")' "$_codex_summary" >/dev/null 2>&1 \
  && grep -q "codex-turns.jsonl" "$REPO_ROOT/hook-audit/"{SKILL,REFERENCE}.md; then
  echo "  PASS  codex turns appear in hook-audit's session-summary feed"
  PASS=$((PASS + 1))
else
  echo "  FAIL  codex session summary missing/wrong or hook-audit doesn't reference the feed"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: codex-notify consumer"
fi
rm -f "$HOOK_METRICS_DIR/"*-codex-*.json

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

# ── Snyk write shapes route through the dispatcher on Claude ─────
# An if-gated standalone entry missed bunx/npx/env-prefixed and curl API
# shapes (PR 72 review) — every guarded shape must reach the guard via
# pre-bash.sh routing.
# Earlier fixtures leave a stale worktree binding; the guard exits silently
# on a mismatched binding, so clear it before asserting deny behavior.
rm -f "$_eval_session_dir/bound-worktree" "$_eval_session_dir/bound-branch"
for _snyk_cmd in "bunx snyk monitor --all-projects" \
  "curl -X POST -d '{}' https://api.snyk.io/rest/orgs/o/projects"; do
  _rc=0
  _out=$(printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$_snyk_cmd" \
    | "$HOOKS_DIR/pre-bash.sh" 2>&1) || _rc=$?
  if [ "$_rc" = "2" ] && printf '%s' "$_out" | grep -qi "snyk"; then
    echo "  PASS  pre-bash routes to snyk guard: $_snyk_cmd"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  snyk shape not denied via dispatcher (exit=$_rc): $_snyk_cmd"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: snyk routing $_snyk_cmd"
  fi
done
if jq -e '[.hooks.PreToolUse[] | select(.matcher=="Bash") | .hooks[] | select(.if)] | length == 0' "$REPO_ROOT/.claude/settings.json" >/dev/null 2>&1; then
  echo "  PASS  no if-gated Bash guard bypasses the dispatcher"
  PASS=$((PASS + 1))
else
  echo "  FAIL  if-gated Bash guard present — shapes outside the prefix escape it"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: if-gated Bash guard"
fi

# ── Generator passes object-entry fields through (fixture repo) ──
_gen_fix=$(mktemp -d)
(
  cd "$_gen_fix" || exit 1
  git init -q .
  mkdir -p .claude/hooks shared hooks
  cp "$REPO_ROOT/shared/hook-lib.sh" shared/hook-lib.sh
  cp "$REPO_ROOT/hooks/frontend-skills.rules" hooks/frontend-skills.rules
  touch .claude/hooks/x.sh
  cat > skill-manifest.json <<'FIX'
{"version":"0.0.0","hooks":{"PreToolUse":{"Bash":[{"script":"x.sh","if":"Bash(demo *)","async":true,"statusMessage":"demo"}]}}}
FIX
  bash "$REPO_ROOT/scripts/generate-hook-configs.sh" --apply >/dev/null 2>&1
)
if jq -e '.hooks.PreToolUse[0].hooks[0] | .if == "Bash(demo *)" and .async == true and .statusMessage == "demo"' "$_gen_fix/.claude/settings.json" >/dev/null 2>&1 \
  && jq -e '[.. | objects | select(has("if") or has("async"))] | length == 0' "$_gen_fix/hooks/codex-hooks.json" >/dev/null 2>&1; then
  echo "  PASS  generator passes if/async/statusMessage to Claude, strips for Codex"
  PASS=$((PASS + 1))
else
  echo "  FAIL  generator object-entry passthrough broken"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: generator if passthrough"
fi
rm -rf "$_gen_fix"
if jq -e '.. | objects | select(.asyncRewake==true)' "$REPO_ROOT/.claude/settings.json" >/dev/null 2>&1; then
  echo "  FAIL  settings still contain delayed asyncRewake behavior"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: asyncRewake remains configured"
else
  echo "  PASS  settings contain no delayed asyncRewake behavior"
  PASS=$((PASS + 1))
fi
if jq -re '.hooks.SessionStart[0].hooks[0].args[0]' "$REPO_ROOT/.claude/settings.json" 2>/dev/null | grep -qx -- "-c"; then
  echo "  PASS  hooks spawn without login shell (-c)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  hook spawn still uses login shell"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: login shell in hook spawn"
fi
# The FULL deny floor must survive regeneration — adding Agent(model:haiku)
# once replaced all ten native Bash rules (PR 72 review).
_deny_missing=""
for _rule in "Bash(npm *)" "Bash(npx *)" "Bash(tsgo)" "Bash(tsgo *)" \
  "Bash(eslint *)" "Bash(prettier *)" "Bash(git reset --hard*)" \
  "Bash(git checkout .)" "Bash(git restore .)" "Bash(sleep *)" \
  "Agent(model:haiku)"; do
  jq -e --arg r "$_rule" '.permissions.deny | index($r)' "$REPO_ROOT/.claude/settings.json" >/dev/null 2>&1 \
    || _deny_missing="$_deny_missing $_rule"
done
if [ -z "$_deny_missing" ]; then
  echo "  PASS  full permissions.deny floor intact (10 Bash rules + never-Haiku)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  permissions.deny floor missing:$_deny_missing"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: deny floor missing$_deny_missing"
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

# Go checks stay in the GLOBAL batch: they act on *.proto and e2e/testdata
# YAML, which never match golang's *.go/go.mod activation paths — skill
# frontmatter scoping silently dropped Claude coverage (PR 72 review).
if grep -q "run_go_proto_reserved_check" "$REPO_ROOT/.claude/hooks/post-tool-batch.sh" 2>/dev/null \
  && grep -q "run_go_test_image_pin_check" "$REPO_ROOT/.claude/hooks/post-tool-batch.sh" 2>/dev/null \
  && ! grep -q "go-proto-reserved-check.sh" "$REPO_ROOT/golang/SKILL.md" 2>/dev/null; then
  echo "  PASS  Go checks owned by global batch (proto/YAML edits stay covered)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Go checks not globally owned — proto/YAML coverage hole"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: go-check ownership"
fi
# Integration: a *.proto edit reaches the proto check with NO skill invoked
_go_fix=$(mktemp -d)
(cd "$_go_fix" && git init -q . \
  && git config user.email eval@example.com && git config user.name Eval \
  && git commit -q --allow-empty -m init)
cat > "$_go_fix/api.proto" <<'PROTO'
syntax = "proto3";
message Thing {
  string keep = 1;
}
PROTO
(cd "$_go_fix" && git add api.proto && git commit -q -m add)
# remove a field without reserving its tag — the check's target pattern
cat > "$_go_fix/api.proto" <<'PROTO'
syntax = "proto3";
message Thing {
}
PROTO
_go_fix_phys=$(cd "$_go_fix" && pwd -P)
echo "$_go_fix_phys" > "$_eval_session_dir/bound-worktree"
_rc=0
_out=$(printf '{"hook_event_name":"PostToolBatch","tool_calls":[{"tool_name":"Edit","tool_input":{"file_path":"%s/api.proto"}}]}' "$_go_fix_phys" \
  | (cd "$_go_fix_phys" && bash "$HOOKS_DIR/post-tool-batch.sh") 2>&1) || _rc=$?
if printf '%s' "$_out" | grep -qi "reserv"; then
  echo "  PASS  proto edit triggers go-proto-reserved-check via global batch"
  PASS=$((PASS + 1))
else
  echo "  FAIL  proto edit did not reach go-proto-reserved-check (exit=$_rc): ${_out:0:160}"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: proto batch integration"
fi
rm -f "$_eval_session_dir/bound-worktree"
rm -rf "$_go_fix"
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
