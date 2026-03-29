#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../../shared/hook-lib.sh"

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
  hook_block "Do not use raw process.env access. Import the validated env object instead:\n\nimport { env } from \\\"@/env\\\";\n\nconst url = env.PUBLIC_API_URL;\n\nAll environment variables must be declared in src/env.ts with zod validation (t3-env). This ensures type safety and runtime validation at startup."
fi

exit 0
