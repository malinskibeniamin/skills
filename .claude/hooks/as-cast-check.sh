#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "ts|tsx"
hook_skip_generated
hook_skip_tests
hook_get_added_lines

# ── Check 1: Hard block `as never` / `as any` ───────────────────
# These suppress TypeScript entirely. Fix types properly.

if echo "$added_lines" | grep -qE '\bas\s+never\b'; then
  hook_block "No 'as never' casts. Fix the underlying type mismatch — use type guards, generics, or discriminated unions."
fi

if echo "$added_lines" | grep -qE '\bas\s+any\b'; then
  hook_block "No 'as any' casts. Fix types properly — type guards, generics, schema validation."
fi

# ── Check 2: Warn on `as TypeName` casts in .tsx ─────────────────
# Prefer type guards (isServerlessCluster(x)) over casts (x as Cluster).
# Allow: 'as const', 'as string', 'as number', 'as boolean' (primitives).

as_casts=$(echo "$added_lines" | grep -E '\bas\s+[A-Z][A-Za-z]+' | grep -vE '\bas\s+const\b|\bas\s+unknown\b|\bas\s+React\.' || true)

if [ -n "$as_casts" ]; then
  _count=$(echo "$as_casts" | wc -l | tr -d '[:space:]')
  if [ "${_count:-0}" -gt 2 ]; then
    if ! hook_has_escape "as-cast"; then
      sample=$(echo "$as_casts" | head -2 | sed 's/^+//' | tr '\n' ' ')
      hook_warn "${_count} type casts with 'as'. Prefer type guards for safety. Found: $sample. Escape: // allow: as-cast [reason]" "as-cast"
    fi
  fi
fi

exit 0
