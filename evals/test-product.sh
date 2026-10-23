# Evals for /product: the single value skill, its catalogs, and its wiring into every
# plan, PR, and review surface.

PRODUCT_SKILL="$REPO_ROOT/product/SKILL.md"
PRODUCT_RULES="$REPO_ROOT/product/RULES.md"
PRODUCT_CRAFT="$REPO_ROOT/product/CRAFT.md"

run_file_eval "$PRODUCT_SKILL" "product skill exists"
run_file_eval "$PRODUCT_RULES" "product rule catalog exists"
run_file_eval "$PRODUCT_CRAFT" "product craft playbook exists"
run_file_eval "$REPO_ROOT/codex-skills/product/SKILL.md" "product has a Codex proxy entrypoint"

# One lane table, one verdict scale, one severity ladder.
for lane in "Keep the lights on" "Quality of life" "Feature" "Taste"; do
  run_content_eval "$PRODUCT_SKILL" "^\\| $lane \\|" "product defines the $lane lane"
done
for verdict in justified thin unjustified; do
  run_content_eval "$PRODUCT_SKILL" "^- \\*\\*$verdict\\*\\*:" "product defines the $verdict verdict"
done
run_content_eval "$PRODUCT_SKILL" 'P1 Value\*\*: false success' "product reserves P1 for trust, money, and one-way doors"
run_content_eval "$PRODUCT_SKILL" "Never block on taste alone" "product leaves taste calls with the owner"
run_content_eval "$PRODUCT_SKILL" 'product: <ktlo\|qol\|feature\|taste>' "product output leads with one verdict line"

# The same skill covers planning, authoring, review, and drift checks.
for mode in Plan Author Review Track; do
  run_content_eval "$PRODUCT_SKILL" "^\\| $mode \\|" "product defines the $mode mode"
done
run_content_eval "$PRODUCT_SKILL" '`on track`, `drifting`, or `park`' "track mode names drift and park outcomes"
run_content_eval "$PRODUCT_SKILL" "Given/When/Then" "plan mode writes acceptance scenarios"

# Automated reviews stay quiet unless the value case is missing.
run_content_eval "$PRODUCT_SKILL" "at most three P1 or P2 findings" "product caps automated value findings"
run_content_eval "$PRODUCT_SKILL" "Silence means the value case is clear" "product approves silently when justified"

# The core rules exist with a grade; each catalog section is reachable from the procedure.
for rule in name-the-beneficiary why-now reachable-by-user one-outcome-per-change \
  smallest-useful-slice demand-before-surface smallest-sufficient-mechanism measure-every-claim \
  verify-at-the-real-entrypoint acceptance-is-observable tests-discriminate price-the-run-cost \
  delete-what-doesnt-pay errors-users-can-act-on build-what-we-sell reuse-before-adding \
  guard-the-mistake-class ship-dark-then-widen protect-live-consumers observable-in-production \
  owner-decides-one-way-doors no-false-success claim-only-what-ships money-path-correctness; do
  run_content_eval "$PRODUCT_RULES" "^\\| [SABC] \\| \`$rule\` \\|" "product catalog grades $rule"
done
for section in Justification Scope Evidence "Keep the lights on" "Quality of life" Feature Taste \
  Delivery Trust Money; do
  run_content_eval "$PRODUCT_RULES" "^## $section" "product catalog has the $section section"
done
for craft in numbered-series revert-test read-back-after-write types-carry-meaning \
  errors-are-values necessity-first tests-grow-with-code test-refusal-and-no-op-paths \
  phase-shape-then-semantics; do
  run_content_eval "$PRODUCT_CRAFT" "^\\| \`$craft\` \\|" "product craft covers $craft"
done
run_content_eval "$PRODUCT_SKILL" 'CRAFT.md for non-generated source or test changes' \
  "product routes code changes to its craft playbook"
run_content_eval "$PRODUCT_SKILL" 'Name what the review could not verify and who should make the final call' \
  "product review output names verification gaps and their decision owner"

# Rule ids are unique across the catalog.
dup_rules=$(grep -oE '^\| [SABC] \| `[a-z-]+`' "$PRODUCT_RULES" | sort | uniq -d | wc -l | tr -d ' ')
if [ "$dup_rules" -eq 0 ]; then
  echo "  PASS  product rule ids are unique"
  PASS=$((PASS + 1))
else
  echo "  FAIL  product catalog repeats $dup_rules rule ids"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: product catalog repeats rule ids"
fi

# Grades are mechanical: S pts >= 10, A >= 7, B >= 4, else C; pts cannot exceed 3 per source.
bad_grades=$(awk -F'|' '/^\| [SABC] \| `/ {
  g=$2; gsub(/ /,"",g); pts=$(NF-1)+0; src=$(NF-2)+0
  want = (pts>=10) ? "S" : (pts>=7) ? "A" : (pts>=4) ? "B" : "C"
  if (g != want || src < 1 || src > 5 || pts > 3*src) bad++
} END {print bad+0}' "$PRODUCT_RULES")
if [ "$bad_grades" -eq 0 ]; then
  echo "  PASS  product grades match converging support"
  PASS=$((PASS + 1))
else
  echo "  FAIL  product catalog has $bad_grades rows whose grade disagrees with support"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: product catalog grade drift"
fi

# The skill is anonymous: no handles, ticket keys, PR or issue refs, or repo URLs.
leaks=$(grep -Ec '@[A-Za-z0-9-]{2,}|[A-Z]{2,}-[0-9]{2,}|[a-z0-9-]+#[0-9]{2,}|github\.com/' \
  "$PRODUCT_SKILL" "$PRODUCT_RULES" "$PRODUCT_CRAFT" 2>/dev/null | awk -F: '{s+=$NF} END{print s+0}')
if [ "$leaks" -eq 0 ]; then
  echo "  PASS  product carries no handles, ticket keys, or refs"
  PASS=$((PASS + 1))
else
  echo "  FAIL  product leaks $leaks identifying references"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: product leaks identifying references"
fi

# Every review, plan, and PR surface applies the one value skill.
run_content_eval "$REPO_ROOT/review/SKILL.md" 'Skill tool separately for "product" and "lie-detector"' \
  "review applies the product hat on every PR"
run_content_eval "$REPO_ROOT/review/REFERENCE.md" '^Value: product:' "review receipt carries the product verdict"
run_content_eval "$REPO_ROOT/setup-routines/routines/pr-review.md" 'apply the `/product` skill' \
  "PR review routine applies product"
run_content_eval "$REPO_ROOT/setup-routines/routines/pr-review.md" '`product:` and `lie-detector:` verdict lines' \
  "PR review approvals carry the product verdict"
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" '^- Lane: <Keep the lights on .*`/product`' \
  "PR body template declares the product lane"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" 'Skill tool separately with "product" for value' \
  "grilling routes the value axis to product"
run_content_eval "$REPO_ROOT/agents/plan-product-hat.md" 'product/SKILL\.md' "plan product hat applies product"
run_content_eval "$REPO_ROOT/steelman/SKILL.md" '`product:` verdict' "steelman merge premise reads the product verdict"

# The five value skills it replaced stay retired.
for retired in ss mm ms jb av; do
  if [ -e "$REPO_ROOT/$retired" ] || grep -qF "\"./$retired/\"" "$REPO_ROOT/.claude-plugin/plugin.json"; then
    echo "  FAIL  retired value skill still present or registered: $retired"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: retired value skill still present: $retired"
  else
    echo "  PASS  retired value skill removed: $retired"
    PASS=$((PASS + 1))
  fi
done
retired_refs=$(cd "$REPO_ROOT" && rg -n --hidden \
  -e '"(ss|mm|ms|jb|av)"( for value|[,;] | and)' \
  -e '`(ss|mm|ms|jb|av):`' \
  -e '(^|[^a-z0-9_-])(ss|mm|ms|jb|av)/(SKILL|RULES|CRAFT|REFERENCE)\.md' \
  -e '`/(ss|mm|ms|jb|av)`' \
  . --glob '!.git/**' --glob '!CHANGELOG.md' --glob '!evals/**' --glob '!.claude-plugin/**' \
  --glob '!docs-site/content/v[0-9]*/**' || true)
if [ -z "$retired_refs" ]; then
  echo "  PASS  live docs do not route to retired value skills"
  PASS=$((PASS + 1))
else
  echo "  FAIL  live docs still route to retired value skills"
  printf '%s\n' "$retired_refs" | sed 's/^/        /'
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: live docs still route to retired value skills"
fi
