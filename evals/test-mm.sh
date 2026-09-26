# Evals for the /mm value hat and its review wiring.

SKILL="$REPO_ROOT/mm/SKILL.md"
RULES="$REPO_ROOT/mm/RULES.md"

run_file_eval "$SKILL" "mm SKILL.md exists"
run_file_eval "$RULES" "mm RULES.md exists"
run_content_eval "$SKILL" "RULES.md" "mm loads its rule catalog on demand"

for lane in "Keep the lights on" "Quality of life" "New capability" "Design taste"; do
  run_content_eval "$SKILL" "\*\*$lane\*\*" "mm defines the $lane lane"
done

run_content_eval "$SKILL" "exactly one primary lane" "mm assigns one lane per change"
run_content_eval "$SKILL" "Revenue likelihood" "mm rates revenue likelihood for new capability"
run_content_eval "$SKILL" "Never invent customers" "mm forbids fabricated demand"
run_content_eval "$SKILL" "never slow a cheap reversible bet" "mm keeps the ship-fast bias"
run_content_eval "$SKILL" "At most five findings" "mm caps review noise"
run_content_eval "$SKILL" "verdict: ship \| ship after fixes \| rethink scope \| not now" "mm emits a fixed verdict vocabulary"

missing_rules=""
for n in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do
  grep -qE "^## V$n\. " "$RULES" || missing_rules="$missing_rules V$n"
done
if [ -z "$missing_rules" ]; then
  echo "  PASS  mm RULES.md defines V1-V16"
  PASS=$((PASS + 1))
else
  echo "  FAIL  mm RULES.md missing:$missing_rules"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: mm RULES.md missing:$missing_rules"
fi

incomplete=$(awk '/^## V[0-9]+\. /{if (id != "" && fields < 5) print id; id=$2; fields=0; next}
  /^- \*\*(Ask|Satisfied by|Finding|Evidence|Support)\*\*/{fields++}
  END{if (id != "" && fields < 5) print id}' "$RULES")
if [ -z "$incomplete" ]; then
  echo "  PASS  every mm rule carries ask, satisfied-by, finding, evidence, and support"
  PASS=$((PASS + 1))
else
  echo "  FAIL  mm rules missing fields: $incomplete"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: mm rules missing fields: $incomplete"
fi

run_content_eval "$REPO_ROOT/review/SKILL.md" "every PR gets the \`/mm\` hat" "review runs the mm value hat on every PR"
run_content_eval "$REPO_ROOT/setup-routines/routines/pr-review.md" "Apply \`/mm\`" "PR-review routine runs the mm value hat"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\"\./mm/\"" "mm is registered in the Claude plugin"
