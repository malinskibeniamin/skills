# Evals for "green != done" warning enforcement.

HOOKS_DIR="$REPO_ROOT/.claude/hooks"
SCRIPT="$HOOKS_DIR/test-warning-check.sh"
CI_SCRIPT="$HOOKS_DIR/ci-warning-audit.sh"

run_file_eval "$SCRIPT" "test-warning-check.sh exists"
run_executable_eval "$SCRIPT" "test-warning-check.sh is executable"
run_content_eval "$SCRIPT" "Warnings are errors" "test-warning-check uses hard-error language"
run_content_eval "$SCRIPT" "hook_block" "test-warning-check blocks warnings"
run_content_eval "$SCRIPT" "No env bypass" "test-warning-check forbids env bypass"
run_file_eval "$CI_SCRIPT" "ci-warning-audit.sh exists"
run_executable_eval "$CI_SCRIPT" "ci-warning-audit.sh is executable"
run_content_eval "$CI_SCRIPT" "hook_stop_block" "ci-warning-audit blocks CI warnings"
run_content_eval "$CI_SCRIPT" "No env bypass" "ci-warning-audit forbids env bypass"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"bun test"},"tool_response":{"exit_code":0,"stdout":"pass","stderr":"DeprecationWarning: old api"}}' \
  2 "block: green test run with deprecation warning" "Warnings are errors"

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

_ci_tmpdir=$(mktemp -d /tmp/ci-warning-evals-XXXXXX)
_ci_bin="$_ci_tmpdir/bin"
_ci_repo="$_ci_tmpdir/repo"
mkdir -p "$_ci_bin" "$_ci_repo/src"
cat > "$_ci_bin/gh" <<'EOF'
#!/bin/bash
case "$1 $2" in
  "pr list") echo "123" ;;
  "pr view") echo '{"headRefOid":"abc123","statusCheckRollup":[{"state":"SUCCESS"}]}' ;;
  "run list") echo "456" ;;
  "run view") echo 'job	step	DeprecationWarning: old api' ;;
  *) exit 1 ;;
esac
EOF
chmod +x "$_ci_bin/gh"
(
  cd "$_ci_repo" || exit 1
  git init -q
  git checkout -q -b feature/ci-warning-eval
  git config user.email eval@example.com
  git config user.name Eval
  printf 'export const value = 1\n' > src/value.ts
  git add src/value.ts
  git commit -q -m "init"
)
_ci_session="ci-warning-eval-$$"
mkdir -p "/tmp/hook-session-${_ci_session}"
printf '%s\n' "$_ci_repo/src/value.ts" > "/tmp/hook-session-${_ci_session}/session-touched-files"
actual_exit=0
(cd "$_ci_repo" && PATH="$_ci_bin:$PATH" CLAUDE_SESSION_ID="$_ci_session" "$CI_SCRIPT" > /tmp/ci-warning-stdout 2> /tmp/ci-warning-stderr) || actual_exit=$?
if [ "$actual_exit" -eq 2 ] && grep -q "CI warnings are errors" /tmp/ci-warning-stderr; then
  echo "  PASS  ci-warning-audit blocks green CI warnings"
  PASS=$((PASS + 1))
else
  echo "  FAIL  ci-warning-audit blocks green CI warnings"
  echo "        expected exit=2, got exit=$actual_exit"
  echo "        stderr: $(cat /tmp/ci-warning-stderr 2>/dev/null)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: ci-warning-audit blocks green CI warnings"
fi
rm -rf "$_ci_tmpdir" "/tmp/hook-session-${_ci_session}" /tmp/ci-warning-stdout /tmp/ci-warning-stderr
