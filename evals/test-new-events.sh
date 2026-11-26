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

# ── Compact hooks emit only host-valid output ──────────────────────
# Neither Claude Code nor Codex accepts hookSpecificOutput on PreCompact or
# PostCompact; post-compaction context goes through SessionStart(source=compact).
_cp_check() {
  if eval "$2"; then
    echo "  PASS  $1"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $1"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $1"
  fi
}
_cp_sid="new-events-compact-$$"
_cp_dir="/tmp/hook-session-$_cp_sid"
_cp_tmp=$(mktemp -d)
mkdir -p "$_cp_dir"
printf 'local\n' > "$_cp_dir/task-endpoint"
_cp_run() {
  (cd "$_cp_tmp" && printf '%s\n' "$2" \
    | env -u CLAUDE_SESSION_ID -u CODEX_SESSION_ID "$HOOKS_DIR/$1" 2>/dev/null)
}
_cp_pre=$(_cp_run pre-compact.sh '{"hook_event_name":"PreCompact","trigger":"manual","session_id":"'"$_cp_sid"'"}')
_cp_check "pre-compact.sh saves its snapshot and prints nothing" \
  '[ -z "$_cp_pre" ] && [ -f "$_cp_dir/pre-compact-snapshot.json" ]'
_cp_post=$(_cp_run post-compact-context.sh '{"hook_event_name":"PostCompact","trigger":"manual","session_id":"'"$_cp_sid"'"}')
_cp_check "post-compact-context.sh prints nothing on PostCompact" '[ -z "$_cp_post" ]'
_cp_startup=$(_cp_run post-compact-context.sh '{"hook_event_name":"SessionStart","source":"startup","session_id":"'"$_cp_sid"'"}')
_cp_check "post-compact-context.sh skips non-compact SessionStart" '[ -z "$_cp_startup" ]'
_cp_start=$(_cp_run post-compact-context.sh '{"hook_event_name":"SessionStart","source":"compact","session_id":"'"$_cp_sid"'"}')
_cp_check "post-compact-context.sh restores context on SessionStart(compact) with real newlines" \
  'printf "%s" "$_cp_start" | jq -e ".hookSpecificOutput.hookEventName == \"SessionStart\"
    and (.hookSpecificOutput.additionalContext | startswith(\"[POST-COMPACTION]\"))
    and (.hookSpecificOutput.additionalContext | contains(\"\nEndpoint: local\"))
    and (.hookSpecificOutput.additionalContext | contains(\"\\\\n\") | not)" >/dev/null 2>&1'
_cp_check "manifest wires post-compact-context.sh to SessionStart(compact), not PostCompact" \
  'jq -e "(.hooks.SessionStart.compact | index(\"post-compact-context.sh\")) and (.hooks.PostCompact == null)" "$REPO_ROOT/skill-manifest.json" >/dev/null 2>&1'
_cp_check "no hook emits context for PreCompact or PostCompact" \
  '! grep -E -q "(hookEventName|hook_context).*(PreCompact|PostCompact)" "$HOOKS_DIR"/*.sh'
rm -f "$_cp_dir/pre-compact-snapshot.json" "$_cp_dir/task-endpoint"
rmdir "$_cp_dir" "$_cp_tmp" 2>/dev/null || true

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
