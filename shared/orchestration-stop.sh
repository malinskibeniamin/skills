#!/bin/bash
set -euo pipefail

# Stop hook: comprehensive quality gate. Reads file categories tracked by
# orchestration-guidance.sh and runs targeted checks. Blocks until truly done.

session_files="/tmp/claude-session-files-${CLAUDE_SESSION_ID:-$$}"
changed=$(git diff --name-only HEAD 2>/dev/null || true)
issues=""

if [ -z "$changed" ] && [ ! -f "$session_files" ]; then
  exit 0
fi

# ── Gate 1: Test files changed → check for async leaks ──────────

if [ -f "$session_files" ] && grep -q "^test:" "$session_files" 2>/dev/null; then
  test_files=$(grep "^test:" "$session_files" | cut -d: -f2- | sort -u | tr '\n' ' ')

  # Check for async leaks if vitest available
  if [ -f "node_modules/.bin/vitest" ] && [ -n "$test_files" ]; then
    leak_output=""
    leak_exit=0
    leak_output=$(bun run test -- --run --detectAsyncLeaks $test_files 2>&1) || leak_exit=$?
    if [ $leak_exit -ne 0 ] && echo "$leak_output" | grep -qiE 'leak|open handle|did not exit'; then
      issues="$issues\n- ASYNC LEAK in test files. Run: bun test --run --detectAsyncLeaks to diagnose."
    fi
  fi
fi

# ── Gate 2: JSX/TSX source changed → verify co-located test ─────

if [ -f "$session_files" ] && grep -q "^jsx:" "$session_files" 2>/dev/null; then
  jsx_files=$(grep "^jsx:" "$session_files" | cut -d: -f2- | sort -u)
  for f in $jsx_files; do
    # Skip files that don't need tests
    if echo "$f" | grep -qE '(index\.|layout\.|middleware\.|types/|\.d\.ts|__root|\.gen\.)'; then
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
      issues="$issues\n- MISSING TEST: $short_name has no co-located test. Add a test file before finishing."
    fi
  done
fi

# ── Gate 3: New source files → verify they have tests ────────────

new_files=$(git diff --name-only --diff-filter=A HEAD 2>/dev/null | grep -E '\.(ts|tsx)$' | grep -vE '(\.test\.|\.spec\.|\.unit\.|\.integration\.|\.d\.ts$|\.gen\.|index\.|layout\.|middleware\.|types/|__root)' || true)
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
      issues="$issues\n- NEW FILE WITHOUT TEST: $short_name — add a test before finishing."
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

if [ -n "$issues" ]; then
  escaped=$(printf '%b' "$issues" | head -20 | jq -Rs .)
  echo "{\"decision\":\"block\",\"reason\":\"Quality gate: fix before finishing:\\n\"$escaped\"\"}" >&2
  exit 2
fi

# Clean up session tracking
rm -f "$session_files" 2>/dev/null || true

exit 0
