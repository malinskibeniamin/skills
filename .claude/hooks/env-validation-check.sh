#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "ts|tsx|js|jsx"

# Skip dedicated env files (where process.env is expected)
case "$(basename "$file_path")" in
  env.ts|env.mts|env.mjs|env.js) exit 0 ;;
esac

hook_skip_tests
hook_get_added_lines

# Check for raw process.env access
if echo "$added_lines" | grep -qE 'process\.env\.'; then
  hook_block "Do not use raw process.env access.\nImport the validated env object: import { env } from \\\"@/env\\\".\n\nAll variables must be declared in src/env.ts with t3-env zod validation."
fi

exit 0
