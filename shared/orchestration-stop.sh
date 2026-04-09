#!/bin/bash
set -eo pipefail

# Stop hook: comprehensive quality gate. Reads file categories tracked by
# orchestration-guidance.sh and runs targeted checks. Blocks until truly done.
#
# Set ORCHESTRATION_STRICT=0 to disable blocking (e.g., during prototyping).
# Default: on (blocks on missing tests, security issues, async leaks).

if [ "${ORCHESTRATION_STRICT:-1}" = "0" ]; then
  exit 0
fi

session_files="/tmp/hook-session-${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}/files"

# Source hook-lib for session-scoped file tracking
source "$(dirname "$0")/hook-lib.sh" 2>/dev/null || true

# Session-scoped: only check files this session touched
if type hook_session_changed_files &>/dev/null; then
  changed=$(hook_session_changed_files)
else
  changed=$(git diff --name-only HEAD 2>/dev/null || true)
fi
issues=""

# Pre-flight checks
if [ ! -d ".git" ]; then exit 0; fi
if [ -z "$changed" ] && [ ! -f "$session_files" ]; then
  exit 0
fi

# Check if typecheck-stop already ran related tests (avoid double-running)
stop_outcome_file="/tmp/hook-session-${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}/last-stop"
typecheck_ran_tests=false
if [ -f "$stop_outcome_file" ] && grep -q "tests PASS\|tests FAIL" "$stop_outcome_file" 2>/dev/null; then
  typecheck_ran_tests=true
fi

# ── Gate 1: Test files changed → check for async leaks ──────────

if [ -f "$session_files" ] && grep -q "^test:" "$session_files" 2>/dev/null; then
  test_files=$(grep "^test:" "$session_files" | cut -d: -f2- | sort -u | tr '\n' ' ')

  # Check for async leaks if vitest + bun available
  if [ -f "node_modules/.bin/vitest" ] && [ -n "$test_files" ] && command -v bun &>/dev/null; then
    leak_output=""
    leak_exit=0
    leak_output=$(bun run test -- --run --detectAsyncLeaks $test_files 2>&1) || leak_exit=$?
    if [ $leak_exit -ne 0 ] && echo "$leak_output" | grep -qiE 'leak|open handle|did not exit'; then
      issues="$issues\n- ASYNC LEAK in test files. Run: bun test --run --detectAsyncLeaks to diagnose."
    fi
  fi
fi

# ── Gate 1b: Run related tests (Bazel-style — only affected tests) ────

if [ "$typecheck_ran_tests" = false ] && [ -n "$changed" ]; then
  changed_source=$(echo "$changed" | grep -E '\.(ts|tsx|js|jsx)$' | grep -vE '(\.test\.|\.spec\.|\.unit\.|\.integration\.|\.d\.ts$|\.gen\.)' || true)
  if [ -n "$changed_source" ] && [ -f "node_modules/.bin/vitest" ] && command -v bun &>/dev/null; then
    test_exit=0
    test_output=$(bun test --run --related $changed_source 2>&1) || test_exit=$?
    if [ $test_exit -ne 0 ]; then
      truncated=$(echo "$test_output" | tail -10)
      issues="$issues\n- TESTS FAILING: Related tests do not pass. Fix before finishing.\n  $truncated"
    fi
  fi
fi

# ── Gate 2: JSX/TSX source changed → verify co-located test ─────

if [ -f "$session_files" ] && grep -q "^jsx:" "$session_files" 2>/dev/null; then
  jsx_files=$(grep "^jsx:" "$session_files" | cut -d: -f2- | sort -u)
  for f in $jsx_files; do
    # Skip files that don't need tests
    if echo "$f" | grep -qE '(index\.|layout\.|middleware\.|types/|\.d\.ts|__root|\.gen\.|providers?\.|constants?\.|theme\.|context\.|config\.)'; then
      continue
    fi
    base="${f%.*}"
    has_test=false
    for suffix in test.tsx test.ts integration.tsx unit.ts spec.ts; do
      if [ -f "${base}.${suffix}" ]; then
        has_test=true
        break
      fi
    done
    if [ "$has_test" = false ]; then
      short_name=$(basename "$f")
      # Warn, not block — prototyping often creates files before tests
      warnings="${warnings:-}\n- MISSING TEST: $short_name has no co-located test. Use /tdd to add one."
    fi
  done
fi

# ── Gate 3: New source files → verify they have tests ────────────

# Session-scoped: only consider new files this session created
_all_new=$(git diff --name-only --diff-filter=A HEAD 2>/dev/null | grep -E '\.(ts|tsx)$' | grep -vE '(\.test\.|\.spec\.|\.unit\.|\.integration\.|\.d\.ts$|\.gen\.|index\.|layout\.|middleware\.|types/|__root)' || true)
if hook_has_session_tracking 2>/dev/null && [ -n "$_all_new" ]; then
  # Intersect new files with session-touched files
  _touched="$_hook_session_dir/session-touched-files"
  if [ -f "$_touched" ]; then
    _repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    _touched_norm=$(sed "s|^${_repo_root}/||" "$_touched" | sort -u)
    new_files=$(comm -12 <(echo "$_all_new" | sort) <(echo "$_touched_norm") 2>/dev/null || echo "$_all_new")
  else
    new_files="$_all_new"
  fi
else
  new_files="$_all_new"
fi
if [ -n "$new_files" ]; then
  for f in $new_files; do
    base="${f%.*}"
    has_test=false
    for suffix in test.tsx test.ts integration.tsx unit.ts spec.ts; do
      if [ -f "${base}.${suffix}" ] || echo "$changed" | grep -q "${base}.${suffix}"; then
        has_test=true
        break
      fi
    done
    if [ "$has_test" = false ]; then
      short_name=$(basename "$f")
      warnings="${warnings:-}\n- NEW FILE WITHOUT TEST: $short_name — use /tdd to add a test."
    fi
  done
fi

# ── Gate 4: Security-sensitive files → extra scrutiny ────────────

if [ -f "$session_files" ] && grep -q "^security:" "$session_files" 2>/dev/null; then
  security_files=$(grep "^security:" "$session_files" | cut -d: -f2- | sort -u)
  for f in $security_files; do
    if [ -f "$f" ]; then
      if grep -qE '(eval\(|new Function\(|dangerouslySetInnerHTML|\.innerHTML\s*=)' "$f" 2>/dev/null; then
        if ! grep -qE '(allow-dangerouslySetInnerHTML|allow-eval)' "$f" 2>/dev/null; then
          short_name=$(basename "$f")
          issues="$issues\n- SECURITY: $short_name contains dangerous patterns (eval/innerHTML). Add escape hatch comment or fix."
        fi
      fi
      if grep -qE "(password|secret|api.?key)\s*[:=]\s*['\"][^'\"]{3,}" "$f" 2>/dev/null; then
        short_name=$(basename "$f")
        issues="$issues\n- SECURITY: $short_name may contain hardcoded secrets. Use env validation (@/env) instead."
      fi
    fi
  done
fi

# ── Decision ─────────────────────────────────────────────────────

# Hard issues (async leaks, security, failing tests) → block
if [ -n "$issues" ]; then
  escaped=$(printf '%b' "$issues" | head -20 | jq -Rs .)
  echo "{\"decision\":\"block\",\"reason\":\"Quality gate: fix before finishing:\\n\"$escaped\"\"}" >&2
  exit 2
fi

# Check if source changed but no test files were touched
changed_source_count=$(echo "$changed" | grep -cE '\.(ts|tsx|js|jsx)$' | grep -vcE '(\.test\.|\.spec\.)' 2>/dev/null || echo "0")
changed_test_count=$(echo "$changed" | grep -cE '\.(test|spec)\.(ts|tsx|js|jsx)$' 2>/dev/null || echo "0")
if [ "${changed_source_count:-0}" -gt 0 ] && [ "${changed_test_count:-0}" -eq 0 ]; then
  warnings="${warnings:-}\n- No test files were modified. Were all tests considered? Use /tdd to add coverage."
fi

# Soft warnings (missing tests) → inform but don't block
if [ -n "${warnings:-}" ]; then
  escaped=$(printf '%b' "$warnings" | head -10 | jq -Rs .)
  echo "{\"hookSpecificOutput\":{\"additionalContext\":\"Quality suggestions (non-blocking):\\n\"$escaped\"\"}}" >&2
fi

# Clean up session tracking
rm -f "$session_files" 2>/dev/null || true

exit 0
