# Evals for the consolidated /frontend-starter-kit (profiles + lazy references, 4.27.0).

KIT="$REPO_ROOT/frontend-starter-kit/SKILL.md"
run_file_eval "$KIT" "frontend-starter-kit SKILL.md exists"
run_content_eval "$KIT" "Profiles" "kit defines profiles"
run_content_eval "$KIT" "full.*minimal.*redpanda" "kit lists full/minimal/redpanda profiles"
run_content_eval "$KIT" "idempotent" "kit steps are idempotent"
run_content_eval "$KIT" "no-ops" "kit notes hook copies are no-ops for plugin consumers"
run_content_eval "$KIT" "references/toolchain" "kit routes to toolchain reference"
run_content_eval "$KIT" "references/redpanda" "kit routes to redpanda reference"
run_content_eval "$KIT" "references/deep-modules" "kit routes to deep-module enforcement"

for ref in toolchain biome quality-gate agent-config conventional-commits deep-modules env-validation react-compiler react-doctor zustand ci-pipeline react-rules redpanda; do
  run_file_eval "$REPO_ROOT/frontend-starter-kit/references/$ref/README.md" "reference exists: $ref"
done

DEEP="$REPO_ROOT/frontend-starter-kit/references/deep-modules"
run_file_eval "$DEEP/dependency-cruiser.config.cjs" "deep-module dependency-cruiser template exists"
run_content_eval "$DEEP/README.md" "bun\\.lock" "deep-module setup detects the current Bun lockfile"
run_content_eval "$DEEP/README.md" "co-located" "deep-module setup preserves co-located tests"
run_content_eval "$DEEP/README.md" "pass.*fail.*pass|PASS.*FAIL.*PASS" "deep-module setup proves rules bite"
run_content_eval "$DEEP/dependency-cruiser.config.cjs" "entrypoint-boundary" "deep-module template guards entry points"
run_content_eval "$DEEP/dependency-cruiser.config.cjs" "tests-through-entrypoints" "deep-module template tests through public entry points"
run_content_eval "$DEEP/dependency-cruiser.config.cjs" "test-files-are-private" "deep-module template keeps co-located test files private"

# Renamed daily-work skills exist under their new names
for skill in accessibility tanstack-router connect-query e2e-testing registry-workflow ux-copy; do
  run_file_eval "$REPO_ROOT/$skill/SKILL.md" "daily-work skill exists: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^name: $skill$" "daily-work skill renamed: $skill"
done

# No model-invoked setup-* skills remain (the 3 survivors are slash-only)
for d in "$REPO_ROOT"/setup-*/; do
  [ -d "$d" ] || continue
  name=$(basename "$d")
  if grep -q "disable-model-invocation: true" "$d/SKILL.md"; then
    echo "  PASS  $name is slash-only (zero context tax)"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $name is a model-invoked setup skill (should be folded or slash-only)"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $name model-invoked setup skill"
  fi
done
