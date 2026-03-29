#!/bin/bash
set -euo pipefail

# Stop hook: run type checking and related tests before Claude finishes.
# Only runs if JS/TS files were actually changed.

changed_files=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(ts|tsx|js|jsx)$' || true)

if [ -z "$changed_files" ]; then
  exit 0
fi

# ── Type check (incremental for speed) ──────────────────────────
# tsgo/tsc cannot target single files — they need the full project graph.
# --incremental reuses .tsbuildinfo to skip unchanged modules.
output=""
exit_code=0
output=$(bun run type:check 2>&1) || exit_code=$?

if [ $exit_code -ne 0 ]; then
  truncated=$(echo "$output" | head -30)
  escaped=$(echo "$truncated" | jq -Rs .)
  echo "{\"decision\":\"block\",\"reason\":\"Type errors found. Fix before finishing:\\n\"$escaped\"\"}" >&2
  exit 2
fi

# ── Related tests (only tests affected by changed files) ────────
# Detect test runner: vitest (--related), jest (--findRelatedTests), bun test (file-only)
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
abs_changed=""
for f in $changed_files; do
  abs_changed="$abs_changed $repo_root/$f"
done

test_output=""
test_exit=0

if [ -f "$repo_root/node_modules/.bin/vitest" ]; then
  # Vitest: --related finds tests that transitively import changed files
  test_output=$(bun run test:related -- $abs_changed 2>&1) || test_exit=$?
elif [ -f "$repo_root/node_modules/.bin/jest" ]; then
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
  truncated=$(echo "$test_output" | head -30)
  escaped=$(echo "$truncated" | jq -Rs .)
  echo "{\"decision\":\"block\",\"reason\":\"Related tests failed. Fix before finishing:\\n\"$escaped\"\"}" >&2
  exit 2
fi

exit 0
