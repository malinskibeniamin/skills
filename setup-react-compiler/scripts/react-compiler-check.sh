#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "tsx|jsx"
hook_skip_ui_dirs

# Skip files with 'use no memo' directive
if head -5 "$file_path" | grep -qF "'use no memo'" || head -5 "$file_path" | grep -qF '"use no memo"'; then
  exit 0
fi

hook_get_added_lines

# ── Check 1: Ban manual memoization ─────────────────────────────
found=""
if echo "$added_lines" | grep -qE '\buseMemo\b'; then
  found="useMemo"
elif echo "$added_lines" | grep -qE '\buseCallback\b'; then
  found="useCallback"
elif echo "$added_lines" | grep -qE '\bReact\.memo\b|\bmemo\('; then
  found="React.memo"
fi

if [ -n "$found" ]; then
  hook_block "React Compiler is enabled — manual $found is unnecessary. The compiler auto-memoizes automatically.\\n\\nPost-compiler rules:\\n- Prefer plain JS: const total = items.reduce(...) — no useMemo wrapper needed\\n- Inline callbacks are fine: <Dialog onClose={() => setOpen(false)} />\\n- Only use $found as escape hatch for non-React system integration (document why, add 'use no memo')"
fi

# ── Check 2: Derived state via useEffect anti-pattern ────────────
if echo "$added_lines" | grep -qE '\buseEffect\b'; then
  file_content=$(cat "$file_path")
  if echo "$file_content" | grep -qE 'const \[.*,\s*set\w+\]\s*=\s*useState' && \
     echo "$added_lines" | grep -qE 'useEffect\(\(\)\s*=>\s*\{?\s*set'; then
    hook_block "Derived-state-via-useEffect detected. Do not useState + useEffect to compute derived values — compute inline during render instead.\n\n// Bad: derived state via effect\nconst [filtered, setFiltered] = useState([])\nuseEffect(() => { setFiltered(items.filter(i => i.visible)) }, [items])\n\n// Good: derive inline\nconst filtered = items.filter(i => i.visible)"
  fi
fi

# ── Check 3: useRef as memoization cache ─────────────────────────
if echo "$added_lines" | grep -qE 'useRef\(' && \
   echo "$added_lines" | grep -qE '\.current\s*=.*\?\?=|\.current\s*\?\?=|if.*\.current.*===.*null'; then
  hook_block "Do not use useRef as a memoization cache. The React Compiler owns caching — write plain derived values instead.\n\n// Bad: manual cache via ref\nconst cache = useRef(null)\nif (cache.current === null) cache.current = expensiveCalc()\n\n// Good: plain computation (compiler memoizes)\nconst value = expensiveCalc()"
fi

exit 0
