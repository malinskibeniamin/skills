#!/bin/bash
set -eo pipefail

# Escape hatch: when Claude is already responding to a Stop block, do not
# block again -- prevents infinite hostage loops (audit cluster 1).
_sha_in=$(cat); if printf '%s' "$_sha_in" | jq -e '.stop_hook_active == true' >/dev/null 2>&1; then exit 0; fi


# Source hook-lib for session-scoped file tracking
_shim="$(dirname "$0")/source-hook-lib.sh"; if [ -f "$_shim" ]; then . "$_shim" 2>/dev/null || true; fi

# Session-scoped: only check files this session touched.
# Includes .ts: transferred rules (tanstack-query, state-and-effects) fire in plain
# TypeScript files too -- a QueryClient created in a .ts module must still be scanned.
if type hook_session_changed_files &>/dev/null; then
  changed_files=$(hook_session_changed_files "tsx?|jsx")
else
  changed_files=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(tsx?|jsx)$' || true)
fi

if [ -z "$changed_files" ]; then
  exit 0
fi

# Skip if project doesn't have a doctor script
if [ ! -f "package.json" ] || ! jq -e '.scripts["doctor"]' package.json >/dev/null 2>&1; then
  exit 0
fi

# Run react-doctor in diff mode
output=""
exit_code=0
output=$(bun run doctor -- --diff --score 2>&1) || exit_code=$?

# No downgrade-to-allow: doctor errors are blocking findings. If React Doctor cannot
# complete, fix the code, config, or toolchain before continuing.

# Known incomplete dead-code failure — still a stop-gap because results are incomplete
if echo "$output" | grep -qE 'issues\.files is not iterable|dead code detection failed \(non-fatal, skipping\)|results are incomplete'; then
  hook_stop_finding "$(printf "React Doctor incomplete results:\n%s" "$(echo "$output" | tail -20)")"
  hook_stop_enforce
fi

# Known doctor-tool internal bugs — block until the tool/config path is fixed
if echo "$output" | grep -qE 'is not iterable|Cannot read propert|TypeError:|ReferenceError:'; then
  hook_stop_finding "$(printf "React Doctor internal error. Fix doctor config/tooling or pin before continuing:\n%s" "$(echo "$output" | tail -20)")"
  hook_stop_enforce
fi

# Block on errors (non-zero exit)
if [ $exit_code -ne 0 ]; then
  truncated=$(echo "$output" | head -30)
  hook_stop_finding "$(printf "React Doctor found blocking errors. Fix before continuing:\n%s" "$truncated")"
  hook_stop_enforce
fi

# Transferred rules are hard blocks regardless of score. These were per-edit
# hook_block rules before the React Doctor delegation; a finding on any of them
# must stop the session even when the overall score clears 80.
_transferred='react-compiler-no-manual-memoization|no-derived-state-effect|no-derived-use-state|rerender-lazy-ref-init|no-reset-all-state-on-prop-change|no-adjust-state-on-prop-change|no-outline-none|no-disabled-zoom|dialog-has-accessible-name|html-no-nested-interactive|img-redundant-alt|label-has-associated-control|query-stable-query-client|query-no-rest-destructuring|query-destructure-result|query-no-void-query-fn'
_transferred_hits=$(echo "$output" | grep -oE "$_transferred" | sort -u | tr '\n' ' ' || true)
if [ -n "$_transferred_hits" ]; then
  hook_stop_finding "React Doctor flagged transferred hard rules (block regardless of score): ${_transferred_hits}. These were per-edit blocks before delegation; fix before finishing."
  hook_stop_enforce
fi

# Extract score
score=$(echo "$output" | grep -oE '[0-9]+' | tail -1 || echo "")

# ── Score ratchet: quality is a one-way street ──────────────────
# Baseline = best score this repo has ever achieved (per-repo file under
# ~/.claude/hook-metrics). A diff may never land below it; beating it
# raises it. 80 stays the absolute floor below, but the ratchet is the
# anti-rot mechanism: slow decline becomes mechanically impossible.
if [ -n "$score" ]; then
  _rd_repo_hash=$(git rev-parse --show-toplevel 2>/dev/null | cksum | cut -d' ' -f1)
  _rd_baseline_file="$HOME/.claude/hook-metrics/doctor-baseline-${_rd_repo_hash}"
  _rd_baseline=$(cat "$_rd_baseline_file" 2>/dev/null | tr -dc '0-9' || true)
  if [ -z "$_rd_baseline" ]; then
    mkdir -p "$HOME/.claude/hook-metrics" 2>/dev/null || true
    echo "$score" > "$_rd_baseline_file" 2>/dev/null || true
  elif [ "$score" -lt "$_rd_baseline" ]; then
    hook_stop_finding "Doctor score $score/100 is BELOW this repo's ratchet baseline ($_rd_baseline). Quality only moves up: fix the regression or justify lowering the baseline explicitly (edit $_rd_baseline_file with a reason in the commit)."
    hook_stop_enforce
  elif [ "$score" -gt "$_rd_baseline" ]; then
    echo "$score" > "$_rd_baseline_file" 2>/dev/null || true
  fi
fi

# Finding on critical score
if [ -n "$score" ] && [ "$score" -lt 50 ]; then
  hook_stop_finding "Doctor score $score/100 (critical). Fix."
fi

# Block on low score (warnings are errors)
if [ -n "$score" ] && [ "$score" -lt 80 ]; then
  hook_stop_finding "Doctor score $score/100. React Doctor warnings are errors; fix before finishing."
  hook_stop_enforce
fi

# Surface any warnings in output even if score is OK
if echo "$output" | grep -qiE 'warn|warning'; then
  warning_count=$(echo "$output" | grep -ciE 'warn|warning' || echo "0")
  hook_stop_finding "Doctor warnings are errors (${score:-N/A}/100, $warning_count warning(s)). Run bun run doctor and fix at source."
fi

hook_stop_enforce
