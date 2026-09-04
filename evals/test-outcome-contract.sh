#!/bin/bash

# Contract for the outcome-oriented, self-verifying harness.

for field in Objective Guardrails Verification Stop; do
  run_content_eval "$REPO_ROOT/CLAUDE.md" "\\*\\*$field\\*\\*" \
    "ambient outcome contract defines $field"
done
run_content_eval "$REPO_ROOT/CLAUDE.md" "inspect.*act.*verify.*repeat" \
  "ambient work guidance uses one evidence loop"

run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "inspect.*act.*verify.*repeat" \
  "development lifecycle is one execution loop"
run_absent_pattern() {
  local file="$1" pattern="$2" description="$3"
  if ! grep -qE -- "$pattern" "$file"; then
    echo "  PASS  $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $description"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
  fi
}

run_absent_pattern "$REPO_ROOT/development-lifecycle/SKILL.md" '^### [0-9]|Bite-sized tasks|2-5 min' \
  "development lifecycle does not prescribe phase ceremony or task duration"
run_absent_pattern "$REPO_ROOT/development-lifecycle/SKILL.md" \
  'Run `/quantify-impact`|Run `/resilience-review`|Invoke `/grilling`|run `/dogfood`' \
  "development lifecycle does not chain optional skills"

run_content_eval "$REPO_ROOT/go/SKILL.md" "exit contract|Exit contract" \
  "go is an exit contract"
run_content_eval "$REPO_ROOT/go/SKILL.md" "verify.*repair.*repeat|verification.*passes" \
  "go keeps shipping until evidence is clean"
run_absent_pattern "$REPO_ROOT/go/SKILL.md" '^## Phase|^### Phase|Max 2 refine rounds|Run `/visual-review`|Run `/commit-push-pr`' \
  "go avoids phase ceremony and mandatory skill chaining"

run_content_eval "$REPO_ROOT/review/SKILL.md" 'inspect.*verify.*classify.*synthesize' \
  "review uses one evidence loop"
run_absent_pattern "$REPO_ROOT/review/SKILL.md" \
  'Use `/agent-watchdog`|run `/steelman`|through `/quantify-impact`|Run `/aip`|Run `/dogfood`' \
  "review does not pre-route work through a skill panel"

run_content_eval "$REPO_ROOT/README.md" "outcome contract|Outcome contract" \
  "README teaches the outcome-contract model"
run_absent_pattern "$REPO_ROOT/README.md" '6-phase workflow|Six phases|Phase 2b|3-15k' \
  "README no longer markets procedural orchestration"
run_absent_pattern "$REPO_ROOT/README.md" 'understand -> plan -> TDD -> verify -> review -> compound' \
  "README does not retain the retired phase chain"

run_absent_pattern "$REPO_ROOT/.claude/hooks/intent-detect.sh" '\[CI-FIX\]|Front-load ALL failures' \
  "prompt hook does not coach a CI workflow"

run_json_eval_local() {
  local expression="$1" file="$2" description="$3"
  if jq -e "$expression" "$file" >/dev/null 2>&1; then
    echo "  PASS  $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $description"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
  fi
}

run_json_eval_local '(.variants == ["bare", "guardrails", "lean", "current"])
  and .release_trigger == "major-model-release"
  and (.tasks | index("self-verifying-repair"))
  and (.tasks | index("workflow-system-audit"))
  and (.tasks | index("knowledge-system-audit"))
  and (.tasks | index("evergreen-project-recovery"))' \
  "$REPO_ROOT/agent-evals/context-ablation/manifest.json" \
  "ablation covers implementation, workflow, knowledge, and recovery tasks"
run_json_eval_local '.selection.single_owner == true
  and .selection.cross_family_review_for_non_trivial_pr == false' \
  "$REPO_ROOT/config/model-routing.json" \
  "model routing keeps one owner without automatic cross-family review"
run_content_eval "$REPO_ROOT/agent-evals/context-ablation/create-experiment.ts" 'instructionFile' \
  "current ablation selects runtime-native instructions"
run_content_eval "$REPO_ROOT/agent-evals/context-ablation/create-experiment.ts" 'runtimeContext = context \?\? ""' \
  "bare ablation clears copied runtime instructions"
run_file_eval "$REPO_ROOT/agent-evals/context-ablation/bare.ts" "bare ablation variant exists"
run_file_eval "$REPO_ROOT/agent-evals/context-ablation/guardrails.ts" "guardrails ablation variant exists"
run_file_eval "$REPO_ROOT/agent-evals/context-ablation/scorecard-template.md" "model-release scorecard template exists"
run_content_eval "$REPO_ROOT/agent-evals/context-ablation/scorecard-template.md" 'Hook retention' \
  "model-release scorecard records hook holdouts"
run_content_eval "$REPO_ROOT/agent-evals/context-ablation/scorecard-template.md" 'Skill retention' \
  "model-release scorecard records skill decisions"

for task in workflow-system-audit knowledge-system-audit evergreen-project-recovery; do
  run_file_eval "$REPO_ROOT/agent-evals/evals/$task/EVAL.ts" \
    "$task has an executable grader"
  run_file_eval "$REPO_ROOT/agent-evals/evals/$task/package.json" \
    "$task declares its evaluator dependencies"
done

for prompt in \
  "$REPO_ROOT/agent-evals/evals/setup-accessibility/PROMPT.md" \
  "$REPO_ROOT/agent-evals/evals/setup-code-organization/PROMPT.md" \
  "$REPO_ROOT/agent-evals/evals/violation-nudge/PROMPT.md" \
  "$REPO_ROOT/agent-evals/evals/workflow-system-audit/PROMPT.md" \
  "$REPO_ROOT/agent-evals/evals/knowledge-system-audit/PROMPT.md" \
  "$REPO_ROOT/agent-evals/evals/evergreen-project-recovery/PROMPT.md"; do
  run_absent_pattern "$prompt" '^# Project Rules|This project enforces strict|MUST|NEVER' \
    "$(basename "$(dirname "$prompt")") prompt does not leak grader rules"
  run_content_eval "$prompt" "verify|verification" \
    "$(basename "$(dirname "$prompt")") prompt supplies an evaluation path"
done

run_content_eval "$REPO_ROOT/.claude/hooks/_hook-lib.sh" 'HOOK_SHADOW_RULES' \
  "hooks support evidence-only shadow trials"
run_absent_pattern "$REPO_ROOT/.claude/hooks/_hook-lib.sh" '\*,all,\*' \
  "hook shadow trials require explicit rule labels"
run_content_eval "$REPO_ROOT/README.md" 'HOOK_SHADOW_RULES' \
  "shadow trials are operator-visible"
run_content_eval "$REPO_ROOT/hooks/rule-policy.json" 'shadow' \
  "hook retirement requires a shadow trial"
run_content_eval "$REPO_ROOT/.claude/hooks/session-end.sh" 'harness_version' \
  "session telemetry records harness version"
run_content_eval "$REPO_ROOT/.claude/hooks/session-end.sh" 'run_kind' \
  "session telemetry distinguishes real and synthetic runs"
run_content_eval "$REPO_ROOT/.claude/hooks/skill-fire-log.sh" 'harness_version' \
  "skill telemetry is version-qualified"
run_absent_pattern "$REPO_ROOT/hook-audit/SKILL.md" \
  'Use `/visual-plan`|`/plan-arbiter`|`/agent-watchdog`' \
  "specialist audits do not chain unrelated skills"
run_content_eval "$REPO_ROOT/hook-audit/REFERENCE.md" 'harness_version.*model|model.*harness_version' \
  "hook pruning evidence is qualified by harness and model"

_shadow_tmp=$(mktemp -d)
_shadow_file="$_shadow_tmp/store.ts"
_shadow_session="outcome-shadow-$$"
printf '%s\n' 'import { create } from "zustand";' \
  'const store = create<{x: string}>((set) => ({ x: "" }))' > "$_shadow_file"
_shadow_out=""
_shadow_rc=0
_shadow_out=$(HOOK_PROTOCOL=shell HOOK_SHADOW_RULES=zustand-check \
  CLAUDE_SESSION_ID="$_shadow_session" \
  jq -nc --arg file "$_shadow_file" --arg content "$(cat "$_shadow_file")" \
    '{tool_name:"Write",tool_input:{file_path:$file,content:$content}}' \
  | HOOK_PROTOCOL=shell HOOK_SHADOW_RULES=zustand-check \
    CLAUDE_SESSION_ID="$_shadow_session" \
    "$REPO_ROOT/.claude/hooks/zustand-check.sh" 2>&1) || _shadow_rc=$?
if [ "$_shadow_rc" -eq 0 ] && [ -z "$_shadow_out" ] \
  && grep -q '"decision":"shadow-block"' "/tmp/hook-session-${_shadow_session}/structured.jsonl" 2>/dev/null; then
  echo "  PASS  shadowed block records evidence without steering the model"
  PASS=$((PASS + 1))
else
  echo "  FAIL  shadowed block records evidence without steering the model"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: hook shadow behavior"
fi
rm -rf "$_shadow_tmp" "/tmp/hook-session-${_shadow_session}" 2>/dev/null || true

_metrics_tmp=$(mktemp -d)
HOOK_METRICS_DIR="$_metrics_tmp" HOOK_METRICS_RUN_KIND=eval \
  HARNESS_VERSION=test-version CLAUDE_SESSION_ID="outcome-skill-$$" \
  printf '%s' '{"hook_event_name":"PreToolUse","tool_name":"Skill","tool_input":{"skill":"tdd"}}' \
  | HOOK_METRICS_DIR="$_metrics_tmp" HOOK_METRICS_RUN_KIND=eval \
    HOOK_METRICS_DISABLED=0 HARNESS_VERSION=test-version \
    CLAUDE_SESSION_ID="outcome-skill-$$" \
    "$REPO_ROOT/.claude/hooks/skill-fire-log.sh"
if jq -e 'select(.harness_version == "test-version" and .run_kind == "eval")' \
  "$_metrics_tmp/skill-fires.jsonl" >/dev/null 2>&1; then
  echo "  PASS  skill telemetry carries version and run kind"
  PASS=$((PASS + 1))
else
  echo "  FAIL  skill telemetry carries version and run kind"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: version-qualified skill telemetry"
fi
rm -rf "$_metrics_tmp" "/tmp/hook-session-outcome-skill-$$" 2>/dev/null || true

_session_metrics_tmp=$(mktemp -d)
_session_metrics_sid="outcome-session-$$"
_session_metrics_dir="/tmp/hook-session-${_session_metrics_sid}"
mkdir -p "$_session_metrics_dir"
cat > "$_session_metrics_dir/structured.jsonl" <<'EOF'
{"ts":100,"hook":"zustand-check","rule":"zustand-check","decision":"shadow-block","file":"src/store.ts"}
{"ts":101,"hook":"zustand-check","rule":"zustand-check","decision":"run","file":"src/store.ts","ms":7}
EOF
printf '%s' '{"outcome":"completed"}' \
  | HOOK_METRICS_DISABLED=0 HOOK_METRICS_DIR="$_session_metrics_tmp" \
    HOOK_METRICS_RUN_KIND=eval HARNESS_VERSION='test"version' \
    CLAUDE_MODEL='model"name' CLAUDE_SESSION_ID="$_session_metrics_sid" \
    "$REPO_ROOT/.claude/hooks/session-end.sh"
_session_summary=$(find "$_session_metrics_tmp" -type f -name '*.json' -print -quit)
if [ -n "$_session_summary" ] && jq -e '
  .schema_version == 4
  and .harness_version == "test\"version"
  and .model == "model\"name"
  and .run_kind == "eval"
  and .shadow_blocks["zustand-check"] == 1
  and .perf_ms["zustand-check"].p95 == 7
' "$_session_summary" >/dev/null 2>&1; then
  echo "  PASS  session telemetry is valid, qualified JSON with shadow and latency evidence"
  PASS=$((PASS + 1))
else
  echo "  FAIL  session telemetry is valid, qualified JSON with shadow and latency evidence"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: session telemetry JSON contract"
fi
rm -rf "$_session_metrics_tmp" "$_session_metrics_dir" 2>/dev/null || true
