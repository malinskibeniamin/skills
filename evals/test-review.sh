# Evals for the evidence-oriented review contract.

SKILL="$REPO_ROOT/review/SKILL.md"
REF="$REPO_ROOT/review/REFERENCE.md"
CONTRACT_EVAL="$REPO_ROOT/agent-evals/evals/contract-tracing-review"
DOGFOOD_REVIEW_EVAL="$REPO_ROOT/agent-evals/evals/dogfood-review-live-data"
CONTRACT_EXPERIMENT="$REPO_ROOT/agent-evals/experiments/review.ts"

run_file_eval "$SKILL" "review SKILL.md exists"
run_file_eval "$REF" "review REFERENCE.md exists"
run_content_eval "$SKILL" "Use (when|for)" "review description uses trigger wording"
run_content_eval "$SKILL" "REFERENCE.md" "review uses one-level progressive disclosure"

for field in Objective Guardrails Verification Stop; do
  run_content_eval "$SKILL" "\*\*$field\*\*" "review contract defines $field"
done

run_content_eval "$SKILL" "inspect -> verify -> classify -> synthesize" "review uses one evidence loop"
run_content_eval "$SKILL" "fixed point" "review pins a comparison base"
run_content_eval "$SKILL" "complete diff" "review inspects the whole change"
run_content_eval "$SKILL" "Do not trust a PR summary" "review trusts code over summaries"
run_content_eval "$SKILL" "standards separate from product/spec" "review separates standards and spec"
run_content_eval "$SKILL" "formatter-owned style and pre-existing defects" "review excludes static noise"
run_content_eval "$SKILL" "real entrypoint" "review exercises runnable behavior"
run_content_eval "$SKILL" "intended path and one credible failure or recovery path" "review checks intended and unhappy paths"
run_content_eval "$SKILL" "test integrity" "review checks behavior proof"
run_content_eval "$SKILL" "[Ss]ource-text" "review treats source-text proxies as missing behavior coverage"
run_content_eval "$SKILL" "public (output|artifact)" "review preserves public-artifact assertions"
run_content_eval "$SKILL" "semantic density" "review challenges unjustified additions"
run_content_eval "$SKILL" "reverse-trace.*authoritative" "review reverse-traces changed assumptions"
run_content_eval "$SKILL" "Search by domain concept" "review searches beyond diff-local names"
run_content_eval "$SKILL" "changed symbol" "review does not stop at changed names"
run_content_eval "$SKILL" "independent artifacts" "review triangulates surprising claims"
run_content_eval "$SKILL" "independent artifacts in relevant unchanged code" "review checks relevant evidence outside the diff"
run_content_eval "$SKILL" "recent history" "review checks recent implementation context"
run_content_eval "$SKILL" "fixtures.*production shape" "review checks fixture fidelity"
run_content_eval "$SKILL" "behavioral counterexample" "review requires a concrete counterexample"
run_content_eval "$SKILL" "Dogfood every runnable change yourself" "review requires experiential use"
run_content_eval "$SKILL" "representative live-scale data" "review exercises realistic data"
run_content_eval "$SKILL" "console/network/logs.*response time" "review observes runtime and performance evidence"
run_content_eval "$SKILL" "entrypoint.*data.*actions.*observations.*timing.*limits" "review reports a dogfood receipt"
run_content_eval "$SKILL" "surface-specific scrutiny only when the diff supplies evidence" "specialist depth is evidence-triggered"
run_content_eval "$SKILL" "Customer-facing UI/CLI/report" "review recognizes visible surfaces"
run_content_eval "$SKILL" "Security/privacy/data loss" "review recognizes high-impact failure surfaces"
run_content_eval "$SKILL" "API/schema/SQL" "review recognizes contract and data surfaces"
run_content_eval "$SKILL" "Go/concurrency/workflows" "review recognizes concurrency surfaces"
run_content_eval "$SKILL" "Dependency/external API" "review recognizes external drift"
run_content_eval "$SKILL" "diff-introduced" "review reports only introduced defects"
run_content_eval "$SKILL" "No performance finding without measurement" "review rejects unmeasured performance nits"
run_content_eval "$SKILL" "No edge-case finding" "review rejects hypothetical edge cases"
run_content_eval "$SKILL" "Deduplicate by root cause" "review deduplicates findings"
run_content_eval "$SKILL" "For a re-review" "re-review anchors prior findings"
run_content_eval "$SKILL" "Deep mode" "review retains a high-stakes audit mode"
run_content_eval "$SKILL" "complete applicability ledger" "deep mode accounts for every surface"
run_content_eval "$SKILL" "Do not edit, commit, push" "review is diagnostic-only"
run_content_eval "$SKILL" "Posting comments" "review does not mutate GitHub by default"
run_content_eval "$SKILL" "tightest changed line" "review targets accurate comment locations"

run_content_eval "$REF" "Fowler smell baseline" "reference keeps the smell baseline"
run_content_eval "$REF" "Mysterious Name" "reference includes Mysterious Name"
run_content_eval "$REF" "Speculative Generality" "reference includes Speculative Generality"
run_content_eval "$REF" "standard always wins" "repository standards override generic smells"
run_content_eval "$REF" "Report schema" "reference defines the report shape"
run_content_eval "$REF" "Example inline comment" "reference gives a concrete comment example"
run_content_eval "$REF" "Evidence:.*reproduction or concrete path" "findings require evidence"
run_content_eval "$REF" "Verify:.*command or replay" "findings include self-verification"

run_file_eval "$CONTRACT_EVAL/EVAL.ts" "contract-tracing behavioral grader exists"
run_file_eval "$CONTRACT_EVAL/PROMPT.md" "contract-tracing behavioral prompt exists"
run_content_eval "$CONTRACT_EVAL/PROMPT.md" "Run available checks.*passing" "contract prompt keeps green tests subordinate to review"
run_file_eval "$DOGFOOD_REVIEW_EVAL/EVAL.ts" "dogfood-review behavioral grader exists"
run_file_eval "$DOGFOOD_REVIEW_EVAL/PROMPT.md" "dogfood-review behavioral prompt exists"
run_file_eval "$CONTRACT_EXPERIMENT" "contract-tracing review experiment exists"
run_content_eval "$CONTRACT_EVAL/EVAL.ts" "structured.*presentation" "contract grader distinguishes semantic and display fields"
run_content_eval "$CONTRACT_EVAL/EVAL.ts" "cross-field collision" "contract grader requires a concrete false-positive"
run_content_eval "$CONTRACT_EVAL/EVAL.ts" "fixture" "contract grader checks fixture fidelity"
run_content_eval "$DOGFOOD_REVIEW_EVAL/EVAL.ts" "bun.*run.*demo" "dogfood grader requires the real entrypoint"
run_content_eval "$DOGFOOD_REVIEW_EVAL/EVAL.ts" "live-data.*correctness" "dogfood grader checks observed live-data behavior"
run_content_eval "$DOGFOOD_REVIEW_EVAL/EVAL.ts" "performance" "dogfood grader checks measured performance"
run_content_eval "$CONTRACT_EXPERIMENT" "contract-tracing-review" "review experiment selects the golden eval"
run_content_eval "$CONTRACT_EXPERIMENT" "dogfood-review-live-data" "review experiment selects the dogfood eval"
run_content_eval "$CONTRACT_EVAL/PROMPT.md" "synthetic" "contract fixture declares synthetic provenance"
run_content_eval "$CONTRACT_EVAL/PROMPT.md" "fictional" "contract fixture declares fictional context"
run_file_eval "$CONTRACT_EVAL/repo/src/activity/filter.ts" "contract fixture uses a generic feature boundary"
run_file_eval "$CONTRACT_EVAL/repo/schema/activity.schema.json" "contract fixture uses a generic schema boundary"

if grep -qE 'Run `/|Use `/agent-watchdog|Hat panel|different-family|claude_eligible|value score HIGH|/steelman' "$SKILL" "$REF"; then
  echo "  FAIL  review retains skill or model panel ceremony"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: review ceremony remains"
else
  echo "  PASS  review has no skill or model panel ceremony"
  PASS=$((PASS + 1))
fi

review_skill_lines=$(wc -l < "$SKILL" | tr -d ' ')
if [ "$review_skill_lines" -le 100 ]; then
  echo "  PASS  review SKILL.md stays compact ($review_skill_lines lines)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  review SKILL.md too long ($review_skill_lines lines)"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: review SKILL.md too long"
fi
