# Evals for /ms: business-value review axis wired into /review.

MS_DIR="$REPO_ROOT/ms"

run_file_eval "$MS_DIR/SKILL.md" "ms skill exists"
run_file_eval "$MS_DIR/RULES.md" "ms rule catalog exists"
run_file_eval "$REPO_ROOT/codex-skills/ms/SKILL.md" "ms codex mirror exists"

# Every PR declares exactly one lane; the four lanes stay named in the skill.
run_content_eval "$MS_DIR/SKILL.md" "Keep the lights on" "ms names the maintenance lane"
run_content_eval "$MS_DIR/SKILL.md" "Quality of life" "ms names the quality-of-life lane"
run_content_eval "$MS_DIR/SKILL.md" "New value" "ms names the revenue lane"
run_content_eval "$MS_DIR/SKILL.md" "Taste" "ms names the design-taste lane"
run_content_eval "$MS_DIR/SKILL.md" "one lane" "ms requires one lane per PR"
run_content_eval "$MS_DIR/SKILL.md" "APPROVED" "ms has a clean verdict line"

# Catalog entries carry grades, and S/A rules are the enforced core.
run_content_eval "$MS_DIR/RULES.md" "^\\| S \\| \`value-beneficiary\`" "ms catalog grades the beneficiary rule"
run_content_eval "$MS_DIR/RULES.md" "accept-done-when" "ms catalog covers acceptance criteria"

# Auto-review: /review and the PR pre-flight apply the ms hat on every PR.
run_content_eval "$REPO_ROOT/review/SKILL.md" "ms/SKILL\\.md" "review applies the ms hat"
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" "\`/ms\`" "PR pre-flight lists the ms axis"
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" "^- Lane:" "PR body template declares a lane"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\"\\./ms/\"" "ms ships in the Claude plugin"

# The catalog is anonymous aggregate evidence: no handles, links, or ticket keys.
ms_leaks=$(grep -rnE "https?://|@[A-Za-z0-9-]+|[A-Z]{2,}-[0-9]{2,}|#[0-9]{3,}" "$MS_DIR" "$REPO_ROOT/codex-skills/ms" 2>/dev/null | wc -l | tr -d ' ')
if [ "$ms_leaks" -eq 0 ]; then
  echo "  PASS  ms stays anonymous (no handles, links, or ticket keys)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  ms leaks $ms_leaks identifying references"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: ms leaks identifying references"
fi
