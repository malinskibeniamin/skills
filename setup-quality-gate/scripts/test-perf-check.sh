#!/bin/bash
set -euo pipefail

# PostToolUse hook: detect test performance anti-patterns at edit time.

source "$(dirname "$0")/../../shared/hook-lib.sh" 2>/dev/null || true

hook_parse_edit_write
hook_skip_generated

# ── Route: test file checks vs vitest config checks ──────────────

case "$file_path" in
  *.test.ts|*.test.tsx|*.spec.ts|*.spec.tsx|*.integration.ts|*.integration.tsx)
    # ── Check 1: await import() in test files ──────────────────────
    hook_get_added_lines

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

exit 0
