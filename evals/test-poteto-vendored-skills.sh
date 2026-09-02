# Evals for the curated Poteto/pstack backport and harness composition.

POTETO_SHA="efa2a531985e0a8084d36ff3cf87233be8a9f34b"
POTETO_SKILLS=(
  blast-radius
  create-verification-skill
  maintain-verification-skill
)

for skill in "${POTETO_SKILLS[@]}"; do
  run_file_eval "$REPO_ROOT/$skill/SKILL.md" "vendored Poteto skill exists: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^name: $skill$" "vendored Poteto skill has matching name: $skill"
  run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\\./$skill/" "Claude plugin registers Poteto skill: $skill"

  if grep -qE '^metadata:|^[[:space:]]+(author|vendored_from):' "$REPO_ROOT/$skill/SKILL.md"; then
    echo "  FAIL  Poteto skill omits per-skill provenance metadata: $skill"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: Poteto skill has redundant provenance metadata: $skill"
  else
    echo "  PASS  Poteto skill omits per-skill provenance metadata: $skill"
    PASS=$((PASS + 1))
  fi
done

if [ -e "$REPO_ROOT/shared/POTETO-PSTACK-LICENSE.md" ]; then
  echo "  FAIL  redundant standalone Poteto license is absent"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: redundant standalone Poteto license remains"
else
  echo "  PASS  redundant standalone Poteto license is absent"
  PASS=$((PASS + 1))
fi
run_file_eval "$REPO_ROOT/shared/POTETO-ENGINEERING.md" "curated Poteto principles have one canonical reference"
run_content_eval "$REPO_ROOT/shared/POTETO-ENGINEERING.md" "$POTETO_SHA" "curated Poteto principles pin the reviewed upstream revision"

# Blast radius owns non-local safety proof instead of another generic review.
run_content_eval "$REPO_ROOT/blast-radius/SKILL.md" "one.*fact.*safe|safety.*hinges" "blast-radius isolates the decisive safety invariant"
run_content_eval "$REPO_ROOT/blast-radius/SKILL.md" "line.*counterexample.*executable.*entrypoint|source.*counterexample.*script.*running" "blast-radius has an escalating proof ladder"
run_content_eval "$REPO_ROOT/blast-radius/SKILL.md" "unproven" "blast-radius labels facts that cannot be executed"

# Verification generation is portable and proves its own output.
run_content_eval "$REPO_ROOT/create-verification-skill/SKILL.md" "\\.agents/skills/verify-<app>" "verification skill uses a portable project-local default"
run_content_eval "$REPO_ROOT/create-verification-skill/SKILL.md" "Launch.*Doctor.*Drive.*Evidence.*Cleanup" "verification skill defines the complete runtime contract"
run_content_eval "$REPO_ROOT/create-verification-skill/SKILL.md" "run.*instructions.*end to end|[Ee]xecute.*generated skill" "verification skill must prove generated instructions"
run_content_eval "$REPO_ROOT/create-verification-skill/SKILL.md" "evidence.*survives.*cleanup|cleanup.*evidence" "verification cleanup preserves proof"
run_file_eval "$REPO_ROOT/create-verification-skill/references/feature-map-example/README.md" "verification feature-map reference exists"

# Maintenance distinguishes docs/harness drift from product defects.
run_content_eval "$REPO_ROOT/maintain-verification-skill/SKILL.md" "clean.*changed.*blocked" "verification maintenance has explicit outcomes"
run_content_eval "$REPO_ROOT/maintain-verification-skill/SKILL.md" "Never edit product code|Do not edit product code" "verification maintenance cannot hide product regressions"
run_content_eval "$REPO_ROOT/maintain-verification-skill/SKILL.md" "source.*live|live.*source" "verification maintenance requires source and live coverage"

# Existing owners compose the new behavior instead of duplicating it.
run_content_eval "$REPO_ROOT/review/SKILL.md" "/blast-radius" "review routes non-local safety claims through blast-radius"
run_content_eval "$REPO_ROOT/review/DEEP-AUDIT.md" "POTETO-ENGINEERING.md" "deep review loads curated Poteto structural guidance"
run_content_eval "$REPO_ROOT/codebase-design/SKILL.md" "POTETO-ENGINEERING.md" "codebase design shares Poteto structural guidance"
run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "/create-verification-skill" "lifecycle can close a missing real-entrypoint harness gap"
run_content_eval "$REPO_ROOT/dogfood/SKILL.md" "verify-\\*|verify-<app>" "dogfood prefers a project-local verification skill"
run_content_eval "$REPO_ROOT/dogfood/SKILL.md" "/maintain-verification-skill" "dogfood routes verifier drift to its maintenance owner"
run_content_eval "$REPO_ROOT/README.md" "pstack.*blast-radius.*create-verification-skill.*maintain-verification-skill" "README documents the curated Poteto backport"

# Poteto's global mode, duplicate owners, and automatic-agent workflows conflict
# with this harness's single-owner execution contract and stay unregistered.
for excluded in architect how no-comments poteto-mode technical-writing unslop why; do
  if [ -e "$REPO_ROOT/$excluded/SKILL.md" ] || grep -q "\"./$excluded/\"" "$REPO_ROOT/.claude-plugin/plugin.json"; then
    echo "  FAIL  duplicate or incompatible Poteto skill stays unregistered: $excluded"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: excluded Poteto skill registered: $excluded"
  else
    echo "  PASS  duplicate or incompatible Poteto skill stays unregistered: $excluded"
    PASS=$((PASS + 1))
  fi
done

if rg -n "Spawn|subagent_type|one .*subagent|Task.*subagent" \
  "$REPO_ROOT/blast-radius/SKILL.md" \
  "$REPO_ROOT/create-verification-skill/SKILL.md" \
  "$REPO_ROOT/maintain-verification-skill/SKILL.md" >/dev/null 2>&1; then
  echo "  FAIL  curated Poteto skills do not auto-spawn agents"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: curated Poteto skill contains automatic-agent instructions"
else
  echo "  PASS  curated Poteto skills do not auto-spawn agents"
  PASS=$((PASS + 1))
fi
