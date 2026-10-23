# Evals for mcp-ban.sh — PreToolUse hook that denies verbose MCP tool
# calls and redirects to CLI equivalents (acli, gog, agent-browser, gh, etc.)

HOOK="$REPO_ROOT/.claude/hooks/mcp-ban.sh"
CLAUDE_SETTINGS="$REPO_ROOT/.claude/settings.json"
CODEX_HOOKS="$REPO_ROOT/.codex/hooks.json"

run_file_eval "$HOOK" "mcp-ban.sh exists"
run_executable_eval "$HOOK" "mcp-ban.sh executable"

# Registration: must appear in both Claude Code + Codex PreToolUse matchers
for cfg in "$CLAUDE_SETTINGS" "$CODEX_HOOKS"; do
  label=$(basename "$(dirname "$cfg")")/$(basename "$cfg")
  if grep -q '"matcher": "mcp__' "$cfg" 2>/dev/null && grep -q 'mcp-ban.sh' "$cfg" 2>/dev/null; then
    echo "  PASS  $label registers mcp-ban with mcp__ matcher"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $label missing mcp-ban registration"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: mcp-ban not registered in $label"
  fi
done

# Helper: run hook and capture stderr/exit
_run_mcp() {
  local tool="$1"
  local input="${2:-}"
  [ -n "$input" ] || input='{}'
  local err; err=$(mktemp); local ec=0
  jq -nc --arg tool "$tool" --argjson input "$input" \
    '{tool_name: $tool, tool_input: $input}' | bash "$HOOK" 2>"$err" >/dev/null || ec=$?
  _last_stderr=$(cat "$err"); _last_exit=$ec
  rm -f "$err"
}

# Helper: assert denies with CLI hint
_assert_denied() {
  local tool="$1" expect_cli="$2" label="$3"
  _run_mcp "$tool" "${4:-}"
  if [ "$_last_exit" = "2" ] && echo "$_last_stderr" | grep -q '"permissionDecision": "deny"' \
     && echo "$_last_stderr" | grep -q "$expect_cli"; then
    echo "  PASS  $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $label (exit=$_last_exit, stderr missing deny or $expect_cli)"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $label"
  fi
}

# Each MCP family: one smoke test per CLI redirect
_assert_denied "mcp__claude_ai_Atlassian__editJiraIssue" "acli" "Jira -> acli"
_assert_denied "mcp__claude_ai_Gmail__gmail_search_messages" "gog gmail" "Gmail -> gog"
_assert_denied "mcp__claude-in-chrome__read_page" "agent-browser" "claude-in-chrome -> agent-browser"
_assert_denied "mcp__chrome-devtools__evaluate_script" "agent-browser" "chrome-devtools -> agent-browser"
_assert_denied "mcp__playwright__browser_navigate" "agent-browser" "playwright -> agent-browser"
_assert_denied "mcp__blacksmith__list_runs" "gh run" "blacksmith -> gh"
_assert_denied "mcp__claude_ai_Google_Calendar__list_events" "gog calendar" "Calendar -> gog"
_assert_denied "mcp__claude_ai_Google_Drive__files_list" "gog drive" "Drive -> gog"
_assert_denied "mcp__claude_ai_Buildkite_read-only__list" "bk" "Buildkite -> bk"
_assert_denied "mcp__claude_ai_Box__files_list" "box" "Box -> box"
_assert_denied "mcp__claude_ai_Microsoft_365__teams" "m365" "M365 -> m365"

# The opt-in React server needs its own isolated page and React-only execution.
_assert_react_allowed() {
  _run_mcp "$1" "${2:-}"
  if [ "$_last_exit" = "0" ] && [ -z "$_last_stderr" ]; then
    echo "  PASS  $1 ${2:-} allowed"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $1 ${2:-} blocked (exit=$_last_exit)"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: React DevTools allowed call $1 ${2:-}"
  fi
}

for server in react-devtools react_devtools; do
  for tool in list_pages new_page select_page close_page navigate_page take_snapshot \
    take_screenshot click fill press_key wait_for list_console_messages list_3p_developer_tools; do
    _assert_react_allowed "mcp__${server}__${tool}"
  done
  for tool in react_get_component_tree react_find_components react_get_component_by_uid \
    react_get_component_by_dom_element react_get_parent_stack react_get_owner_stack \
    react_get_owner_stack_trace react_get_component_source react_start_profiling \
    react_stop_profiling react_get_trace_overview react_get_commit_report; do
    _assert_react_allowed "mcp__${server}__execute_3p_developer_tool" "{\"pageId\":2,\"toolName\":\"$tool\",\"params\":\"{}\"}"
  done
  for tool in react_override_props react_unknown unrelated_tool ''; do
    _assert_denied "mcp__${server}__execute_3p_developer_tool" "React DevTools" \
      "React server rejects unsupported tool '$tool'" "{\"pageId\":2,\"toolName\":\"$tool\",\"params\":\"{}\"}"
  done
  _assert_denied "mcp__${server}__execute_3p_developer_tool" "React DevTools" \
    "React server rejects missing toolName"
  _assert_denied "mcp__${server}__evaluate_script" "agent-browser" \
    "React server cannot bypass the generic script ban"
  _assert_denied "mcp__${server}__unrelated_tool" "agent-browser" \
    "React server rejects unrelated browser tools"
done

# LaunchDarkly reads and writes use ldcli across host naming conventions.
_assert_denied "mcp__launchdarkly__get_feature_flag" "ldcli" "LaunchDarkly read -> ldcli"
_assert_denied "mcp__LaunchDarkly__update_feature_flag" "ldcli" "LaunchDarkly write -> ldcli"
_assert_denied "mcp__claude_ai_LaunchDarkly__list_flags" "ldcli" "Claude LaunchDarkly -> ldcli"
_assert_denied "mcp__codex_apps__launchdarkly_get_flag" "ldcli" "Codex LaunchDarkly -> ldcli"

# JSON validity on every deny — prevent regressions from unescaped quotes
_run_mcp "mcp__claude_ai_Gmail__gmail_search_messages"
if echo "$_last_stderr" | python3 -c "import json,sys; json.loads(sys.stdin.read())" 2>/dev/null; then
  echo "  PASS  gmail deny produces valid JSON"
  PASS=$((PASS + 1))
else
  echo "  FAIL  gmail deny emits malformed JSON"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: mcp-ban JSON malformed"
fi

# Passthrough for unrelated tools
_run_mcp "Bash"
if [ "$_last_exit" = "0" ] && [ -z "$_last_stderr" ]; then
  echo "  PASS  silent passthrough on non-MCP tool"
  PASS=$((PASS + 1))
else
  echo "  FAIL  non-MCP tool should silent-pass (exit=$_last_exit)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: mcp-ban non-MCP passthrough"
fi

# TraceDecay is the harness's local semantic code graph, not a verbose remote
# service with a cheaper CLI replacement. Preserve its MCP path explicitly.
_run_mcp "mcp__graph__tracedecay_context"
if [ "$_last_exit" = "0" ] && [ -z "$_last_stderr" ]; then
  echo "  PASS  TraceDecay MCP remains allowed"
  PASS=$((PASS + 1))
else
  echo "  FAIL  TraceDecay MCP should silent-pass (exit=$_last_exit)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: TraceDecay MCP passthrough"
fi

# Migration guard: live guidance should not point agents at the old Workspace CLI.
old_cli_pattern="\b([g]ws|[g]oogleworkspace[-]cli|@[g]oogleworkspace/cli|Google[ ]Workspace[ ]CLI)\b"
if rg -n "$old_cli_pattern" "$REPO_ROOT/.claude/hooks/mcp-ban.sh" "$REPO_ROOT/CLAUDE.md" >/tmp/old-workspace-cli-remnants 2>/dev/null; then
  echo "  FAIL  no old Workspace CLI remnants in live guidance"
  sed 's/^/    /' /tmp/old-workspace-cli-remnants
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: old Workspace CLI remnants remain"
else
  echo "  PASS  no old Workspace CLI remnants in live guidance"
  PASS=$((PASS + 1))
fi
