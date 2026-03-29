#!/bin/bash
set -euo pipefail

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

if [ "$tool_name" != "Edit" ] && [ "$tool_name" != "Write" ]; then
  exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
  exit 0
fi

# Only check TS/TSX/JS/JSX files
case "$file_path" in
  *.ts|*.tsx|*.js|*.jsx) ;;
  *) exit 0 ;;
esac

# Skip dedicated env files (where process.env is expected)
basename=$(basename "$file_path")
case "$basename" in
  env.ts|env.mts|env.mjs|env.js) exit 0 ;;
esac

# Skip test files
case "$file_path" in
  *.test.*|*.spec.*) exit 0 ;;
esac

# Get added lines from diff
diff_output=""
diff_output=$(git diff HEAD -- "$file_path" 2>/dev/null) || true

if [ -z "$diff_output" ]; then
  added_lines=$(cat "$file_path")
else
  added_lines=$(echo "$diff_output" | grep '^+' | grep -v '^+++' || true)
fi

if [ -z "$added_lines" ]; then
  exit 0
fi

# Check for raw process.env access
if echo "$added_lines" | grep -qE 'process\.env\.'; then
  echo '{"suppressOutput":true,"systemMessage":"Do not use raw process.env access. Import the validated env object instead:\n\nimport { env } from \"@/env\";\n\nconst url = env.PUBLIC_API_URL;\n\nAll environment variables must be declared in src/env.ts with zod validation (t3-env). This ensures type safety and runtime validation at startup."}' >&2
  exit 2
fi

exit 0
