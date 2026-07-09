# Validates mattpocock/skills v1 shared design/domain model split:
#   - codebase-design owns architecture vocabulary
#   - tdd and improve-codebase-architecture invoke codebase-design
#   - domain-modeling owns active CONTEXT.md/ADR updates

CBD_DIR="$REPO_ROOT/codebase-design"
TDD_DIR="$REPO_ROOT/tdd"
DM_DIR="$REPO_ROOT/domain-modeling"
ICA_DIR="$REPO_ROOT/improve-codebase-architecture"

# ── codebase-design vocabulary ────────────────────────────────────
run_file_eval "$CBD_DIR/SKILL.md" "codebase-design SKILL.md exists"
run_file_eval "$CBD_DIR/DEEPENING.md" "codebase-design DEEPENING.md exists"
run_file_eval "$CBD_DIR/DESIGN-IT-TWICE.md" "codebase-design DESIGN-IT-TWICE.md exists"

for term in "Module" "Interface" "Implementation" "Depth" "Seam" "Adapter" "Leverage" "Locality"; do
  run_content_eval "$CBD_DIR/SKILL.md" "^\\*\\*$term\\*\\*" "codebase-design defines $term"
done

run_content_eval "$CBD_DIR/SKILL.md" "[Dd]eletion test" "codebase-design describes deletion test"
run_content_eval "$CBD_DIR/SKILL.md" "interface is the test surface" "codebase-design asserts interface=test surface"
run_content_eval "$CBD_DIR/SKILL.md" "One adapter.*hypothetical seam.*Two adapters.*real" "codebase-design has one-vs-two-adapters rule"
run_content_eval "$CBD_DIR/SKILL.md" "Boundary: use seam|Avoid: boundary" "codebase-design rejects boundary as overloaded"

# ── consumers invoke shared design skill ──────────────────────────
run_content_eval "$ICA_DIR/SKILL.md" "/codebase-design" "ICA invokes codebase-design"
run_content_eval "$TDD_DIR/SKILL.md" "/codebase-design" "tdd invokes codebase-design"
run_content_eval "$TDD_DIR/tests.md" "Good Tests" "tests.md keeps Good Tests section"
run_content_eval "$TDD_DIR/tests.md" "Bad Tests" "tests.md keeps Bad Tests section"
run_content_eval "$TDD_DIR/tests.md" "[Ii]ntegration-style" "tests.md prefers integration-style tests"
run_content_eval "$TDD_DIR/tests.md" "[Ii]mplementation-detail" "tests.md flags implementation-detail tests"
run_content_eval "$TDD_DIR/SKILL.md" "tests\\.md" "tdd SKILL.md references tests.md"

# ── domain-modeling active docs discipline ────────────────────────
run_file_eval "$DM_DIR/SKILL.md" "domain-modeling SKILL.md exists"
run_file_eval "$DM_DIR/ADR-FORMAT.md" "ADR-FORMAT.md exists in domain-modeling/"
run_file_eval "$DM_DIR/CONTEXT-FORMAT.md" "CONTEXT-FORMAT.md exists in domain-modeling/"
run_content_eval "$DM_DIR/SKILL.md" "Update CONTEXT.md inline" "domain-modeling updates CONTEXT.md inline"
run_content_eval "$DM_DIR/SKILL.md" "Offer ADRs sparingly" "domain-modeling offers ADRs sparingly"
run_content_eval "$ICA_DIR/SKILL.md" "/domain-modeling" "ICA invokes domain-modeling for side effects"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "/domain-modeling" "grilling invokes domain-modeling"

run_content_eval "$DM_DIR/ADR-FORMAT.md" "[Aa]rchitectural shape" "ADR-FORMAT lists architectural shape"
run_content_eval "$DM_DIR/ADR-FORMAT.md" "[Ii]ntegration patterns" "ADR-FORMAT lists integration patterns"
run_content_eval "$DM_DIR/ADR-FORMAT.md" "[Tt]echnology.*lock-in|lock-in" "ADR-FORMAT lists technology with lock-in"
run_content_eval "$DM_DIR/ADR-FORMAT.md" "[Bb]oundary.*decisions|[Bb]oundary and scope" "ADR-FORMAT lists boundary decisions"
run_content_eval "$DM_DIR/ADR-FORMAT.md" "[Dd]eliberate deviations" "ADR-FORMAT lists deliberate deviations"
run_content_eval "$DM_DIR/ADR-FORMAT.md" "[Cc]onstraints not visible|[Ii]nvisible constraints" "ADR-FORMAT lists invisible constraints"
run_content_eval "$DM_DIR/ADR-FORMAT.md" "[Rr]ejected alternatives|[Nn]on-obvious rejections" "ADR-FORMAT lists non-obvious rejections"
run_content_eval "$DM_DIR/ADR-FORMAT.md" "[Hh]ard to reverse" "ADR-FORMAT requires hard-to-reverse"
run_content_eval "$DM_DIR/ADR-FORMAT.md" "[Ss]urprising without context" "ADR-FORMAT requires surprising-without-context"
run_content_eval "$DM_DIR/ADR-FORMAT.md" "[Rr]eal trade-off|real alternatives" "ADR-FORMAT requires real trade-off"
