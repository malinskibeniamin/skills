# Evals for hooks created from PR audit analysis (2025-2026)

HOOKS_DIR="$REPO_ROOT/.claude/hooks"

# ══════════════════════════════════════════════════════════════════
# legacy-import-check + env-validation-check: retired, Biome owns them
# (noRestrictedImports / noRestrictedElements / noProcessEnv).
# Guard: the hooks stay dead and the Biome config carries the rules.
# ══════════════════════════════════════════════════════════════════

for _dead_hook in legacy-import-check env-validation-check; do
  if [ -e "$HOOKS_DIR/$_dead_hook.sh" ] || [ -e "$HOOKS_DIR/checks/$_dead_hook.lib.sh" ]; then
    echo "  FAIL  $_dead_hook resurrected — Biome owns these rules"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $_dead_hook resurrected"
  else
    echo "  PASS  $_dead_hook stays retired (Biome owns the rules)"
    PASS=$((PASS + 1))
  fi
done

_BIOME_REF="$REPO_ROOT/frontend-starter-kit/references/biome/REFERENCE.md"
run_content_eval "$_BIOME_REF" "@redpanda-data/ui" "Biome config bans @redpanda-data/ui (noRestrictedImports)"
run_content_eval "$_BIOME_REF" "lucide-react" "Biome config bans lucide-react (noRestrictedImports)"
run_content_eval "$_BIOME_REF" "noRestrictedElements" "Biome config bans raw elements (noRestrictedElements)"
run_content_eval "$_BIOME_REF" "noProcessEnv" "Biome config bans raw process.env (noProcessEnv)"

# ══════════════════════════════════════════════════════════════════
# test-convention-check.sh
# ══════════════════════════════════════════════════════════════════

run_file_eval "$HOOKS_DIR/test-convention-check.sh" "test-convention-check.sh exists"
run_executable_eval "$HOOKS_DIR/test-convention-check.sh" "test-convention-check.sh is executable"

run_content_eval "$HOOKS_DIR/checks/test-convention-check.lib.sh" "it.*.'" "test-convention detects it() pattern"
run_content_eval "$HOOKS_DIR/checks/test-convention-check.lib.sh" "jest" "test-convention detects jest.fn"
run_content_eval "$HOOKS_DIR/checks/test-convention-check.lib.sh" "toBeInTheDocument" "test-convention detects toBeInTheDocument"
run_content_eval "$HOOKS_DIR/checks/test-convention-check.lib.sh" "waitForTimeout" "test-convention detects waitForTimeout"
run_content_eval "$HOOKS_DIR/checks/test-convention-check.lib.sh" "test.skip" "test-convention detects test.skip"
run_content_eval "$HOOKS_DIR/checks/test-convention-check.lib.sh" "test-magic-timeout" "test-convention detects { timeout: <n> } magic number"
run_content_eval "$HOOKS_DIR/checks/test-convention-check.lib.sh" "test-unawaited" "test-convention detects unawaited findBy/waitFor"
run_content_eval "$HOOKS_DIR/checks/test-convention-check.lib.sh" "test-declarative-metadata" "test-convention detects declarative metadata assertions"

# ── Warn: it() in test file ─────────────────────────────────────

_tc_tmpdir=$(mktemp -d /tmp/test-conv-evals-XXXXXX)
tmpfile="$_tc_tmpdir/page.test.tsx"
printf "it('should render', () => {})\n" > "$tmpfile"
(cd "$_tc_tmpdir" && git init -q && git commit -q --allow-empty -m "init") 2>/dev/null

run_hook_eval "$HOOKS_DIR/test-convention-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "delegated to Biome: it() vs test() (useConsistentTestIt)"

# ── Warn: jest.fn() ─────────────────────────────────────────────

tmpfile="$_tc_tmpdir/mock.test.ts"
printf "const fn = jest.fn()\n" > "$tmpfile"

run_hook_eval "$HOOKS_DIR/test-convention-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: jest.fn() in test file" "Vitest"

# ── Skip: non-test file ─────────────────────────────────────────

tmpfile="$_tc_tmpdir/component.tsx"
printf "const x = 1\n" > "$tmpfile"

run_hook_eval "$HOOKS_DIR/test-convention-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "skip: non-test file"

# ── Warn: test.skip in E2E ──────────────────────────────────────

tmpfile="$_tc_tmpdir/login.spec.ts"
printf "test.skip('broken test', () => {})\n" > "$tmpfile"

run_hook_eval "$HOOKS_DIR/test-convention-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: test.skip in E2E file" "skip"

# ── Warn: { timeout: <n> } magic number ────────────────────────

tmpfile="$_tc_tmpdir/wait.test.tsx"
printf "await waitFor(() => expect(x).toBe(1), { timeout: 5000 })\n" > "$tmpfile"

run_hook_eval "$HOOKS_DIR/test-convention-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: { timeout: 5000 } magic number" "magic number"

# ── Warn: unawaited findByRole ─────────────────────────────────

tmpfile="$_tc_tmpdir/find.test.tsx"
printf "screen.findByRole('button')\n" > "$tmpfile"

run_hook_eval "$HOOKS_DIR/test-convention-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: unawaited findByRole" "missing await"

# ── Allow: awaited findByRole ──────────────────────────────────

tmpfile="$_tc_tmpdir/find-ok.test.tsx"
printf "const el = await screen.findByRole('button')\n" > "$tmpfile"

run_hook_eval "$HOOKS_DIR/test-convention-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: awaited findByRole"

# ── Warn: package metadata assertion ───────────────────────────

tmpfile="$_tc_tmpdir/package-metadata.test.ts"
cat > "$tmpfile" <<'EOF'
import { readFileSync } from "node:fs"

const packageJson = JSON.parse(readFileSync("package.json", "utf8"))
expect(packageJson.devDependencies.vitest).toBe("4.1.10")
EOF

run_hook_eval "$HOOKS_DIR/test-convention-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: package metadata assertion" "Declarative metadata"

# ── Allow: dependency behavior without manifest assertion ─────

tmpfile="$_tc_tmpdir/dependency-behavior.test.ts"
cat > "$tmpfile" <<'EOF'
import { expect, test } from "vitest"
import { parseISO } from "date-fns"

test("parses an ISO date", () => {
  expect(parseISO("2026-08-30").getUTCFullYear()).toBe(2026)
})
EOF

run_hook_eval "$HOOKS_DIR/test-convention-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: dependency behavior test"

# ── Allow: justified public manifest output ────────────────────

tmpfile="$_tc_tmpdir/generated-manifest.test.ts"
cat > "$tmpfile" <<'EOF'
// allow: test-declarative-metadata public package.json is the generator contract
import { readFileSync } from "node:fs"

const packageJson = JSON.parse(readFileSync("package.json", "utf8"))
expect(packageJson.scripts.build).toBe("vite build")
EOF

run_hook_eval "$HOOKS_DIR/test-convention-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: public manifest output escape"

(cd /tmp && rm -r "$_tc_tmpdir" 2>/dev/null) || true

# ══════════════════════════════════════════════════════════════════
# connect-query-check.sh
# ══════════════════════════════════════════════════════════════════

run_file_eval "$HOOKS_DIR/connect-query-check.sh" "connect-query-check.sh exists"
run_executable_eval "$HOOKS_DIR/connect-query-check.sh" "connect-query-check.sh is executable"

run_content_eval "$HOOKS_DIR/checks/connect-query-check.lib.sh" "ConnectError.from" "connect-error-format prescribes ConnectError.from"
run_content_eval "$HOOKS_DIR/checks/connect-query-check.lib.sh" "formatToastErrorMessageGRPC" "connect-error-format prescribes formatToastErrorMessageGRPC"
run_content_eval "$HOOKS_DIR/checks/connect-query-check.lib.sh" "onError" "connect-error-format checks for onError"

# console-log-check.sh REMOVED — covered by Biome noConsole rule

# ══════════════════════════════════════════════════════════════════
# form-mode-check.sh
# ══════════════════════════════════════════════════════════════════

run_file_eval "$HOOKS_DIR/form-mode-check.sh" "form-mode-check.sh exists"
run_executable_eval "$HOOKS_DIR/form-mode-check.sh" "form-mode-check.sh is executable"

run_content_eval "$HOOKS_DIR/checks/form-mode-check.lib.sh" "useWatch" "form-watch suggests useWatch"
run_content_eval "$HOOKS_DIR/checks/form-mode-check.lib.sh" "getValues.*snapshot" "form-watch distinguishes getValues snapshots"

# ══════════════════════════════════════════════════════════════════
# ts-no-escape-hatches-check.sh
# ══════════════════════════════════════════════════════════════════

run_file_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" "ts-no-escape-hatches-check.sh exists"
run_executable_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" "ts-no-escape-hatches-check.sh is executable"

run_content_eval "$HOOKS_DIR/checks/ts-no-escape-hatches-check.lib.sh" "as\s*never" "as-cast blocks as never"
run_content_eval "$HOOKS_DIR/checks/ts-no-escape-hatches-check.lib.sh" "as\s*any" "as-cast blocks as any"
run_content_eval "$HOOKS_DIR/checks/ts-no-escape-hatches-check.lib.sh" "hook_block" "as-cast uses hook_block for hard blocks"
run_content_eval "$HOOKS_DIR/checks/ts-no-escape-hatches-check.lib.sh" "type guard" "as-cast suggests type guards"

# ── Block: as never ──────────────────────────────────────────────

_ac_tmpdir=$(mktemp -d /tmp/as-cast-evals-XXXXXX)
tmpfile="$_ac_tmpdir/route.tsx"
printf "const x = foo as never\n" > "$tmpfile"
(cd "$_ac_tmpdir" && git init -q && git commit -q --allow-empty -m "init") 2>/dev/null

run_hook_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: as never" "never"

# ── Block: as any ────────────────────────────────────────────────

tmpfile="$_ac_tmpdir/route2.tsx"
printf "const x = foo as any\n" > "$tmpfile"

run_hook_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: as any" "any"

# ── Allow: as const ──────────────────────────────────────────────

tmpfile="$_ac_tmpdir/config.ts"
printf "const routes = ['/a', '/b'] as const\n" > "$tmpfile"

run_hook_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: as const"

(cd /tmp && rm -r "$_ac_tmpdir" 2>/dev/null) || true

# ══════════════════════════════════════════════════════════════════
# ══════════════════════════════════════════════════════════════════


# ══════════════════════════════════════════════════════════════════
# ══════════════════════════════════════════════════════════════════


# ══════════════════════════════════════════════════════════════════
# hooks.json wiring
# ══════════════════════════════════════════════════════════════════

run_content_eval "$REPO_ROOT/hooks/hooks.json" "post-tool-batch.sh" "hooks.json has PostToolBatch dispatcher"
run_content_eval "$REPO_ROOT/hooks/codex-hooks.json" "codex-edit-dispatch.sh" "codex-hooks.json uses one edit dispatcher"
run_content_eval "$REPO_ROOT/skill-manifest.json" "connect-query-check.sh" "edit dispatcher includes connect-query-check"
# console-log-check removed — Biome noConsole handles it
run_content_eval "$REPO_ROOT/skill-manifest.json" "form-mode-check.sh" "edit dispatcher includes form-mode-check"
run_content_eval "$REPO_ROOT/skill-manifest.json" "ts-no-escape-hatches-check.sh" "edit dispatcher includes ts-no-escape-hatches-check"
