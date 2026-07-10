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

_teardown_session

# ═══════════════════════════════════════════════════════════════

_report_results "Channel Contracts"
