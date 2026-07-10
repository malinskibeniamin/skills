# Evals for Claude PostToolBatch dispatcher plus Codex per-call parity.

BATCH_HOOK="$REPO_ROOT/.claude/hooks/post-tool-batch.sh"
CODEX_HOOKS="$REPO_ROOT/hooks/codex-hooks.json"
CLAUDE_SETTINGS="$REPO_ROOT/.claude/settings.json"

run_file_eval "$BATCH_HOOK" "post-tool-batch.sh exists"
run_executable_eval "$BATCH_HOOK" "post-tool-batch.sh is executable"

_batch_tmp=$(mktemp -d)
trap "rm -rf '$_batch_tmp'" EXIT
git init -q "$_batch_tmp" 2>/dev/null || true

_run_batch() {
  local payload="$1"
  local stdout_file stderr_file exit_code
  stdout_file=$(mktemp)
  stderr_file=$(mktemp)
  exit_code=0
  export CLAUDE_SESSION_ID="eval-post-tool-batch-$$-$RANDOM"
  (cd "$_batch_tmp" && printf '%s' "$payload" | bash "$BATCH_HOOK" >"$stdout_file" 2>"$stderr_file") || exit_code=$?
  _batch_stdout=$(cat "$stdout_file")
  _batch_stderr=$(cat "$stderr_file")
  _batch_exit=$exit_code
  rm -f "$stdout_file" "$stderr_file"
  rm -rf "/tmp/hook-session-${CLAUDE_SESSION_ID}" 2>/dev/null || true
  unset CLAUDE_SESSION_ID
}

_assert_batch() {
  local desc="$1" expected_exit="$2" must_contain="${3:-}" must_not_contain="${4:-}"
  local ok=true combined
  combined="$_batch_stdout$_batch_stderr"
  [ "$_batch_exit" -ne "$expected_exit" ] && ok=false
  if [ -n "$must_contain" ] && ! printf '%s' "$combined" | grep -qF -- "$must_contain"; then
    ok=false
  fi
  if [ -n "$must_not_contain" ] && printf '%s' "$combined" | grep -qF -- "$must_not_contain"; then
    ok=false
  fi
  if [ "$ok" = true ]; then
    echo "  PASS  $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $desc (exit=$_batch_exit expected=$expected_exit)"
    [ -n "$must_contain" ] && echo "        missing: $must_contain"
    [ -n "$must_not_contain" ] && echo "        unexpected: $must_not_contain"
    echo "        stdout: ${_batch_stdout:0:400}"
    echo "        stderr: ${_batch_stderr:0:400}"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $desc"
  fi
}

# (a) Two Edit calls: one introduces : any, one clean. Only bad file appears.
_bad_file="$_batch_tmp/bad.ts"
_clean_file="$_batch_tmp/clean.ts"
printf '// Copyright 2026 Redpanda Data, Inc.\nexport function bad(x: any) { return x; }\n' > "$_bad_file"
printf '// Copyright 2026 Redpanda Data, Inc.\nexport function clean(x: number) { return x; }\n' > "$_clean_file"
_bad_json=$(jq -n --arg bad "$_bad_file" --arg clean "$_clean_file" '{hook_event_name:"PostToolBatch",tool_calls:[{tool_name:"Edit",tool_input:{file_path:$bad,old_string:"export function bad(x: number) { return x; }",new_string:"export function bad(x: any) { return x; }"},tool_use_id:"bad",tool_response:"{}"},{tool_name:"Edit",tool_input:{file_path:$clean,old_string:"export function clean(x: string) { return x; }",new_string:"export function clean(x: number) { return x; }"},tool_use_id:"clean",tool_response:"{}"}]}')
_run_batch "$_bad_json"
_assert_batch "batch blocks on hard finding for bad file only" 2 "MUST FIX before proceeding:" "clean.ts"
_assert_batch "batch mentions ': any' escape hatch" 2 ": any" ""

# (b) Same file edited twice: duplicate drops payloads and re-diffs SURVIVING
# final state -- the transient ": any" was reverted by the second edit, so no
# finding (file on disk matches its committed/clean state).
_same_file="$_batch_tmp/same.ts"
printf '// Copyright 2026 Redpanda Data, Inc.\nexport const value: number = 2;\n' > "$_same_file"
_same_json=$(jq -n --arg f "$_same_file" '{hook_event_name:"PostToolBatch",tool_calls:[{tool_name:"Edit",tool_input:{file_path:$f,old_string:"export const value: number = 0;",new_string:"export const value: any = 1;"},tool_use_id:"first",tool_response:"{}"},{tool_name:"Bash",tool_input:{command:"echo ignored"},tool_use_id:"bash",tool_response:"ok"},{tool_name:"Edit",tool_input:{file_path:$f,old_string:"export const value: any = 1;",new_string:"export const value: number = 2;"},tool_use_id:"second",tool_response:"{}"}]}')
_run_batch "$_same_json"
_assert_batch "batch re-diffs surviving state on duplicate file (reverted violation silent)" 0 "" ": any"

# (b2) Same file edited twice, violation PERSISTS in final state: caught via
# surviving-state re-diff even though the LAST payload alone is clean.
_pers_file="$_batch_tmp/persist.ts"
printf '// Copyright 2026 Redpanda Data, Inc.\nexport const v: any = 1;\nexport const w = 2;\n' > "$_pers_file"
_pers_json=$(jq -n --arg f "$_pers_file" '{hook_event_name:"PostToolBatch",tool_calls:[{tool_name:"Edit",tool_input:{file_path:$f,old_string:"export const v: number = 1;",new_string:"export const v: any = 1;"},tool_use_id:"first",tool_response:"{}"},{tool_name:"Edit",tool_input:{file_path:$f,old_string:"export const w = 1;",new_string:"export const w = 2;"},tool_use_id:"second",tool_response:"{}"}]}')
_run_batch "$_pers_json"
_assert_batch "duplicate-file batch catches persistent violation from earlier call" 2 ": any" ""

# (c) All-clean batch is silent and exit 0.
_clean_batch=$(jq -n --arg f "$_clean_file" '{hook_event_name:"PostToolBatch",tool_calls:[{tool_name:"Edit",tool_input:{file_path:$f,old_string:"export function clean(x: string) { return x; }",new_string:"export function clean(x: number) { return x; }"},tool_use_id:"clean",tool_response:"{}"}]}')
_run_batch "$_clean_batch"
if [ "$_batch_exit" -eq 0 ] && [ -z "$_batch_stdout$_batch_stderr" ]; then
  echo "  PASS  all-clean batch is silent"
  PASS=$((PASS + 1))
else
  echo "  FAIL  all-clean batch is silent (exit=$_batch_exit stdout=${_batch_stdout:0:120} stderr=${_batch_stderr:0:120})"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: all-clean batch is silent"
fi

# (d) Non-edit tools ignored.
_non_edit_json='{ "hook_event_name":"PostToolBatch", "tool_calls":[{"tool_name":"Bash","tool_input":{"command":"echo x"},"tool_use_id":"bash","tool_response":"x"}] }'
_run_batch "$_non_edit_json"
if [ "$_batch_exit" -eq 0 ] && [ -z "$_batch_stdout$_batch_stderr" ]; then
  echo "  PASS  non-Edit tools ignored"
  PASS=$((PASS + 1))
else
  echo "  FAIL  non-Edit tools ignored (exit=$_batch_exit stdout=${_batch_stdout:0:120} stderr=${_batch_stderr:0:120})"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: non-Edit tools ignored"
fi

# (e) Codex keeps per-call scripts and never gets PostToolBatch.
_codex_count=$(jq '[.hooks.PostToolUse[]? | select(.matcher == "Edit|Write|apply_patch") | .hooks[]?.command | select(test("(vendor-file-check|react-rules-check|tailwind-check|accessibility-check|zustand-check|tanstack-router-check|tanstack-router-gen|connect-query-check|aip-proto-check|ux-copy-check|orchestration-guidance|form-mode-check|error-boundary-check|test-convention-check|ts-no-escape-hatches-check|tsconfig-strict-check|llm-failure-mode-check|security-audit-check|query-pattern-check|copyright-check|edit-loop-check|lockfile-sync-check)\\.sh"))] | length' "$CODEX_HOOKS" 2>/dev/null || echo 0)
if [ "$_codex_count" = "22" ] && ! grep -q 'post-tool-batch.sh' "$CODEX_HOOKS" 2>/dev/null; then
  echo "  PASS  codex-hooks.json keeps 22 per-call scripts and omits dispatcher"
  PASS=$((PASS + 1))
else
  echo "  FAIL  codex-hooks.json per-call parity (count=$_codex_count)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: codex-hooks per-call parity"
fi

# (f) Claude settings has dispatcher, not the 22 per-edit scripts under PostToolUse.
_claude_batch=$(jq '[.hooks.PostToolBatch[]?.hooks[]?.args[]? | select(test("post-tool-batch\\.sh"))] | length' "$CLAUDE_SETTINGS" 2>/dev/null || echo 0)
_claude_posttool_edit_count=$(jq '[.hooks.PostToolUse[]? | select(.matcher == "Edit|Write|apply_patch") | .hooks[]?.args[]? | select(test("(vendor-file-check|react-rules-check|tailwind-check|accessibility-check|zustand-check|tanstack-router-check|tanstack-router-gen|connect-query-check|aip-proto-check|ux-copy-check|orchestration-guidance|form-mode-check|error-boundary-check|test-convention-check|ts-no-escape-hatches-check|tsconfig-strict-check|llm-failure-mode-check|security-audit-check|query-pattern-check|copyright-check|edit-loop-check|lockfile-sync-check)\\.sh"))] | length' "$CLAUDE_SETTINGS" 2>/dev/null || echo 0)
if [ "$_claude_batch" = "1" ] && [ "$_claude_posttool_edit_count" = "0" ]; then
  echo "  PASS  Claude settings uses PostToolBatch dispatcher only for per-edit checks"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Claude settings dispatcher wiring (batch=$_claude_batch posttool_edit=$_claude_posttool_edit_count)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Claude PostToolBatch wiring"
fi
