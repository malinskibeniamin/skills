#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "ts|tsx|js|jsx"
hook_skip_generated
hook_skip_tests
hook_get_added_lines

# ── Check 1: Side-effect fetch calls should use useMutation ──────
# fetch() with method: DELETE/POST/PUT/PATCH outside mutationFn
# should be wrapped in useMutation for proper loading/error state.
# Only fire in React component/route/hook files, not utility/lib files.

# Gate: only check files that are React components or hooks
file_content=$(cat "$file_path")
is_react_file=false
if echo "$file_path" | grep -qE '/(routes|components|hooks|pages|features)/'; then
  is_react_file=true
elif echo "$file_content" | grep -qE "from\s+['\"]react['\"]|from\s+['\"]@tanstack/"; then
  is_react_file=true
fi

if [ "$is_react_file" = true ]; then
  if echo "$added_lines" | grep -qE "method:\s*['\"]?(DELETE|POST|PUT|PATCH)['\"]?"; then
    # Skip if file already uses useMutation for this pattern
    if ! echo "$file_content" | grep -qE 'mutationFn|useMutation|createConnectQueryKey.*mutation'; then
      if ! hook_has_escape "inline-mutation"; then
        hook_warn "Side-effect fetch (DELETE/POST/PUT/PATCH) without useMutation. Wrap in useMutation hook for loading/error state. Escape: // allow: inline-mutation [reason]"
      fi
    fi
  fi
fi

exit 0
