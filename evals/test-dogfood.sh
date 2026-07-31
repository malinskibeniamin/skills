# Evals for /dogfood behavior, lifecycle ownership, and completion enforcement.

SKILL="$REPO_ROOT/dogfood/SKILL.md"
STOP_HOOK="$REPO_ROOT/.claude/hooks/dogfood-stop.sh"
FIRE_HOOK="$REPO_ROOT/.claude/hooks/skill-fire-log.sh"

run_file_eval "$SKILL" "dogfood SKILL.md exists"
run_file_eval "$STOP_HOOK" "dogfood completion hook exists"
run_executable_eval "$REPO_ROOT/.claude/hooks/dogfood-state.sh" \
  "dogfood PR-state helper exists"
run_content_eval "$SKILL" "^name: dogfood" "dogfood has correct name"
run_content_eval "$SKILL" "^description:.*Use after each material behavior slice" \
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
run_content_eval "$SKILL" "merge-base|whole PR|full PR|PR diff" \
  "dogfood inventories the whole PR"
run_content_eval "$SKILL" "representative live-scale data" \
  "dogfood uses realistic data shape and cardinality"
run_content_eval "$SKILL" "counts.*ordering.*timing" \
  "dogfood compares observable data outcomes"
run_content_eval "$SKILL" "response time.*network.*render.*CPU.*memory" \
  "dogfood measures applicable performance"

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
run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "real entrypoint" \
  "development lifecycle exercises material behavior during implementation"
run_content_eval "$REPO_ROOT/go/SKILL.md" "real user or public entrypoint" \
  "go has a final real-use gate"
run_content_eval "$REPO_ROOT/go/REFERENCE.md" "real entrypoint and one credible failure" \
  "go reference preserves experiential evidence without a skill chain"
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
run_content_eval "$REPO_ROOT/.claude/hooks/intent-detect.sh" "dogfood-task-start-head" \
  "prompt boundary snapshots dogfood turn state"

if [ -x "$STOP_HOOK" ] && [ -x "$FIRE_HOOK" ]; then
  # PR-aware gate: delivery checks the whole branch, including work committed
  # before this session. Local/read-only turns remain session-owned.
  _dogfood_repo=$(mktemp -d)
  _dogfood_repo_cwd=$PWD
  git -C "$_dogfood_repo" init -q
  git -C "$_dogfood_repo" config user.email dogfood@example.com
  git -C "$_dogfood_repo" config user.name Dogfood
  mkdir -p "$_dogfood_repo/src"
  printf 'export const value = 1;\n' > "$_dogfood_repo/src/app.ts"
  git -C "$_dogfood_repo" add src/app.ts
  git -C "$_dogfood_repo" commit -qm "base"
  git -C "$_dogfood_repo" branch -M main
  git -C "$_dogfood_repo" update-ref refs/remotes/origin/main HEAD
  git -C "$_dogfood_repo" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
  git -C "$_dogfood_repo" checkout -qb feature
  printf 'export const value = 2;\n' > "$_dogfood_repo/src/app.ts"
  git -C "$_dogfood_repo" add src/app.ts
  git -C "$_dogfood_repo" commit -qm "change behavior"

  _dogfood_pr_sid="eval-dogfood-pr-$$"
  _dogfood_pr_session="/tmp/hook-session-${_dogfood_pr_sid}"
  rm -rf "$_dogfood_pr_session"
  mkdir -p "$_dogfood_pr_session"
  : > "$_dogfood_pr_session/dirty-files-baseline"
  printf 'pr\n' > "$_dogfood_pr_session/task-endpoint"
  export CLAUDE_SESSION_ID="$_dogfood_pr_sid"
  cd "$_dogfood_repo"

  run_hook_eval "$STOP_HOOK" \
    '{"last_assistant_message":"No dogfood receipt."}' 2 \
    "PR endpoint blocks on pre-session runnable diff" "Run /dogfood"

  _dogfood_real_sid="eval-dogfood-real-stop-$$"
  _dogfood_real_session="/tmp/hook-session-${_dogfood_real_sid}"
  mkdir -p "$_dogfood_real_session"
  : > "$_dogfood_real_session/dirty-files-baseline"
  printf 'pr\n' > "$_dogfood_real_session/task-endpoint"
  CLAUDE_SESSION_ID="$_dogfood_real_sid" HOOK_STOP_BLOCK_CAP_GUARD=1 \
    run_hook_eval "$STOP_HOOK" '{}' 2 \
      "blocks on a real fresh Stop session" "Run /dogfood"
  rm -rf "$_dogfood_real_session"

  rm -f "$_dogfood_pr_session/task-endpoint"
  printf 'local\n' > "$_dogfood_pr_session/task-endpoint"
  run_hook_eval "$STOP_HOOK" \
    '{"last_assistant_message":"Read-only response."}' 0 \
    "read-only local turn ignores pre-session PR diff"

  printf '%s\n' "$_dogfood_repo/src/app.ts" \
    > "$_dogfood_pr_session/session-touched-files"
  printf '%s\n' \
    '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"dogfood"}}' \
    | "$FIRE_HOOK" >/dev/null
  run_hook_eval "$STOP_HOOK" \
    '{"last_assistant_message":"Dogfood ran, trust me."}' 2 \
    "dogfood invocation still requires PASS receipt" "structured PASS receipt"

  _dogfood_pass='Verdict: PASS
- **Entrypoint:** hook event
- **Actions:** intended and invalid event flows
- **Observations:** expected block and pass decisions
- **Repairs:** none; replay passed
- **Limits:** no live host process'
  _dogfood_pass_json=$(jq -nc --arg message "$_dogfood_pass" \
    '{last_assistant_message:$message}')
  run_hook_eval "$STOP_HOOK" "$_dogfood_pass_json" 0 \
    "current invocation plus PASS receipt allows completion"

  printf 'export const value = 3;\n' > "$_dogfood_repo/src/app.ts"
  run_hook_eval "$STOP_HOOK" "$_dogfood_pass_json" 2 \
    "later runnable PR edit invalidates dogfood" "current PR state"

  printf '%s\n' \
    '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"dogfood"}}' \
    | "$FIRE_HOOK" >/dev/null
  printf 'test only\n' > "$_dogfood_repo/src/app.test.ts"
  printf '%s\n' "$_dogfood_repo/src/app.test.ts" \
    >> "$_dogfood_pr_session/session-touched-files"
  run_hook_eval "$STOP_HOOK" "$_dogfood_pass_json" 0 \
    "later test-only PR edit keeps dogfood current"

  wc -l < "$_dogfood_pr_session/session-touched-files" \
    | tr -d '[:space:]' > "$_dogfood_pr_session/dogfood-task-start-touched-count"
  git rev-parse HEAD > "$_dogfood_pr_session/dogfood-task-start-head"
  {
    git diff --name-only HEAD
    git ls-files --others --exclude-standard
  } | sort -u > "$_dogfood_pr_session/dogfood-task-dirty-baseline"
  run_hook_eval "$STOP_HOOK" \
    '{"last_assistant_message":"A new local read-only response."}' 0 \
    "new local turn ignores prior-turn runnable edits"

  printf 'export const value = 4;\n' > "$_dogfood_repo/src/app.ts"
  printf '%s\n' "$_dogfood_repo/src/app.ts" \
    >> "$_dogfood_pr_session/session-touched-files"
  run_hook_eval "$STOP_HOOK" '{}' 2 \
    "new local runnable edit activates dogfood gate" "Run /dogfood"

  cd "$_dogfood_repo_cwd"
  rm -rf "$_dogfood_repo" "$_dogfood_pr_session"
  unset CLAUDE_SESSION_ID

  # Files nested under a skill are executable agent behavior even when their
  # extension is Markdown. Standalone documentation and tests are not.
  _dogfood_skill_repo=$(mktemp -d)
  git -C "$_dogfood_skill_repo" init -q
  git -C "$_dogfood_skill_repo" config user.email dogfood@example.com
  git -C "$_dogfood_skill_repo" config user.name Dogfood
  mkdir -p "$_dogfood_skill_repo/example-skill/references"
  printf '%s\n' '---' 'name: example-skill' '---' \
    > "$_dogfood_skill_repo/example-skill/SKILL.md"
  printf 'base guidance\n' \
    > "$_dogfood_skill_repo/example-skill/references/guide.md"
  printf 'base docs\n' > "$_dogfood_skill_repo/README.md"
  git -C "$_dogfood_skill_repo" add .
  git -C "$_dogfood_skill_repo" commit -qm "base"
  git -C "$_dogfood_skill_repo" branch -M main
  git -C "$_dogfood_skill_repo" update-ref refs/remotes/origin/main HEAD
  git -C "$_dogfood_skill_repo" checkout -qb feature
  printf 'changed guidance\n' \
    > "$_dogfood_skill_repo/example-skill/references/guide.md"

  _dogfood_skill_sid="eval-dogfood-skill-$$"
  _dogfood_skill_session="/tmp/hook-session-${_dogfood_skill_sid}"
  rm -rf "$_dogfood_skill_session"
  mkdir -p "$_dogfood_skill_session"
  : > "$_dogfood_skill_session/dirty-files-baseline"
  printf 'local\n' > "$_dogfood_skill_session/task-endpoint"
  printf '%s\n' "$_dogfood_skill_repo/example-skill/references/guide.md" \
    > "$_dogfood_skill_session/session-touched-files"
  export CLAUDE_SESSION_ID="$_dogfood_skill_sid"
  cd "$_dogfood_skill_repo"
  run_hook_eval "$STOP_HOOK" '{}' 2 \
    "skill reference edit requires dogfood" "Run /dogfood"

  printf 'changed docs\n' > "$_dogfood_skill_repo/README.md"
  printf 'test only\n' > "$_dogfood_skill_repo/example.test.ts"
  rm -f "$_dogfood_skill_repo/example-skill/references/guide.md"
  git -C "$_dogfood_skill_repo" checkout -- \
    example-skill/references/guide.md
  printf '%s\n' "$_dogfood_skill_repo/README.md" \
    "$_dogfood_skill_repo/example.test.ts" \
    > "$_dogfood_skill_session/session-touched-files"
  run_hook_eval "$STOP_HOOK" '{}' 0 \
    "standalone docs and tests do not require dogfood"

  cd "$_dogfood_repo_cwd"
  rm -rf "$_dogfood_skill_repo" "$_dogfood_skill_session"
  unset CLAUDE_SESSION_ID
else
  echo "  FAIL  dogfood hook behavior could not run"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: dogfood hook behavior could not run"
fi
