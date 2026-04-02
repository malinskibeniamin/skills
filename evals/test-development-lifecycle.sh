# Evals for development-lifecycle skill

SKILL_DIR="$REPO_ROOT/development-lifecycle"

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_content_eval "$SKILL_DIR/SKILL.md" "^name: development-lifecycle" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "Understand" "SKILL.md has understand phase"
run_content_eval "$SKILL_DIR/SKILL.md" "Plan" "SKILL.md has plan phase"
run_content_eval "$SKILL_DIR/SKILL.md" "Implement" "SKILL.md has implement phase"
run_content_eval "$SKILL_DIR/SKILL.md" "Review" "SKILL.md has review phase"
run_content_eval "$SKILL_DIR/SKILL.md" "TDD" "SKILL.md references TDD"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Iron Law" "REFERENCE has TDD iron law"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Spec Compliance" "REFERENCE has spec compliance review"
run_content_eval "$SKILL_DIR/REFERENCE.md" "codex" "REFERENCE has codex review instructions"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Common Agent Excuses" "REFERENCE has rationalization table"

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
