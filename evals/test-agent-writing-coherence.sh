# Semantic regressions from the writing-for-agents audit.

assert_present() {
  local pattern="$1"
  local description="$2"
  shift 2
  if grep -qE -- "$pattern" "$@"; then
    echo "  PASS  $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $description"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
  fi
}

assert_absent() {
  local pattern="$1"
  local description="$2"
  shift 2
  if grep -qE -- "$pattern" "$@"; then
    echo "  FAIL  $description"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
  else
    echo "  PASS  $description"
    PASS=$((PASS + 1))
  fi
}

assert_present 'agents/references/findings-schema\.md' \
  "delegated review pointers use the canonical findings schema" \
  "$REPO_ROOT/development-lifecycle/REFERENCE.md" \
  "$REPO_ROOT/shared/subagent-start.sh" \
  "$REPO_ROOT/shared/subagent-stop.sh"
assert_absent 'agents/findings-schema\.md' \
  "stale findings-schema paths are gone" \
  "$REPO_ROOT/development-lifecycle/REFERENCE.md" \
  "$REPO_ROOT/shared/subagent-start.sh"
run_executable_eval "$REPO_ROOT/snyk-ux-security/scripts/codeowners-teams.sh" \
  "Snyk CODEOWNERS reviewer command exists"

assert_present 'disable-model-invocation: true' \
  "swarm requires explicit user invocation" "$REPO_ROOT/swarm/SKILL.md"
assert_absent 'Implementation pairs|setup-ux-copy' \
  "swarm has no stale automatic pair or skill pointer" "$REPO_ROOT/swarm/SKILL.md"
assert_present 'Without delegation.*sequential' \
  "revamp keeps one owner unless parallelism was authorized" "$REPO_ROOT/revamp/SKILL.md"
assert_absent 'Parallelize across \*\*worktrees\*\*' \
  "revamp does not imply worktree agents from invocation alone" "$REPO_ROOT/revamp/SKILL.md"
assert_present 'non-trivial PR or ship endpoint' \
  "revamp scopes cross-model review to the allowed endpoint" "$REPO_ROOT/revamp/SKILL.md"
assert_present 'explicit.*delegation|invokes? `/swarm`' \
  "wayfinder gates parallel research on consent" "$REPO_ROOT/wayfinder/SKILL.md"
assert_absent 'Fire research subagents|Parallel research subagents may' \
  "wayfinder does not auto-spawn research agents" "$REPO_ROOT/wayfinder/SKILL.md"
assert_absent 'Do not also resolve tickets by hand' \
  "wayfinder charting instructions agree on inline research" "$REPO_ROOT/wayfinder/SKILL.md"
assert_present 'requested endpoint' \
  "dependency upgrades honor the requested endpoint" "$REPO_ROOT/upgrade-dependency/SKILL.md"
assert_absent 'Many packages -> subagents' \
  "dependency upgrades do not auto-spawn package agents" "$REPO_ROOT/upgrade-dependency/SKILL.md"
assert_present 'inline' \
  "Go review is an inline axis by default" "$REPO_ROOT/golang-review/SKILL.md"
assert_absent 'one subagent' \
  "Go review does not imply a subagent" "$REPO_ROOT/golang-review/SKILL.md"
assert_present 'disable-model-invocation: true' \
  "go ships only after explicit invocation" "$REPO_ROOT/go/SKILL.md"
assert_present 'requested endpoint' \
  "work follows the request endpoint" "$REPO_ROOT/work/SKILL.md"
assert_absent 'starting features' \
  "grilling trigger excludes ordinary feature starts" "$REPO_ROOT/grilling/SKILL.md"
assert_present 'no production code or implementation' \
  "grilling gate permits its own decision artifacts" "$REPO_ROOT/grilling/SKILL.md"
assert_absent 'no code, no files, no implementation' \
  "grilling has no file-write contradiction" "$REPO_ROOT/grilling/SKILL.md"
assert_present 'asked to diagnose|hard bug' \
  "diagnosis trigger matches its hard-bug procedure" "$REPO_ROOT/diagnosing-bugs/SKILL.md"
assert_present 'Report mode' \
  "improve can audit without writing plan files" "$REPO_ROOT/improve/SKILL.md"

assert_present 'fix\(review\):' \
  "PR feedback uses a scoped conventional commit" "$REPO_ROOT/resolve-pr-feedback/SKILL.md"
assert_absent 'code-reviewer agent|up to 3 auto rounds' \
  "PR feedback uses current inline review policy" "$REPO_ROOT/resolve-pr-feedback/SKILL.md"
assert_present 'disable-model-invocation: true' \
  "visual recap is explicit extra-artifact work" "$REPO_ROOT/visual-recap/SKILL.md"
assert_absent 'should create or link.*visual recap|should treat recap' \
  "shipping docs do not auto-create visual recaps" \
  "$REPO_ROOT/visual-recap/SKILL.md" "$REPO_ROOT/setup-routines/SKILL.md"
assert_absent 'Do not interview.*Check with the user|A LONG|extremely extensive' \
  "to-spec has one bounded synthesis contract" "$REPO_ROOT/to-spec/SKILL.md"
assert_present 'one story per|Completion' \
  "to-spec defines story completion" "$REPO_ROOT/to-spec/SKILL.md"
assert_absent 'run `/work-automation-kit` if not|publish `/visual-plan` as the review artifact' \
  "to-spec does not imply unrelated setup or publication" "$REPO_ROOT/to-spec/SKILL.md"
assert_absent 'Always resolve; never `--abort`' \
  "merge conflict guidance allows safe escalation" "$REPO_ROOT/resolving-merge-conflicts/SKILL.md"
assert_absent 'Security review is intentionally absent|ALL hats with no skips permitted' \
  "review has no stale or contradictory hat policy" "$REPO_ROOT/review/SKILL.md"
assert_present 'stay-within-limits/select-review-profile\.sh' \
  "usage selector step names a resolvable path" "$REPO_ROOT/stay-within-limits/SKILL.md"
assert_absent 'cat .*handoff_file.*>/dev/null' \
  "handoff has no no-op temp-file read" "$REPO_ROOT/handoff/SKILL.md"
assert_absent 'Repo/code changes:' \
  "teach contains only teaching guidance" "$REPO_ROOT/teach/SKILL.md"
assert_absent '\.\.\. \|' \
  "ask-ben router descriptions end at complete words" "$REPO_ROOT/ask-ben/SKILL.md"
assert_present 'for skill in' \
  "work automation installs its declared workflow set from one source" \
  "$REPO_ROOT/work-automation-kit/SKILL.md"

assert_absent 'setup-registry-workflow|orchestration-guidance|npx opensrc|14 setup' \
  "Redpanda setup reference has no retired workflow" \
  "$REPO_ROOT/frontend-starter-kit/references/redpanda/README.md" \
  "$REPO_ROOT/frontend-starter-kit/references/redpanda/REFERENCE.md"
assert_absent 'proto-form-parallel-state-check|form-setvalue-options-check|form-error-summary-check|connect-error-fieldmap-check|setup-connect-query' \
  "React reference names current consolidated owners" \
  "$REPO_ROOT/frontend-starter-kit/references/react-rules/REFERENCE.md"
assert_absent 'PostToolUse hook block|Hook block/allow' \
  "env reference names Biome as the owner" \
  "$REPO_ROOT/frontend-starter-kit/references/env-validation/README.md"
assert_absent 'route-visual-test-check\.sh' \
  "visual review has no retired hook pointer" "$REPO_ROOT/visual-review/REFERENCE.md"

assert_absent 'no-memo\(compiler\)|no-raw-HTML' \
  "prompt context does not duplicate static project rules" \
  "$REPO_ROOT/.claude/hooks/user-prompt-context.sh"
assert_absent 'Code is liability.*smallest passing diff' \
  "violation summary reports evidence without a generic slogan" \
  "$REPO_ROOT/.claude/hooks/violation-summary-stop.sh"
assert_absent 'Auto mode safe' \
  "hook inventory makes no unsupported safety claim" \
  "$REPO_ROOT/.claude/hooks/session-env.sh"
assert_present 'pool=threads' \
  "test command guidance matches Vitest thread policy" \
  "$REPO_ROOT/.claude/hooks/llm-test-flags.sh"
assert_absent 'pool=forks|forceExit' \
  "test command guidance does not hide leaks or contradict pool policy" \
  "$REPO_ROOT/.claude/hooks/llm-test-flags.sh" \
  "$REPO_ROOT/frontend-starter-kit/references/agent-config/scripts/llm-test-flags.sh"
assert_present 'return-to-bound' \
  "branch guard has an executable recovery branch" \
  "$REPO_ROOT/.claude/hooks/branch-safety-check.sh"
assert_absent 'npx playwright|npm i -g' \
  "MCP remediation follows the configured toolchain" "$REPO_ROOT/.claude/hooks/mcp-ban.sh"

invalidate_owners=$(grep -l 'await-invalidate' \
  "$REPO_ROOT/.claude/hooks/checks/query-pattern-check.lib.sh" \
  "$REPO_ROOT/.claude/hooks/checks/connect-query-check.lib.sh" | wc -l | tr -d ' ')
if [ "$invalidate_owners" = "1" ]; then
  echo "  PASS  invalidateQueries has one hook owner"
  PASS=$((PASS + 1))
else
  echo "  FAIL  invalidateQueries has one hook owner"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: invalidateQueries has one hook owner"
fi

assert_absent 'Heavy getByRole usage' \
  "test hook preserves role-first selector guidance" \
  "$REPO_ROOT/.claude/hooks/checks/test-convention-check.lib.sh"
assert_present 'If this is a version upgrade' \
  "dependency hook points to upgrade workflow only on its branch" \
  "$REPO_ROOT/.claude/hooks/file-changed-deps.sh"
assert_present 'existing deployment' \
  "env hook limits follow-up to configured deployment owners" \
  "$REPO_ROOT/.claude/hooks/file-changed-env.sh"
assert_absent "grep -oE '#\\(\\[0-9\\]\\{4,\\}\\)'" \
  "intent hook does not guess that a bare issue number is a PR" \
  "$REPO_ROOT/.claude/hooks/intent-detect.sh"
assert_present 'pr-feedback-active' \
  "PR feedback Stop gate is scoped to its workflow" \
  "$REPO_ROOT/.claude/hooks/pr-feedback-completeness-stop.sh" \
  "$REPO_ROOT/.claude/hooks/skill-fire-log.sh"
assert_absent 'nudge-rtk|prefix with rtk' \
  "bash verbosity hook does not duplicate automatic rtk rewriting" \
  "$REPO_ROOT/.claude/hooks/bash-verbose-guard.sh"
assert_absent 'Drop everything' \
  "test warning recovery is direct rather than dramatic" \
  "$REPO_ROOT/.claude/hooks/test-warning-check.sh"
assert_absent 'stop-gaps' \
  "React Doctor names blocking findings precisely" \
  "$REPO_ROOT/.claude/hooks/react-doctor-stop.sh"
assert_present '__pycache__.*\.claude/skills.*skills-lock\.json' \
  "rm recovery message lists every allowed target" \
  "$REPO_ROOT/.claude/hooks/enforce-toolchain.sh"
assert_present 'security:' \
  "orchestration producer emits the category its consumer reads" \
  "$REPO_ROOT/.claude/hooks/checks/orchestration-guidance.lib.sh"
assert_absent 'test:|component:|route:|store:|jsx:' \
  "orchestration producer does not record unconsumed categories" \
  "$REPO_ROOT/.claude/hooks/checks/orchestration-guidance.lib.sh"

snyk_reference_lines=$(wc -l < "$REPO_ROOT/snyk-ux-security/REFERENCE.md" | tr -d ' ')
if [ "$snyk_reference_lines" -le 80 ] \
  && [ -f "$REPO_ROOT/snyk-ux-security/references/js.md" ] \
  && [ -f "$REPO_ROOT/snyk-ux-security/references/go.md" ] \
  && [ -f "$REPO_ROOT/snyk-ux-security/references/bazel.md" ] \
  && [ -f "$REPO_ROOT/snyk-ux-security/references/publish.md" ]; then
  echo "  PASS  Snyk reference is disclosed by ecosystem branch"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Snyk reference is disclosed by ecosystem branch"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Snyk reference is disclosed by ecosystem branch"
fi

assert_present 'If the requested endpoint includes a commit or PR' \
  "Snyk publication follows the requested endpoint" \
  "$REPO_ROOT/snyk-ux-security/SKILL.md"
assert_absent 'commit `.snyk`, then' \
  "Snyk local remediation does not imply a commit" \
  "$REPO_ROOT/snyk-ux-security/SKILL.md"
assert_present 'Report-only runs stop after scan and reachability' \
  "Snyk report mode is read-only" "$REPO_ROOT/snyk-ux-security/SKILL.md"
assert_present 'snyk monitor.*only when the requested endpoint includes a Snyk cloud update' \
  "Snyk cloud writes require the matching endpoint" "$REPO_ROOT/snyk-ux-security/SKILL.md"
assert_absent 'one `refactor\\(deps\\)` commit each|Trigger cloud review with' \
  "Snyk migration and cloud delivery are not unconditional" \
  "$REPO_ROOT/snyk-ux-security/SKILL.md"
