# Evals for new hook events added in 2.2.4:

HOOKS_DIR="$REPO_ROOT/.claude/hooks"

# ── Scripts exist and are executable ────────────────────────────
for script in session-end.sh pre-compact.sh post-tool-failure.sh \
              file-changed-deps.sh file-changed-schema.sh \
              file-changed-config.sh file-changed-env.sh file-changed-manifest.sh; do
  if [ -x "$HOOKS_DIR/$script" ]; then
    echo "  PASS  $script exists and executable"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $script missing or not executable"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $script"
  fi
done

# ── Manifest wires all new events ───────────────────────────────
for event in SessionEnd PreCompact PostToolUseFailure FileChanged; do
  if jq -e ".hooks.$event" "$REPO_ROOT/skill-manifest.json" >/dev/null 2>&1; then
    echo "  PASS  manifest wires $event"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  manifest missing $event"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: manifest missing $event"
  fi
done

# ── FileChanged has 4 matcher groups ─────────────────────────────
# Literal groups for static names (env/manifest/deps) plus one empty-matcher
# group for pattern-shaped names (schema/config) whose watches session-env
# registers via watchPaths — FileChanged matchers are literal-only, so the
# old glob matchers never fired.
_matchers=$(jq '.hooks.FileChanged | keys | length' "$REPO_ROOT/skill-manifest.json" 2>/dev/null)
if [ "$_matchers" = "4" ]; then
  echo "  PASS  FileChanged has 4 matcher groups (dynamic/env/manifest/deps)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  FileChanged matcher count wrong: $_matchers (expected 4)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: FileChanged matcher count"
fi
if jq -e '.hooks.FileChanged[""] | index("file-changed-schema.sh")' "$REPO_ROOT/skill-manifest.json" >/dev/null 2>&1 \
  && grep -q "watchPaths" "$HOOKS_DIR/session-env.sh"; then
  echo "  PASS  dynamic FileChanged names routed via watchPaths + internal filters"
  PASS=$((PASS + 1))
else
  echo "  FAIL  dynamic FileChanged routing broken (empty matcher group or watchPaths missing)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: FileChanged dynamic routing"
fi

# ── PreCompact injects additionalContext (paired with PostCompact) ─
if grep -q 'hookEventName.*PreCompact' "$HOOKS_DIR/pre-compact.sh"; then
  echo "  PASS  pre-compact.sh emits additionalContext for PreCompact"
  PASS=$((PASS + 1))
else
  echo "  FAIL  pre-compact.sh missing additionalContext emission"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: pre-compact emit"
fi

# ── file-changed-manifest auto-regens configs (drift prevention) ───
if grep -q 'generate-hook-configs.sh' "$HOOKS_DIR/file-changed-manifest.sh"; then
  echo "  PASS  file-changed-manifest.sh invokes codegen (drift prevention)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  file-changed-manifest.sh not wired to regen"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: manifest file watcher not auto-regen"
fi

# ── Syntax-check new hooks ──────────────────────────────────────
_bad=0
for script in session-end.sh pre-compact.sh post-tool-failure.sh \
              file-changed-deps.sh file-changed-schema.sh \
              file-changed-config.sh file-changed-env.sh file-changed-manifest.sh; do
  if ! bash -n "$HOOKS_DIR/$script" 2>/dev/null; then
    _bad=$((_bad + 1))
  fi
done
if [ "$_bad" = "0" ]; then
  echo "  PASS  all 9 new hooks pass bash -n syntax check"
  PASS=$((PASS + 1))
else
  echo "  FAIL  $_bad of 9 new hooks have syntax errors"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: syntax in new hooks"
fi

# ── Rstest configuration watches ────────────────────────────────────────

run_hook_eval "$HOOKS_DIR/file-changed-config.sh" \
  '{"filename":"rstest.config.ts"}' \
  0 "Rstest config changes request full test collection" "Rstest config changed"

_watch_tmp=$(mktemp -d /tmp/rstest-watch-XXXXXX)
touch "$_watch_tmp/rstest.config.ts"
if "$HOOKS_DIR/discover-watch-paths.sh" "$_watch_tmp" | grep -qF "$_watch_tmp/rstest.config.ts"; then
  echo "  PASS  Rstest config registered as dynamic FileChanged watch"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Rstest config missing from dynamic FileChanged watches"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Rstest FileChanged watch"
fi
rm -rf "$_watch_tmp"
