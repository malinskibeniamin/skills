#!/bin/bash
set -eo pipefail

# Remove only session directories with neither a recently modified directory
# nor a recently modified top-level state file. One find replaces thousands
# of per-directory processes on machines with substantial hook history.
session_root="${HOOK_SESSION_ROOT:-/tmp}"

while IFS= read -r stale_dir; do
  [ -d "$stale_dir" ] || continue
  rm -r "$stale_dir" 2>/dev/null || true
done < <(
  comm -23 \
    <(printf '%s\n' "$session_root"/hook-session-* | sort -u) \
    <(
      find "$session_root" -maxdepth 2 -path "$session_root/hook-session-*" \
        -mmin -1440 -print 2>/dev/null \
        | sed -E "s#^(${session_root}/hook-session-[^/]+).*#\\1#" \
        | sort -u
    )
)

exit 0
