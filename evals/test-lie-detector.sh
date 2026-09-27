# Evals for /lie-detector: truth axis for consumer-facing diffs and the steelman merge gate.

LD_SKILL="$REPO_ROOT/lie-detector/SKILL.md"

run_file_eval "$LD_SKILL" "lie-detector skill exists"
run_file_eval "$REPO_ROOT/codex-skills/lie-detector/SKILL.md" "lie-detector Codex wrapper exists"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '\./lie-detector/' "Claude plugin registers lie-detector"
run_content_eval "$REPO_ROOT/scripts/generate-skill-catalog.sh" '"lie-detector":' \
  "catalog generator knows lie-detector"

# Every run states a truth verdict and a merge verdict, even when clean.
run_content_eval "$LD_SKILL" 'lie-detector: <truthful|suspect|lying> -- merge <ready|not proven>' \
  "lie-detector output leads with a verdict line"
for lane in "Tests that cannot fail" "Claims without evidence" "Changes nobody asked for" \
  "Patterns that will spread" "Steelman gate"; do
  run_content_eval "$LD_SKILL" "^## [0-9]\. $lane" "lie-detector covers: $lane"
done

# A test is proven only by going red on broken behavior, not by reading it.
run_content_eval "$LD_SKILL" 'git apply -R' "lie-detector breaks the behavior to prove a test can fail"
run_content_eval "$LD_SKILL" 'test-audit/SKILL\.md#junk-patterns' \
  "lie-detector reuses the test-audit junk patterns"
# Hallucinated surfaces are checked against installed code or primary docs, not memory.
run_content_eval "$LD_SKILL" 'installed version' "lie-detector checks phantom APIs at the installed version"
# Copyable locations raise anti-pattern severity: one bad example spreads.
run_content_eval "$LD_SKILL" 'exemplar' "lie-detector weighs copy reach of anti-patterns"

# Merge-ready needs value, truth, and implementation together.
run_content_eval "$LD_SKILL" 'jb/SKILL\.md' "steelman gate reads the jb value verdict"
run_content_eval "$LD_SKILL" 'steelman/SKILL\.md' "steelman gate follows the steelman procedure"
run_content_eval "$LD_SKILL" '`justified`' "merge-ready requires a justified jb lane"
run_content_eval "$LD_SKILL" 'no P0/P1' "merge-ready requires a clean implementation review"

# Auto-invocation: customer-facing reviews apply the hat, steelman knows the merge premise,
# and the test-audit gate carries the frontend can-it-fail patterns.
run_content_eval "$REPO_ROOT/review/SKILL.md" 'lie-detector hat.*lie-detector/SKILL\.md' \
  "review applies the lie-detector hat on customer-facing diffs"
run_content_eval "$REPO_ROOT/review/REFERENCE.md" '^Truth: lie-detector:' \
  "review receipt carries the lie-detector verdict"
run_content_eval "$REPO_ROOT/setup-routines/routines/pr-review.md" '/lie-detector' \
  "PR review routine applies the truth axis"
run_content_eval "$REPO_ROOT/steelman/SKILL.md" 'merge premise' "steelman tests a PR merge premise"
run_content_eval "$REPO_ROOT/test-audit/SKILL.md" 'render regardless of the changed branch' \
  "test-audit rejects UI assertions that cannot fail"
run_content_eval "$REPO_ROOT/test-audit/SKILL.md" 'same change as the markup' \
  "test-audit rejects snapshots rewritten with the markup they pin"
run_content_eval "$REPO_ROOT/test-audit/SKILL.md" 'loosened, skipped' \
  "test-audit rejects assertions weakened to reach green"
