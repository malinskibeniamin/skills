#!/bin/bash
set -eo pipefail

# Source hook-lib for session-scoped file tracking
source "$(dirname "$0")/source-hook-lib.sh" 2>/dev/null || true

# Session-scoped: only check files this session touched
if type hook_session_changed_files &>/dev/null; then
  changed_files=$(hook_session_changed_files "tsx|jsx")
else
  changed_files=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(tsx|jsx)$' || true)
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

# No downgrade-to-allow: doctor errors are stop-gaps. If React Doctor cannot
# complete, fix the code, config, or toolchain before continuing.

# Known incomplete dead-code failure — still a stop-gap because results are incomplete
if echo "$output" | grep -qE 'issues\.files is not iterable|dead code detection failed \(non-fatal, skipping\)|results are incomplete'; then
  hook_stop_finding "$(printf "React Doctor incomplete results:\n%s" "$(echo "$output" | tail -20)")"
  exit 0
fi

# Known doctor-tool internal bugs — block until the tool/config path is fixed
if echo "$output" | grep -qE 'is not iterable|Cannot read propert|TypeError:|ReferenceError:'; then
  hook_stop_finding "$(printf "React Doctor internal error. Fix doctor config/tooling or pin before continuing:\n%s" "$(echo "$output" | tail -20)")"
  exit 0
fi

# Block on errors (non-zero exit)
if [ $exit_code -ne 0 ]; then
  truncated=$(echo "$output" | head -30)
  hook_stop_finding "$(printf "React Doctor errors are stop-gaps. Fix before continuing:\n%s" "$truncated")"
  exit 0
fi

# Extract score
score=$(echo "$output" | grep -oE '[0-9]+' | tail -1 || echo "")

# Finding on critical score
if [ -n "$score" ] && [ "$score" -lt 50 ]; then
  hook_stop_finding "Doctor score $score/100 (critical). Fix."
fi

# Block on low score (warnings are errors)
if [ -n "$score" ] && [ "$score" -lt 80 ]; then
  hook_stop_finding "Doctor score $score/100. React Doctor warnings are errors; fix before finishing."
  exit 0
fi

# Surface any warnings in output even if score is OK
if echo "$output" | grep -qiE 'warn|warning'; then
  warning_count=$(echo "$output" | grep -ciE 'warn|warning' || echo "0")
  hook_stop_finding "Doctor warnings are errors (${score:-N/A}/100, $warning_count warning(s)). Run bun run doctor and fix at source."
fi

exit 0
