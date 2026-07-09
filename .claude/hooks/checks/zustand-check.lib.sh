#!/bin/bash
# Extracted check logic for zustand-check.sh. Source ../_hook-lib.sh before this file.

run_zustand_check() {
hook_filter_extensions "ts|tsx" || return 0
hook_get_added_lines || return 0

# Read full file for context checks
file_content=$(cat "$file_path")
imports_zustand=false
if echo "$file_content" | grep -qE "from\s+['\"]zustand"; then
  imports_zustand=true
fi

# ── Check 1: Ban single-parens create<T>() — must be create<T>()() ──

if [ "$imports_zustand" = true ]; then
  if echo "$added_lines" | grep -qE 'create<[^>]+>\(' && ! echo "$added_lines" | grep -qE 'create<[^>]+>\(\)\s*\('; then
    hook_block "Use create<T>()() double-parens. Single-parens breaks middleware types."
    return 0
  fi
fi

# ── Check 2: Ban inline object selectors — suggest useShallow ────────

if echo "$added_lines" | grep -qE 'use\w+Store\(.*=>\s*\(\{'; then
  hook_block "Wrap multi-field selector with useShallow. Inline object = new ref = infinite re-render."
  return 0
fi

# ── Check 3: Ban localStorage/sessionStorage in zustand stores ──

if [ "$imports_zustand" = true ]; then
  if echo "$added_lines" | grep -qE '\b(localStorage|sessionStorage)\b'; then
    hook_block "No direct localStorage in stores. Use zustand persist middleware."
    return 0
  fi
fi

return 0
}
