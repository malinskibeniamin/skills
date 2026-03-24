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

# Only check TSX/JSX files
case "$file_path" in
  *.tsx|*.jsx) ;;
  *) exit 0 ;;
esac

# Skip redpanda-ui directory (uses 'use no memo')
if echo "$file_path" | grep -qF '/redpanda-ui/'; then
  exit 0
fi

# Skip if file doesn't exist
if [ ! -f "$file_path" ]; then
  exit 0
fi

# Skip files with 'use no memo' directive
if head -5 "$file_path" | grep -qF "'use no memo'" || head -5 "$file_path" | grep -qF '"use no memo"'; then
  exit 0
fi

# Check git diff for new useMemo/useCallback/React.memo additions
diff_output=""
diff_output=$(git diff HEAD -- "$file_path" 2>/dev/null) || true

if [ -z "$diff_output" ]; then
  # File is new (untracked), check entire content
  diff_output=$(cat "$file_path")
  check_lines="$diff_output"
else
  # Only check added lines
  check_lines=$(echo "$diff_output" | grep '^+' | grep -v '^+++' || true)
fi

if [ -z "$check_lines" ]; then
  exit 0
fi

found=""
if echo "$check_lines" | grep -qE '\buseMemo\b'; then
  found="useMemo"
elif echo "$check_lines" | grep -qE '\buseCallback\b'; then
  found="useCallback"
elif echo "$check_lines" | grep -qE '\bReact\.memo\b|\bmemo\('; then
  found="React.memo"
fi

if [ -n "$found" ]; then
  echo "{\"suppressOutput\":true,\"systemMessage\":\"React Compiler is enabled — manual $found is unnecessary. The compiler auto-memoizes components and hooks. Remove $found unless there is a specific reason (add 'use no memo' directive at the file top if needed).\"}" >&2
  exit 2
fi

exit 0
