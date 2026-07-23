#!/bin/bash
# Channel contract tests: which stream carries hook JSON per tier.
#
# Claude Code's hook contract (and the Codex adapter that mirrors it):
#   exit 0 — JSON payloads (systemMessage, hookSpecificOutput) are parsed
#            from STDOUT. stderr on exit 0 is debug-only and never reaches
#            the model or the user.
#   exit 2 — the block/deny reason is read from STDERR.
#
# These tests pin the contract per tier so a future emitter can't silently
# post to the dead stream again (issue #60 P1: the whole advisory tier was
# emitting to stderr with exit 0 — invisible on both harnesses).

source "$(dirname "$0")/hook-test-helpers.sh"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║        Channel Contracts — stream per hook tier          ║"
echo "╚═══════════════════════════════════════════════════════════╝"

# Run a small script sourcing _hook-lib.sh, capturing both streams + exit.
_run_lib_call() {
  local body="$1"
  local script stdout_file stderr_file
  script=$(mktemp)
  stdout_file=$(mktemp)
  stderr_file=$(mktemp)
  cat > "$script" <<EOF
#!/bin/bash
source "$HOOKS_DIR/_hook-lib.sh"
$body
EOF
  chmod +x "$script"
  _rc=0
  echo '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/x.ts"}}' \
    | bash "$script" >"$stdout_file" 2>"$stderr_file" || _rc=$?
  _stdout=$(cat "$stdout_file")
  _stderr=$(cat "$stderr_file")
  rm -f "$script" "$stdout_file" "$stderr_file"
}

# Run a real hook script, capturing both streams + exit.
_run_hook_both() {
  local hook="$1" input="$2"
  local stdout_file stderr_file
  stdout_file=$(mktemp)
  stderr_file=$(mktemp)
  _rc=0
  echo "$input" | bash "$HOOKS_DIR/$hook" >"$stdout_file" 2>"$stderr_file" || _rc=$?
  _stdout=$(cat "$stdout_file")
  _stderr=$(cat "$stderr_file")
  rm -f "$stdout_file" "$stderr_file"
}

_check() {
  local name="$1" cond="$2"
  if eval "$cond"; then
    PASS=$((PASS + 1)); echo -e "  ${GREEN}✓${NC} $name"
  else
    FAIL=$((FAIL + 1)); echo -e "  ${RED}✗${NC} $name (rc=$_rc stdout=${_stdout:0:120} stderr=${_stderr:0:120})"
  fi
}

_is_json() { printf '%s' "$1" | jq -e . >/dev/null 2>&1; }

_setup_session

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ warn tier (exit 0 → stdout) ━━━"
# ═══════════════════════════════════════════════════════════════

_run_lib_call 'hook_warn "advisory message" "test-rule"'
_check "hook_warn exits 0" '[ "$_rc" = "0" ]'
_check "hook_warn JSON lands on stdout" '_is_json "$_stdout" && printf "%s" "$_stdout" | jq -e ".systemMessage" >/dev/null 2>&1'
_check "hook_warn emits nothing to stderr" '[ -z "$_stderr" ]'

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ nudge tier (exit 0 → stdout) ━━━"
# ═══════════════════════════════════════════════════════════════

_run_lib_call 'hook_nudge "consider X" "test-rule"'
_check "hook_nudge exits 0" '[ "$_rc" = "0" ]'
_check "hook_nudge JSON lands on stdout with [nudge] prefix" '_is_json "$_stdout" && printf "%s" "$_stdout" | jq -re ".systemMessage" 2>/dev/null | grep -q "\[nudge\]"'
_check "hook_nudge emits nothing to stderr" '[ -z "$_stderr" ]'

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ block tier (exit 2 → stderr) ━━━"
# ═══════════════════════════════════════════════════════════════

_run_lib_call 'hook_block "hard stop" "test-rule"'
_check "hook_block exits 2" '[ "$_rc" = "2" ]'
_check "hook_block reason lands on stderr" 'printf "%s" "$_stderr" | grep -q "hard stop"'
_check "hook_block emits nothing to stdout" '[ -z "$_stdout" ]'

_run_lib_call 'hook_block_strict "sec issue" "test-rule"'
_check "hook_block_strict exits 2" '[ "$_rc" = "2" ]'
_check "hook_block_strict [STRICT] reason lands on stderr" 'printf "%s" "$_stderr" | grep -q "\[STRICT\]"'
_check "hook_block_strict emits nothing to stdout" '[ -z "$_stdout" ]'

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ deny tier (PreToolUse, exit 2 → stderr) ━━━"
# ═══════════════════════════════════════════════════════════════

_run_lib_call 'hook_deny "denied" "test-rule"'
_check "hook_deny exits 2" '[ "$_rc" = "2" ]'
_check "hook_deny reason lands on stderr" 'printf "%s" "$_stderr" | grep -q "denied"'

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ stop tier (Stop hook, exit 2 → stderr) ━━━"
# ═══════════════════════════════════════════════════════════════

_run_lib_call 'hook_stop_block "not done yet"'
_check "hook_stop_block exits 2" '[ "$_rc" = "2" ]'
_check "hook_stop_block decision JSON lands on stderr" 'printf "%s" "$_stderr" | grep -q "\"decision\":\"block\""'

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ context tier (exit 0 → stdout) ━━━"
# ═══════════════════════════════════════════════════════════════

# Representative FileChanged context injector (FileChanged payloads carry
# a top-level filename, not tool_input.file_path).
_run_hook_both "file-changed-env.sh" '{"filename":"src/env.ts"}'
_check "file-changed-env exits 0" '[ "$_rc" = "0" ]'
_check "file-changed-env context lands on stdout" '_is_json "$_stdout" && printf "%s" "$_stdout" | jq -re ".systemMessage" 2>/dev/null | grep -q "^\[env\]"'
_check "file-changed-env emits nothing to stderr" '[ -z "$_stderr" ]'

# hook_skip_ui_dirs is skip-only: the registry-edit warning has ONE owner
# (vendor-file-check.lib.sh via hook_warn, covered by the warn tier above).
_ui_root=$(mktemp -d)
mkdir -p "$_ui_root/components/ui"
echo 'export const x = 1' > "$_ui_root/components/ui/button.tsx"
echo '{}' > "$_ui_root/components.json"
( cd "$_ui_root" && git init -q . )
_stdout_file=$(mktemp); _stderr_file=$(mktemp)
_script=$(mktemp)
cat > "$_script" <<EOF
#!/bin/bash
source "$HOOKS_DIR/_hook-lib.sh"
hook_parse_edit_write
hook_skip_ui_dirs
exit 0
EOF
_rc=0
printf '{"tool_name":"Edit","tool_input":{"file_path":"%s"}}' "$_ui_root/components/ui/button.tsx" \
  | ( cd "$_ui_root" && bash "$_script" ) >"$_stdout_file" 2>"$_stderr_file" || _rc=$?
_stdout=$(cat "$_stdout_file"); _stderr=$(cat "$_stderr_file")
rm -f "$_script" "$_stdout_file" "$_stderr_file"; rm -rf "$_ui_root"
_check "hook_skip_ui_dirs exits 0" '[ "$_rc" = "0" ]'
_check "hook_skip_ui_dirs is silent on stdout (vendor-file owns the warn)" '[ -z "$_stdout" ]'
_check "hook_skip_ui_dirs emits nothing to stderr" '[ -z "$_stderr" ]'

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ rewrite tier (PreToolUse updatedInput, exit 0 → stdout) ━━━"
# ═══════════════════════════════════════════════════════════════

_run_hook_both "llm-test-flags.sh" '{"tool_name":"Bash","tool_input":{"command":"bunx vitest run --verbose foo.test.ts"}}'
_check "llm-test-flags exits 0" '[ "$_rc" = "0" ]'
_check "llm-test-flags updatedInput lands on stdout" '_is_json "$_stdout" && printf "%s" "$_stdout" | jq -re ".hookSpecificOutput.updatedInput.command" 2>/dev/null | grep -qv -- "--verbose"'
_check "llm-test-flags emits nothing to stderr" '[ -z "$_stderr" ]'

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ message cap (Codex forwards ~2.5K tokens ≈ 10KB per call) ━━━"
# ═══════════════════════════════════════════════════════════════

_run_lib_call 'hook_warn "$(printf "x%.0s" $(seq 1 20000))" cap-test'
_check "oversized warn still exits 0" '[ "$_rc" = "0" ]'
_check "oversized warn is truncated under 9KB" '[ "${#_stdout}" -lt 9216 ]'
_check "truncation is announced, not silent" 'printf "%s" "$_stdout" | grep -q "truncated: message exceeded"'

_run_lib_call 'hook_block "$(printf "y%.0s" $(seq 1 20000))" cap-test'
_check "oversized block still exits 2" '[ "$_rc" = "2" ]'
_check "oversized block reason truncated under 9KB" '[ "${#_stderr}" -lt 9216 ]'

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ Stop tier — block-cap guard + additionalContext channel ━━━"
# ═══════════════════════════════════════════════════════════════

_run_lib_call 'hook_stop_context "advice for the model" ctx-test'
_check "stop-context exits 0" '[ "$_rc" = "0" ]'
_check "stop-context additionalContext lands on stdout" '_is_json "$_stdout" && printf "%s" "$_stdout" | jq -re ".hookSpecificOutput.additionalContext" >/dev/null 2>&1'
_check "stop-context names its event" 'printf "%s" "$_stdout" | jq -re ".hookSpecificOutput.hookEventName" 2>/dev/null | grep -q "^Stop$"'

_run_lib_call 'hook_stop_block "fix this first"'
_check "stop-block exits 2" '[ "$_rc" = "2" ]'
_check "stop-block decision lands on stderr" 'printf "%s" "$_stderr" | jq -re ".decision" 2>/dev/null | grep -q "^block$"'

# Spend the consecutive-block budget (cap 8 → guard at 6), next call downgrades.
echo "999" > "/tmp/hook-session-${CLAUDE_SESSION_ID}/stop-block-count" 2>/dev/null || true
_run_lib_call 'hook_stop_block "still broken"'
_check "capped stop-block downgrades to exit 0" '[ "$_rc" = "0" ]'
_check "capped stop-block message lands on stdout" 'printf "%s" "$_stdout" | jq -re ".systemMessage" 2>/dev/null | grep -q "stop-block cap"'
rm -f "/tmp/hook-session-${CLAUDE_SESSION_ID}/stop-block-count" "/tmp/hook-session-${CLAUDE_SESSION_ID}/stop-block-marker" 2>/dev/null || true

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ typed protocol parity (bun path == shell fallback) ━━━"
# ═══════════════════════════════════════════════════════════════

# The lib delegates emission to shared/hook-protocol.ts when bun exists;
# HOOK_PROTOCOL=shell forces the pure-shell path. Both must land on the
# same stream with the same exit code, or consumers without bun diverge.

_run_lib_call_env() {
  local envmode="$1" body="$2"
  local stdin_payload="${3:-}"
  [ -n "$stdin_payload" ] || stdin_payload='{"tool_name":"Edit","tool_input":{"file_path":"/tmp/x.ts"}}'
  local script stdout_file stderr_file
  script=$(mktemp)
  stdout_file=$(mktemp)
  stderr_file=$(mktemp)
  cat > "$script" <<EOF
#!/bin/bash
export HOOK_PROTOCOL=$envmode
source "$HOOKS_DIR/_hook-lib.sh"
$body
EOF
  chmod +x "$script"
  _rc=0
  printf '%s' "$stdin_payload" \
    | bash "$script" >"$stdout_file" 2>"$stderr_file" || _rc=$?
  _stdout=$(cat "$stdout_file")
  _stderr=$(cat "$stderr_file")
  rm -f "$script" "$stdout_file" "$stderr_file"
}

if command -v bun >/dev/null 2>&1; then
  # Hostile fixture: embedded quotes + newline. Catches escaping divergence
  # between JSON.stringify and _safe_json_escape that a plain message hides.
  _pmsg='say "hi" and
then stop'
  for _tier_case in "warn:hook_warn \"\$_pmsg\" r:0:stdout" "nudge:hook_nudge \"\$_pmsg\" r:0:stdout" "block:hook_block \"\$_pmsg\" r:2:stderr" "block-strict:hook_block_strict \"\$_pmsg\" r:2:stderr" "deny:hook_deny \"\$_pmsg\" r:2:stderr" "stop:hook_stop_block \"\$_pmsg\":2:stderr" "context:hook_context \"\$_pmsg\" UserPromptSubmit:0:stdout"; do
    _name="${_tier_case%%:*}"
    _rest="${_tier_case#*:}"
    _call="${_rest%%:*}"; _rest="${_rest#*:}"
    _want_rc="${_rest%%:*}"; _want_stream="${_rest#*:}"
    _typed_payload=""; _shell_payload=""
    for _mode in typed shell; do
      _run_lib_call_env "$_mode" "_pmsg='say \"hi\" and
then stop'; $_call"
      _got=""
      [ -n "$_stdout" ] && _got="stdout"
      [ -n "$_stderr" ] && _got="${_got:+$_got+}stderr"
      _check "$_name/$_mode: exit $_want_rc, payload on $_want_stream only" '[ "$_rc" = "$_want_rc" ] && [ "$_got" = "$_want_stream" ]'
      if [ "$_want_stream" = "stdout" ]; then
        _payload="$_stdout"
      else
        _payload="$_stderr"
      fi
      _check "$_name/$_mode: payload is valid JSON" '_is_json "$_payload"'
      _norm=$(printf '%s' "$_payload" | jq -Sc . 2>/dev/null || printf 'INVALID-%s' "$_mode")
      if [ "$_mode" = "typed" ]; then _typed_payload="$_norm"; else _shell_payload="$_norm"; fi
    done
    _check "$_name: typed and shell payloads are byte-identical (normalized)" '[ -n "$_typed_payload" ] && [ "$_typed_payload" = "$_shell_payload" ]'
  done

  # context payloads must carry hookEventName -- harness contract for
  # additionalContext -- on BOTH paths.
  for _mode in typed shell; do
    _run_lib_call_env "$_mode" 'hook_context "ctx body" PostCompact'
    _check "context/$_mode: payload carries hookEventName" 'printf "%s" "$_stdout" | jq -re ".hookSpecificOutput.hookEventName" 2>/dev/null | grep -qx "PostCompact"'
  done

  # parse: shell-safe assignments round-trip quotes and newlines
  _hp_out=$(jq -nc '{session_id:"s-42",tool_name:"Bash",tool_input:{command:"echo '"'"'a b'"'"'\nsecond"}}' | bun "$REPO_ROOT/shared/hook-protocol.ts" parse) || true
  hp_session_id=""; hp_tool_name=""; hp_command=""
  eval "$_hp_out"
  _rc=0
  _check "parse exports shell-safe fields" '[ "$hp_session_id" = "s-42" ] && [ "$hp_tool_name" = "Bash" ]'
  _check "parse round-trips quoted command text" 'printf "%s" "$hp_command" | grep -q "a b" && printf "%s" "$hp_command" | grep -q "second"'

  # parse-path parity (phase 2): the wired typed parse and the jq fallback
  # must extract byte-identical fields from a hostile payload.
  _hostile_cmd='echo '\''a b'\'' "q"
line2'
  _parse_payload=$(jq -nc --arg c "$_hostile_cmd" '{session_id:"s-77",tool_name:"Bash",tool_input:{command:$c}}')
  _parse_body='hook_parse_bash; printf "%s" "$command"'
  _run_lib_call_env typed "$_parse_body" "$_parse_payload"
  _typed_cmd="$_stdout"; _typed_rc="$_rc"
  _run_lib_call_env shell "$_parse_body" "$_parse_payload"
  _shell_cmd="$_stdout"; _shell_rc="$_rc"
  _check "parse-path: typed extraction succeeds on hostile command" '[ "$_typed_rc" = "0" ] && [ -n "$_typed_cmd" ]'
  _check "parse-path: typed and shell extract identical command" '[ "$_typed_cmd" = "$_shell_cmd" ]'
  _check "parse-path: newline and quotes survive extraction" 'printf "%s" "$_typed_cmd" | grep -q "line2" && printf "%s" "$_typed_cmd" | grep -q "\"q\""'

  # Trailing newline: $(... | jq -r ...) strips it, so the typed layer
  # must pre-trim or an end-anchored matcher diverges across paths. The
  # byte COUNT is asserted inside the script -- capturing via $() out here
  # would strip the very newline under test on both paths and mask it.
  _tnl_payload=$(jq -nc '{tool_name:"Bash",tool_input:{command:"sleep 1\n"}}')
  _tnl_body='hook_parse_bash; printf "%s" "$command" | wc -c | tr -d " "'
  _run_lib_call_env typed "$_tnl_body" "$_tnl_payload"
  _typed_len="$_stdout"
  _run_lib_call_env shell "$_tnl_body" "$_tnl_payload"
  _shell_len="$_stdout"
  _check "parse-path: trailing newline trims identically (typed=$_typed_len shell=$_shell_len)" '[ "$_typed_len" = "7" ] && [ "$_shell_len" = "7" ]'

  # Empty event name: contract-invalid on every path -- both must skip
  # silently (exit 0, no payload) instead of diverging (typed usage error
  # vs shell emitting hookEventName:"").
  for _mode in typed shell; do
    _run_lib_call_env "$_mode" 'hook_context "ctx body" ""'
    _check "context/$_mode: empty event name skips emission" '[ "$_rc" = "0" ] && [ -z "$_stdout" ] && [ -z "$_stderr" ]'
  done

  # Path with a space: the field the shell reads must be the exact string,
  # not a word-split fragment. The file must exist or the parser skips.
  # mktemp -d: a predictable /tmp name would race concurrent runs and
  # could clobber a user's real file.
  _parity_dir=$(mktemp -d "${TMPDIR:-/tmp}/hook-parity.XXXXXX")
  _parity_file="$_parity_dir/parity check.ts"
  : > "$_parity_file"
  _edit_payload=$(jq -nc --arg f "$_parity_file" '{session_id:"s-78",tool_name:"Edit",tool_input:{file_path:$f}}')
  _edit_body='hook_parse_edit_write; printf "%s" "$file_path"'
  _run_lib_call_env typed "$_edit_body" "$_edit_payload"
  _typed_fp="$_stdout"
  _run_lib_call_env shell "$_edit_body" "$_edit_payload"
  _shell_fp="$_stdout"
  rm -rf "$_parity_dir"
  _check "parse-path: typed and shell extract identical file_path" '[ "$_typed_fp" = "$_parity_file" ] && [ "$_typed_fp" = "$_shell_fp" ]'
else
  _skip "typed protocol parity" "bun not installed"
fi

_teardown_session

# ═══════════════════════════════════════════════════════════════

_report_results "Channel Contracts"
