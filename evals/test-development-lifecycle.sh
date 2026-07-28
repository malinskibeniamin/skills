# Evals for development-lifecycle skill

SKILL_DIR="$REPO_ROOT/development-lifecycle"

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_content_eval "$SKILL_DIR/SKILL.md" "^name: development-lifecycle" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use (when|for)" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "Understand" "SKILL.md has understand phase"
run_content_eval "$SKILL_DIR/SKILL.md" "Plan" "SKILL.md has plan phase"
run_content_eval "$SKILL_DIR/SKILL.md" "Implement" "SKILL.md has implement phase"
run_content_eval "$SKILL_DIR/SKILL.md" "Review" "SKILL.md has review phase"
run_content_eval "$SKILL_DIR/SKILL.md" "TDD" "SKILL.md references TDD"
run_content_eval "$SKILL_DIR/SKILL.md" "smallest obvious" "SKILL.md starts with smallest design"
run_content_eval "$SKILL_DIR/SKILL.md" "demonstrated scale" "SKILL.md designs for demonstrated scale"
run_content_eval "$SKILL_DIR/SKILL.md" "[Ss]ingle owner" "SKILL.md uses single-owner implementation"
run_content_eval "$SKILL_DIR/SKILL.md" "continue immediately" "SKILL.md continues ordinary implementation without approval"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Test meaningful behavior" "REFERENCE scopes TDD to meaningful behavior"
run_content_eval "$SKILL_DIR/REFERENCE.md" "P1_RCA --> P2" "bug fixes receive a concise plan before implementation"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Spec Compliance" "REFERENCE has spec compliance review"
run_content_eval "$SKILL_DIR/REFERENCE.md" "foreground.*Sol high|Sol high.*foreground" "REFERENCE has bounded cross-model review instructions"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Hard Rules" "REFERENCE has hard rules"

# ── Phase 4b (Refine) ───────────────────────────────────────────
run_content_eval "$SKILL_DIR/SKILL.md" "4b.*Refine" "SKILL.md has Phase 4b (Refine)"
run_content_eval "$SKILL_DIR/SKILL.md" "inline self/adversarial review" "SKILL.md keeps review axes inline"
run_content_eval "$SKILL_DIR/SKILL.md" "awaited cross-model review" "SKILL.md keeps one foreground cross-model pass"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Phase 4b.*Refine" "REFERENCE has Phase 4b section"
run_content_eval "$SKILL_DIR/REFERENCE.md" "self-reviewer" "REFERENCE references self-reviewer"
run_content_eval "$SKILL_DIR/REFERENCE.md" "adversarial-reviewer" "REFERENCE references adversarial-reviewer"
run_content_eval "$SKILL_DIR/REFERENCE.md" "findings-schema" "REFERENCE references findings-schema"
run_content_eval "$SKILL_DIR/REFERENCE.md" "SubagentStart" "REFERENCE documents SubagentStart hook"
run_content_eval "$SKILL_DIR/REFERENCE.md" "SubagentStop" "REFERENCE documents SubagentStop hook"

# ── Routing table includes 4b ────────────────────────────────────
run_content_eval "$SKILL_DIR/SKILL.md" "4b\\. Review" "SKILL.md routing includes phase 4b"
run_content_eval "$SKILL_DIR/SKILL.md" "5\\. Ship" "SKILL.md routing includes phase 5"

desc=$(grep '^description:' "$SKILL_DIR/SKILL.md" | sed 's/^description: //' | tr -d '"')
desc_len=${#desc}
if [ $desc_len -le 250 ]; then
  echo "  PASS  description under 250 chars ($desc_len)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  description over 250 chars ($desc_len)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: description over 250 chars ($desc_len)"
fi

line_count=$(wc -l < "$SKILL_DIR/SKILL.md" | tr -d ' ')
if [ "$line_count" -le 100 ]; then
  echo "  PASS  SKILL.md under 100 lines ($line_count)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  SKILL.md over 100 lines ($line_count)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: SKILL.md over 100 lines ($line_count)"
fi
