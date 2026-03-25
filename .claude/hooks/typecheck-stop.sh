#!/bin/bash
set -euo pipefail

# Stop hook: run type checking before Claude finishes responding.
# Only runs if JS/TS files were actually changed.

changed_files=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(ts|tsx|js|jsx)$' || true)

if [ -z "$changed_files" ]; then
  exit 0
fi

# Use package.json script for consistency with CI
output=""
exit_code=0
output=$(bun run type:check 2>&1) || exit_code=$?

if [ $exit_code -ne 0 ]; then
  truncated=$(echo "$output" | head -30)
  escaped=$(echo "$truncated" | jq -Rs .)
  echo "{\"decision\":\"block\",\"reason\":\"Type errors found. Fix before finishing:\\n\"$escaped\"\"}" >&2
  exit 2
fi

exit 0
