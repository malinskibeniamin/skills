# Evals for /ss: the value-review lens and its wiring into review surfaces.

SS_SKILL="$REPO_ROOT/ss/SKILL.md"
SS_RULES="$REPO_ROOT/ss/RULES.md"

run_file_eval "$SS_SKILL" "ss skill exists"
run_file_eval "$SS_RULES" "ss rule catalog exists"
run_file_eval "$REPO_ROOT/codex-skills/ss/SKILL.md" "ss has a Codex proxy entrypoint"

# The four buckets are the contract every PR is classified against.
for bucket in "Keep the lights on" "Quality of life" "Feature" "Design bet"; do
  run_content_eval "$SS_SKILL" "\\| $bucket \\|" "ss defines the $bucket bucket"
done

# The three verdicts and the value severity ladder stay explicit.
run_content_eval "$SS_SKILL" "\\*\\*justified\\*\\*" "ss defines the justified verdict"
run_content_eval "$SS_SKILL" "\\*\\*needs justification\\*\\*" "ss defines the needs-justification verdict"
run_content_eval "$SS_SKILL" "\\*\\*unlikely to pay off\\*\\*" "ss defines the unlikely-to-pay-off verdict"
run_content_eval "$SS_SKILL" "P1 Value" "ss reserves P1 for money or trust loss"
run_content_eval "$SS_SKILL" "Never block on taste alone" "ss leaves the value decision with the owner"

# Automated reviews stay quiet unless the value case is missing.
run_content_eval "$SS_SKILL" "at most three findings" "ss caps automated value findings"
run_content_eval "$SS_SKILL" "Silence means the value case is clear" "ss approves silently when justified"

# Every rule the skill cites exists in the catalog with a grade and support.
for rule in evidence-over-assertion reachable-by-user no-silent-no-op one-primary-bucket \
  name-the-beneficiary why-now acceptance-as-demo name-the-deal revenue-path-correctness \
  cost-in-dollars delete-what-doesnt-pay smallest-slice-that-proves-value default-off-reversible \
  protect-paying-customers; do
  run_content_eval "$SS_RULES" "^\\| [SAB] \\| \`$rule\` \\|" "ss catalog grades $rule"
done
run_content_eval "$SS_RULES" "recency-weighted" "ss catalog states its weighting"

# The catalog is anonymous: no personal handles, customer names, or ticket keys.
ss_leaks=$(grep -Eic 'simon|soriano|globalfoundries|fastweb|stifel|databricks|[A-Z]{2,}-[0-9]{2,}|cloudv2#|github\.com/redpanda' \
  "$SS_SKILL" "$SS_RULES" 2>/dev/null | awk -F: '{s+=$NF} END{print s+0}')
if [ "$ss_leaks" -eq 0 ]; then
  echo "  PASS  ss catalog carries no names, customers, or ticket keys"
  PASS=$((PASS + 1))
else
  echo "  FAIL  ss catalog leaks $ss_leaks identifying references"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: ss catalog leaks identifying references"
fi

# Review surfaces apply the lens automatically.
run_content_eval "$REPO_ROOT/review/SKILL.md" "/ss" "review applies the ss value lens"
run_content_eval "$REPO_ROOT/setup-routines/routines/pr-review.md" "/ss" "PR review routine runs the ss lens"
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" "Value: <one /ss bucket" "PR body template declares the ss bucket"

# Grades are mechanical: every catalog row's grade matches its weighted support.
ss_bad_grades=$(awk -F'|' '/^\| [SABC] \| `/ {
  g=$2; gsub(/ /,"",g); w=$(NF-1)+0
  want = (w>=10) ? "S" : (w>=7) ? "A" : (w>=4.5) ? "B" : "C"
  if (g != want) bad++
} END {print bad+0}' "$SS_RULES")
if [ "$ss_bad_grades" -eq 0 ]; then
  echo "  PASS  ss catalog grades match weighted support"
  PASS=$((PASS + 1))
else
  echo "  FAIL  ss catalog has $ss_bad_grades rows whose grade disagrees with support"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: ss catalog grade drift"
fi
