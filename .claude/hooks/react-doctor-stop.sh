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

if [ $exit_code -ne 0 ]; then
  truncated=$(echo "$output" | head -30)
  escaped=$(echo "$truncated" | jq -Rs .)
  echo "{\"decision\":\"block\",\"reason\":\"React Doctor found issues in changed files:\\n\"$escaped\"\"}" >&2
  exit 2
fi

# Extract score if available
score=$(echo "$output" | grep -oE '[0-9]+' | tail -1 || echo "")

if [ -n "$score" ] && [ "$score" -lt 50 ]; then
  echo "{\"decision\":\"block\",\"reason\":\"React Doctor health score is $score/100 (critical). Fix issues before finishing.\"}" >&2
  exit 2
fi

exit 0
