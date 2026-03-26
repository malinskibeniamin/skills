# React Compiler Reference

## Post-Compiler Mental Model

> "Write React as if every render is free and memoization is automatic."

**Pre-compiler era:** manual control over re-renders, defensive memoization, referential equality as priority.
**Post-compiler era:** compiler auto-inserts memoization, renders are cheap, code organized around clarity and correctness.

## react-compiler-check.sh

```bash
#!/bin/bash
set -euo pipefail

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

if [ "$tool_name" != "Edit" ] && [ "$tool_name" != "Write" ]; then
  exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [ -z "$file_path" ]; then
  exit 0
fi

# Only check TSX/JSX files
case "$file_path" in
  *.tsx|*.jsx) ;;
  *) exit 0 ;;
esac

# Skip redpanda-ui directory (uses 'use no memo')
if echo "$file_path" | grep -qF '/redpanda-ui/'; then
  exit 0
fi

# Skip if file doesn't exist
if [ ! -f "$file_path" ]; then
  exit 0
fi

# Skip files with 'use no memo' directive
if head -5 "$file_path" | grep -qF "'use no memo'" || head -5 "$file_path" | grep -qF '"use no memo"'; then
  exit 0
fi

# Get added lines from diff
diff_output=""
diff_output=$(git diff HEAD -- "$file_path" 2>/dev/null) || true

if [ -z "$diff_output" ]; then
  check_lines=$(cat "$file_path")
else
  check_lines=$(echo "$diff_output" | grep '^+' | grep -v '^+++' || true)
fi

if [ -z "$check_lines" ]; then
  exit 0
fi

# ── Check 1: Ban manual memoization ─────────────────────────────
found=""
if echo "$check_lines" | grep -qE '\buseMemo\b'; then
  found="useMemo"
elif echo "$check_lines" | grep -qE '\buseCallback\b'; then
  found="useCallback"
elif echo "$check_lines" | grep -qE '\bReact\.memo\b|\bmemo\('; then
  found="React.memo"
fi

if [ -n "$found" ]; then
  echo "{\"suppressOutput\":true,\"systemMessage\":\"React Compiler is enabled — manual $found is unnecessary. The compiler auto-memoizes automatically.\\n\\nPost-compiler rules:\\n- Prefer plain JS: const total = items.reduce(...) — no useMemo wrapper needed\\n- Inline callbacks are fine: <Dialog onClose={() => setOpen(false)} />\\n- Only use $found as escape hatch for non-React system integration (document why, add 'use no memo')\"}" >&2
  exit 2
fi

# ── Check 2: Derived state via useEffect anti-pattern ────────────
# Detect: useState + useEffect used to compute derived values
if echo "$check_lines" | grep -qE '\buseEffect\b'; then
  file_content=$(cat "$file_path")
  if echo "$file_content" | grep -qE 'const \[.*,\s*set\w+\]\s*=\s*useState' && \
     echo "$check_lines" | grep -qE 'useEffect\(\(\)\s*=>\s*\{?\s*set'; then
    echo '{"suppressOutput":true,"systemMessage":"Derived-state-via-useEffect detected. Do not useState + useEffect to compute derived values — compute inline during render instead.\n\n// Bad: derived state via effect\nconst [filtered, setFiltered] = useState([])\nuseEffect(() => { setFiltered(items.filter(i => i.visible)) }, [items])\n\n// Good: derive inline\nconst filtered = items.filter(i => i.visible)"}' >&2
    exit 2
  fi
fi

# ── Check 3: useRef as memoization cache ─────────────────────────
if echo "$check_lines" | grep -qE 'useRef\(' && \
   echo "$check_lines" | grep -qE '\.current\s*=.*\?\?=|\.current\s*\?\?=|if.*\.current.*===.*null'; then
  echo '{"suppressOutput":true,"systemMessage":"Do not use useRef as a memoization cache. The React Compiler owns caching — write plain derived values instead.\n\n// Bad: manual cache via ref\nconst cache = useRef(null)\nif (cache.current === null) cache.current = expensiveCalc()\n\n// Good: plain computation (compiler memoizes)\nconst value = expensiveCalc()"}' >&2
  exit 2
fi

exit 0
```

## Escape Hatch: 'use no memo'

When the React Compiler causes issues with a specific component, add the directive at the file top:

```tsx
'use no memo'

export function ProblematicComponent() {
  // Compiler will skip this file
  const value = useMemo(() => expensiveCalc(), [dep])
  return <div>{value}</div>
}
```

Rules for directives:
- Never introduce directives automatically
- Respect existing directives — never remove `'use no memo'`
- Use `'use no memo'` only as last-resort escape hatch
- Document why the opt-out exists

## redpanda-ui Directory

All files in `redpanda-ui/` should have `'use no memo'` because:
- Registry/distribution components need explicit control over memoization
- The compiler may interfere with component API contracts
- Consumers of these components may have different compiler settings

## Post-Compiler Pattern Reference

| Pre-compiler (avoid) | Post-compiler (prefer) |
|---|---|
| `useMemo(() => items.reduce(...), [items])` | `const total = items.reduce(...)` |
| `useCallback(() => setOpen(false), [])` | `() => setOpen(false)` inline |
| `React.memo(Component)` | Plain `function Component()` |
| `useState` + `useEffect` for derived values | Compute inline: `const filtered = items.filter(...)` |
| `useRef` as memoization cache | Plain computation |
| Extract callbacks to variables | Inline in JSX props |
| `useState({a, b, c})` single large object | Multiple `useState` calls |

## When Manual Optimization IS Allowed

Only when:
1. Profiling reveals real bottleneck **after** compilation
2. Interfacing with non-React or legacy systems
3. Referential stability required for **correctness** (not performance)
4. Precise effect re-execution control beyond compiler inference

In these cases: add `'use no memo'` and document why.
