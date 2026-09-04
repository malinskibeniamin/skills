# Dedicated capability probes must remain opt-in hypotheses, separate from routing and
# ambient-context ablation.

PROBE_ROOT="$REPO_ROOT/agent-evals/capability-probes"
PROBE_MANIFEST="$PROBE_ROOT/manifest.json"
PROBE_RUNNER="$PROBE_ROOT/run.sh"

run_file_eval "$PROBE_MANIFEST" "capability-probe manifest exists"
run_file_eval "$PROBE_ROOT/create-experiment.ts" "capability experiment exists"
run_file_eval "$PROBE_ROOT/README.md" "capability-probe operator guide exists"
run_file_eval "$PROBE_ROOT/scorecard-template.md" "capability scorecard exists"
run_file_eval "$REPO_ROOT/agent-evals/evals/research-data-synthesis/EVAL.ts" \
  "research and data-analysis grader exists"
run_content_eval "$REPO_ROOT/README.md" 'agent-evals/capability-probes/run\.sh' \
  "repository eval guide exposes capability probes"

if jq -e '
  .claim_status == "hypothesis"
  and .routing_effect == "none-until-gate"
  and (.automated_tasks | index("research-data-synthesis"))
  and (.automated_tasks | index("evergreen-project-recovery"))
  and ([.probes[].capabilities[]] | unique | sort) ==
    (["computer_use", "data_analysis", "debugging", "multi_agent_coordination",
      "scientific_research", "spatial_3d", "vision"] | sort)
  and ([.probes[] | select(.execution == "manual") | .protocol] | all(type == "string"))
' "$PROBE_MANIFEST" >/dev/null 2>&1; then
  echo "  PASS  capability claims are gated hypotheses with complete probe coverage"
  PASS=$((PASS + 1))
else
  echo "  FAIL  capability claims are promoted, incomplete, or lack manual protocols"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: capability-probe manifest contract"
fi

run_content_eval "$PROBE_ROOT/README.md" 'separate.*context.ablation|context.ablation.*separate' \
  "capability probes do not distort ambient-context results"
run_content_eval "$PROBE_ROOT/README.md" 'paid|opt-in' \
  "capability probes disclose paid execution"
run_file_eval "$PROBE_ROOT/manual/spatial-computer-use.md" \
  "computer-use, vision, and 3D protocol exists"
run_file_eval "$PROBE_ROOT/manual/owner-controlled-swarm-debugging.md" \
  "multi-agent debugging protocol exists"

_probe_tmp=$(mktemp -d)
_probe_bin="$_probe_tmp/bin"
_probe_log="$_probe_tmp/cells.log"
mkdir -p "$_probe_bin"
cat > "$_probe_bin/claude" <<'STUB'
#!/bin/sh
printf '%s (Claude Code)\n' "${FAKE_CLAUDE_VERSION:-2.1.258}"
STUB
cat > "$_probe_bin/bunx" <<'STUB'
#!/bin/sh
printf '%s|%s|%s|%s\n' \
  "${CAPABILITY_AGENT:-}" "${CAPABILITY_MODEL:-}" "${CAPABILITY_EFFORT:-}" "$*" \
  >> "$CELL_LOG"
STUB
chmod +x "$_probe_bin/claude" "$_probe_bin/bunx"

: > "$_probe_log"
_probe_output="$_probe_tmp/output"
if PATH="$_probe_bin:$PATH" CELL_LOG="$_probe_log" \
  FAKE_CLAUDE_VERSION=2.1.258 "$PROBE_RUNNER" --dry >"$_probe_output" 2>&1 \
  && [ "$(wc -l < "$_probe_log" | tr -d ' ')" -eq 3 ] \
  && grep -q '^codex|gpt-6-astra|max|' "$_probe_log" \
  && grep -q '^codex|gpt-5.6-sol|max|' "$_probe_log" \
  && grep -q '^claude-code|claude-fable-5-1|max|' "$_probe_log"; then
  echo "  PASS  capability runner compares Astra with exact current baselines"
  PASS=$((PASS + 1))
else
  echo "  FAIL  capability runner model matrix is incomplete or aliased"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: capability-probe model matrix"
fi

: > "$_probe_log"
_probe_rc=0
PATH="$_probe_bin:$PATH" CELL_LOG="$_probe_log" \
  "$PROBE_RUNNER" --unknown >"$_probe_output" 2>&1 || _probe_rc=$?
if [ "$_probe_rc" -ne 0 ] && [ ! -s "$_probe_log" ]; then
  echo "  PASS  invalid capability mode fails before paid calls"
  PASS=$((PASS + 1))
else
  echo "  FAIL  invalid capability mode reached a paid call"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: capability-probe invalid mode"
fi

: > "$_probe_log"
_probe_rc=0
PATH="$_probe_bin:$PATH" CELL_LOG="$_probe_log" FAKE_CLAUDE_VERSION=2.1.256 \
  "$PROBE_RUNNER" --dry >"$_probe_output" 2>&1 || _probe_rc=$?
if [ "$_probe_rc" -ne 0 ] && [ ! -s "$_probe_log" ] \
  && grep -q 'Claude Code 2.1.257 or newer' "$_probe_output"; then
  echo "  PASS  stale Claude fails before capability calls"
  PASS=$((PASS + 1))
else
  echo "  FAIL  stale Claude reached capability calls"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: capability-probe Claude preflight"
fi

if CAPABILITY_AGENT=codex CAPABILITY_MODEL=gpt-6-astra CAPABILITY_EFFORT=max bun -e '
  const config = (await import("./agent-evals/capability-probes/create-experiment.ts")).default;
  if (config.model !== "gpt-6-astra?reasoningEffort=max") process.exit(1);
  if (config.runs !== 3) process.exit(1);
  if (JSON.stringify(config.evals) !== JSON.stringify(["research-data-synthesis", "evergreen-project-recovery"])) process.exit(1);
' >/dev/null 2>&1; then
  echo "  PASS  capability experiment preserves exact model, effort, runs, and tasks"
  PASS=$((PASS + 1))
else
  echo "  FAIL  capability experiment drops its exact execution contract"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: capability-probe experiment propagation"
fi

run_absent_pattern_capability() {
  local file="$1" pattern="$2" description="$3"
  if [ -f "$file" ] && ! grep -qE -- "$pattern" "$file"; then
    echo "  PASS  $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $description"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
  fi
}

run_absent_pattern_capability \
  "$REPO_ROOT/agent-evals/evals/research-data-synthesis/PROMPT.md" \
  '32%|best model|generational leap|Simpson' \
  "research prompt avoids capability hype and grader leakage"
run_content_eval "$REPO_ROOT/agent-evals/evals/research-data-synthesis/PROMPT.md" \
  'verify|verification' "research prompt supplies an evaluation path"

python3 - "$_probe_tmp" <<'PY'
import shutil
import sys

shutil.rmtree(sys.argv[1])
PY
