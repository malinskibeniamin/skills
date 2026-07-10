#!/bin/bash
# Extracted check logic for tanstack-router-gen.sh. Source ../_hook-lib.sh before this file.

run_tanstack_router_gen() {

# Check if the file is in a routes directory
if ! echo "$file_path" | grep -qE '/routes/'; then
  return 0
fi

# Only trigger for TS/TSX files
hook_filter_extensions "ts|tsx" || return 0

# Regenerate route tree silently
bun run generate:routes > /dev/null 2>&1 || true

if [ "${HOOK_COLLECT:-0}" != "1" ]; then echo '{"suppressOutput":true}'; fi
return 0
}
