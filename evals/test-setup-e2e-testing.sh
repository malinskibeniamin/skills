# Evals for setup-e2e-testing skill

SKILL_DIR="$REPO_ROOT/e2e-testing"
ROUTE_SIBLING_SCRIPT="$REPO_ROOT/e2e-testing/scripts/route-sibling-test-check.sh"
STRUCTURAL_TEST_SCRIPT="$REPO_ROOT/e2e-testing/scripts/structural-test-nudge-check.sh"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/SETUP.md" "SETUP.md exists"
run_file_eval "$SKILL_DIR/SOAK-TESTING.md" "SOAK-TESTING.md exists"

# ── SKILL.md content (auto-loaded, edit-time guidance) ──────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: e2e-testing" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "Test IDs|getByTestId" "SKILL.md has test ID conventions"
run_content_eval "$SKILL_DIR/SKILL.md" "getByRole" "SKILL.md has selector priority"
run_content_eval "$SKILL_DIR/SKILL.md" "agent-browser|Playwright" "SKILL.md mentions test tools"
run_content_eval "$SKILL_DIR/SKILL.md" "route sibling" "SKILL.md mentions route sibling tests"
run_content_eval "$SKILL_DIR/SKILL.md" "structural refactor" "SKILL.md mentions structural refactor test nudge"
run_content_eval "$SKILL_DIR/SKILL.md" "fake timers.*E2E|E2E.*fake timers" "SKILL.md separates timer contracts from E2E outcomes"
run_content_eval "$SKILL_DIR/SKILL.md" "SOAK-TESTING" "SKILL.md routes long-lived SPA risks to soak guidance"
run_content_eval "$SKILL_DIR/SOAK-TESTING.md" "round trip" "soak guidance requires a round-trip flow"
run_content_eval "$SKILL_DIR/SOAK-TESTING.md" "positive control" "soak guidance calibrates with a positive control"
run_content_eval "$SKILL_DIR/SOAK-TESTING.md" "multiple checkpoints|three.*checkpoint" "soak guidance samples multiple checkpoints"
run_content_eval "$SKILL_DIR/SOAK-TESTING.md" "timer-only|timers.*counter" "soak guidance covers timer-only counter blind spots"
run_content_eval "$SKILL_DIR/SOAK-TESTING.md" "fixed.*allowance|fixed.*budget" "soak guidance uses calibrated fixed thresholds"
run_content_eval "$SKILL_DIR/SOAK-TESTING.md" "heap snapshot|MemLab" "soak guidance includes leak localization"

# ── SETUP.md content (one-time setup, not auto-loaded) ──────────

run_content_eval "$SKILL_DIR/SETUP.md" "playwright/test" "SETUP has Playwright install"
run_content_eval "$SKILL_DIR/SETUP.md" "GenericContainer" "SETUP has Testcontainers setup"
run_content_eval "$SKILL_DIR/SETUP.md" "AxeBuilder" "SETUP has axe-core fixture"


_e2e_tmpdir=$(mktemp -d /tmp/e2e-route-hook-XXXXXX)
mkdir -p "$_e2e_tmpdir/src/routes" "$_e2e_tmpdir/bin"
cat > "$_e2e_tmpdir/bin/vitest" << 'EOF'
#!/bin/bash
echo "$*" > "$ROUTE_SIBLING_TEST_CAPTURE"
exit "${ROUTE_SIBLING_TEST_EXIT:-0}"
EOF
chmod +x "$_e2e_tmpdir/bin/vitest"
route_file="$_e2e_tmpdir/src/routes/users.page.tsx"
test_file="$_e2e_tmpdir/src/routes/users.browser.test.tsx"
printf "export function UsersPage() { return <div /> }\n" > "$route_file"
printf "test('users page', () => {})\n" > "$test_file"
capture="$_e2e_tmpdir/capture.txt"

actual_exit=0
(
  cd "$_e2e_tmpdir"
  PATH="$_e2e_tmpdir/bin:$PATH" ROUTE_SIBLING_TEST_CAPTURE="$capture" \
    "$ROUTE_SIBLING_SCRIPT"
) > /tmp/e2e-route-stdout 2> /tmp/e2e-route-stderr <<JSON || actual_exit=$?
{"tool_name":"Write","tool_input":{"file_path":"$route_file"}}
JSON

if [ "$actual_exit" -eq 0 ] && grep -q "users.browser.test.tsx" "$capture" 2>/dev/null; then
  echo "  PASS  route sibling hook runs browser test for .page.tsx route"
  PASS=$((PASS + 1))
else
  echo "  FAIL  route sibling hook did not run browser test"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: route sibling hook did not run browser test"
fi

actual_exit=0
(
  cd "$_e2e_tmpdir"
  PATH="$_e2e_tmpdir/bin:$PATH" ROUTE_SIBLING_TEST_CAPTURE="$capture" ROUTE_SIBLING_TEST_EXIT=1 \
    "$ROUTE_SIBLING_SCRIPT"
) > /tmp/e2e-route-stdout 2> /tmp/e2e-route-stderr <<JSON || actual_exit=$?
{"tool_name":"Write","tool_input":{"file_path":"$route_file"}}
JSON

if [ "$actual_exit" -eq 2 ] && grep -q "Sibling route test failed" /tmp/e2e-route-stderr; then
  echo "  PASS  route sibling hook blocks failing sibling test"
  PASS=$((PASS + 1))
else
  echo "  FAIL  route sibling hook did not block failing sibling test"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: route sibling hook did not block failing sibling test"
fi


rm -f "$test_file"
actual_exit=0
"$STRUCTURAL_TEST_SCRIPT" > /tmp/e2e-structural-stdout 2> /tmp/e2e-structural-stderr <<JSON || actual_exit=$?
{"tool_name":"Write","tool_input":{"file_path":"$route_file"}}
JSON

if [ "$actual_exit" -eq 2 ] && grep -q "Structural refactor without test" /tmp/e2e-structural-stderr; then
  echo "  PASS  structural test hook blocks new page without test"
  PASS=$((PASS + 1))
else
  echo "  FAIL  structural test hook did not block new page without test"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: structural test hook did not block new page without test"
fi

printf "test('users page', () => {})\n" > "$test_file"
actual_exit=0
"$STRUCTURAL_TEST_SCRIPT" > /tmp/e2e-structural-stdout 2> /tmp/e2e-structural-stderr <<JSON || actual_exit=$?
{"tool_name":"Write","tool_input":{"file_path":"$route_file"}}
JSON

if [ "$actual_exit" -eq 0 ] && ! grep -q "Structural refactor without test" /tmp/e2e-structural-stderr; then
  echo "  PASS  structural test hook allows new page with sibling test"
  PASS=$((PASS + 1))
else
  echo "  FAIL  structural test hook warned despite sibling test"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: structural test hook warned despite sibling test"
fi

rm -rf "$_e2e_tmpdir" /tmp/e2e-route-stdout /tmp/e2e-route-stderr /tmp/e2e-structural-stdout /tmp/e2e-structural-stderr

# ── Description length ──────────────────────────────────────────

desc=$(grep '^description:' "$SKILL_DIR/SKILL.md" | sed 's/^description: //')
desc_len=${#desc}
if [ $desc_len -le 250 ]; then
  echo "  PASS  description under 250 chars ($desc_len)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  description over 250 chars ($desc_len)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: description over 250 chars ($desc_len)"
fi

# ── Line count ──────────────────────────────────────────────────

line_count=$(wc -l < "$SKILL_DIR/SKILL.md" | tr -d ' ')
if [ "$line_count" -le 100 ]; then
  echo "  PASS  SKILL.md under 100 lines ($line_count)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  SKILL.md over 100 lines ($line_count)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: SKILL.md over 100 lines ($line_count)"
fi
