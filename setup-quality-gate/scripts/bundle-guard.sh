#!/bin/bash
set -euo pipefail

# PostToolUse hook: warn when known-heavy dependencies are added to package.json.
# Only checks production "dependencies" (not devDependencies).

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

if [ "$tool_name" != "Edit" ] && [ "$tool_name" != "Write" ]; then
  exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
  exit 0
fi

# Only check package.json files
case "$file_path" in
  */package.json|package.json) ;;
  *) exit 0 ;;
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

# We need to verify the dep is in "dependencies", not "devDependencies".
# Extract the "dependencies" block from the file.
deps_block=$(jq -r '.dependencies // {} | keys[]' "$file_path" 2>/dev/null || true)

# ── Check: moment ──
if echo "$added_lines" | grep -qE '"moment"' && echo "$deps_block" | grep -qx 'moment'; then
  echo '{"suppressOutput":true,"systemMessage":"Do not add moment (330KB).\nUse date-fns (22KB) instead."}' >&2
  exit 2
fi

# ── Check: lodash (but not lodash-es or lodash/) ──
if echo "$added_lines" | grep -qE '"lodash"' && ! echo "$added_lines" | grep -qE '"lodash-es"|"lodash/' && echo "$deps_block" | grep -qx 'lodash'; then
  echo '{"suppressOutput":true,"systemMessage":"Do not add full lodash (530KB).\nUse lodash-es or per-function imports (e.g., lodash/get)."}' >&2
  exit 2
fi

# ── Check: jquery ──
if echo "$added_lines" | grep -qE '"jquery"' && echo "$deps_block" | grep -qx 'jquery'; then
  echo '{"suppressOutput":true,"systemMessage":"Do not add jQuery in a React project.\nUse native DOM APIs or React refs."}' >&2
  exit 2
fi

# ── Check: core-js ──
if echo "$added_lines" | grep -qE '"core-js"' && echo "$deps_block" | grep -qx 'core-js'; then
  echo '{"suppressOutput":true,"systemMessage":"Do not add full core-js (250KB+).\nUse specific polyfills or @babel/preset-env with useBuiltIns: '\''usage'\''."}' >&2
  exit 2
fi

# ── Check: classnames ──
if echo "$added_lines" | grep -qE '"classnames"' && echo "$deps_block" | grep -qx 'classnames'; then
  echo '{"suppressOutput":true,"systemMessage":"Do not add classnames (1.8KB).\nUse clsx (330B) instead."}' >&2
  exit 2
fi

exit 0
