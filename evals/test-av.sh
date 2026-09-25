# Evals for /av: value-lane review axis, its rule catalog, and its review/planning wiring.

AV_SKILL="$REPO_ROOT/av/SKILL.md"
AV_RULES="$REPO_ROOT/av/RULES.md"

run_file_eval "$AV_SKILL" "av skill exists"
run_file_eval "$AV_RULES" "av rule catalog exists"
run_file_eval "$REPO_ROOT/codex-skills/av/SKILL.md" "av Codex wrapper exists"

# Every review states a lane and verdict, even when clean.
run_content_eval "$AV_SKILL" 'av: <lane> -- <justified\|thin\|unjustified>' \
  "av output leads with a verdict line"
for lane in ktlo qol growth taste; do
  run_content_eval "$AV_SKILL" "^\| \`$lane\` \|" "av lane table defines $lane"
done
run_content_eval "$AV_SKILL" 'P1\*\*: non-trivial change with no identifiable beneficiary' \
  "av escalates unjustified work to P1"
run_content_eval "$AV_SKILL" 'money-path risk' "av escalates money-path risk"

# Auto-invocation: every PR review and every plan gate applies the hat.
run_content_eval "$REPO_ROOT/review/SKILL.md" 'av hat.*av/SKILL\.md' \
  "review applies the av hat on every PR"
run_content_eval "$REPO_ROOT/review/REFERENCE.md" '^Value: av:' \
  "review receipt carries the av verdict"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" 'value uses `/av`' \
  "grilling routes the value axis to av"
run_content_eval "$REPO_ROOT/agents/plan-product-hat.md" 'av/SKILL\.md' \
  "product hat applies the av value lane"

# Grades are mechanical: each rule's grade must match its weighted support.
grade_errors=$(python3 - "$AV_RULES" <<'PY'
import re, sys
bad = []
rows = 0
for line in open(sys.argv[1]):
    m = re.match(r"\| ([SABC]) \| `([a-z0-9-]+)` \|.*\| (\d+) \| ([\d.]+) \|$", line.rstrip())
    if not m:
        continue
    rows += 1
    grade, rule, _, w = m.groups()
    w = float(w)
    want = "S" if w >= 14 else "A" if w >= 7 else "B" if w >= 3.5 else "C"
    if grade != want:
        bad.append(f"{rule}:{grade}!={want}")
if rows < 20:
    bad.append(f"only {rows} rules parsed")
print(" ".join(bad))
PY
)
if [ -z "$grade_errors" ]; then
  echo "  PASS  av rule grades match weighted-support thresholds"
  PASS=$((PASS + 1))
else
  echo "  FAIL  av rule grades drift: $grade_errors"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: av rule grades drift: $grade_errors"
fi

# The skill routes to these catalog sections.
for section in Scope Money Trust Delivery Taste; do
  run_content_eval "$AV_RULES" "^## $section " "av catalog has the $section section"
done
