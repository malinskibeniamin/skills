# Context-ablation runner contracts: exact model pins, complete effort cells,
# and a fail-fast Claude Code compatibility check.

RUNNER="$REPO_ROOT/agent-evals/context-ablation/run.sh"
_ablation_tmp=$(mktemp -d)
_ablation_bin="$_ablation_tmp/bin"
_ablation_log="$_ablation_tmp/cells.log"
mkdir -p "$_ablation_bin"

cat > "$_ablation_bin/claude" <<'STUB'
#!/bin/bash
printf '%s (Claude Code)\n' "${FAKE_CLAUDE_VERSION:-2.1.258}"
STUB
cat > "$_ablation_bin/bunx" <<'STUB'
#!/bin/bash
printf '%s|%s|%s|%s\n' \
  "${ABLATION_AGENT:-}" "${ABLATION_MODEL:-}" "${ABLATION_EFFORT:-}" "$*" \
  >> "$CELL_LOG"
STUB
chmod +x "$_ablation_bin/claude" "$_ablation_bin/bunx"

: > "$_ablation_log"
_ablation_output="$_ablation_tmp/output"
if PATH="$_ablation_bin:$PATH" CELL_LOG="$_ablation_log" \
  FAKE_CLAUDE_VERSION=2.1.258 "$RUNNER" --dry >"$_ablation_output" 2>&1; then
  echo "  PASS  context-ablation runner accepts a Fable 5.1-capable Claude Code"
  PASS=$((PASS + 1))
else
  echo "  FAIL  context-ablation runner rejected compatible Claude Code: $(cat "$_ablation_output")"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: compatible context-ablation preflight"
fi

_expected_cells="$_ablation_tmp/expected.log"
: > "$_expected_cells"
for _variant in bare guardrails lean current; do
  for _effort in low medium high xhigh max; do
    printf 'codex|gpt-6-astra|%s|@vercel/agent-eval@1.4.0 --dry agent-evals/context-ablation/%s.ts\n' \
      "$_effort" "$_variant" >> "$_expected_cells"
  done
  for _effort in xhigh max; do
    printf 'codex|gpt-5.6-sol|%s|@vercel/agent-eval@1.4.0 --dry agent-evals/context-ablation/%s.ts\n' \
      "$_effort" "$_variant" >> "$_expected_cells"
  done
  for _effort in low medium high xhigh max; do
    printf 'claude-code|claude-fable-5-1|%s|@vercel/agent-eval@1.4.0 --dry agent-evals/context-ablation/%s.ts\n' \
      "$_effort" "$_variant" >> "$_expected_cells"
  done
  for _effort in high xhigh; do
    printf 'claude-code|claude-opus-5|%s|@vercel/agent-eval@1.4.0 --dry agent-evals/context-ablation/%s.ts\n' \
      "$_effort" "$_variant" >> "$_expected_cells"
  done
done

if diff -u <(sort "$_expected_cells") <(sort "$_ablation_log") >/dev/null 2>&1; then
  echo "  PASS  context-ablation executes every pinned model/effort cell exactly once"
  PASS=$((PASS + 1))
else
  echo "  FAIL  context-ablation model/effort matrix is incomplete or aliased"
  diff -u <(sort "$_expected_cells") <(sort "$_ablation_log") || true
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: context-ablation matrix"
fi

: > "$_ablation_log"
_ablation_rc=0
PATH="$_ablation_bin:$PATH" CELL_LOG="$_ablation_log" \
  FAKE_CLAUDE_VERSION=2.1.256 "$RUNNER" --dry >"$_ablation_output" 2>&1 || _ablation_rc=$?
if [ "$_ablation_rc" -ne 0 ] && [ ! -s "$_ablation_log" ] \
  && grep -q 'Claude Code 2.1.257 or newer' "$_ablation_output"; then
  echo "  PASS  context-ablation fails before any cell on an incompatible Claude Code"
  PASS=$((PASS + 1))
else
  echo "  FAIL  context-ablation did not fail fast for Claude Code 2.1.256"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: context-ablation version preflight"
fi

if ABLATION_AGENT=claude-code ABLATION_MODEL=claude-fable-5-1 \
  ABLATION_EFFORT=medium bun -e '
    const { createExperiment } = await import("./agent-evals/context-ablation/create-experiment.ts");
    const config = createExperiment(null);
    if (config.model !== "claude-fable-5-1" || config.agentOptions?.effort !== "medium") process.exit(1);
  ' >/dev/null 2>&1; then
  echo "  PASS  experiment receives the runner's exact Claude model and effort"
  PASS=$((PASS + 1))
else
  echo "  FAIL  experiment drops the runner's exact Claude model or effort"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: context-ablation experiment model propagation"
fi

if ABLATION_AGENT=codex ABLATION_MODEL=gpt-6-astra \
  ABLATION_EFFORT=max bun -e '
    const { createExperiment } = await import("./agent-evals/context-ablation/create-experiment.ts");
    const config = createExperiment(null);
    if (config.model !== "gpt-6-astra?reasoningEffort=max") process.exit(1);
  ' >/dev/null 2>&1; then
  echo "  PASS  experiment preserves the exact GPT-6 Astra model and effort"
  PASS=$((PASS + 1))
else
  echo "  FAIL  experiment drops the GPT-6 Astra model or effort"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: GPT-6 Astra experiment model propagation"
fi

rm -rf "$_ablation_tmp"
