# Evals for removed legacy local/Matt sediment. New skills own these jobs now.

LEGACY_SKILLS=(
  design-an-interface
  qa
  request-refactor-plan
  setup-matt-pocock-skills
  ubiquitous-language
  domain-model
)

for skill in "${LEGACY_SKILLS[@]}"; do
  if [ -e "$REPO_ROOT/$skill" ]; then
    echo "  FAIL  legacy skill directory removed: $skill"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: legacy skill directory still exists: $skill"
  else
    echo "  PASS  legacy skill directory removed: $skill"
    PASS=$((PASS + 1))
  fi

  if grep -qF "./$skill/" "$REPO_ROOT/.claude-plugin/plugin.json" "$REPO_ROOT/.codex-plugin/plugin.json"; then
    echo "  FAIL  legacy skill not registered in plugins: $skill"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: legacy skill still registered in plugin metadata: $skill"
  else
    echo "  PASS  legacy skill not registered in plugins: $skill"
    PASS=$((PASS + 1))
  fi
done

if grep -qE '/grilling|/prototype' "$REPO_ROOT/development-lifecycle/SKILL.md"; then
  echo "  FAIL  lifecycle pre-routes optional skills"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: lifecycle pre-routes optional skills"
else
  echo "  PASS  lifecycle loads specialist guidance only from observed need"
  PASS=$((PASS + 1))
fi
run_content_eval "$REPO_ROOT/development-lifecycle/REFERENCE.md" "Disposable prototype" "lifecycle keeps executable probes available without skill chaining"
run_content_eval "$REPO_ROOT/triage/SKILL.md" "/grilling" "triage uses grilling for docs grill"
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" "/prototype" "commit-push-pr recommends prototype over legacy design fan-out"
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" "/improve architecture" "commit-push recommends architecture skill over refactor-plan"
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" "/prototype" "commit-push-pr recommends prototype over legacy design fan-out"
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" "/triage" "commit-push-pr recommends triage over qa"

_live_refs=$(rg -n --hidden '/(design-an-interface|qa|request-refactor-plan|setup-matt-pocock-skills|ubiquitous-language|domain-model)([^[:alnum:]_-]|$)|"(design-an-interface|qa|request-refactor-plan|setup-matt-pocock-skills|ubiquitous-language|domain-model)"[[:space:]]*:|\b(design-an-interface|request-refactor-plan|setup-matt-pocock-skills|ubiquitous-language)\b|mattpocock/skills/(design-an-interface|qa|request-refactor-plan|setup-matt-pocock-skills|ubiquitous-language|domain-model)([^[:alnum:]_-]|$)|malinskibeniamin/skills/(design-an-interface|qa|request-refactor-plan|setup-matt-pocock-skills|ubiquitous-language|domain-model)([^[:alnum:]_-]|$)' "$REPO_ROOT" \
  --glob '!.git/**' \
  --glob '!CHANGELOG.md' \
  --glob '!evals/**' \
  --glob '!.claude-plugin/**' \
  --glob '!.codex-plugin/**' \
  --glob '!.agents/plugins/marketplace.json' || true)
if [ -n "$_live_refs" ]; then
  echo "  FAIL  live docs/config do not route to removed legacy skills"
  printf '%s\n' "$_live_refs" | sed 's/^/        /'
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: live docs still route to removed legacy skills"
else
  echo "  PASS  live docs/config do not route to removed legacy skills"
  PASS=$((PASS + 1))
fi
