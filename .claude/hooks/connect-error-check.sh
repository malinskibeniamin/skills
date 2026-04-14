#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "ts|tsx|js|jsx"
hook_skip_generated
hook_skip_tests
hook_get_added_lines

# ── Check 1: Use ConnectError.from() in ConnectRPC files ─────────
# In files that import from @connectrpc/, throw new Error() loses
# gRPC status codes. Use ConnectError.from() for consistency.

file_content=$(cat "$file_path")

if echo "$file_content" | grep -qE "from\s+['\"]@connectrpc/"; then
  if echo "$added_lines" | grep -qE 'throw\s+new\s+Error\('; then
    # Only flag if near fetch/RPC context, not form validation or assertions
    # Check if the throw is inside a queryFn, mutationFn, loader, or fetch handler
    if echo "$file_content" | grep -qE 'queryFn|mutationFn|loader|\.fetch\(|callUnaryMethod'; then
      if ! hook_has_escape "connect-error"; then
        hook_warn "Use ConnectError.from() not throw new Error() in ConnectRPC data-fetching code. Preserves gRPC status codes. Escape: // allow: connect-error [reason]"
      fi
    fi
  fi
fi

exit 0
