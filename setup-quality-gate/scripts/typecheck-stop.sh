#!/bin/bash
set -eo pipefail

# Stop hook: run type checking and related tests before Claude finishes.
# Only runs if JS/TS files were actually changed.

# Ensure session directory exists for state tracking
_session_dir="/tmp/hook-session-${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}"
mkdir -p "$_session_dir" 2>/dev/null || true

changed_files=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(ts|tsx|js|jsx)$' || true)

if [ -z "$changed_files" ]; then
  exit 0
fi

# Skip if project doesn't have a type:check script
if [ ! -f "package.json" ] || ! jq -e '.scripts["type:check"]' package.json >/dev/null 2>&1; then
  exit 0
fi

# ── Consecutive failure tracking ─────────────────────────────────
# After 2 consecutive blocks, downgrade to warn so the agent isn't stuck
# in a loop (e.g., pre-existing errors, errors from another LLM session).
_fail_counter="$_session_dir/typecheck-fail-count"
_fail_count=0
if [ -f "$_fail_counter" ]; then
  _fail_count=$(cat "$_fail_counter" 2>/dev/null || echo "0")
fi

# ── Type check (incremental for speed) ──────────────────────────
# tsgo/tsc cannot target single files — they need the full project graph.
# --incremental reuses .tsbuildinfo to skip unchanged modules.
output=""
exit_code=0
output=$(bun run type:check 2>&1) || exit_code=$?

if [ $exit_code -ne 0 ]; then
  _fail_count=$((_fail_count + 1))
  echo "$_fail_count" > "$_fail_counter"
  truncated=$(echo "$output" | head -30)
  escaped=$(echo "$truncated" | jq -Rs .)

  if [ "$_fail_count" -ge 3 ]; then
    # Downgrade: errors persisted across 3 attempts — likely pre-existing or from another session
    echo "{\"decision\":\"allow\",\"reason\":\"Type errors still present after $_fail_count attempts (may be pre-existing). Allowing finish:\\n\"$escaped\"\"}" >&2
    echo "typecheck FAIL (allowed after $_fail_count attempts)" > "$_session_dir/last-stop" 2>/dev/null || true
    exit 0
  fi

  echo "{\"decision\":\"block\",\"reason\":\"Type errors found. Fix before finishing:\\n\"$escaped\"\"}" >&2
  echo "typecheck FAIL" > "$_session_dir/last-stop" 2>/dev/null || true
  exit 2
fi

# Reset counter on success
echo "0" > "$_fail_counter" 2>/dev/null || true

# ── Related tests (only tests affected by changed files) ────────
# Detect test runner: vitest (--related), jest (--findRelatedTests), bun test (file-only)
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
abs_changed=""
for f in $changed_files; do
  abs_changed="$abs_changed $repo_root/$f"
done

test_output=""
test_exit=0

if [ -f "node_modules/.bin/vitest" ] || [ -f "$repo_root/node_modules/.bin/vitest" ]; then
  # Vitest: --related finds tests that transitively import changed files
  # Check cwd first (monorepo app), then repo root
  test_output=$(bun run test:related -- $abs_changed 2>&1) || test_exit=$?
elif [ -f "node_modules/.bin/jest" ] || [ -f "$repo_root/node_modules/.bin/jest" ]; then
  # Jest: --findRelatedTests does the same
  test_output=$(npx jest --findRelatedTests $abs_changed --passWithNoTests 2>&1) || test_exit=$?
else
  # Bun test or unknown: find co-located test files for changed source files
  test_files=""
  for f in $changed_files; do
    base="${f%.*}"
    ext="${f##*.}"
    for suffix in test spec; do
      candidate="$repo_root/${base}.${suffix}.${ext}"
      [ -f "$candidate" ] && test_files="$test_files $candidate"
    done
  done
  if [ -n "$test_files" ]; then
    test_output=$(bun test $test_files 2>&1) || test_exit=$?
  fi
fi

if [ $test_exit -ne 0 ] && [ -n "$test_output" ]; then
  _test_fail_counter="$_session_dir/test-fail-count"
  _test_fail_count=0
  if [ -f "$_test_fail_counter" ]; then
    _test_fail_count=$(cat "$_test_fail_counter" 2>/dev/null || echo "0")
  fi
  _test_fail_count=$((_test_fail_count + 1))
  echo "$_test_fail_count" > "$_test_fail_counter"
  truncated=$(echo "$test_output" | head -30)
  escaped=$(echo "$truncated" | jq -Rs .)

  if [ "$_test_fail_count" -ge 3 ]; then
    echo "{\"decision\":\"allow\",\"reason\":\"Tests still failing after $_test_fail_count attempts (may be pre-existing). Allowing finish:\\n\"$escaped\"\"}" >&2
    echo "typecheck PASS, tests FAIL (allowed after $_test_fail_count attempts)" > "$_session_dir/last-stop" 2>/dev/null || true
    exit 0
  fi

  echo "{\"decision\":\"block\",\"reason\":\"Related tests failed. Fix before finishing:\\n\"$escaped\"\"}" >&2
  echo "typecheck PASS, tests FAIL" > "$_session_dir/last-stop" 2>/dev/null || true
  exit 2
fi

# Reset counters on full success
echo "0" > "$_session_dir/test-fail-count" 2>/dev/null || true

# Write success outcome for UserPromptSubmit full-level context
echo "typecheck PASS, tests PASS" > "$_session_dir/last-stop" 2>/dev/null || true

exit 0
