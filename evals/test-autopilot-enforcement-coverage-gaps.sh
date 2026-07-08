# Evals for coverage gap hooks: biome-ignore, route-visual-test, hook-location,
# mutation-side-effect, field-mask, connect-error — hooks that lacked eval coverage.

HOOKS_DIR="$REPO_ROOT/.claude/hooks"

# ══════════════════════════════════════════════════════════════════
# ts-no-escape-hatches-check.sh
# ══════════════════════════════════════════════════════════════════

run_file_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" "ts-no-escape-hatches-check.sh exists"
run_executable_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" "ts-no-escape-hatches-check.sh is executable"

# ── Script content ──────────────────────────────────────────────

run_content_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" "noExplicitAny" "biome-ignore still calls out noExplicitAny"
run_content_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" "hook_block" "biome-ignore hard-blocks lint suppressions"
run_content_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" "ts-ignore|ts-expect-error" "biome-ignore documents ts-ignore ownership"
run_content_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" "No lint suppression" "biome-ignore has no escape-hatch messaging"
run_content_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" "LLMs" "biome-ignore mentions LLM copy risk"

# ── Block: biome-ignore noExplicitAny ────────────────────────────

_bi_tmpdir=$(mktemp -d /tmp/biome-ignore-evals-XXXXXX)
tmpfile="$_bi_tmpdir/test.tsx"
printf '// biome-ignore lint/suspicious/noExplicitAny: complex type\nconst x: unknown = {}\n' > "$tmpfile"
(cd "$_bi_tmpdir" && git init -q && git add . && git commit -q -m "init" && \
  printf '+// biome-ignore lint/suspicious/noExplicitAny: complex type\n+const x: unknown = {}\n' > "$tmpfile") 2>/dev/null

run_hook_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: biome-ignore noExplicitAny" "noExplicitAny"

# ── Block: any other biome-ignore ────────────────────────────────

tmpfile="$_bi_tmpdir/test2.tsx"
printf '// biome-ignore lint/a11y/noAriaUnsupported: legacy\n' > "$tmpfile"
(cd "$_bi_tmpdir" && git add . && git commit -q -m "init2" && \
  printf '+// biome-ignore lint/a11y/noAriaUnsupported: legacy\n' > "$tmpfile") 2>/dev/null

run_hook_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: other biome-ignore" "No lint suppression"

# Note: @ts-ignore/@ts-expect-error handling moved to ts-no-escape-hatches-check.sh (block, exit 2)
# in 2.2.x. See evals/test-setup-react-rules.sh for the block test. ts-no-escape-hatches-check.sh
# intentionally skips @ts-ignore to avoid duplicate enforcement.

# ── Allow: clean code ────────────────────────────────────────────

tmpfile="$_bi_tmpdir/clean.tsx"
printf 'const x: string = "hello"\n' > "$tmpfile"
(cd "$_bi_tmpdir" && git add . && git commit -q -m "init4" && \
  printf '+const x: string = "hello"\n' > "$tmpfile") 2>/dev/null

run_hook_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: clean code with no ignores"

# ── Block: old escape hatch is not honored ───────────────────────

tmpfile="$_bi_tmpdir/escaped.tsx"
printf '// allow: lint-ignore third-party types are untyped\n// biome-ignore lint/correctness/noUndeclaredVariables: untyped lib\n' > "$tmpfile"
(cd "$_bi_tmpdir" && git add . && git commit -q -m "init5" && \
  printf '+// allow: lint-ignore third-party types are untyped\n+// biome-ignore lint/correctness/noUndeclaredVariables: untyped lib\n' > "$tmpfile") 2>/dev/null

run_hook_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: biome-ignore despite escape hatch" "No lint suppression"

# ── Skip: non-JS/TS files ───────────────────────────────────────

run_hook_eval "$HOOKS_DIR/ts-no-escape-hatches-check.sh" \
  '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.md"}}' \
  0 "skip: non-JS/TS file"

rm -rf "$_bi_tmpdir"

# ══════════════════════════════════════════════════════════════════
# ══════════════════════════════════════════════════════════════════


# ── Script content ──────────────────────────────────────────────


# ── Skip: non-route file ────────────────────────────────────────

_rvt_tmpdir=$(mktemp -d /tmp/route-visual-evals-XXXXXX)
tmpfile="$_rvt_tmpdir/component.tsx"
printf 'export function Button() { return <button /> }\n' > "$tmpfile"


# ── Skip: test file in routes ────────────────────────────────────

mkdir -p "$_rvt_tmpdir/routes"
tmpfile="$_rvt_tmpdir/routes/index.test.tsx"
printf 'test("renders", () => {})\n' > "$tmpfile"


# ── Skip: layout/root route ──────────────────────────────────────

tmpfile="$_rvt_tmpdir/routes/__root.tsx"
printf 'export const Route = createRootRoute({})\n' > "$tmpfile"


rm -rf "$_rvt_tmpdir"

# ══════════════════════════════════════════════════════════════════
# tanstack-router-check.sh
# ══════════════════════════════════════════════════════════════════

run_file_eval "$HOOKS_DIR/tanstack-router-check.sh" "tanstack-router-check.sh exists"
run_executable_eval "$HOOKS_DIR/tanstack-router-check.sh" "tanstack-router-check.sh is executable"

# ── Script content ──────────────────────────────────────────────

run_content_eval "$HOOKS_DIR/tanstack-router-check.sh" "function.*use.A-Z" "hook-location detects function useX pattern"
run_content_eval "$HOOKS_DIR/tanstack-router-check.sh" "const.*use.A-Z" "hook-location detects const useX arrow pattern"
run_content_eval "$HOOKS_DIR/tanstack-router-check.sh" "hook_warn" "hook-location uses hook_warn (advisory)"
run_content_eval "$HOOKS_DIR/tanstack-router-check.sh" "/hooks/" "hook-location prescribes /hooks/ directory"

# ── Warn: function hook in route file ────────────────────────────

_hl_tmpdir=$(mktemp -d /tmp/hook-loc-evals-XXXXXX)
mkdir -p "$_hl_tmpdir/routes"
tmpfile="$_hl_tmpdir/routes/users.tsx"
printf 'function useUserData() { return {} }\n' > "$tmpfile"
(cd "$_hl_tmpdir" && git init -q && git add . && git commit -q -m "init" && \
  printf '+function useUserData() { return {} }\n' > "$tmpfile") 2>/dev/null

run_hook_eval "$HOOKS_DIR/tanstack-router-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: function hook in route file" "hooks"

# ── Warn: arrow function hook in route file ──────────────────────

tmpfile="$_hl_tmpdir/routes/users2.tsx"
printf 'const useUserData = () => { return {} }\n' > "$tmpfile"
(cd "$_hl_tmpdir" && git add . && git commit -q -m "init2" && \
  printf '+const useUserData = () => { return {} }\n' > "$tmpfile") 2>/dev/null

run_hook_eval "$HOOKS_DIR/tanstack-router-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: arrow function hook in route file" "hooks"

# ── Allow: hook in hooks directory ───────────────────────────────

mkdir -p "$_hl_tmpdir/hooks"
tmpfile="$_hl_tmpdir/hooks/use-user-data.ts"
printf 'export function useUserData() { return {} }\n' > "$tmpfile"
(cd "$_hl_tmpdir" && git add . && git commit -q -m "init3" && \
  printf '+export function useUserData() { return {} }\n' > "$tmpfile") 2>/dev/null

run_hook_eval "$HOOKS_DIR/tanstack-router-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: hook in hooks directory"

# ── Allow: non-hook function in route file ───────────────────────

tmpfile="$_hl_tmpdir/routes/users3.tsx"
printf 'function formatDate(d: Date) { return d.toISOString() }\n' > "$tmpfile"
(cd "$_hl_tmpdir" && git add . && git commit -q -m "init4" && \
  printf '+function formatDate(d: Date) { return d.toISOString() }\n' > "$tmpfile") 2>/dev/null

run_hook_eval "$HOOKS_DIR/tanstack-router-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: non-hook function in route file"

rm -rf "$_hl_tmpdir"

# ══════════════════════════════════════════════════════════════════
# query-pattern-check.sh
# ══════════════════════════════════════════════════════════════════

run_file_eval "$HOOKS_DIR/query-pattern-check.sh" "query-pattern-check.sh exists"
run_executable_eval "$HOOKS_DIR/query-pattern-check.sh" "query-pattern-check.sh is executable"

run_content_eval "$HOOKS_DIR/query-pattern-check.sh" "useMutation" "mutation-check detects useMutation"
run_content_eval "$HOOKS_DIR/query-pattern-check.sh" "DELETE.*POST.*PUT.*PATCH" "mutation-check catches side-effect methods"
run_content_eval "$HOOKS_DIR/query-pattern-check.sh" "new_fetch_count" "mutation-check uses per-fetch counting (not file-level)"

# ── Warn: raw fetch DELETE in route file ─────────────────────────

_ms_tmpdir=$(mktemp -d /tmp/mutation-evals-XXXXXX)
mkdir -p "$_ms_tmpdir/routes"
tmpfile="$_ms_tmpdir/routes/connections.tsx"
printf "import React from 'react'\nconst disconnect = () => fetch('/api/disconnect', { method: 'DELETE' })\n" > "$tmpfile"
(cd "$_ms_tmpdir" && git init -q && git add . && git commit -q -m "init" && \
  printf "+const disconnect = () => fetch('/api/disconnect', { method: 'DELETE' })\n" > "$tmpfile") 2>/dev/null

run_hook_eval "$HOOKS_DIR/query-pattern-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: raw fetch DELETE without useMutation" "useMutation"

# ── Allow: fetch wrapped in useMutation ──────────────────────────

tmpfile="$_ms_tmpdir/routes/connections2.tsx"
printf "import React from 'react'\nimport { useMutation } from '@tanstack/react-query'\nconst { mutate } = useMutation({ mutationFn: () => fetch('/api/x', { method: 'DELETE' }) })\n" > "$tmpfile"
(cd "$_ms_tmpdir" && git add . && git commit -q -m "init2" && \
  printf "+import { useMutation } from '@tanstack/react-query'\n+const { mutate } = useMutation({ mutationFn: () => fetch('/api/x', { method: 'DELETE' }) })\n" > "$tmpfile") 2>/dev/null

run_hook_eval "$HOOKS_DIR/query-pattern-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: fetch DELETE wrapped in useMutation"

# ── Skip: non-React file ─────────────────────────────────────────

tmpfile="$_ms_tmpdir/utils.ts"
printf "export const apiDelete = () => fetch('/api/x', { method: 'DELETE' })\n" > "$tmpfile"
(cd "$_ms_tmpdir" && git add . && git commit -q -m "init3" && \
  printf "+export const apiDelete = () => fetch('/api/x', { method: 'DELETE' })\n" > "$tmpfile") 2>/dev/null

run_hook_eval "$HOOKS_DIR/query-pattern-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "skip: non-React utility file"

rm -rf "$_ms_tmpdir"

# ══════════════════════════════════════════════════════════════════
# form-mode-check.sh
# ══════════════════════════════════════════════════════════════════

run_file_eval "$HOOKS_DIR/form-mode-check.sh" "form-mode-check.sh exists"
run_executable_eval "$HOOKS_DIR/form-mode-check.sh" "form-mode-check.sh is executable"

run_content_eval "$HOOKS_DIR/form-mode-check.sh" "FieldMask|updateMask|update_mask" "field-mask detects multiple FieldMask patterns"
run_content_eval "$HOOKS_DIR/form-mode-check.sh" "dirtyFields" "field-mask suggests dynamic computation"
run_content_eval "$HOOKS_DIR/form-mode-check.sh" "hook_has_escape" "field-mask respects escape hatch"

# ── Warn: >2 hardcoded paths ─────────────────────────────────────

_fm_tmpdir=$(mktemp -d /tmp/field-mask-evals-XXXXXX)
# Must init git with empty commit, then add the file so git diff HEAD shows it
(cd "$_fm_tmpdir" && git init -q && git commit -q --allow-empty -m "init") 2>/dev/null
tmpfile="$_fm_tmpdir/edit.tsx"
cat > "$tmpfile" << 'FEOF'
import { FieldMask } from '@bufbuild/protobuf'
const mask = { paths: ['name', 'description', 'scopes'] }
FEOF

run_hook_eval "$HOOKS_DIR/form-mode-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: FieldMask with 3+ hardcoded paths" "dirty"

# ── Allow: <=2 hardcoded paths ───────────────────────────────────

tmpfile="$_fm_tmpdir/edit2.tsx"
cat > "$tmpfile" << 'FEOF'
import { FieldMask } from '@bufbuild/protobuf'
const mask = { paths: ['name', 'description'] }
FEOF

run_hook_eval "$HOOKS_DIR/form-mode-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: FieldMask with <=2 hardcoded paths"

# cleanup
(cd /tmp && rm -r "$_fm_tmpdir" 2>/dev/null) || true

# ══════════════════════════════════════════════════════════════════
# connect-query-check.sh
# ══════════════════════════════════════════════════════════════════

run_file_eval "$HOOKS_DIR/connect-query-check.sh" "connect-query-check.sh exists"
run_executable_eval "$HOOKS_DIR/connect-query-check.sh" "connect-query-check.sh is executable"

run_content_eval "$HOOKS_DIR/connect-query-check.sh" "ConnectError.from" "connect-error prescribes ConnectError.from()"
run_content_eval "$HOOKS_DIR/connect-query-check.sh" "package.json.*@connectrpc" "connect-error checks project-level connectrpc dep"
run_content_eval "$HOOKS_DIR/connect-query-check.sh" "hook_has_escape" "connect-error respects escape hatch"

# ── Warn: throw new Error in connectrpc file ─────────────────────

_ce_tmpdir=$(mktemp -d /tmp/connect-error-evals-XXXXXX)
mkdir -p "$_ce_tmpdir/routes"
tmpfile="$_ce_tmpdir/routes/api.tsx"
# File must import @connectrpc AND have loader/queryFn context AND throw new Error
printf "import { createClient } from '@connectrpc/connect'\nexport const loader = async () => { throw new Error('fail') }\n" > "$tmpfile"
(cd "$_ce_tmpdir" && git init -q && git add . && git commit -q -m "init" && \
  printf "+import { createClient } from '@connectrpc/connect'\n+export const loader = async () => { throw new Error('fail') }\n" > "$tmpfile") 2>/dev/null

run_hook_eval "$HOOKS_DIR/connect-query-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: throw new Error in connectrpc file" "ConnectError"

# ── Allow: no throw new Error ────────────────────────────────────

tmpfile="$_ce_tmpdir/routes/api2.tsx"
printf "import { createClient } from '@connectrpc/connect'\nconst loader = async () => { return data }\n" > "$tmpfile"
(cd "$_ce_tmpdir" && git add . && git commit -q -m "init2" && \
  printf "+const loader = async () => { return data }\n" > "$tmpfile") 2>/dev/null

run_hook_eval "$HOOKS_DIR/connect-query-check.sh" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: no throw new Error in connectrpc file"

rm -rf "$_ce_tmpdir"

# ══════════════════════════════════════════════════════════════════
# hooks.json wiring: new hooks registered
# ══════════════════════════════════════════════════════════════════

run_content_eval "$REPO_ROOT/hooks/hooks.json" "ts-no-escape-hatches-check" "hooks.json has ts-no-escape-hatches-check"

# ══════════════════════════════════════════════════════════════════
# Proto-form hooks: files, executable bits, registration in BOTH
# hooks.json (plugin manifest) and .claude/settings.json (local dev)
# ══════════════════════════════════════════════════════════════════

for h in connect-query-check form-mode-check form-mode-check form-mode-check; do
  run_file_eval       "$HOOKS_DIR/${h}.sh" "${h}.sh exists"
  run_executable_eval "$HOOKS_DIR/${h}.sh" "${h}.sh is executable"
  run_content_eval    "$HOOKS_DIR/${h}.sh" "hook_has_escape" "${h} respects escape hatch"
  run_content_eval    "$REPO_ROOT/hooks/hooks.json"       "${h}" "hooks.json has ${h}"
  run_content_eval    "$REPO_ROOT/.claude/settings.json"  "${h}" "settings.json has ${h}"
done
