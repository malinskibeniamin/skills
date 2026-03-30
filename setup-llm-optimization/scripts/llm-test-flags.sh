#!/bin/bash
set -euo pipefail

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

if [ "$tool_name" != "Bash" ]; then
  exit 0
fi

command=$(echo "$input" | jq -r '.tool_input.command // empty')

if [ -z "$command" ]; then
  exit 0
fi

# Strip --verbose flag from test runners (wastes tokens).
# Uses updatedInput to silently rewrite the command instead of denying.
if echo "$command" | grep -qE '(vitest|bun (test|run test\S*)|jest).*--verbose'; then
  rewritten=$(echo "$command" | sed -E 's/[[:space:]]+--verbose//g; s/--verbose[[:space:]]+//g; s/--verbose$//g')
  # Preserve all other tool_input fields (timeout, run_in_background, description)
  updated_input=$(echo "$input" | jq --arg cmd "$rewritten" '.tool_input | .command = $cmd')
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"allow\",\"updatedInput\":$updated_input}}" >&2
  exit 0
fi

exit 0
