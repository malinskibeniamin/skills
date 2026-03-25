#!/bin/bash
set -euo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

if [ -z "$command" ]; then
  exit 0
fi

# Block --verbose flag on test runners (wastes tokens)
if echo "$command" | grep -qE '(vitest|bun test|jest).*--verbose'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"Do not use --verbose on test runners. AI_AGENT=1 and CLAUDECODE=1 are set, so test output is already optimized to show only failures. Remove --verbose flag."}' >&2
  exit 2
fi

exit 0
