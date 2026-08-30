# Evals for the repository-wide low-value test audit.

AUDIT_SCRIPT="$REPO_ROOT/scripts/audit-tests.sh"

run_file_eval "$AUDIT_SCRIPT" "test audit script exists"
run_executable_eval "$AUDIT_SCRIPT" "test audit script is executable"

if [ -x "$AUDIT_SCRIPT" ]; then
  _audit_tmpdir=$(mktemp -d /tmp/test-audit-evals-XXXXXX)
  trap 'find "$_audit_tmpdir" -depth -delete 2>/dev/null || true' EXIT
  git -C "$_audit_tmpdir" init -q

  cat > "$_audit_tmpdir/package-metadata.test.ts" <<'EOF'
import { readFileSync } from "node:fs"

const packageJson = JSON.parse(readFileSync("package.json", "utf8"))
expect(packageJson.dependencies.react).toBe("19.1.1")
EOF

  _audit_output=$("$AUDIT_SCRIPT" "$_audit_tmpdir" 2>&1)
  _audit_exit=$?
  if [ "$_audit_exit" -eq 0 ] && echo "$_audit_output" | grep -qF "package-metadata.test.ts"; then
    echo "  PASS  audit reports declarative metadata assertions without blocking"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  audit reports declarative metadata assertions without blocking"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: audit reports declarative metadata assertions without blocking"
  fi

  cat > "$_audit_tmpdir/dependency-behavior.test.ts" <<'EOF'
import { expect, test } from "vitest"
import { parseISO } from "date-fns"

test("parses a date", () => {
  expect(parseISO("2026-08-30").getUTCFullYear()).toBe(2026)
})
EOF

  _audit_output=$("$AUDIT_SCRIPT" "$_audit_tmpdir" 2>&1)
  if echo "$_audit_output" | grep -qF "dependency-behavior.test.ts"; then
    echo "  FAIL  audit ignores behavior tests that use dependencies"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: audit ignores behavior tests that use dependencies"
  else
    echo "  PASS  audit ignores behavior tests that use dependencies"
    PASS=$((PASS + 1))
  fi

  cat > "$_audit_tmpdir/generated-manifest.test.ts" <<'EOF'
// allow: test-declarative-metadata public package.json is the generator contract
import { readFileSync } from "node:fs"

const packageJson = JSON.parse(readFileSync("package.json", "utf8"))
expect(packageJson.scripts.build).toBe("vite build")
EOF

  _audit_output=$("$AUDIT_SCRIPT" "$_audit_tmpdir" 2>&1)
  if echo "$_audit_output" | grep -qF "generated-manifest.test.ts"; then
    echo "  FAIL  audit honors public-output escape"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: audit honors public-output escape"
  else
    echo "  PASS  audit honors public-output escape"
    PASS=$((PASS + 1))
  fi

  find "$_audit_tmpdir" -depth -delete 2>/dev/null || true
  trap - EXIT
fi
