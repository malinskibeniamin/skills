# Evals for the inline 3-hat grill gate (Phase 2b of /grilling).

AGENT_DIR="$REPO_ROOT/agents"
PLAN_SCHEMA="$AGENT_DIR/references/plan-findings-schema.md"

run_file_eval "$PLAN_SCHEMA" "plan findings schema exists"
run_content_eval "$PLAN_SCHEMA" "Evidence packet" "plan schema defines the shared evidence packet"
run_content_eval "$PLAN_SCHEMA" "spec_sources" "plan schema carries spec sources"
run_content_eval "$PLAN_SCHEMA" "standards_sources" "plan schema carries standards sources"
run_content_eval "$PLAN_SCHEMA" "planned_paths" "plan schema carries planned paths"
run_content_eval "$PLAN_SCHEMA" "assumptions" "plan schema carries assumptions"
run_content_eval "$PLAN_SCHEMA" "blocking" "plan findings identify blockers"
run_content_eval "$PLAN_SCHEMA" "confidence" "plan findings carry confidence"
run_content_eval "$PLAN_SCHEMA" "section" "plan findings preserve report sections"
run_content_eval "$PLAN_SCHEMA" "must_answer" "plan findings surface decisions"
run_content_eval "$PLAN_SCHEMA" "skip_reason" "plan axes explain skips"

for hat in plan-product-hat plan-engineering-hat plan-design-hat; do
  run_file_eval "$AGENT_DIR/$hat.md" "$hat.md exists"
  run_content_eval "$AGENT_DIR/$hat.md" "^name: $hat" "$hat has name frontmatter"
  run_content_eval "$AGENT_DIR/$hat.md" "^model: inherit" "$hat inherits usage-routed model"
  run_content_eval "$AGENT_DIR/$hat.md" "^allowed-tools:" "$hat declares allowed-tools"
  run_content_eval "$AGENT_DIR/$hat.md" "Applied inline by /grilling" "$hat is an inline grilling hat"
  run_content_eval "$AGENT_DIR/$hat.md" "plan-findings-schema" "$hat references plan-findings-schema"
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
run_content_eval "$AGENT_DIR/plan-product-hat.md" "Spec axis" "product-hat owns the separate Spec axis"
run_content_eval "$AGENT_DIR/plan-product-hat.md" "section.*spec" \
  "product-hat labels Spec findings"

run_content_eval "$AGENT_DIR/plan-engineering-hat.md" "[Aa]rchitecture" "engineering-hat covers architecture"
run_content_eval "$AGENT_DIR/plan-engineering-hat.md" "[Rr]ollback" "engineering-hat covers rollback"
run_content_eval "$AGENT_DIR/plan-engineering-hat.md" "test_first" "engineering-hat surfaces test_first"
run_content_eval "$AGENT_DIR/plan-engineering-hat.md" "Standards axis" \
  "engineering-hat owns the separate Standards axis"
run_content_eval "$AGENT_DIR/plan-engineering-hat.md" "section.*standards" \
  "engineering-hat labels Standards findings"

run_content_eval "$AGENT_DIR/plan-design-hat.md" "[Aa]ccessibility" "design-hat covers a11y"
run_content_eval "$AGENT_DIR/plan-design-hat.md" "[Ee]mpty" "design-hat covers empty state"
run_content_eval "$AGENT_DIR/plan-design-hat.md" "[Kk]eyboard" "design-hat covers kbd path"
run_content_eval "$AGENT_DIR/plan-design-hat.md" "section.*design" \
  "design-hat labels Design findings"

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
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "ETHOS: Discover Before Commitment" \
  "/grilling cross-references ETHOS principle"
if grep -q "spawn them.*parallel" "$REPO_ROOT/grilling/SKILL.md"; then
  echo "  FAIL  /grilling still auto-spawns parallel plan agents"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: grilling still auto-spawns agents"
else
  echo "  PASS  /grilling does not auto-spawn plan agents"
  PASS=$((PASS + 1))
fi

# Review-grade plan gate mechanics
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "Evidence packet" \
  "/grilling gathers one evidence packet"
for tier in Quick Standard Deep-risk; do
  run_content_eval "$REPO_ROOT/grilling/SKILL.md" "\\*\\*$tier\\*\\*" \
    "/grilling defines the $tier plan-review tier"
done
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "auth.*migration.*public API.*destructive" \
  "/grilling names trust-boundary deep-risk triggers"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "concurrency.*Temporal.*cross-service.*one-way" \
  "/grilling names coordination deep-risk triggers"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "Spec.*plan-product-hat" \
  "/grilling assigns Spec to the product hat"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "Standards.*plan-engineering-hat" \
  "/grilling assigns Standards to the engineering hat"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "adversarial/value" \
  "/grilling includes the adversarial/value axis"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "root cause" \
  "/grilling deduplicates findings by root cause"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "skip reason" \
  "/grilling forbids silent axis skips"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "Specialist registry" \
  "/grilling defines conditional specialist routing"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "go\\.mod|planned Go" \
  "/grilling detects planned Go work"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "/golang" \
  "/grilling routes planned Go work through golang guidance"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "/resilience-review" \
  "/grilling deep-risk plans receive a resilience pass"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "/steelman" \
  "/grilling deep-risk plans steelman the highest-risk assumption"
