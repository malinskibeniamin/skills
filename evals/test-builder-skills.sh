# Evals for BuilderIO skill vendoring and harness wiring.

BUILDER_SKILLS=(
  agent-watchdog
  efficient-fable
  efficient-frontier
  plan-arbiter
  plow-ahead
  quick-recap
  read-the-damn-docs
  stay-within-limits
  visual-plan
  visual-recap
)

PLUGIN="$REPO_ROOT/.claude-plugin/plugin.json"

for skill in "${BUILDER_SKILLS[@]}"; do
  run_file_eval "$REPO_ROOT/$skill/SKILL.md" "Builder skill exists: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^name: $skill$" "Builder skill has matching name: $skill"
  run_content_eval "$PLUGIN" "\./$skill/" "Claude plugin registers Builder skill: $skill"
done

run_content_eval "$REPO_ROOT/visual-plan/SKILL.md" "Agent-Native|visual plan|references/agent-native-plan.md" "visual-plan keeps Agent-Native plan contract"
run_content_eval "$REPO_ROOT/visual-recap/SKILL.md" "create-visual-recap|Agent-Native|references/agent-native-recap.md" "visual-recap keeps Agent-Native recap contract"
run_file_eval "$REPO_ROOT/visual-plan/references/agent-native-plan.md" "visual-plan upstream reference exists"
run_file_eval "$REPO_ROOT/visual-recap/references/agent-native-recap.md" "visual-recap upstream reference exists"
run_file_eval "$REPO_ROOT/visual-plan/references/wireframe.md" "visual-plan wireframe reference exists"
run_file_eval "$REPO_ROOT/visual-recap/references/wireframe.md" "visual-recap wireframe reference exists"

run_content_eval "$REPO_ROOT/scripts/sync-agent-native-plan-skills.mjs" "visual-plan|visual-recap|AGENT_NATIVE" "Agent Native visual sync script exists"
run_content_eval "$REPO_ROOT/.github/workflows/update-agent-native-plan-skills.yml" "Refresh visual-plan and visual-recap|sync:agent-native-plan-skills" "Agent Native visual sync workflow exists"

run_content_eval "$REPO_ROOT/swarm/SKILL.md" "/stay-within-limits" "swarm checks usage limits between waves"
run_content_eval "$REPO_ROOT/swarm/SKILL.md" "/efficient-frontier" "swarm uses efficient frontier delegation discipline"
run_content_eval "$REPO_ROOT/brainstorming/SKILL.md" "/plan-arbiter|competing plans" "brainstorming routes competing plans through plan-arbiter"
run_content_eval "$REPO_ROOT/grill-me/SKILL.md" "/plan-arbiter|competing plans" "grill-me routes competing plans through plan-arbiter"
run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" "/visual-recap" "commit-push-pr creates visual recap for PRs"
run_content_eval "$REPO_ROOT/go/SKILL.md" "/visual-recap" "go includes visual recap before PR handoff"
run_content_eval "$REPO_ROOT/research/SKILL.md" "/read-the-damn-docs" "research uses read-the-damn-docs for official docs"
run_content_eval "$REPO_ROOT/review/SKILL.md" "/agent-watchdog" "review can watchdog other agent or PR work"
run_content_eval "$REPO_ROOT/resolve-pr-feedback/SKILL.md" "/agent-watchdog" "resolve-pr-feedback can watchdog completeness"
run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "/plow-ahead" "development lifecycle supports plow-ahead autonomy"
run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" "/quick-recap" "commit-push-pr ends with quick recap status"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "/visual-plan.*Builder|/agent-watchdog.*Builder|/read-the-damn-docs" "ask-ben routes Builder skills"
