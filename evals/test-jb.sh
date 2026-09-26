# Evals for /jb: value-lane review axis, its rule catalog, and its review wiring.

JB_SKILL="$REPO_ROOT/jb/SKILL.md"
JB_RULES="$REPO_ROOT/jb/RULES.md"

run_file_eval "$JB_SKILL" "jb skill exists"
run_file_eval "$JB_RULES" "jb rule catalog exists"
run_file_eval "$REPO_ROOT/codex-skills/jb/SKILL.md" "jb Codex wrapper exists"

# Every review states a lane and verdict, even when clean.
run_content_eval "$JB_SKILL" 'jb: <lane> -- <justified\|thin\|unjustified>' \
  "jb output leads with a verdict line"
for lane in ktlo qol growth taste; do
  run_content_eval "$JB_SKILL" "^\| \`$lane\` \|" "jb lane table defines $lane"
done
run_content_eval "$JB_SKILL" 'P1\*\*: non-trivial change with no identifiable beneficiary' \
  "jb escalates unjustified work to P1"
run_content_eval "$JB_SKILL" 'no caller' "jb escalates speculative scope"
run_content_eval "$JB_SKILL" 'falsifiable' "jb escalates missing acceptance criteria"
run_content_eval "$JB_SKILL" '[Dd]efault to approv' "jb keeps an approve-by-default posture"

# Auto-invocation: every PR review and the PR review routine apply the hat.
run_content_eval "$REPO_ROOT/review/SKILL.md" 'jb hat.*jb/SKILL\.md' \
  "review applies the jb hat on every PR"
run_content_eval "$REPO_ROOT/review/REFERENCE.md" '^Value: jb:' \
  "review receipt carries the jb verdict"
run_content_eval "$REPO_ROOT/setup-routines/routines/pr-review.md" '/jb' \
  "PR review routine applies the jb value axis"

# The catalog stays anonymous: aggregate counts only, no people or customers. The denylist
# is stored as truncated SHA-256 hashes so this check does not publish the names it guards.
named=$(python3 - "$JB_SKILL" "$JB_RULES" <<'PY'
import hashlib, re, sys
deny = {"8c431d6a56286376", "1d4b41c9db9172e5", "0f2d4cb0963c29ec", "78c4544269d9e516",
        "e0088c4805a2684d", "47679f81beb4cebd", "d530e674d548f1a5", "abcc9e6038121f4e"}
words = {w.lower() for path in sys.argv[1:] for w in re.findall(r"[^\W\d_]+", open(path).read())}
print(sum(hashlib.sha256(w.encode()).hexdigest()[:16] in deny for w in words))
PY
)
if [ "$named" != "0" ]; then
  echo "  FAIL  jb names a person or customer"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: jb names a person or customer"
else
  echo "  PASS  jb stays anonymous"
  PASS=$((PASS + 1))
fi

# Grades are mechanical: each rule's grade must match its weighted support.
grade_errors=$(python3 - "$JB_RULES" <<'PY'
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
    want = "S" if w >= 50 else "A" if w >= 25 else "B" if w >= 12.5 else "C"
    if grade != want:
        bad.append(f"{rule}:{grade}!={want}")
if rows < 30:
    bad.append(f"only {rows} rules parsed")
print(" ".join(bad))
PY
)
if [ -z "$grade_errors" ]; then
  echo "  PASS  jb rule grades match weighted-support thresholds"
  PASS=$((PASS + 1))
else
  echo "  FAIL  jb rule grades drift: $grade_errors"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: jb rule grades drift: $grade_errors"
fi

# The skill routes to these catalog sections.
for section in Scope Evidence Delivery Contracts Taste Cost; do
  run_content_eval "$JB_RULES" "^## $section " "jb catalog has the $section section"
  run_content_eval "$JB_SKILL" "$section" "jb skill routes to the $section section"
done
