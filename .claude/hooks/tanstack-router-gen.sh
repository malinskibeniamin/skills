#!/bin/bash
set -euo pipefail

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

if [ "$tool_name" != "Edit" ] && [ "$tool_name" != "Write" ]; then
  exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [ -z "$file_path" ]; then
  exit 0
fi

# Check if the file is in a routes directory
if ! echo "$file_path" | grep -qE '/routes/'; then
  exit 0
fi

# Only trigger for TS/TSX files
case "$file_path" in
  *.ts|*.tsx) ;;
  *) exit 0 ;;
esac

# Regenerate route tree silently
bun run generate:routes > /dev/null 2>&1 || true

echo '{"suppressOutput":true}'
exit 0
