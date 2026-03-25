# Zustand Reference

## zustand-check.sh

```bash
#!/bin/bash
set -euo pipefail

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

if [ "$tool_name" != "Edit" ] && [ "$tool_name" != "Write" ]; then
  exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
  exit 0
fi

# Only check TS/TSX/JS/JSX files
case "$file_path" in
  *.ts|*.tsx|*.js|*.jsx) ;;
  *) exit 0 ;;
esac

# Get added lines from diff
diff_output=""
diff_output=$(git diff HEAD -- "$file_path" 2>/dev/null) || true

if [ -z "$diff_output" ]; then
  added_lines=$(cat "$file_path")
else
  added_lines=$(echo "$diff_output" | grep '^+' | grep -v '^+++' || true)
fi

if [ -z "$added_lines" ]; then
  exit 0
fi

# Read full file for context checks
file_content=$(cat "$file_path")
imports_zustand=false
if echo "$file_content" | grep -qE "from\s+['\"]zustand"; then
  imports_zustand=true
fi

# ── Check 1: Ban single-parens create<T>() — must be create<T>()() ──

if [ "$imports_zustand" = true ]; then
  # Match create<Type>( but NOT create<Type>()( which is the correct curried form
  if echo "$added_lines" | grep -qE 'create<[^>]+>\(' && ! echo "$added_lines" | grep -qE 'create<[^>]+>\(\)\s*\('; then
    echo '{"suppressOutput":true,"systemMessage":"zustand: Single-parens create<T>() breaks middleware type inference. Use double-parens create<T>()():\n\n// BAD\nconst useStore = create<State>((set) => ...)\n\n// GOOD\nconst useStore = create<State>()((set) => ...)\n\nThe extra () is required for TypeScript to correctly infer middleware types."}' >&2
    exit 2
  fi
fi

# ── Check 2: Ban inline object selectors — suggest useShallow ────────

if echo "$added_lines" | grep -qE 'use\w+Store\(.*=>\s*\(\{'; then
  echo '{"suppressOutput":true,"systemMessage":"zustand: Inline object selectors cause infinite re-renders. The selector creates a new object reference every render.\n\n// BAD — new object every render, infinite re-renders\nconst { a, b } = useStore((s) => ({ a: s.a, b: s.b }))\n\n// GOOD — useShallow does shallow comparison\nimport { useShallow } from '\''zustand/react/shallow'\''\nconst { a, b } = useStore(useShallow((s) => ({ a: s.a, b: s.b })))"}' >&2
  exit 2
fi

# ── Check 3: Ban localStorage/sessionStorage in zustand store files ──

if [ "$imports_zustand" = true ]; then
  if echo "$added_lines" | grep -qE '\b(localStorage|sessionStorage)\b'; then
    echo '{"suppressOutput":true,"systemMessage":"zustand: Do not use localStorage/sessionStorage directly in stores. Use the persist middleware instead:\n\nimport { persist } from '\''zustand/middleware'\''\n\nconst useStore = create<State>()(\n  persist(\n    (set) => ({ ... }),\n    { name: '\''unique-storage-key'\'' }\n  )\n)"}' >&2
    exit 2
  fi
fi

exit 0
```

## Best Practices (Reference)

### Selectors — Always Use `useShallow` for Multiple Values

```tsx
import { useShallow } from 'zustand/react/shallow'

// Single value — no useShallow needed
const count = useStore((s) => s.count)

// Multiple values — MUST use useShallow
const { count, name } = useStore(useShallow((s) => ({ count: s.count, name: s.name })))
```

### State Updates — Always Use Callback Form

```tsx
// BAD — stale state in async contexts
set({ count: state.count + 1 })

// GOOD — always has latest state
set((state) => ({ count: state.count + 1 }))
```

### Don't Use Zustand for Server State

Zustand is for client-side state (UI state, form state, local preferences). For server data, use TanStack Query / Connect Query:

- **Zustand**: theme, sidebar open/closed, selected tab, draft form data
- **TanStack Query**: API responses, entity lists, server-computed data

### Middleware Chaining

```tsx
import { create } from 'zustand'
import { persist, devtools } from 'zustand/middleware'
import { immer } from 'zustand/middleware/immer'

const useStore = create<State>()(
  devtools(
    persist(
      immer((set) => ({
        // store definition
      })),
      { name: 'store-key' }
    )
  )
)
```

### Separate State and Action Interfaces

```tsx
interface State {
  count: number
  name: string
}

interface Actions {
  increment: () => void
  setName: (name: string) => void
}

const useStore = create<State & Actions>()((set) => ({
  count: 0,
  name: '',
  increment: () => set((state) => ({ count: state.count + 1 })),
  setName: (name) => set({ name }),
}))
```
