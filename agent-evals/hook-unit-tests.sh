#!/bin/bash
set -euo pipefail

# Unit tests for hook scripts.
# Tests individual hooks by simulating tool input on stdin
# and checking exit code + stderr output.
#
# Usage: bash agent-evals/hook-unit-tests.sh

HOOKS_DIR="$(cd "$(dirname "$0")/../.claude/hooks" && pwd)"
PASS=0
FAIL=0
SKIP=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Test helpers
_hooktest_created_list=""

_setup_session() {
  export CLAUDE_SESSION_ID="test-$$-$(date +%s)"
  _session_dir="/tmp/hook-session-${CLAUDE_SESSION_ID}"
  mkdir -p "$_session_dir"
  _hooktest_created_list="$_session_dir/test-created-files"
  : > "$_hooktest_created_list"
}

_teardown_session() {
  rm -rf "$_session_dir" 2>/dev/null || true
  _hooktest_created_list=""
  unset CLAUDE_SESSION_ID
}

_setup_test_file() {
  local path="$1"
  local content="$2"
  mkdir -p "$(dirname "$path")"
  # Never clobber uncommitted work (issue #60 P2 -- this helper family
  # destroyed real files): a tracked file dirty vs HEAD is an in-progress
  # edit; an untracked file we did not create is someone's data (cleanup
  # would classify it absent-from-HEAD and DELETE it). Tracked-clean files
  # are fine -- cleanup restores them from HEAD.
  if [ -e "$path" ] && ! grep -qxF "$path" "$_hooktest_created_list" 2>/dev/null; then
    if git ls-files --error-unmatch "$path" >/dev/null 2>&1; then
      if ! git diff --quiet HEAD -- "$path" 2>/dev/null; then
        echo "REFUSING to overwrite dirty tracked file: $path" >&2
        exit 1
      fi
    else
      echo "REFUSING to overwrite pre-existing untracked file: $path" >&2
      exit 1
    fi
  fi
  echo "$path" >> "$_hooktest_created_list" 2>/dev/null || true
  echo "$content" > "$path"
  git add "$path" 2>/dev/null || true
}

_cleanup_test_file() {
  local path="$1"
  # Tracked at HEAD: restore the committed content (checkout HEAD, not the
  # index -- setup's git add put the fixture in the index) and keep the
  # file. Created by the test: unstage and remove. Never checkout-then-rm
  # -- that deleted tracked files after "restoring" them.
  local rel
  rel=$(git ls-files --full-name -- "$path" 2>/dev/null | head -1 || true)
  if [ -n "$rel" ] && git cat-file -e "HEAD:$rel" 2>/dev/null; then
    git checkout HEAD -- "$path" 2>/dev/null || true
  else
    git rm --cached -q -f "$path" 2>/dev/null || true
    rm -f "$path" 2>/dev/null || true
  fi
}

_run_hook() {
  local hook="$1"
  local input="$2"
  local stderr_file="/tmp/hook-test-stderr-$$"
  local stdout_file="/tmp/hook-test-stdout-$$"
  local exit_code=0
  echo "$input" | bash "$HOOKS_DIR/$hook" >"$stdout_file" 2>"$stderr_file" || exit_code=$?
  _last_stderr=$(cat "$stderr_file")
  _last_stdout=$(cat "$stdout_file")
  _last_exit=$exit_code
  rm -f "$stderr_file" "$stdout_file"
}

_assert_exit() {
  local expected="$1"
  local test_name="$2"
  if [ "$_last_exit" -eq "$expected" ]; then
    PASS=$((PASS + 1))
    echo -e "  ${GREEN}✓${NC} $test_name"
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}✗${NC} $test_name (expected exit $expected, got $_last_exit)"
    [ -n "$_last_stderr" ] && echo "    stderr: $_last_stderr"
  fi
}

_assert_stderr_contains() {
  local pattern="$1"
  local test_name="$2"
  if echo "$_last_stderr" | grep -qE "$pattern"; then
    PASS=$((PASS + 1))
    echo -e "  ${GREEN}✓${NC} $test_name"
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}✗${NC} $test_name (stderr missing pattern: $pattern)"
    echo "    stderr: $_last_stderr"
  fi
}

_assert_stdout_contains() {
  local pattern="$1"
  local test_name="$2"
  if echo "$_last_stdout" | grep -qE "$pattern"; then
    PASS=$((PASS + 1))
    echo -e "  ${GREEN}✓${NC} $test_name"
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}✗${NC} $test_name (stdout missing pattern: $pattern)"
    echo "    stdout: $_last_stdout"
  fi
}

_skip() {
  local test_name="$1"
  local reason="$2"
  SKIP=$((SKIP + 1))
  echo -e "  ${YELLOW}○${NC} $test_name ($reason)"
}

# ═══════════════════════════════════════════════════════════════
echo "━━━ enforce-toolchain.sh ━━━"
# ═══════════════════════════════════════════════════════════════

echo "  npm → bun rewrite:"
_run_hook "enforce-toolchain.sh" '{"tool_name":"Bash","tool_input":{"command":"npm install express"}}'
_assert_exit 2 "npm install denied"
_assert_stderr_contains "bun install express" "stderr includes exact bun replacement"

echo "  npx → bunx rewrite:"
_run_hook "enforce-toolchain.sh" '{"tool_name":"Bash","tool_input":{"command":"npx vitest run"}}'
_assert_exit 2 "npx vitest denied"
_assert_stderr_contains "bunx vitest run" "stderr includes exact bunx replacement"

echo "  tsgo → tsc rewrite:"
_run_hook "enforce-toolchain.sh" '{"tool_name":"Bash","tool_input":{"command":"tsgo --noEmit"}}'
_assert_exit 2 "tsgo denied"
_assert_stderr_contains "TypeScript 7 Go compiler" "stderr explains tsc is the Go compiler"
_assert_stderr_contains "tsc --noEmit" "stderr includes exact tsc replacement"

_run_hook "enforce-toolchain.sh" '{"tool_name":"Bash","tool_input":{"command":"tsc --noEmit"}}'
_assert_exit 0 "tsc allowed"

echo "  sleep ban:"
_run_hook "enforce-toolchain.sh" '{"tool_name":"Bash","tool_input":{"command":"sleep 5"}}'
_assert_exit 2 "sleep 5 denied"
_assert_stderr_contains "sleep banned" "stderr mentions sleep banned"

_run_hook "enforce-toolchain.sh" '{"tool_name":"Bash","tool_input":{"command":"sleep 60 && gh pr checks 123"}}'
_assert_exit 2 "sleep in chain denied"

echo "  allowed commands pass:"
_run_hook "enforce-toolchain.sh" '{"tool_name":"Bash","tool_input":{"command":"bun run lint:fix"}}'
_assert_exit 0 "bun run lint:fix allowed"

_run_hook "enforce-toolchain.sh" '{"tool_name":"Bash","tool_input":{"command":"git push -u origin feat/test"}}'
_assert_exit 0 "git push allowed"

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ conventional-commits-check.sh ━━━"
# ═══════════════════════════════════════════════════════════════

echo "  scoped commit (should pass):"
_run_hook "conventional-commits-check.sh" '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat(hooks): add quality gate\""}}'
_assert_exit 0 "feat(hooks): passes"

echo "  scopeless commit in heredoc (was crashing, now properly denies):"
_run_hook "conventional-commits-check.sh" '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"docs: add lifecycle documentation\""}}'
# Bug was: script crashed (exit 1) instead of clean deny (exit 2).
# Now it properly denies with "Missing scope" message.
_assert_exit 2 "scopeless commit properly denied (not crashed)"
_assert_stderr_contains "Missing scope" "clean deny message instead of crash"

echo "  missing scope (should deny):"
_run_hook "conventional-commits-check.sh" '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat: add feature\""}}'
_assert_exit 2 "feat: without scope denied"
_assert_stderr_contains "Missing scope" "stderr says missing scope"

echo "  non-commit command (should pass through):"
_run_hook "conventional-commits-check.sh" '{"tool_name":"Bash","tool_input":{"command":"git status"}}'
_assert_exit 0 "non-commit passes through"

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ form-mode-check.sh (advisory subscription guidance) ━━━"
# ═══════════════════════════════════════════════════════════════

_setup_session
_test_file="/tmp/hook-test-form-$$.tsx"
_setup_test_file "$_test_file" "import { useForm } from 'react-hook-form';
const MyForm = () => {
  const form = useForm({ resolver: zodResolver(schema) });
  const val = form.watch('field');
  return <FormMessage>{val}</FormMessage>;
};"

echo "  form.watch() in react-hook-form file:"
_run_hook "form-mode-check.sh" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$_test_file\"}}"
_assert_exit 0 "form.watch() is advisory"
_assert_stdout_contains "\\[nudge\\].*useWatch" "message suggests localized useWatch"
_assert_stdout_contains "getValues.*snapshot" "message distinguishes event-time snapshots"

_cleanup_test_file "$_test_file"
_teardown_session

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ vendor-file-check.sh (new) ━━━"
# ═══════════════════════════════════════════════════════════════

_setup_session

echo "  edit to redpanda-ui/ path:"
_run_hook "vendor-file-check.sh" '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/project/redpanda-ui/button.tsx","old_string":"x","new_string":"y"}}'
_assert_exit 2 "redpanda-ui edit blocked"
_assert_stderr_contains "vendor.*registry|CLI-installed" "message mentions vendor/registry"

echo "  edit to normal path:"
_run_hook "vendor-file-check.sh" '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/project/src/components/MyButton.tsx","old_string":"x","new_string":"y"}}'
_assert_exit 0 "normal path allowed"

echo "  Go file in vendor/ (should NOT fire — backend scope):"
_run_hook "vendor-file-check.sh" '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/project/vendor/github.com/pkg/errors/errors.go","old_string":"x","new_string":"y"}}'
_assert_exit 0 "Go vendor file — not our concern"

echo "  Python file (should NOT fire):"
_run_hook "vendor-file-check.sh" '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/project/vendor/lib/utils.py","old_string":"x","new_string":"y"}}'
_assert_exit 0 "Python vendor file — not our concern"

_teardown_session

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ query-pattern-check.sh (new) ━━━"
# ═══════════════════════════════════════════════════════════════

_setup_session
_test_file="/tmp/hook-test-mutation-$$.tsx"
_setup_test_file "$_test_file" "import { useMutation } from '@tanstack/react-query';
const MyComponent = () => {
  const deleteMutation = useMutation({ mutationFn: deleteItem });
  const handleClick = () => deleteMutation.mutate({ id: 1 });
  return <button onClick={handleClick}>Delete</button>;
};"

echo "  mutate() without onError:"
_content=$(jq -Rs . < "$_test_file")
_run_hook "query-pattern-check.sh" "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$_test_file\",\"content\":$_content}}"
_assert_exit 2 "mutate without onError blocked"
_assert_stderr_contains "onError" "message mentions onError"

_cleanup_test_file "$_test_file"

_test_file2="/tmp/hook-test-mutation2-$$.tsx"
_setup_test_file "$_test_file2" "import { useMutation } from '@tanstack/react-query';
const MyComponent = () => {
  const deleteMutation = useMutation({
    mutationFn: deleteItem,
    onError: (error) => toast.error(error.message),
  });
  const handleClick = () => deleteMutation.mutate({ id: 1 });
  return <button onClick={handleClick}>Delete</button>;
};"

echo "  mutate() with onError:"
_run_hook "query-pattern-check.sh" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$_test_file2\",\"old_string\":\"x\",\"new_string\":\"y\"}}"
_assert_exit 0 "mutate with onError allowed"

_cleanup_test_file "$_test_file2"
_teardown_session

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ ts-no-escape-hatches-check.sh (absorbed checks) ━━━"
# ═══════════════════════════════════════════════════════════════

_setup_session
_test_file="/tmp/hook-test-cast-$$.ts"
_setup_test_file "$_test_file" "const x = foo as any;"

echo "  as any:"
_content=$(jq -Rs . < "$_test_file")
_run_hook "ts-no-escape-hatches-check.sh" "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$_test_file\",\"content\":$_content}}"
_assert_exit 2 "as any blocked"

_cleanup_test_file "$_test_file"

_test_file2="/tmp/hook-test-tsignore-$$.ts"
_setup_test_file "$_test_file2" "// @ts-ignore
const x = foo;"

echo "  @ts-ignore:"
_content=$(jq -Rs . < "$_test_file2")
_run_hook "ts-no-escape-hatches-check.sh" "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$_test_file2\",\"content\":$_content}}"
_assert_exit 2 "@ts-ignore blocked"

_cleanup_test_file "$_test_file2"

_test_file3="/tmp/hook-test-tsexpect-$$.ts"
_setup_test_file "$_test_file3" "// @ts-expect-error
const x = foo;"

echo "  @ts-expect-error:"
_content=$(jq -Rs . < "$_test_file3")
_run_hook "ts-no-escape-hatches-check.sh" "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$_test_file3\",\"content\":$_content}}"
_assert_exit 2 "@ts-expect-error blocked"

_cleanup_test_file "$_test_file3"
_teardown_session

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ edit-loop-check.sh (new) ━━━"
# ═══════════════════════════════════════════════════════════════

_setup_session
_test_file="/tmp/hook-test-loop-$$.tsx"
_setup_test_file "$_test_file" "const x = 1;"

echo "  first 11 edits (no warn):"
for i in $(seq 1 11); do
  _run_hook "edit-loop-check.sh" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$_test_file\"}}"
done
_assert_exit 0 "11th edit — no warn yet"

echo "  12th edit (should warn):"
_run_hook "edit-loop-check.sh" "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$_test_file\"}}"
_assert_stdout_contains "12 times" "12th edit triggers warning"

_cleanup_test_file "$_test_file"
_teardown_session

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ consecutive-failure-check.sh (new) ━━━"
# ═══════════════════════════════════════════════════════════════

_setup_session

echo "  first lint failure (no inject):"
_run_hook "consecutive-failure-check.sh" '{"tool_name":"Bash","tool_input":{"command":"bun run lint"},"tool_result":{"exit_code":1}}'
_assert_exit 0 "1st failure — no message"

echo "  second lint failure (no inject):"
_run_hook "consecutive-failure-check.sh" '{"tool_name":"Bash","tool_input":{"command":"bun run lint:fix"},"tool_result":{"exit_code":1}}'
_assert_exit 0 "2nd failure — no message yet"

echo "  third lint failure (should inject):"
_run_hook "consecutive-failure-check.sh" '{"tool_name":"Bash","tool_input":{"command":"bun run lint"},"tool_result":{"exit_code":1}}'
_assert_stdout_contains "failed.*3x|Fix ALL" "3rd consecutive failure triggers guidance"

echo "  lint success (resets counter):"
_run_hook "consecutive-failure-check.sh" '{"tool_name":"Bash","tool_input":{"command":"bun run lint"},"tool_result":{"exit_code":0}}'
_assert_exit 0 "success resets counter"

_teardown_session

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ quality-gate-stop.sh (new aggregator) ━━━"
# ═══════════════════════════════════════════════════════════════

_setup_session

echo "  no findings (should pass):"
_run_hook "quality-gate-stop.sh" ""
_assert_exit 0 "no findings — allows through"

echo "  with findings (should block):"
printf 'Type errors: 3 new\n---\n' >> "/tmp/hook-session-${CLAUDE_SESSION_ID}/stop-findings"
printf 'Biome: 2 unfixable\n---\n' >> "/tmp/hook-session-${CLAUDE_SESSION_ID}/stop-findings"
_run_hook "quality-gate-stop.sh" ""
_assert_exit 2 "findings present — blocks"
_assert_stderr_contains "2 issue" "reports correct count"
_assert_stderr_contains "Type errors" "includes type error finding"
_assert_stderr_contains "Biome" "includes biome finding"

_teardown_session

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ session-env.sh (skills repo excluded) ━━━"
# ═══════════════════════════════════════════════════════════════

echo "  skills repo (no package.json warning):"
cd "$(git rev-parse --show-toplevel)"
_run_hook "session-env.sh" ""
if echo "$_last_stderr" | grep -q "No package.json"; then
  FAIL=$((FAIL + 1))
  echo -e "  ${RED}✗${NC} skills repo still shows package.json warning"
else
  PASS=$((PASS + 1))
  echo -e "  ${GREEN}✓${NC} skills repo — no false warning"
fi

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}, ${YELLOW}${SKIP} skipped${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
