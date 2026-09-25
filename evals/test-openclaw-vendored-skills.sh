# Evals for the OpenClaw test-audit backport and harness composition.

OPENCLAW_SHA="80930af448ebabc84174146b56bc106d37fab3b4"
SKILL="$REPO_ROOT/test-audit/SKILL.md"
CAMPAIGN="$REPO_ROOT/test-audit/CAMPAIGN.md"

run_file_eval "$SKILL" "vendored OpenClaw skill exists: test-audit"
run_content_eval "$SKILL" "^name: test-audit$" "test-audit has matching name"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\\./test-audit/" "Claude plugin registers test-audit"
run_content_eval "$REPO_ROOT/codex-skills/test-audit/SKILL.md" "\\.\\./\\.\\./test-audit/SKILL\\.md" "Codex mirror points at canonical test-audit"
run_file_eval "$REPO_ROOT/codex-skills/test-audit/agents/openai.yaml" "Codex mirror declares test-audit interface"
run_content_eval "$REPO_ROOT/test-audit/CREDITS.md" "$OPENCLAW_SHA" "test-audit credits pin the reviewed upstream revision"
run_content_eval "$REPO_ROOT/test-audit/CREDITS.md" "Copyright \\(c\\) 2026 OpenClaw Foundation" "test-audit credits carry the upstream MIT notice"
run_content_eval "$REPO_ROOT/README.md" "openclaw/openclaw.*test-audit" "README documents the OpenClaw backport"

# The value bar keeps its upstream contract.
run_content_eval "$SKILL" "\\[CAMPAIGN\\.md\\]\\(CAMPAIGN\\.md\\)" "test-audit links campaign mode"
run_content_eval "$SKILL" "^## Authoring gate" "test-audit owns the authoring gate"
run_content_eval "$SKILL" "^## Junk patterns" "test-audit owns the shared junk-pattern checklist"
run_content_eval "$SKILL" "^## Retention bar" "test-audit has a retention bar"
run_content_eval "$SKILL" "^## Candidate evidence" "test-audit requires candidate evidence before deletion"
run_content_eval "$SKILL" "fail on the pre-fix code" "regression tests must demonstrably fail first"
run_content_eval "$CAMPAIGN" "[Mm]utation" "campaign preservation review proves keepers with mutations"
run_content_eval "$CAMPAIGN" "\\*\\*ledger\\*\\*" "campaign records a per-declaration ledger"

# OpenClaw-only tooling maps onto this harness's owners.
if rg -n 'run-vitest\.mjs|check-changed\.mjs|\$crabbox|\$openclaw|\$autoreview|scripts/pr\b|extensions/' "$SKILL" "$CAMPAIGN" >/dev/null 2>&1; then
  echo "  FAIL  test-audit drops OpenClaw-only tooling"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: test-audit references OpenClaw-only tooling"
else
  echo "  PASS  test-audit drops OpenClaw-only tooling"
  PASS=$((PASS + 1))
fi
run_content_eval "$SKILL" "/review" "test-audit closes with /review"
run_content_eval "$SKILL" "/commit-push-pr" "test-audit lands through /commit-push-pr"
run_content_eval "$CAMPAIGN" "explicit.*delegat|/swarm" "campaign lanes parallelize only on explicit delegation"
run_content_eval "$REPO_ROOT/tdd/SKILL.md" "\\.\\./test-audit/SKILL\\.md#authoring-gate" "tdd routes new tests through the test-audit authoring gate"
run_content_eval "$REPO_ROOT/scripts/generate-skill-catalog.sh" '"test-audit":' "skill catalog has a test-audit short description"
