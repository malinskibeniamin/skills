# Evals for env-validation reference (Biome-delegated; hook retired)

SKILL_DIR="$REPO_ROOT/frontend-starter-kit/references/env-validation"

run_file_eval "$SKILL_DIR/README.md" "README.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"

run_content_eval "$SKILL_DIR/REFERENCE.md" "noProcessEnv" "reference delegates to Biome noProcessEnv"
run_content_eval "$SKILL_DIR/REFERENCE.md" "hook was retired" "reference records the hook retirement"
run_content_eval "$SKILL_DIR/REFERENCE.md" "createEnv" "reference keeps t3-env example"
run_content_eval "$SKILL_DIR/REFERENCE.md" "import \{ env \} from \"@/env\"" "reference keeps @/env usage pattern"

# The hook must stay dead in every install surface.
for _p in ".claude/hooks/env-validation-check.sh" ".claude/hooks/checks/env-validation-check.lib.sh" "frontend-starter-kit/references/env-validation/scripts/env-validation-check.sh"; do
  if [ -e "$REPO_ROOT/$_p" ]; then
    echo "  FAIL  $_p resurrected — Biome noProcessEnv owns this rule"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $_p resurrected"
  else
    echo "  PASS  $_p stays retired"
    PASS=$((PASS + 1))
  fi
done
