#!/bin/bash
set -euo pipefail

# Check if any React files were changed
changed_files=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(tsx|jsx)$' || true)

if [ -z "$changed_files" ]; then
  exit 0
fi

# Run react-doctor in diff mode
output=""
exit_code=0
output=$(bun run doctor -- --diff --score 2>&1) || exit_code=$?

# Block on errors (non-zero exit)
if [ $exit_code -ne 0 ]; then
  truncated=$(echo "$output" | head -30)
  escaped=$(echo "$truncated" | jq -Rs .)
  echo "{\"decision\":\"block\",\"reason\":\"React Doctor found errors in changed files:\\n\"$escaped\"\"}" >&2
  exit 2
fi

# Extract score
score=$(echo "$output" | grep -oE '[0-9]+' | tail -1 || echo "")

# Block on critical score
if [ -n "$score" ] && [ "$score" -lt 50 ]; then
  echo "{\"decision\":\"block\",\"reason\":\"React Doctor health score is $score/100 (critical). Fix issues before finishing.\"}" >&2
  exit 2
fi

# Warn on low score (surface warnings without blocking)
if [ -n "$score" ] && [ "$score" -lt 80 ]; then
  echo "{\"decision\":\"allow\",\"reason\":\"React Doctor health score is $score/100. Consider fixing warnings to improve code health.\"}" >&2
  exit 0
fi

# Surface any warnings in output even if score is OK
if echo "$output" | grep -qiE 'warn|warning'; then
  warning_count=$(echo "$output" | grep -ciE 'warn|warning' || echo "0")
  echo "{\"decision\":\"allow\",\"reason\":\"React Doctor passed (score: ${score:-N/A}/100) but found $warning_count warning(s). Run 'bun run doctor' for details.\"}" >&2
fi

exit 0
