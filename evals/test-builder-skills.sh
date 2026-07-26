# Evals for BuilderIO skill vendoring and harness wiring.

BUILDER_SKILLS=(
  agent-watchdog
  efficient-frontier
  plan-arbiter
  plow-ahead
  read-the-damn-docs
  visual-plan
  visual-recap
)

PLUGIN="$REPO_ROOT/.claude-plugin/plugin.json"

for skill in "${BUILDER_SKILLS[@]}"; do
  run_file_eval "$REPO_ROOT/$skill/SKILL.md" "Builder skill exists: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^name: $skill$" "Builder skill has matching name: $skill"
  run_content_eval "$PLUGIN" "\./$skill/" "Claude plugin registers Builder skill: $skill"

  if grep -qE "Vendored from Builder\.io|Builder\.io\. Read|Builder\.io Agent-Native" "$REPO_ROOT/$skill/SKILL.md"; then
    echo "  FAIL  Builder skill avoids origin-label prose: $skill"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: Builder skill has origin-label prose: $skill"
  else
    echo "  PASS  Builder skill avoids origin-label prose: $skill"
    PASS=$((PASS + 1))
  fi

  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "references/" "Builder skill uses progressive disclosure: $skill"
done

run_content_eval "$REPO_ROOT/visual-plan/SKILL.md" "Agent-Native|visual plan|references/agent-native-plan.md" "visual-plan keeps Agent-Native plan contract"
run_content_eval "$REPO_ROOT/visual-recap/SKILL.md" "create-visual-recap|Agent-Native|references/agent-native-recap.md" "visual-recap keeps Agent-Native recap contract"
run_file_eval "$REPO_ROOT/visual-plan/references/agent-native-plan.md" "visual-plan upstream reference exists"
run_file_eval "$REPO_ROOT/visual-recap/references/agent-native-recap.md" "visual-recap upstream reference exists"
run_file_eval "$REPO_ROOT/visual-plan/references/wireframe.md" "visual-plan wireframe reference exists"
run_file_eval "$REPO_ROOT/visual-recap/references/wireframe.md" "visual-recap wireframe reference exists"

run_content_eval "$REPO_ROOT/scripts/sync-agent-native-plan-skills.mjs" "visual-plan|visual-recap|AGENT_NATIVE" "Agent Native visual sync script exists"
run_content_eval "$REPO_ROOT/.github/workflows/update-agent-native-plan-skills.yml" "Refresh visual-plan and visual-recap|sync:agent-native-plan-skills" "Agent Native visual sync workflow exists"

run_content_eval "$REPO_ROOT/swarm/SKILL.md" "/efficient-frontier" "swarm uses efficient frontier delegation discipline"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "/plan-arbiter|competing plans" "brainstorming routes competing plans through plan-arbiter"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "/plan-arbiter|competing plans" "grilling routes competing plans through plan-arbiter"
run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" "/visual-recap" "commit-push-pr creates visual recap for PRs"
run_content_eval "$REPO_ROOT/go/SKILL.md" "/visual-recap" "go includes visual recap before PR handoff"
run_content_eval "$REPO_ROOT/review/SKILL.md" "/agent-watchdog" "review can watchdog other agent or PR work"
run_content_eval "$REPO_ROOT/resolve-pr-feedback/SKILL.md" "/agent-watchdog" "resolve-pr-feedback can watchdog completeness"
run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "/plow-ahead" "development lifecycle supports plow-ahead autonomy"
run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" "status line" "commit-push-pr ends with a status line"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "/visual-plan.*Builder|/agent-watchdog.*Builder|/read-the-damn-docs" "ask-ben routes Builder skills"
run_content_eval "$REPO_ROOT/visual-review/REFERENCE.md" "/visual-plan" "visual-review can publish visual plans for planned surfaces"
run_content_eval "$REPO_ROOT/visual-review/REFERENCE.md" "/visual-recap" "visual-review can feed visual recaps for implemented surfaces"
run_content_eval "$REPO_ROOT/visual-review/REFERENCE.md" "/plan-arbiter" "visual-review arbitrates competing visual directions"
run_content_eval "$REPO_ROOT/visual-review/REFERENCE.md" "Visual artifacts|/visual-plan|/visual-recap" "visual-review reference distinguishes review from visual artifacts"
run_content_eval "$REPO_ROOT/improve/SKILL.md" "/visual-plan|/plan-arbiter" "architecture improvement can publish/arbitrate visual plans"
run_content_eval "$REPO_ROOT/codebase-design/SKILL.md" "/plan-arbiter" "codebase design compares alternate module designs through plan-arbiter"
run_content_eval "$REPO_ROOT/to-spec/SKILL.md" "/visual-plan|/read-the-damn-docs|/plan-arbiter" "to-spec uses visual plans docs and arbitration"
run_content_eval "$REPO_ROOT/to-tickets/SKILL.md" "/plan-arbiter|/visual-plan" "to-tickets can arbitrate and visualize ticket graphs"
run_content_eval "$REPO_ROOT/setup-routines/SKILL.md" "/agent-watchdog|/visual-recap" "routines setup wires watchdog and visual recap"
run_content_eval "$REPO_ROOT/diagnosing-bugs/SKILL.md" "/read-the-damn-docs" "diagnosing-bugs reads official docs for external drift"
run_content_eval "$REPO_ROOT/resilience-review/SKILL.md" "/read-the-damn-docs|/visual-plan" "resilience-review uses docs and plans for edge-case surfaces"
run_content_eval "$REPO_ROOT/upgrade-dependency/SKILL.md" "/read-the-damn-docs" "upgrade-dependency routes current release facts through docs skill"
run_content_eval "$REPO_ROOT/tdd/SKILL.md" "/read-the-damn-docs" "tdd uses docs for externally specified behavior"
run_content_eval "$REPO_ROOT/prime/SKILL.md" "/agent-watchdog.*/plan-arbiter.*/read-the-damn-docs" "prime distrusts agent claims and external facts with Builder helpers"
run_content_eval "$REPO_ROOT/triage/SKILL.md" "/read-the-damn-docs.*/plan-arbiter.*/visual-plan" "triage routes external behavior plans and epics through Builder helpers"
run_content_eval "$REPO_ROOT/wizard/SKILL.md" "/read-the-damn-docs" "wizard reads official docs before third-party manual steps"
run_content_eval "$REPO_ROOT/codex-compat/SKILL.md" "/read-the-damn-docs.*/plan-arbiter" "codex compat checks current docs and arbitrates mappings"
run_content_eval "$REPO_ROOT/hook-audit/SKILL.md" "/visual-plan" "hook audit visualizes large actions"
run_content_eval "$REPO_ROOT/hook-audit/SKILL.md" "/plan-arbiter" "hook audit arbitrates conflicting recommendations"
run_content_eval "$REPO_ROOT/hook-audit/SKILL.md" "/agent-watchdog" "hook audit verifies agent reports"
run_content_eval "$REPO_ROOT/resolving-merge-conflicts/SKILL.md" "/agent-watchdog.*/plan-arbiter" "merge conflicts watchdog agent branches and arbitrate semantic choices"
run_content_eval "$REPO_ROOT/frontend-starter-kit/references/ci-pipeline/README.md" "/read-the-damn-docs" "setup-ci-pipeline reads current GitHub Actions docs"
run_content_eval "$REPO_ROOT/e2e-testing/SKILL.md" "/read-the-damn-docs" "setup-e2e-testing reads current Playwright docs"
run_content_eval "$REPO_ROOT/frontend-starter-kit/references/react-compiler/README.md" "/read-the-damn-docs" "setup-react-compiler reads current compiler docs"
run_content_eval "$REPO_ROOT/tanstack-router/SKILL.md" "/read-the-damn-docs" "setup-tanstack-router reads current router docs"
run_content_eval "$REPO_ROOT/connect-query/SKILL.md" "/read-the-damn-docs" "setup-connect-query reads current Connect docs"

run_content_eval "$REPO_ROOT/read-the-damn-docs/SKILL.md" "quick official fact check|without creating a research artifact|no research artifact" "read-the-damn-docs owns quick official fact checks"
