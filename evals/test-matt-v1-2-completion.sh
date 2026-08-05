# Regression coverage for the remaining mattpocock/skills v1.2 contracts.

WAIT_WHAT="$REPO_ROOT/wait-what/SKILL.md"
WIZARD="$REPO_ROOT/wizard/SKILL.md"
PROTOTYPE="$REPO_ROOT/prototype/SKILL.md"

run_file_eval "$WAIT_WHAT" "wait-what skill exists"
run_content_eval "$WAIT_WHAT" '^name: wait-what$' "wait-what has matching frontmatter"
run_content_eval "$WAIT_WHAT" '^disable-model-invocation: true$' "wait-what is user-invoked"
run_content_eval "$WAIT_WHAT" 'ASD-STE100 Simplified Technical English' "wait-what requests simplified English"
run_content_eval "$WAIT_WHAT" 'CONTEXT\.md' "wait-what reuses the project vocabulary"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"\./wait-what/"' "Claude plugin registers wait-what"
run_content_eval "$REPO_ROOT/scripts/generate-skill-catalog.sh" '"wait-what":' "catalog generator knows wait-what"
run_file_eval "$REPO_ROOT/codex-skills/wait-what/SKILL.md" "Codex packages wait-what"
run_content_eval "$REPO_ROOT/codex-skills/wait-what/agents/openai.yaml" \
  'allow_implicit_invocation: false' "Codex keeps wait-what explicit-use only"

run_content_eval "$WIZARD" '^description: .*human-only' \
  "wizard description names its human-only boundary"
run_content_eval "$WIZARD" 'infrastructure.*credentials or CI secrets.*third-party dashboards.*migrations.*cutovers' \
  "wizard description carries every model-invocation trigger"
run_content_eval "$WIZARD" 'Do not invoke it for work the agent can perform' \
  "wizard description excludes agent-executable work"
if grep -q '^disable-model-invocation:' "$WIZARD"; then
  echo "  FAIL  wizard remains user-invoked"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: wizard remains user-invoked"
else
  echo "  PASS  wizard is model-invoked"
  PASS=$((PASS + 1))
fi
if grep -q 'allow_implicit_invocation: false' "$REPO_ROOT/codex-skills/wizard/agents/openai.yaml"; then
  echo "  FAIL  Codex still blocks implicit wizard invocation"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Codex blocks implicit wizard invocation"
else
  echo "  PASS  Codex permits implicit wizard invocation"
  PASS=$((PASS + 1))
fi

run_content_eval "$PROTOTYPE" 'primary source' "prototype retains runnable primary-source evidence"
run_content_eval "$PROTOTYPE" '\.context/prototypes' "prototype has a no-commit retention destination"
run_content_eval "$PROTOTYPE" 'prototype/<name>' "prototype supports an isolated retention branch"
run_content_eval "$PROTOTYPE" 'endpoint.*authorizes commits|authorizes commits.*endpoint' \
  "prototype branch capture respects the requested endpoint"
run_content_eval "$PROTOTYPE" '[Dd]o not delete|never delete' "prototype is not deleted by default"
run_content_eval "$REPO_ROOT/prototype/LOGIC.md" 'retention policy.*SKILL\.md' \
  "logic prototypes defer to the canonical retention policy"
run_content_eval "$REPO_ROOT/prototype/UI.md" 'retention policy.*SKILL\.md' \
  "UI prototypes defer to the canonical retention policy"

if grep -qE 'Delete the artifact by default|delete it before shipping' "$PROTOTYPE"; then
  echo "  FAIL  prototype still instructs default deletion"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: prototype still defaults to deletion"
else
  echo "  PASS  prototype has one retention policy"
  PASS=$((PASS + 1))
fi
