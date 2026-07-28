# Evals for the inline 3-hat grill gate (Phase 2b of /grilling).

AGENT_DIR="$REPO_ROOT/agents"

for hat in plan-product-hat plan-engineering-hat plan-design-hat; do
  run_file_eval "$AGENT_DIR/$hat.md" "$hat.md exists"
  run_content_eval "$AGENT_DIR/$hat.md" "^name: $hat" "$hat has name frontmatter"
  run_content_eval "$AGENT_DIR/$hat.md" "^model: inherit" "$hat inherits usage-routed model"
  run_content_eval "$AGENT_DIR/$hat.md" "^allowed-tools:" "$hat declares allowed-tools"
  run_content_eval "$AGENT_DIR/$hat.md" "Applied inline by /grilling" "$hat is an inline grilling hat"
  run_content_eval "$AGENT_DIR/$hat.md" "findings-schema" "$hat references findings-schema"
  run_content_eval "$AGENT_DIR/$hat.md" "must_answer" "$hat emits must_answer list"
  run_content_eval "$AGENT_DIR/$hat.md" "Non-Goals" "$hat declares non-goals"

  # Registered in plugin.json
  run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\"./agents/$hat.md\"" \
    "plugin.json registers $hat"
done

# Each hat is distinct — no overlap in responsibilities
run_content_eval "$AGENT_DIR/plan-product-hat.md" "persona" "product-hat covers persona"
run_content_eval "$AGENT_DIR/plan-product-hat.md" "[Ss]uccess metric" "product-hat covers success metric"
run_content_eval "$AGENT_DIR/plan-product-hat.md" "[Rr]eversibility" "product-hat covers reversibility"

run_content_eval "$AGENT_DIR/plan-engineering-hat.md" "[Aa]rchitecture" "engineering-hat covers architecture"
run_content_eval "$AGENT_DIR/plan-engineering-hat.md" "[Rr]ollback" "engineering-hat covers rollback"
run_content_eval "$AGENT_DIR/plan-engineering-hat.md" "test_first" "engineering-hat surfaces test_first"

run_content_eval "$AGENT_DIR/plan-design-hat.md" "[Aa]ccessibility" "design-hat covers a11y"
run_content_eval "$AGENT_DIR/plan-design-hat.md" "[Ee]mpty" "design-hat covers empty state"
run_content_eval "$AGENT_DIR/plan-design-hat.md" "[Kk]eyboard" "design-hat covers kbd path"

# grilling wired to inline review
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "Plan gate" \
  "/grilling has three-hat fan-out section"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "plan-product-hat" \
  "/grilling invokes plan-product-hat"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "plan-engineering-hat" \
  "/grilling invokes plan-engineering-hat"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "plan-design-hat" \
  "/grilling invokes plan-design-hat"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "inline" \
  "/grilling runs hats inline"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "BLOCKED" \
  "/grilling honors BLOCKED status"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "ETHOS: Grill Before Build" \
  "/grilling cross-references ETHOS principle"
if grep -q "spawn them.*parallel" "$REPO_ROOT/grilling/SKILL.md"; then
  echo "  FAIL  /grilling still auto-spawns parallel plan agents"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: grilling still auto-spawns agents"
else
  echo "  PASS  /grilling does not auto-spawn plan agents"
  PASS=$((PASS + 1))
fi
