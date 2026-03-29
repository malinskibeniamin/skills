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
    hook_block "zustand: Single-parens create<T>() breaks middleware type inference. Use double-parens create<T>()():\n\n// BAD\nconst useStore = create<State>((set) => ...)\n\n// GOOD\nconst useStore = create<State>()((set) => ...)\n\nThe extra () is required for TypeScript to correctly infer middleware types."
  fi
fi

# ── Check 2: Ban inline object selectors — suggest useShallow ────────

if echo "$added_lines" | grep -qE 'use\w+Store\(.*=>\s*\(\{'; then
  hook_block "zustand: Inline object selectors cause infinite re-renders. The selector creates a new object reference every render.\n\n// BAD — new object every render, infinite re-renders\nconst { a, b } = useStore((s) => ({ a: s.a, b: s.b }))\n\n// GOOD — useShallow does shallow comparison\nimport { useShallow } from 'zustand/react/shallow'\nconst { a, b } = useStore(useShallow((s) => ({ a: s.a, b: s.b })))"
fi

# ── Check 3: Ban localStorage/sessionStorage in zustand store files ──

if [ "$imports_zustand" = true ]; then
  if echo "$added_lines" | grep -qE '\b(localStorage|sessionStorage)\b'; then
    hook_block "zustand: Do not use localStorage/sessionStorage directly in stores. Use the persist middleware instead:\n\nimport { persist } from 'zustand/middleware'\n\nconst useStore = create<State>()(\n  persist(\n    (set) => ({ ... }),\n    { name: 'unique-storage-key' }\n  )\n)"
  fi
fi

exit 0
