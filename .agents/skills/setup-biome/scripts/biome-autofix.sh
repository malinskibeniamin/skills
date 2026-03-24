#!/bin/bash
set -euo pipefail

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

# Only run for Edit and Write tools
if [ "$tool_name" != "Edit" ] && [ "$tool_name" != "Write" ]; then
  exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [ -z "$file_path" ]; then
  exit 0
fi

# Only lint JS/TS/JSX/TSX files
case "$file_path" in
  *.js|*.jsx|*.ts|*.tsx|*.mjs|*.mts|*.cjs|*.cts) ;;
  *) exit 0 ;;
esac

# Skip if file doesn't exist (was deleted)
if [ ! -f "$file_path" ]; then
  exit 0
fi

# Run biome fix on just this file, skipping noUnusedImports to avoid
# deleting imports Claude hasn't used yet (caught later at quality:gate)
fix_output=""
fix_exit=0
fix_output=$(biome check --write --skip=lint/correctness/noUnusedImports "$file_path" 2>&1) || fix_exit=$?

# Check if there are remaining unfixable errors
if [ $fix_exit -ne 0 ]; then
  # Run check-only to get remaining errors
  remaining=""
  remaining=$(biome check --skip=lint/correctness/noUnusedImports "$file_path" 2>&1) || true

  if [ -n "$remaining" ]; then
    # Truncate to avoid flooding context
    truncated=$(echo "$remaining" | head -20)
    # Escape for JSON
    escaped=$(echo "$truncated" | jq -Rs .)
    echo "{\"suppressOutput\":true,\"systemMessage\":\"Biome found unfixable errors in $file_path:\\n\"$escaped\"\"}"
    exit 0
  fi
fi

# Auto-fix succeeded silently — suppress all output
echo '{"suppressOutput":true}'
exit 0
