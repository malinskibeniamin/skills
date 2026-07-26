# Evals for /dogfood behavior, lifecycle ownership, and completion enforcement.

SKILL="$REPO_ROOT/dogfood/SKILL.md"
STOP_HOOK="$REPO_ROOT/.claude/hooks/dogfood-stop.sh"
FIRE_HOOK="$REPO_ROOT/.claude/hooks/skill-fire-log.sh"

run_file_eval "$SKILL" "dogfood SKILL.md exists"
run_file_eval "$STOP_HOOK" "dogfood completion hook exists"
run_content_eval "$SKILL" "^name: dogfood" "dogfood has correct name"
run_content_eval "$SKILL" "^description:.*(building|built|fixing|fixed|iterating)" \
  "description triggers after runnable work"
run_content_eval "$SKILL" "material runnable (increment|slice)" \
  "dogfood defines its checkpoint cadence"
run_content_eval "$SKILL" "Tests.*(are not|do not count|never count).*dogfood|dogfood.*(is not|does not replace).*tests" \
  "dogfood distinguishes tests from real use"
run_content_eval "$SKILL" "use.*abuse.*repair.*replay" \
  "dogfood has the use-abuse-repair-replay loop"
run_content_eval "$SKILL" "real (user|public) (entrypoint|entry point)|public seam" \
  "dogfood requires a real user entrypoint"
run_content_eval "$SKILL" "same|identical" \
  "bug branch replays the original reproduction"
run_content_eval "$SKILL" "cannot reproduce|does not reproduce|not reproduce" \
  "invalid bug reports stop diagnosis"
run_content_eval "$SKILL" "PASS.*FAIL.*BLOCKED" \
  "dogfood has explicit verdicts"
run_content_eval "$SKILL" "entrypoint.*actions.*observ" \
  "dogfood receipt captures experiential evidence"
run_content_eval "$SKILL" "current implementation|current runnable" \
  "dogfood evidence binds to current work"

if grep -q "^disable-model-invocation:" "$SKILL" 2>/dev/null; then
  echo "  FAIL  dogfood must be model-invoked"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: dogfood must be model-invoked"
else
  echo "  PASS  dogfood is model-invoked"
  PASS=$((PASS + 1))
fi

run_content_eval "$REPO_ROOT/tdd/SKILL.md" "/dogfood" "TDD dogfoods material green slices"
run_content_eval "$REPO_ROOT/diagnosing-bugs/SKILL.md" "/dogfood" \
  "bug diagnosis dogfoods before and after"
run_content_eval "$REPO_ROOT/prototype/SKILL.md" "/dogfood" \
  "prototypes are dogfooded before verdict"
run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "/dogfood" \
  "development lifecycle dogfoods during implementation"
run_content_eval "$REPO_ROOT/go/SKILL.md" "/dogfood" \
  "go has a final dogfood gate"
run_content_eval "$REPO_ROOT/go/REFERENCE.md" "Dogfood [Ee]vidence" \
  "go reference preserves dogfood evidence"
run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" "/dogfood|[Dd]ogfood" \
  "PR creation requires dogfood evidence"
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" "## Dogfood evidence" \
  "PR template exposes dogfood evidence"

run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"./dogfood/"' \
  "Claude plugin registers dogfood"
run_content_eval "$REPO_ROOT/scripts/generate-skill-catalog.sh" '"dogfood":' \
  "Codex metadata defines dogfood"
run_file_eval "$REPO_ROOT/codex-skills/dogfood/SKILL.md" \
  "generated Codex dogfood proxy exists"
run_file_eval "$REPO_ROOT/codex-skills/dogfood/agents/openai.yaml" \
  "generated Codex dogfood metadata exists"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "/dogfood" \
  "generated catalog lists dogfood"
run_content_eval "$REPO_ROOT/skill-manifest.json" "dogfood-stop.sh" \
  "hook manifest registers dogfood completion gate"
run_content_eval "$FIRE_HOOK" "dogfood-invocation" \
  "skill telemetry records dogfood invocation state"

if [ -x "$STOP_HOOK" ] && [ -x "$FIRE_HOOK" ]; then
  _dogfood_sid="eval-dogfood-$$"
  _dogfood_session="/tmp/hook-session-${_dogfood_sid}"
  rm -rf "$_dogfood_session"
  mkdir -p "$_dogfood_session"
  export CLAUDE_SESSION_ID="$_dogfood_sid"

  printf '%s\n' "/tmp/project/src/dashboard.tsx" \
    > "$_dogfood_session/session-touched-files"
  run_hook_eval "$STOP_HOOK" '{}' 2 \
    "blocks runnable work without dogfood" "Run /dogfood"

  _dogfood_real_sid="eval-dogfood-real-stop-$$"
  _dogfood_real_session="/tmp/hook-session-${_dogfood_real_sid}"
  mkdir -p "$_dogfood_real_session"
  printf '%s\n' "/tmp/project/src/dashboard.tsx" \
    > "$_dogfood_real_session/session-touched-files"
  CLAUDE_SESSION_ID="$_dogfood_real_sid" HOOK_STOP_BLOCK_CAP_GUARD=1 \
    run_hook_eval "$STOP_HOOK" '{}' 2 \
      "blocks on a real fresh Stop session" "Run /dogfood"
  rm -rf "$_dogfood_real_session"

  printf '%s\n' \
    '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"dogfood"}}' \
    | "$FIRE_HOOK" >/dev/null
  run_hook_eval "$STOP_HOOK" '{}' 0 \
    "allows runnable work dogfooded after its latest edit"

  printf '%s\n' "/tmp/project/src/dashboard.tsx" \
    >> "$_dogfood_session/session-touched-files"
  run_hook_eval "$STOP_HOOK" '{}' 2 \
    "invalidates dogfood after a later runnable edit" "Run /dogfood"

  printf '%s\n' \
    '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"dogfood"}}' \
    | "$FIRE_HOOK" >/dev/null
  printf '%s\n' "/tmp/project/src/dashboard.test.tsx" \
    >> "$_dogfood_session/session-touched-files"
  run_hook_eval "$STOP_HOOK" '{}' 0 \
    "does not invalidate dogfood for a later test-only edit"

  rm -f "$_dogfood_session/dogfood-invocation"
  printf '%s\n' "/tmp/project/README.md" \
    > "$_dogfood_session/session-touched-files"
  run_hook_eval "$STOP_HOOK" '{}' 0 \
    "does not block documentation-only work"

  printf '%s\n' "/tmp/project/dogfood/SKILL.md" \
    > "$_dogfood_session/session-touched-files"
  run_hook_eval "$STOP_HOOK" '{}' 2 \
    "treats skills as runnable artifacts" "Run /dogfood"

  rm -rf "$_dogfood_session"
  unset CLAUDE_SESSION_ID
else
  echo "  FAIL  dogfood hook behavior could not run"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: dogfood hook behavior could not run"
fi
