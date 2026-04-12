#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "tsx|jsx"
hook_skip_ui_dirs
hook_skip_generated

# Skip entirely if React Compiler is not installed in this project
# Check package.json for the babel plugin, or rsbuild/vite config for the plugin reference
_has_compiler=false
if [ -f "package.json" ] && grep -q 'babel-plugin-react-compiler' package.json 2>/dev/null; then
  _has_compiler=true
elif ls rsbuild.config.* vite.config.* babel.config.* .babelrc* 2>/dev/null | head -1 | while read cfg; do
  grep -q 'react-compiler' "$cfg" 2>/dev/null && echo "found"
done | grep -q "found" 2>/dev/null; then
  _has_compiler=true
fi

if [ "$_has_compiler" = false ]; then
  exit 0
fi

# Skip files with 'use no memo' directive
if head -5 "$file_path" | grep -qF "'use no memo'" || head -5 "$file_path" | grep -qF '"use no memo"'; then
  exit 0
fi

# In annotation mode, only check files with 'use memo' directive
# (other files aren't compiled, so manual memoization is correct)
# Config via: .skills.json { "react-compiler": { "mode": "annotation" } }
# Legacy env: REACT_COMPILER_MODE=annotation
_compiler_mode=$(hook_config "react-compiler.mode")
if [ "${_compiler_mode:-infer}" = "annotation" ]; then
  if ! head -5 "$file_path" | grep -qF "'use memo'" && ! head -5 "$file_path" | grep -qF '"use memo"'; then
    exit 0
  fi
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
  hook_block "Remove manual $found -- React Compiler auto-memoizes.\nWrite plain JS expressions and inline callbacks instead.\n\nEscape hatch: add 'use no memo' directive with a comment explaining why."
fi

# ── Check 2: Derived state via useEffect anti-pattern ────────────
if echo "$added_lines" | grep -qE '\buseEffect\b'; then
  file_content=$(cat "$file_path")
  if echo "$file_content" | grep -qE 'const \[.*,\s*set\w+\]\s*=\s*useState' && \
     echo "$added_lines" | grep -qE 'useEffect\(\(\)\s*=>\s*\{?\s*set'; then
    hook_block "Do not derive state via useState + useEffect.\nCompute the value inline during render instead.\n\n// BAD\nconst [filtered, setFiltered] = useState([])\nuseEffect(() => { setFiltered(items.filter(i => i.visible)) }, [items])\n\n// GOOD\nconst filtered = items.filter(i => i.visible)"
  fi
fi

# ── Check 3: useRef as memoization cache ─────────────────────────
if echo "$added_lines" | grep -qE 'useRef\(' && \
   echo "$added_lines" | grep -qE '\.current\s*=.*\?\?=|\.current\s*\?\?=|if.*\.current.*===.*null'; then
  hook_block "Do not use useRef as a memoization cache.\nWrite plain derived values -- React Compiler owns caching."
fi

exit 0
