#!/bin/bash
# Extracted check logic for test-convention-check.sh. Source ../_hook-lib.sh before this file.

run_test_convention_check() {
case "$file_path" in
  */vitest.config.*|vitest.config.*) ;;  # allow vitest config files (any ext)
  *) hook_filter_extensions "ts|tsx" || return 0 ;;
esac
hook_skip_generated || return 0

added_lines="$(
  set +e
  hook_get_added_lines
  _status=$?
  if [ "$_status" -eq 0 ]; then
    printf '%s' "$added_lines"
  fi
  return 0
)"

# ── Gate: only test files ────────────────────────────────────────
_is_test_file=false
case "$file_path" in
  *.test.*|*.spec.*|*.integration.*) _is_test_file=true ;;
  */__tests__/*) _is_test_file=true ;;
esac

if [ "$_is_test_file" = true ] && [ -n "$added_lines" ]; then

# it() vs test() -- Biome useConsistentTestIt owns this rule.

# ── Check 2: jest.fn() should be vi.fn() ────────────────────────

if echo "$added_lines" | grep -qE 'jest\.(fn|mock|spyOn|clearAllMocks|restoreAllMocks)\b'; then
  hook_warn "Use vi.fn()/vi.mock()/vi.spyOn() — project uses Vitest not Jest." "test-convention-jest"
fi

# ── Check 3: .toBeInTheDocument() → .toBeVisible() ──────────────
# toBeVisible is stricter — also checks element isn't hidden/obstructed.

if echo "$added_lines" | grep -qE '\.toBeInTheDocument\(\)'; then
  if ! hook_has_escape "to-be-in-document"; then
    hook_warn "Prefer .toBeVisible() over .toBeInTheDocument() — verifies element is actually visible, not just in DOM. Escape: // allow: to-be-in-document [reason]" "test-convention-visible"
  fi
fi

# waitForTimeout -- Biome noPlaywrightWaitForTimeout owns this rule.

# ── Check 5: test.skip in E2E files ─────────────────────────────
# E2E tests should hard fail, not skip. Missing env = CI config issue.

case "$file_path" in
  *.spec.*|*e2e*|*playwright*)
    if echo "$added_lines" | grep -qE '\b(test|it)\.skip\b'; then
      hook_warn "No test.skip in E2E tests. If env/credentials missing, fail loudly so CI catches it. Use test.fixme() with linked GitHub issue for known bugs." "test-convention-skip"
    fi
    ;;
esac

# ── Check 7: literal timeout: in test option objects ────────────
# Hardcoded `{ timeout: <ms> }` in waitFor/findBy/expect.poll/page.*
# is a magic number — brittle if the operation gets slower over time.
# Prefer condition-based assertion or framework default timeout.

if echo "$added_lines" | grep -qE '\btimeout:\s*[0-9]+'; then
  if ! hook_has_escape "test-magic-timeout"; then
    hook_warn "Hardcoded { timeout: <ms> } in test — magic number, brittle as code slows. Prefer condition-based waitFor/expect.poll with default timeout. Escape: // allow: test-magic-timeout [reason]" "test-convention-magic-timeout"
  fi
fi

# ── Check 8: findBy*/waitFor without await ──────────────────────
# Both return Promises. Missing await leads to flaky tests, unhandled
# rejections, and assertions that pass before the DOM settles.

unawaited=$(echo "$added_lines" | grep -E '(findBy[A-Z][A-Za-z]*|\bwaitFor)\(' | grep -vE '\b(await|return)\b' | grep -vE '^\+?\s*(//|\*)' || true)
if [ -n "$unawaited" ]; then
  if ! hook_has_escape "test-unawaited"; then
    sample=$(echo "$unawaited" | head -2 | sed 's/^+//' | tr '\n' ' ')
    hook_warn "findBy*/waitFor returns Promise — missing await is flaky. Found: $sample Escape: // allow: test-unawaited [reason]" "test-convention-unawaited"
  fi
fi

# ── Check 6: data-testid reminder for interactive elements ───────
# Advisory only — remind when creating new interactive components.

case "$file_path" in
  *.test.tsx|*.spec.tsx|*.integration.tsx)
    if echo "$added_lines" | grep -qE 'getByRole\('; then
      # Count getByRole usage in added lines
      _role_count=$(echo "$added_lines" | grep -c 'getByRole\(' || echo "0")
      _role_count=$(echo "$_role_count" | tr -d '[:space:]')
      if [ "${_role_count:-0}" -gt 5 ]; then
        # Session-scoped: only warn once
        _marker="$_hook_session_dir/testid-reminded"
        if [ ! -f "$_marker" ]; then
          touch "$_marker"
          hook_warn "Heavy getByRole usage (${_role_count}x). Consider adding data-testid for faster, more stable selectors." "test-convention-testid"
        fi
      fi
    fi
    ;;
esac

fi

# ── absorbed from test-perf-check.sh (4.28 family consolidation) ──
# PostToolUse hook: detect test performance anti-patterns at edit time.

# ── Route: test file checks vs vitest config checks ──────────────

case "$file_path" in
  *.test.ts|*.test.tsx|*.spec.ts|*.spec.tsx|*.integration.ts|*.integration.tsx)
    if [ -n "$added_lines" ]; then
      # ── Check 1: await import() in test files ──────────────────────

      dynamic_imports=$(echo "$added_lines" | grep -E 'await\s+import\(' || true)

      if [ -n "$dynamic_imports" ]; then
        filtered=$(echo "$dynamic_imports" | grep -vE 'vi\.(importActual|importMock)|import\.meta' || true)

        if [ -n "$filtered" ]; then
          sample=$(echo "$filtered" | head -3 | sed 's/^+//' | tr '\n' ' ')
          hook_warn "PERF: await import() in test +~100ms/call. Use static imports. Found: $sample" "test-perf-dynamic-import"
        fi
      fi

      # ── Check: userEvent.type() is slow in integration tests ──────
      type_usage=$(echo "$added_lines" | grep -E 'user(Event)?\.type\(' || true)

      if [ -n "$type_usage" ]; then
        sample=$(echo "$type_usage" | head -2 | sed 's/^+//' | tr '\n' ' ')
        hook_warn "PERF: userEvent.type() fires per-keystroke (~50ms/char). Use user.clear()+user.paste() or fireEvent.change(). Found: $sample" "test-perf-user-type"
      fi

      # ── Check: setInterval in test files = open handle / leak ────
      # Even with cleanup, raw setInterval is fragile. Prefer
      # vi.useFakeTimers() + vi.advanceTimersByTime() so the test is
      # deterministic and the handle can't escape teardown.
      interval_usage=$(echo "$added_lines" | grep -E '\bsetInterval\(' || true)

      if [ -n "$interval_usage" ]; then
        if ! hook_has_escape "test-set-interval"; then
          hook_warn "LEAK: setInterval in test = open handle. Use vi.useFakeTimers() + vi.advanceTimersByTime(), or guarantee clearInterval in cleanup. Escape: // allow: test-set-interval [reason]" "test-perf-set-interval"
        fi
      fi

      # ── Check: it.concurrent + isolate: false is unsafe ───────────
      concurrent_usage=$(echo "$added_lines" | grep -E '\.concurrent' || true)

      if [ -n "$concurrent_usage" ]; then
        config_dir=$(dirname "$file_path")
        vitest_config=""
        while [ "$config_dir" != "/" ]; do
          for cfg in "$config_dir"/vitest.config.*; do
            [ -f "$cfg" ] && vitest_config="$cfg" && break 2
          done
          config_dir=$(dirname "$config_dir")
        done

        if [ -n "$vitest_config" ] && grep -qE "isolate.*false" "$vitest_config" 2>/dev/null; then
          hook_warn "PERF: it.concurrent + isolate:false unsafe. Shared context → race conditions." "test-perf-concurrent-isolate"
        fi
      fi
    fi
    ;;

  */vitest.config.*|vitest.config.*)
    # ── Check 2: missing pool: 'threads' ───────────────────────────
    if ! grep -qE "pool.*['\"]threads['\"]|pool.*:.*['\"]threads['\"]" "$file_path" 2>/dev/null; then
      hook_warn "PERF: Add pool:'threads' to vitest config. ~30% less import overhead than forks." "test-perf-missing-threads"
    fi

    # ── Check 3: unit config missing isolate: false ────────────────
    is_unit_config=false

    if ! grep -qE "environment.*['\"]happy-dom['\"]|environment.*['\"]jsdom['\"]" "$file_path" 2>/dev/null; then
      is_unit_config=true
    fi

    if [ "$is_unit_config" = true ]; then
      if ! grep -qE "isolate.*false" "$file_path" 2>/dev/null; then
        hook_warn "PERF: Unit config missing isolate:false. Pure-logic tests can share thread context." "test-perf-missing-isolate"
      fi
    fi
    ;;
esac

return 0
}
