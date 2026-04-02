SKILL_DIR="$REPO_ROOT/systematic-debugging"

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_content_eval "$SKILL_DIR/SKILL.md" "^name: systematic-debugging" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"

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

run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_content_eval "$SKILL_DIR/SKILL.md" "root cause|Root Cause" "SKILL.md mentions root cause"
run_content_eval "$SKILL_DIR/SKILL.md" "Reproduce|reproduce" "SKILL.md has reproduce phase"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Defense-in-Depth|defense-in-depth" "REFERENCE has defense-in-depth"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Common Agent Excuses" "REFERENCE has rationalization table"
