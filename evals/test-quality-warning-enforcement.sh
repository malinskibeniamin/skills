# Evals for "green != done" warning enforcement.

HOOKS_DIR="$REPO_ROOT/.claude/hooks"
SCRIPT="$HOOKS_DIR/test-warning-check.sh"
CI_SCRIPT="$HOOKS_DIR/ci-warning-audit.sh"

run_file_eval "$SCRIPT" "test-warning-check.sh exists"
run_executable_eval "$SCRIPT" "test-warning-check.sh is executable"
run_content_eval "$SCRIPT" "Warnings are errors" "test-warning-check uses hard-error language"
run_content_eval "$SCRIPT" "hook_block" "test-warning-check blocks warnings"
run_content_eval "$SCRIPT" "No env bypass" "test-warning-check forbids env bypass"
if [ -e "$CI_SCRIPT" ]; then
  echo "  FAIL  ci-warning-audit still exists as an automatic delayed-wake hook"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: ci-warning-audit still exists"
else
  echo "  PASS  delayed CI warning audit removed"
  PASS=$((PASS + 1))
fi

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"bun test"},"tool_response":{"exit_code":0,"stdout":"pass","stderr":"DeprecationWarning: old api"}}' \
  2 "block: green test run with deprecation warning" "Warnings are errors"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"rstest run"},"tool_response":{"exit_code":0,"stdout":"pass","stderr":"DeprecationWarning: old api"}}' \
  2 "block: green Rstest run with deprecation warning" "Warnings are errors"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"bun run lint"},"tool_response":{"exit_code":0,"stdout":"WARNING: formatter skipped file","stderr":""}}' \
  2 "block: green lint run with warning" "Warnings are errors"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"bun run type:check"},"tool_response":{"exit_code":0,"stdout":"","stderr":"npm WARN deprecated old-package@1.0.0"}}' \
  2 "block: npm WARN deprecated in green command" "Warnings are errors"

_tw_tmpdir=$(mktemp -d /tmp/test-warning-evals-XXXXXX)
_tw_file="$_tw_tmpdir/example.test.ts"
printf '// allow: test-warning legacy library\n' > "$_tw_file"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"bun test $_tw_file\"},\"tool_response\":{\"exit_code\":0,\"stdout\":\"$_tw_file stderr | DeprecationWarning: old api\",\"stderr\":\"\"}}" \
  2 "block: allow comment does not bypass warning" "Warnings are errors"

rm -rf "$_tw_tmpdir"

TEST_WARNINGS_ALLOW=1
export TEST_WARNINGS_ALLOW
run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"bun test"},"tool_response":{"exit_code":0,"stdout":"","stderr":"Warning: An update to Component inside a test was not wrapped in act"}}' \
  2 "block: env var does not bypass warning" "Warnings are errors"
unset TEST_WARNINGS_ALLOW

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"bun test"},"tool_response":{"exit_code":0,"stdout":"pass","stderr":""}}' \
  0 "allow: green test run without warnings"
