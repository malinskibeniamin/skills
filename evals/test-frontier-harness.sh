#!/bin/bash

# Contract for the quality-first, low-context frontier-model harness.

run_absent_eval() {
  local file="$1"
  local pattern="$2"
  local description="$3"

  if [ -f "$file" ] && ! grep -qE -- "$pattern" "$file"; then
    echo "  PASS  $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $description"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
  fi
}

run_json_eval() {
  local expression="$1"
  local file="$2"
  local description="$3"

  if jq -e "$expression" "$file" >/dev/null 2>&1; then
    echo "  PASS  $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $description"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
  fi
}

run_file_eval "config/model-routing.json" "model routing is data, not ambient prose"
run_json_eval '.quality_first.default.model == "gpt-5.6-sol"
  and .quality_first.default.effort == "xhigh"
  and (.quality_first.hard.efforts | index("max"))
  and .quality_first.ultra.requires_explicit_delegation
  and (.quality_first.ui_owners | index("gpt-5.6-sol"))
  and .models["gpt-5.6-terra"].status == "eval-gated"
  and .models["gpt-5.6-luna"].status == "eval-gated"' \
  "config/model-routing.json" "routing reflects quality-first GPT-5.6 capabilities"

run_file_eval "agent-evals/context-ablation/manifest.json" "ablation matrix is versioned"
run_json_eval '.schema_version == 2
  and (.capabilities | has("codex"))
  and (.capabilities | has("claude-code"))
  and (.variants | index("current"))
  and (.variants | index("lean"))
  and (.metrics | index("task_success"))
  and (.metrics | index("regressions"))
  and (.metrics | index("input_tokens"))
  and any(.capabilities.codex.models[]; .id == "gpt-5.6-sol" and (.efforts | index("xhigh")) and (.efforts | index("max")))
  and any(.capabilities["claude-code"].models[]; .id == "claude-fable-5-1")
  and any(.capabilities["claude-code"].models[]; .id == "claude-opus-5")' \
  "agent-evals/context-ablation/manifest.json" "ablation compares families, context, effort, quality, and cost"
run_executable_eval "agent-evals/context-ablation/run.sh" "ablation runner is executable"
run_json_eval 'any(.capabilities["claude-code"].models[];
  .id == "claude-fable-5-1" and .efforts == ["low", "medium", "high", "xhigh", "max"])' \
  "agent-evals/context-ablation/manifest.json" "ablation includes every Fable 5.1 effort"
run_json_eval 'any(.capabilities["claude-code"].models[];
  .id == "claude-opus-5" and .efforts == ["high", "xhigh"])' \
  "agent-evals/context-ablation/manifest.json" \
  "ablation includes Opus as a Claude alternative"

run_content_eval "evals/run.sh" 'HOOK_METRICS_DISABLED=1' "fixture evals cannot pollute production telemetry"
run_content_eval ".claude/hooks/skill-fire-log.sh" 'HOOK_METRICS_DISABLED' "skill telemetry honors isolation"
run_content_eval ".claude/hooks/session-end.sh" 'HOOK_METRICS_DISABLED' "session telemetry honors isolation"
run_content_eval ".claude/hooks/model-switch-router.sh" '/efficient-frontier' \
  "model switches revalidate the active route"
run_content_eval ".claude/hooks/model-switch-router.sh" '/prime' \
  "resumed model switches can refresh stale state"
run_content_eval "hook-audit/SKILL.md" '/quantify-impact' \
  "model-switch policy changes require measured impact"

run_executable_eval ".claude/hooks/codex-edit-dispatch.sh" "Codex edit dispatcher is executable"
run_executable_eval ".claude/hooks/stop-dispatch.sh" "endpoint-aware Stop dispatcher is executable"
run_json_eval '."x-codex-edit-dispatch" == "codex-edit-dispatch.sh"
  and has("x-codex-per-call") == false
  and (.hooks.Stop[""] | length) == 1
  and .hooks.Stop[""][0] == "stop-dispatch.sh"' \
  "skill-manifest.json" "manifest starts one edit and one Stop process"
run_json_eval '([.hooks.PostToolUse[]?.hooks[]?.command | select(test("codex-edit-dispatch"))] | length) == 1
  and ([.hooks.PostToolUse[]?.hooks[]?.command | select(test("vendor-file-check|react-rules-check|tailwind-check"))] | length) == 0
  and ([.hooks.Stop[]?.hooks[]?.command | select(test("stop-dispatch"))] | length) == 1' \
  ".codex/hooks.json" "generated Codex hooks stay consolidated"

_edit_tmp=$(mktemp /tmp/frontier-edit-XXXXXX)
_edit_file="${_edit_tmp}.tsx"
printf '%s\n' 'const X = () => <div className="bg-red-500">x</div>;' >"$_edit_file"
_edit_output=$(jq -nc --arg f "$_edit_file" \
  --arg content 'const X = () => <div className="bg-red-500">x</div>;' \
  '{tool_name:"Write",tool_input:{file_path:$f,content:$content}}' \
  | ".claude/hooks/codex-edit-dispatch.sh")
if jq -e '.hookSpecificOutput.hookEventName == "PostToolUse"
  and (.hookSpecificOutput.additionalContext | contains("semantic tokens"))' \
  <<<"$_edit_output" >/dev/null; then
  echo "  PASS  Codex edit dispatcher adapts and returns shared findings"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Codex edit dispatcher adapts and returns shared findings"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Codex edit adapter protocol"
fi
rm -f "$_edit_tmp" "$_edit_file"

_stop_root=$(mktemp -d)
mkdir -p "$_stop_root/.claude/hooks"
cp ".claude/hooks/stop-dispatch.sh" "$_stop_root/.claude/hooks/"
cat >"$_stop_root/skill-manifest.json" <<'JSON'
{"x-stop-dispatch":["typecheck-stop.sh","pr-feedback-completeness-stop.sh","completion-contract-stop.sh"]}
JSON
git -C "$_stop_root" init -q
printf 'clean\n' >"$_stop_root/tracked.txt"
git -C "$_stop_root" add -- tracked.txt
git -C "$_stop_root" \
  -c user.name="Harness Eval" \
  -c user.email="harness@example.invalid" \
  commit -qm "test: establish clean baseline"
printf 'dirty\n' >"$_stop_root/tracked.txt"
cat >"$_stop_root/.claude/hooks/typecheck-stop.sh" <<'SH'
#!/bin/bash
touch "${STOP_TEST_DIR}/code-ran"
SH
cat >"$_stop_root/.claude/hooks/pr-feedback-completeness-stop.sh" <<'SH'
#!/bin/bash
touch "${STOP_TEST_DIR}/pr-ran"
SH
cat >"$_stop_root/.claude/hooks/completion-contract-stop.sh" <<'SH'
#!/bin/bash
jq -n '{decision:"block",reason:"contract failed"}' >&2
exit 2
SH
chmod +x "$_stop_root/.claude/hooks/"*.sh

_stop_sid="frontier-stop-$$"
_stop_session="/tmp/hook-session-${_stop_sid}"
mkdir -p "$_stop_session"
printf 'local\n' >"$_stop_session/task-endpoint"
_stop_status=0
(
  cd "$_stop_root"
  STOP_TEST_DIR="$_stop_root" CLAUDE_SESSION_ID="$_stop_sid" \
    ".claude/hooks/stop-dispatch.sh" <<<'{}'
) >"$_stop_root/out" 2>"$_stop_root/err" || _stop_status=$?
if [ -f "$_stop_root/code-ran" ]; then
  echo "  PASS  Stop dispatcher verifies a resumed dirty worktree"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Stop dispatcher verifies a resumed dirty worktree"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: resumed dirty worktree skipped"
fi
if [ ! -f "$_stop_root/pr-ran" ]; then
  echo "  PASS  Stop dispatcher skips PR feedback outside PR endpoints"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Stop dispatcher skips PR feedback outside PR endpoints"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: unscoped PR feedback ran"
fi
if [ "$_stop_status" -eq 2 ] && grep -q "contract failed" "$_stop_root/err"; then
  echo "  PASS  Stop dispatcher preserves blocking child output"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Stop dispatcher preserves blocking child output"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Stop block aggregation"
fi

rm -f "$_stop_root/code-ran" "$_stop_root/err" "$_stop_root/out"
printf 'pr\n' >"$_stop_session/task-endpoint"
(
  cd "$_stop_root"
  STOP_TEST_DIR="$_stop_root" CLAUDE_SESSION_ID="$_stop_sid" \
    ".claude/hooks/stop-dispatch.sh" <<<'{}'
) >/dev/null 2>&1 || true
if [ -f "$_stop_root/pr-ran" ]; then
  echo "  PASS  Stop dispatcher runs PR feedback at a PR endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Stop dispatcher runs PR feedback at a PR endpoint"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: scoped PR feedback skipped"
fi
rm -rf "$_stop_root" "$_stop_session"

run_content_eval "development-lifecycle/SKILL.md" 'blind spot' "lifecycle starts with blind spots"
run_content_eval "development-lifecycle/SKILL.md" 'volatile' "plans order work by uncertainty"
run_content_eval "development-lifecycle/SKILL.md" '\.context/implementation-notes\.md' "long work records deviations"
run_content_eval "development-lifecycle/SKILL.md" 'revisit|[Rr]e-plan' "implementation can revise the plan"
run_content_eval "grilling/SKILL.md" 'lookup.*prototype.*reversible assumption.*pause trigger' "grill classifies remaining unknowns"
run_absent_eval "grilling/SKILL.md" 'frontier is empty' "grill does not demand exhaustive certainty"
run_content_eval "prototype/SKILL.md" '\.context/prototypes' "prototypes have a no-commit retention home"
run_content_eval "prototype/SKILL.md" 'endpoint.*authorizes commits|authorizes commits.*endpoint' \
  "prototype branch retention respects endpoint ownership"

run_absent_eval "CLAUDE.md" 'Rank cost/intel/taste|Terra.*never|Luna.*never' "ambient context has no subjective model rankings"
if [ "$(wc -c < CLAUDE.md | tr -d '[:space:]')" -le 4500 ]; then
  echo "  PASS  ambient context stays below 4.5 KB"
  PASS=$((PASS + 1))
else
  echo "  FAIL  ambient context stays below 4.5 KB"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: ambient context stays below 4.5 KB"
fi
run_absent_eval ".claude/hooks/post-compact-context.sh" 'no-memo|zustand:create' "compaction restores state, not static rules"
run_absent_eval ".claude/hooks/session-env.sh" '\[HOOK INVENTORY\]' "session start omits ambient hook counts"

for skill in research prototype what-did-i-get-done hook-audit visual-plan; do
  run_absent_eval "$skill/SKILL.md" '^disable-model-invocation: true$' "$skill remains model-discoverable"
  run_content_eval "$skill/SKILL.md" '^description: .*Use when' "$skill keeps model-facing triggers"
  run_absent_eval "codex-skills/$skill/agents/openai.yaml" 'allow_implicit_invocation: false' \
    "$skill keeps Claude and Codex invocation parity"
done

for skill in wayfinder stay-within-limits; do
  run_content_eval "$skill/SKILL.md" '^disable-model-invocation: true$' "$skill is explicit-use only"
  run_content_eval "codex-skills/$skill/agents/openai.yaml" 'allow_implicit_invocation: false' \
    "$skill keeps Claude and Codex invocation parity"
done

run_file_eval "hooks/rule-policy.json" "hook severity policy is explicit"
run_json_eval '.block == ["safety", "security", "provable-correctness", "explicit-incompatibility", "workflow-integrity"]
  and (.warn | index("taste"))
  and (.warn | index("heuristic"))' \
  "hooks/rule-policy.json" "hard blocks are limited to high-confidence failures"
