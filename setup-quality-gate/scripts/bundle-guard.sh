#!/bin/bash
set -euo pipefail

# PostToolUse hook: warn when known-heavy dependencies are added to package.json.
# Only checks production "dependencies" (not devDependencies).

source "$(dirname "$0")/source-hook-lib.sh" 2>/dev/null || true

hook_parse_edit_write

# Only check package.json files
case "$file_path" in
  */package.json|package.json) ;;
  *) exit 0 ;;
esac

hook_get_added_lines

# We need to verify the dep is in "dependencies", not "devDependencies".
# Extract the "dependencies" block from the file.
deps_block=$(jq -r '.dependencies // {} | keys[]' "$file_path" 2>/dev/null || true)

# ── Check: moment ──
if echo "$added_lines" | grep -qE '"moment"' && echo "$deps_block" | grep -qx 'moment'; then
  hook_block "Do not add moment (330KB).\nUse date-fns (22KB) instead."
fi

# ── Check: lodash (but not lodash-es or lodash/) ──
if echo "$added_lines" | grep -qE '"lodash"' && ! echo "$added_lines" | grep -qE '"lodash-es"|"lodash/' && echo "$deps_block" | grep -qx 'lodash'; then
  hook_block "Do not add full lodash (530KB).\nUse lodash-es or per-function imports (e.g., lodash/get)."
fi

# ── Check: jquery ──
if echo "$added_lines" | grep -qE '"jquery"' && echo "$deps_block" | grep -qx 'jquery'; then
  hook_block "Do not add jQuery in a React project.\nUse native DOM APIs or React refs."
fi

# ── Check: core-js ──
if echo "$added_lines" | grep -qE '"core-js"' && echo "$deps_block" | grep -qx 'core-js'; then
  hook_block "Do not add full core-js (250KB+).\nUse specific polyfills or @babel/preset-env with useBuiltIns: 'usage'."
fi

# ── Check: classnames ──
if echo "$added_lines" | grep -qE '"classnames"' && echo "$deps_block" | grep -qx 'classnames'; then
  hook_block "Do not add classnames (1.8KB).\nUse clsx (330B) instead."
fi

exit 0
