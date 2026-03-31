#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "ts|tsx|js|jsx"
hook_get_added_lines

# Read full file for context checks
file_content=$(cat "$file_path")
imports_zustand=false
if echo "$file_content" | grep -qE "from\s+['\"]zustand"; then
  imports_zustand=true
fi

# ── Check 1: Ban single-parens create<T>() — must be create<T>()() ──

if [ "$imports_zustand" = true ]; then
  if echo "$added_lines" | grep -qE 'create<[^>]+>\(' && ! echo "$added_lines" | grep -qE 'create<[^>]+>\(\)\s*\('; then
    hook_block "Use double-parens create<T>()() for correct middleware types.\nSingle-parens create<T>((set) => ...) breaks type inference.\n\n// BAD\nconst useStore = create<State>((set) => ...)\n\n// GOOD\nconst useStore = create<State>()((set) => ...)"
  fi
fi

# ── Check 2: Ban inline object selectors — suggest useShallow ────────

if echo "$added_lines" | grep -qE 'use\w+Store\(.*=>\s*\(\{'; then
  hook_block "Wrap multi-field selectors with useShallow to prevent infinite re-renders.\nThe inline object creates a new reference every render.\n\n// BAD\nconst { a, b } = useStore((s) => ({ a: s.a, b: s.b }))\n\n// GOOD\nimport { useShallow } from 'zustand/react/shallow'\nconst { a, b } = useStore(useShallow((s) => ({ a: s.a, b: s.b })))"
fi

# ── Check 3: Ban localStorage/sessionStorage in zustand store files ──

if [ "$imports_zustand" = true ]; then
  if echo "$added_lines" | grep -qE '\b(localStorage|sessionStorage)\b'; then
    hook_block "Do not use localStorage/sessionStorage directly in stores.\nUse the zustand persist middleware instead.\n\nimport { persist } from 'zustand/middleware'"
  fi
fi

exit 0
