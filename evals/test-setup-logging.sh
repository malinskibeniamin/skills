# Evals for setup-logging skill

SCRIPT="$REPO_ROOT/setup-logging/scripts/logging-check.sh"
SKILL_DIR="$REPO_ROOT/setup-logging"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_executable_eval "$SCRIPT" "logging-check.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: setup-logging" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "pino" "SKILL.md mentions pino"
run_content_eval "$SKILL_DIR/SKILL.md" "console.error" "SKILL.md mentions console.error ban"

# ── Hook: skip non-Edit/Write ──────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"echo"}}' \
  0 "skip: Bash tool"

# ── Hook: skip test files ───────────────────────────────────────

_lg_tmpdir=$(mktemp -d /tmp/logging-evals-XXXXXX)

tmpfile="$_lg_tmpdir/api.test.ts"
echo 'console.error("test failure expected")' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "skip: test file"

tmpfile="$_lg_tmpdir/api.spec.ts"
echo 'console.warn("spec warning")' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "skip: spec file"

# ── Hook: block console.error ────────────────────────────────────

tmpfile="$_lg_tmpdir/handler.ts"
echo 'console.error("request failed", err)' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: console.error" "logger"

# ── Hook: block console.warn ─────────────────────────────────────

tmpfile="$_lg_tmpdir/service.ts"
echo 'console.warn("deprecated feature")' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: console.warn" "logger"

# ── Hook: block console.debug ────────────────────────────────────

tmpfile="$_lg_tmpdir/debug.ts"
echo 'console.debug("processing", data)' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: console.debug" "logger"

# ── Hook: block string concatenation in logger ───────────────────

tmpfile="$_lg_tmpdir/concat.ts"
echo 'logger.error("failed: " + err.message)' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: string concatenation in logger" "structured"

# ── Hook: block template literal in logger ───────────────────────

tmpfile="$_lg_tmpdir/template.ts"
printf 'logger.error(`failed: ${err.message}`)\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: template literal in logger" "structured"

# ── Hook: allow structured logger ─────────────────────────────────

tmpfile="$_lg_tmpdir/good.ts"
echo 'logger.error({ message: "request failed", error: err })' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: structured logger call"

# ── Hook: skip non-JS/TS ─────────────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.go"}}' \
  0 "skip: .go file"

# ── Script content ───────────────────────────────────────────────

run_content_eval "$SCRIPT" "console\.error" "hook checks console.error"
run_content_eval "$SCRIPT" "console\.warn" "hook checks console.warn"
run_content_eval "$SCRIPT" "console\.debug" "hook checks console.debug"
run_content_eval "$SCRIPT" "logger\." "hook checks logger concatenation"
run_content_eval "$SCRIPT" "__tests__" "hook skips __tests__ directory"

rm -rf "$_lg_tmpdir"
