# Evals for mandatory, version-matched TanStack Intent guidance.

INTENT_SKILL="$REPO_ROOT/tanstack-intent/SKILL.md"
INTENT_SETUP="$REPO_ROOT/tanstack-intent/SETUP.md"

run_file_eval "$INTENT_SKILL" "TanStack Intent skill exists"
run_file_eval "$INTENT_SETUP" "TanStack Intent setup exists"
run_content_eval "$INTENT_SKILL" "mentioned.*referenced.*worked on" \
  "skill covers every TanStack contact point"
run_content_eval "$INTENT_SKILL" "list --json" \
  "skill discovers guidance from installed packages"
run_content_eval "$INTENT_SKILL" "load.*use" \
  "skill loads the task-specific Intent use id"
run_content_eval "$INTENT_SKILL" "installed.*version|version-matched" \
  "skill makes installed-version guidance authoritative"

if [ -f "$INTENT_SKILL" ] && grep -q '^disable-model-invocation:[[:space:]]*true$' "$INTENT_SKILL"; then
  echo "  FAIL  TanStack Intent cannot trigger automatically"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: TanStack Intent is user-invoked only"
else
  echo "  PASS  TanStack Intent can trigger automatically"
  PASS=$((PASS + 1))
fi

run_content_eval "$INTENT_SETUP" '"@tanstack/\*"' \
  "setup trusts only TanStack package skills"
run_content_eval "$INTENT_SETUP" "install --map" \
  "setup installs explicit task mappings"
run_content_eval "$INTENT_SETUP" "hooks install.*claude,codex" \
  "setup installs official Claude and Codex enforcement"

run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"./tanstack-intent/"' \
  "Claude plugin registers TanStack Intent"
run_content_eval "$REPO_ROOT/frontend-starter-kit/SKILL.md" "tanstack-intent" \
  "full starter kit includes TanStack Intent"

for skill in tanstack-router tanstack-table; do
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "tanstack-intent" \
    "$skill loads Intent before local guidance"
done

if grep -qE 'still published under the beta tag|tanstack\.com/table/beta' \
  "$REPO_ROOT/tanstack-table/SKILL.md"; then
  echo "  FAIL  TanStack Table skill preserves stale beta guidance"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: stale TanStack Table beta guidance"
else
  echo "  PASS  TanStack Table skill has no stale beta guidance"
  PASS=$((PASS + 1))
fi
