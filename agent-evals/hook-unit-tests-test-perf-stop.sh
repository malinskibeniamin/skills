#!/bin/bash
# test-perf-stop.sh: async-leak detection reports only handles a test can close.

source "$(dirname "$0")/hook-test-helpers.sh"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║          test-perf-stop Tests                            ║"
echo "╚═══════════════════════════════════════════════════════════╝"

# vitest --detectAsyncLeaks lists a CustomGC entry whenever a suite loads a
# native addon (@rspack/binding via @rstest/core, for example). That handle
# lives for the process and no test can close it, so it is not a leak.
# Every case runs against both shipped copies of the hook.
_PERF_HOOKS="
$HOOKS_DIR/test-perf-stop.sh
$REPO_ROOT/frontend-starter-kit/references/quality-gate/scripts/test-perf-stop.sh
"

_leak_run() {
  local root="$1"
  local hook="$2"
  local fixture="${3:-}"
  local stderr_file="/tmp/hook-test-stderr-$$-$RANDOM"
  local stdout_file="/tmp/hook-test-stdout-$$-$RANDOM"
  local exit_code=0
  ( cd "$root" && echo "" | LEAK_FIXTURE="$fixture" bash "$hook" >"$stdout_file" 2>"$stderr_file" ) || exit_code=$?
  _last_stderr=$(cat "$stderr_file")
  _last_stdout=$(cat "$stdout_file")
  _last_exit=$exit_code
  rm -f "$stderr_file" "$stdout_file"
}

_leak_repo() {
  local root
  root=$(mktemp -d /tmp/hook-test-perf-XXXXXX)
  ( cd "$root" && git init -q . && git -c user.email=t@t -c user.name=t commit -q --allow-empty -m init )
  echo "$root"
}

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ leak filtering (stubbed vitest output) ━━━"
# ═══════════════════════════════════════════════════════════════

_stub_root=$(_leak_repo)
mkdir -p "$_stub_root/node_modules/.bin"
cat > "$_stub_root/node_modules/.bin/vitest" <<'STUB'
#!/bin/bash
cat "$LEAK_FIXTURE"
STUB
chmod +x "$_stub_root/node_modules/.bin/vitest"
echo "test('x', () => undefined);" > "$_stub_root/widget.test.ts"

_customgc_only="$_stub_root/customgc-only.txt"
cat > "$_customgc_only" <<'OUT'
⎯⎯⎯⎯⎯⎯⎯ Async Leaks 2 ⎯⎯⎯⎯⎯⎯⎯

CustomGC leaking in src/a.integration.test.tsx
 ❯ requireNative node_modules/@rspack/binding/binding.js:165:16

CustomGC leaking in src/b.integration.test.tsx
 ❯ requireNative node_modules/@rspack/binding/binding.js:165:16
OUT

_mixed="$_stub_root/mixed.txt"
cat > "$_mixed" <<'OUT'
⎯⎯⎯⎯⎯⎯⎯ Async Leaks 2 ⎯⎯⎯⎯⎯⎯⎯

CustomGC leaking in src/a.integration.test.tsx
 ❯ requireNative node_modules/@rspack/binding/binding.js:165:16

Timeout leaking in src/widget.test.ts
 ❯ src/widget.test.ts:1:34
OUT

_esc=$(printf '\033')
_colored="$_stub_root/colored.txt"
{
  printf '%s[31m⎯⎯⎯⎯⎯⎯⎯%s[39m%s[1m%s[41m Async Leaks 2 %s[49m\n\n' "$_esc" "$_esc" "$_esc" "$_esc" "$_esc"
  printf '%s[31mCustomGC leaking in src/a.integration.test.tsx%s[39m\n\n' "$_esc" "$_esc"
  printf '%s[31mTimeout leaking in src/widget.test.ts%s[39m\n' "$_esc" "$_esc"
} > "$_colored"

for _hook in $_PERF_HOOKS; do
  _label="${_hook#"$REPO_ROOT"/}"
  _setup_session

  echo "  [$_label] CustomGC entries only → no leak report:"
  _leak_run "$_stub_root" "$_hook" "$_customgc_only"
  _assert_exit 0 "hook exits cleanly"
  _assert_stdout_not_contains "Async leak detected" "CustomGC is not reported as a leak"

  echo "  [$_label] real handle beside CustomGC → reported without the noise:"
  _leak_run "$_stub_root" "$_hook" "$_mixed"
  _assert_stdout_contains "Async leak detected" "real leak still reported"
  _assert_stdout_contains "Timeout leaking in src/widget.test.ts" "names the leaking handle and file"
  _assert_stdout_not_contains "CustomGC" "omits CustomGC entries"

  echo "  [$_label] colored output (vitest under CI) → still parsed:"
  _leak_run "$_stub_root" "$_hook" "$_colored"
  _assert_stdout_contains "Timeout leaking in src/widget.test.ts" "names the leak despite ANSI codes"
  _assert_stdout_not_contains "CustomGC" "still omits colored CustomGC entries"

  _teardown_session
done

rm -rf "$_stub_root"

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━ leak detection contract (real vitest) ━━━"
# Pins the vitest output format the filter parses. A vitest upgrade that
# renames "<Kind> leaking in <file>" fails here instead of silently hiding
# real leaks. The native addon is lightningcss, which vite always installs.
# ═══════════════════════════════════════════════════════════════

_real_vitest="$REPO_ROOT/node_modules/.bin/vitest"
if [ ! -x "$_real_vitest" ]; then
  if [ -n "${CI:-}" ]; then
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}✗${NC} real vitest missing in CI (run bun install before this suite)"
  else
    _skip "real vitest contract" "no node_modules; run bun install"
  fi
else
  _real_root() {
    local root
    root=$(_leak_repo)
    ln -s "$REPO_ROOT/node_modules" "$root/node_modules"
    echo "export default { test: { globals: true } };" > "$root/vitest.config.ts"
    echo "$root"
  }

  _native_root=$(_real_root)
  cat > "$_native_root/native.test.ts" <<'EOF'
import { createRequire } from 'node:module';
const fromHere = createRequire(import.meta.url);
const fromVitest = createRequire(fromHere.resolve('vitest/package.json'));
const fromVite = createRequire(fromVitest.resolve('vite/package.json'));
test('loads a native addon', () => {
  expect(typeof fromVite('lightningcss').transform).toBe('function');
});
EOF

  _timer_root=$(_real_root)
  cat > "$_timer_root/timer.test.ts" <<'EOF'
test('leaves a timer running', () => {
  setInterval(() => undefined, 1000);
  expect(1).toBe(1);
});
EOF

  _vitest_leaks=$(cd "$_native_root" && ./node_modules/.bin/vitest run --detectAsyncLeaks 2>&1 || true)
  if echo "$_vitest_leaks" | sed "s/${_esc}\[[0-9;]*m//g" | grep -q '^CustomGC leaking in native.test.ts'; then
    PASS=$((PASS + 1))
    echo -e "  ${GREEN}✓${NC} fixture: vitest reports CustomGC for a native addon"
  else
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}✗${NC} fixture: vitest no longer reports CustomGC for a native addon"
    echo "$_vitest_leaks" | grep -iE 'leak|Tests|Error' | head -5 | sed 's/^/    /'
  fi

  for _hook in $_PERF_HOOKS; do
    _label="${_hook#"$REPO_ROOT"/}"

    _setup_session
    echo "  [$_label] native addon only → no leak report:"
    _leak_run "$_native_root" "$_hook"
    _assert_stdout_not_contains "Async leak detected" "native addon load is not a leak"
    _teardown_session

    _setup_session
    echo "  [$_label] leaked timer → reported by name:"
    _leak_run "$_timer_root" "$_hook"
    _assert_stdout_contains "Async leak detected" "leaked timer reported"
    _assert_stdout_contains "Timeout leaking in timer.test.ts" "names the timer and file"
    _teardown_session
  done

  rm -f "$_native_root/node_modules" "$_timer_root/node_modules"
  rm -rf "$_native_root" "$_timer_root"
fi

# ═══════════════════════════════════════════════════════════════

_report_results "test-perf-stop Tests"
