# Evals for mattpocock/skills v1 taxonomy and renamed skills.

# Upstream public skills that this harness vendors directly.
MATT_V1_SKILLS=(
  ask-ben
  codebase-design
  diagnosing-bugs
  domain-modeling
  grilling
  implement
  resolving-merge-conflicts
  research
  wayfinder
  writing-great-skills
)

for skill in "${MATT_V1_SKILLS[@]}"; do
  run_file_eval "$REPO_ROOT/$skill/SKILL.md" "Matt v1 skill exists: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^name: $skill$" "Matt v1 skill has matching name: $skill"
  run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\\./$skill/" "Claude plugin registers Matt v1 skill: $skill"
done

# Renamed/removed upstream surfaces should not remain slash-invocable.
for removed in diagnose write-a-skill caveman zoom-out; do
  if [ ! -e "$REPO_ROOT/$removed/SKILL.md" ]; then
    echo "  PASS  upstream-removed skill not present: $removed"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  upstream-removed skill still present: $removed"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: upstream-removed skill still present: $removed"
  fi
  if ! grep -q "\\./$removed/" "$REPO_ROOT/.claude-plugin/plugin.json"; then
    echo "  PASS  Claude plugin does not register removed skill: $removed"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  Claude plugin still registers removed skill: $removed"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: Claude plugin still registers removed skill: $removed"
  fi
done

# User-invoked skills explicitly disable model invocation.
for skill in ask-ben grill-me grill-with-docs handoff implement improve-codebase-architecture prototype teach to-issues to-prd triage writing-great-skills; do
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^disable-model-invocation: true$" "$skill is user-invoked"
done

# Model-invoked reusable skills omit disable-model-invocation.
for skill in codebase-design diagnosing-bugs domain-modeling grilling research resolving-merge-conflicts tdd wayfinder; do
  if grep -q "^disable-model-invocation:" "$REPO_ROOT/$skill/SKILL.md" 2>/dev/null; then
    echo "  FAIL  $skill should be model-invoked"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $skill should be model-invoked"
  else
    echo "  PASS  $skill is model-invoked"
    PASS=$((PASS + 1))
  fi
done

# Shared v1 skills are composed by the existing harness entrypoints.
run_content_eval "$REPO_ROOT/grill-me/SKILL.md" "/grilling" "grill-me delegates to grilling"
run_content_eval "$REPO_ROOT/grill-with-docs/SKILL.md" "/grilling" "grill-with-docs delegates interview loop to grilling"
run_content_eval "$REPO_ROOT/grill-with-docs/SKILL.md" "/domain-modeling" "grill-with-docs updates docs through domain-modeling"
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "/codebase-design" "ICA uses codebase-design vocabulary"
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "/domain-modeling" "ICA uses domain-modeling for side effects"
run_content_eval "$REPO_ROOT/tdd/SKILL.md" "/codebase-design" "TDD uses codebase-design for interface design"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "frontend/React/TypeScript/Go" "ask-ben is tailored to Ben work"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "/grill-with-docs" "ask-ben routes planning through grill-with-docs"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "/diagnosing-bugs" "ask-ben routes hard bugs to diagnosing-bugs"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "/research" "ask-ben routes reading legwork to research"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "Do not enact the plan until I confirm" "grilling has confirmation gate"
run_content_eval "$REPO_ROOT/tdd/SKILL.md" "pre-agreed seams|confirm.*seams" "TDD requires agreed test seams"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "Claim.*assigning" "wayfinder claims tickets by assignment"
run_content_eval "$REPO_ROOT/writing-great-skills/SKILL.md" "Hunt no-ops|No-op" "writing-great-skills includes no-op hunting guidance"
run_file_eval "$REPO_ROOT/writing-great-skills/GLOSSARY.md" "writing-great-skills glossary exists"
run_content_eval "$REPO_ROOT/teach/SKILL.md" "./assets/|Assets" "teach includes v1.0.1 reusable assets guidance"
