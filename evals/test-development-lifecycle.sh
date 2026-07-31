# Evals for the outcome-oriented development lifecycle.

SKILL_DIR="$REPO_ROOT/development-lifecycle"

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_content_eval "$SKILL_DIR/SKILL.md" "^name: development-lifecycle" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "high-level outcome through self-verification" "description states the result, not a phase chain"

for field in Objective Guardrails Verification Stop; do
  run_content_eval "$SKILL_DIR/SKILL.md" "\*\*$field\*\*" "lifecycle outcome contract defines $field"
done

run_content_eval "$SKILL_DIR/SKILL.md" "inspect -> act -> verify -> repeat" "lifecycle owns one evidence loop"
run_content_eval "$SKILL_DIR/SKILL.md" "blind spot" "lifecycle starts with the likeliest invalidating unknown"
run_content_eval "$SKILL_DIR/SKILL.md" "volatile unknown" "lifecycle orders discovery by volatility"
run_content_eval "$SKILL_DIR/SKILL.md" "demonstrated scale" "lifecycle designs for demonstrated scale"
run_content_eval "$SKILL_DIR/SKILL.md" "[Ss]ingle owner" "lifecycle keeps one owner"
run_content_eval "$SKILL_DIR/SKILL.md" "continue immediately" "ordinary implementation does not wait for approval"
run_content_eval "$SKILL_DIR/SKILL.md" "smallest obvious change" "implementation starts with the smallest clear change"
run_content_eval "$SKILL_DIR/SKILL.md" "RED -> smallest GREEN" "meaningful behavior uses TDD"
run_content_eval "$SKILL_DIR/SKILL.md" "public contract" "tests prove the public seam"
run_content_eval "$SKILL_DIR/SKILL.md" "Re-plan the affected slice" "evidence can revise the approach"
run_content_eval "$SKILL_DIR/SKILL.md" "real entrypoint" "verification includes actual use"
run_content_eval "$SKILL_DIR/SKILL.md" "failure becomes the next action" "failed evidence feeds the loop"
run_content_eval "$SKILL_DIR/SKILL.md" "user-reserved decision" "lifecycle pauses only for reserved decisions"
run_content_eval "$SKILL_DIR/SKILL.md" "requested endpoint" "lifecycle stops at the user endpoint"

run_content_eval "$SKILL_DIR/REFERENCE.md" "Outcome evidence by task" "reference branches by task evidence"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Bug branch" "reference has a root-cause bug branch"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Meaningful behavior branch" "reference has a TDD behavior branch"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Review depth" "reference scales review to evidence"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Endpoint evidence" "reference defines delivery completion"
run_content_eval "$SKILL_DIR/REFERENCE.md" "schedule fixed review rounds" "reference rejects review ceremony"

if grep -qE '^## Phase|^### Phase|2-5 min|/grilling|/dogfood|/resilience-review|self-reviewer|adversarial-reviewer|different-family' \
  "$SKILL_DIR/SKILL.md" "$SKILL_DIR/REFERENCE.md"; then
  echo "  FAIL  lifecycle retains phase, skill, or model ceremony"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: lifecycle ceremony remains"
else
  echo "  PASS  lifecycle has no phase, skill, or model ceremony"
  PASS=$((PASS + 1))
fi

desc=$(grep '^description:' "$SKILL_DIR/SKILL.md" | sed 's/^description: //' | tr -d '"')
desc_len=${#desc}
if [ "$desc_len" -le 180 ]; then
  echo "  PASS  description stays compact ($desc_len chars)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  description too long ($desc_len chars)"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: lifecycle description too long"
fi

line_count=$(wc -l < "$SKILL_DIR/SKILL.md" | tr -d ' ')
if [ "$line_count" -le 100 ]; then
  echo "  PASS  SKILL.md under 100 lines ($line_count)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  SKILL.md over 100 lines ($line_count)"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: lifecycle SKILL.md over 100 lines"
fi
