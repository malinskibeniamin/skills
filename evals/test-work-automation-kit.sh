# Evals for work-automation-kit meta-skill

SKILL_DIR="$REPO_ROOT/work-automation-kit"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: work-automation-kit" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "disable-model-invocation: true" "work-automation-kit is slash-only (no trigger prose needed)"
run_content_eval "$SKILL_DIR/SKILL.md" "to-spec" "references to-spec (mattpocock)"
run_content_eval "$SKILL_DIR/SKILL.md" "explore mode" "references grilling explore mode (owned)"
run_content_eval "$SKILL_DIR/SKILL.md" "to-tickets" "references to-tickets (mattpocock)"
run_content_eval "$SKILL_DIR/SKILL.md" "visual-plan.*visual-recap.*plan-arbiter.*agent-watchdog.*read-the-damn-docs" "references Builder planning and review helpers"
run_content_eval "$SKILL_DIR/SKILL.md" "bunx skills@latest add" "uses bunx (not npx) to install"
run_content_eval "$SKILL_DIR/SKILL.md" "triage.*installed|installed.*triage" "setup detects whether triage labels are needed"
run_content_eval "$SKILL_DIR/SKILL.md" "recommended.*yes|yes.*recommended" "setup recommends the default triage labels"
run_content_eval "$SKILL_DIR/SKILL.md" "says no|answer is no|declines.*default" "setup asks for label overrides only after rejecting defaults"
run_content_eval "$SKILL_DIR/SKILL.md" "monorepo signals" "setup checks for monorepo signals"
run_content_eval "$SKILL_DIR/SKILL.md" "single-context.*without asking|without asking.*single-context" "setup defaults ordinary repos to single-context without another question"
run_content_eval "$SKILL_DIR/SKILL.md" "multi-context.*only.*monorepo|monorepo.*only.*multi-context" "setup offers multi-context only for monorepos"
run_content_eval "$SKILL_DIR/SKILL.md" "Confirm draft docs before writing" "setup preserves final write confirmation"
run_content_eval "$SKILL_DIR/SKILL.md" "### Issue tracker" "setup produces the tracker pointer consumed by workflow skills"
run_content_eval "$SKILL_DIR/SKILL.md" "issue-tracker\\.md" "setup links the tracker pointer to its configured document"
run_content_eval "$SKILL_DIR/REFERENCE.md" "### Issue tracker" "setup reference defines the tracker pointer shape"
run_content_eval "$SKILL_DIR/SKILL.md" "Verify.*### Issue tracker|### Issue tracker.*verify" "setup verifies the tracker pointer after writing"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Confirm.*### Issue tracker|### Issue tracker.*confirm" "setup reference verifies the tracker pointer after writing"
run_content_eval "$SKILL_DIR/SKILL.md" "CLAUDE\\.md.*first|If.*CLAUDE\\.md.*exists.*AGENTS\\.md" "setup defines instruction-file precedence"
run_content_eval "$SKILL_DIR/SKILL.md" "neither exists.*ask|ask.*neither exists" "setup asks which instruction file to create"

if grep -q 'Ask tracker, triage-label, and domain-doc decisions one at a time' "$SKILL_DIR/SKILL.md"; then
  echo "  FAIL  work automation removes the blanket three-question setup flow"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: work automation still requires all three setup questions"
else
  echo "  PASS  work automation removes the blanket three-question setup flow"
  PASS=$((PASS + 1))
fi

run_content_eval "$SKILL_DIR/SKILL.md" "triage" "references triage instead of qa"
if grep -qE "malinskibeniamin/skills/qa|/qa\b|design-an-interface|request-refactor-plan|ubiquitous-language" "$SKILL_DIR/SKILL.md" "$SKILL_DIR/REFERENCE.md"; then
  echo "  FAIL  work automation avoids removed legacy workflow skills"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: work automation still references removed legacy workflow skills"
else
  echo "  PASS  work automation avoids removed legacy workflow skills"
  PASS=$((PASS + 1))
fi
