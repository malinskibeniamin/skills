#!/bin/bash
# Extracted check logic for test-convention-check.sh. Source ../_hook-lib.sh before this file.

source "$(dirname "${BASH_SOURCE[0]}")/declarative-metadata-test.lib.sh"

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

# ── Declarative repository metadata is not behavior ────────────

if declarative_metadata_test_detect "$file_content" "$added_lines"; then
  hook_warn "Declarative metadata assertion: package.json and lockfile dependency names, scripts, or exact versions restate repository configuration. Test observable behavior or enforce the invariant with the package manager, schema, policy, or lint. Escape only for a public generated manifest: // allow: test-declarative-metadata [reason]" "test-convention-declarative-metadata"
fi

# ── Browser visual assertions: use the Browser Mode matcher ─────

case "$file_path" in
  *.browser.test.*)
    if printf '%s\n' "$added_lines" | grep -qE 'toMatchSnapshot[[:space:]]*\('; then
      _browser_visual_snapshots() {
        if command -v perl >/dev/null 2>&1; then perl -0pe 's{/\*.*?\*/}{}gs'; else cat; fi |
          grep -vE '^[[:space:]]*//' | tr '\n' ' ' | grep -oE 'expect[[:space:]]*\([[:space:]]*(page|element)[[:space:]]*\)[[:space:]]*\.[[:space:]]*toMatchSnapshot[[:space:]]*\(' || true
      }
      _current_browser_snapshots=$(printf '%s' "$file_content" | _browser_visual_snapshots)
      _head_browser_snapshots=""
      _repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
      case "$file_path" in
        "$_repo_root"/*)
          _head_content=$(git show "HEAD:${file_path#"$_repo_root"/}" 2>/dev/null || true)
          _head_browser_snapshots=$(printf '%s' "$_head_content" | _browser_visual_snapshots)
          ;;
      esac
      _current_count=$(printf '%s\n' "$_current_browser_snapshots" | grep -c . || true)
      _head_count=$(printf '%s\n' "$_head_browser_snapshots" | grep -c . || true)
      if [ "${_current_count:-0}" -gt "${_head_count:-0}" ]; then
        hook_block_strict "Browser visual assertions must use toMatchScreenshot(), not toMatchSnapshot()." "test-convention-browser-snapshot"
      fi
    fi
    ;;
esac

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

# ── e2e discipline pack (spec files only) ─────────────────────────
case "$file_path" in
  *.spec.ts|*.spec.tsx)
    # force-clicks paper over obstructed elements — the obstruction is the bug.
    if echo "$added_lines" | grep -qE 'force\s*:\s*true'; then
      if ! hook_has_escape "force-click"; then
        hook_warn "force:true click — if the element needs forcing, something obstructs it and users hit the same wall. Fix the obstruction or wait for the right state. Escape: // allow: force-click [reason]" "e2e-force-click"
      fi
    fi
    # expect.soft inside toPass polls nothing — soft failures never retry the block.
    if echo "$added_lines" | grep -qE 'expect\.soft\(' && echo "$file_content" | grep -qE '\.toPass\('; then
      hook_warn "expect.soft inside a toPass block is a silent no-op wait — soft failures do not fail the retry block. Use hard expect inside toPass." "e2e-soft-topass"
    fi
    # Version-pinned RPC route matchers break on API version bumps.
    if echo "$added_lines" | grep -qE 'route\([^)]*v1(alpha|beta)[0-9]*'; then
      hook_warn "page.route matcher pins the RPC version (v1alpha/v1beta) — the spec breaks on the next version bump. Match on Service/Method only." "e2e-versioned-route"
    fi
    ;;
esac

# ── Check: proto fixture version must match the component under test ──
# A v1beta2 fixture cast into a v1-typed prop passes type-check but tests
# the wrong shape — invisible to CI until production.

case "$file_path" in
  *.test.ts|*.test.tsx)
    _pb_versions=$(echo "$file_content" | grep -oE "from\s+['\"][^'\"]*/(v1(alpha|beta)?[0-9]*)/[^'\"]*_pb" | grep -oE 'v1(alpha|beta)?[0-9]*' | sort -u || true)
    _pb_version_count=$(printf '%s\n' "$_pb_versions" | grep -c . || true)
    if [ "${_pb_version_count:-0}" -gt 1 ]; then
      if ! hook_has_escape "fixture-proto-version"; then
        hook_warn "Test imports _pb types from multiple API versions ($(echo "$_pb_versions" | tr '\n' ' ')). Fixtures must use the SAME proto version as the component under test — mixed versions test the wrong shape and CI can't see it. Escape: // allow: fixture-proto-version [reason]" "fixture-proto-version"
      fi
    fi
    ;;
esac

return 0
}
