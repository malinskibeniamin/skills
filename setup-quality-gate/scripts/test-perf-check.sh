#!/bin/bash
set -euo pipefail

# PostToolUse hook: detect test performance anti-patterns at edit time.
#
# Checks:
# 1. await import() in test files — use static imports (saves ~100ms per test)
# 2. vitest config missing pool: 'threads' — threads have less spawn overhead than forks
# 3. unit vitest config missing isolate: false — pure-logic tests can share context

source "$(dirname "$0")/../../shared/hook-lib.sh" 2>/dev/null || true

hook_parse_edit_write
hook_skip_generated

# ── Route: test file checks vs vitest config checks ──────────────

case "$file_path" in
  *.test.ts|*.test.tsx|*.spec.ts|*.spec.tsx|*.integration.ts|*.integration.tsx)
    # ── Check 1: await import() in test files ──────────────────────
    # Dynamic imports add ~100ms per call in tests. Use static imports
    # unless the test specifically needs lazy/conditional loading.
    hook_get_added_lines

    dynamic_imports=$(echo "$added_lines" | grep -E 'await\s+import\(' || true)

    if [ -n "$dynamic_imports" ]; then
      # Exclude legitimate uses: vi.importActual, vi.importMock, import.meta
      filtered=$(echo "$dynamic_imports" | grep -vE 'vi\.(importActual|importMock)|import\.meta' || true)

      if [ -n "$filtered" ]; then
        sample=$(echo "$filtered" | head -3 | sed 's/^+//' | tr '\n' ' ')
        hook_warn "PERF: await import() in test file adds ~100ms per call. Use static imports unless you need lazy/conditional loading. Found: $sample" "test-perf-dynamic-import"
      fi
    fi

    # ── Check: it.concurrent + isolate: false is unsafe ───────────
    # Concurrent tests sharing a single thread context will race on
    # mutable state. Warn when both are detected together.
    concurrent_usage=$(echo "$added_lines" | grep -E '\.concurrent' || true)

    if [ -n "$concurrent_usage" ]; then
      # Find nearest vitest config (same dir or parent dirs)
      config_dir=$(dirname "$file_path")
      vitest_config=""
      while [ "$config_dir" != "/" ]; do
        for cfg in "$config_dir"/vitest.config.*; do
          [ -f "$cfg" ] && vitest_config="$cfg" && break 2
        done
        config_dir=$(dirname "$config_dir")
      done

      if [ -n "$vitest_config" ] && grep -qE "isolate.*false" "$vitest_config" 2>/dev/null; then
        hook_warn "PERF: it.concurrent + isolate: false is unsafe. Concurrent tests sharing a single thread context will race on mutable state. Remove isolate: false or drop .concurrent." "test-perf-concurrent-isolate"
      fi
    fi
    ;;

  */vitest.config.*|vitest.config.*)
    # ── Check 2: missing pool: 'threads' ───────────────────────────
    # Worker threads have less spawn overhead than forks (the default).
    # Import times drop ~30% with threads.
    if ! grep -qE "pool.*['\"]threads['\"]|pool.*:.*['\"]threads['\"]" "$file_path" 2>/dev/null; then
      hook_warn "PERF: vitest config missing pool: 'threads'. Worker threads have ~30% less import overhead than forks (the default). Add pool: 'threads' to test config." "test-perf-missing-threads"
    fi

    # ── Check 3: unit config missing isolate: false ────────────────
    # Pure-logic tests (.test.ts, node env) don't need per-file isolation.
    # Only suggest for unit configs (not integration/happy-dom/jsdom).
    is_unit_config=false

    # Detect unit config: no browser environment OR includes only .test.ts
    if ! grep -qE "environment.*['\"]happy-dom['\"]|environment.*['\"]jsdom['\"]" "$file_path" 2>/dev/null; then
      is_unit_config=true
    fi

    if [ "$is_unit_config" = true ]; then
      if ! grep -qE "isolate.*false" "$file_path" 2>/dev/null; then
        hook_warn "PERF: unit vitest config missing isolate: false. Pure-logic tests (.test.ts) can safely share a single thread context. Saves per-file isolation overhead." "test-perf-missing-isolate"
      fi
    fi
    ;;
esac

exit 0
