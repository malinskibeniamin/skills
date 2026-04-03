#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_skip_ui_dirs
hook_skip_generated
hook_filter_extensions "ts|tsx|js|jsx"
hook_get_added_lines

# ── Check 1: Ban useEffect/useLayoutEffect/useInsertionEffect (opt-in) ──
# Enable via: export REACT_RULES_BAN_USEEFFECT=1

if [ "${REACT_RULES_BAN_USEEFFECT:-}" = "1" ]; then
  if echo "$added_lines" | grep -qE '\b(useEffect|useLayoutEffect|useInsertionEffect)\b'; then
    # Check for escape hatch: // allow-useEffect: [reason]
    has_escape=false
    if [ -f "$file_path" ]; then
      if grep -qE '//\s*allow-useEffect:' "$file_path"; then
        has_escape=true
      fi
    fi

    if [ "$has_escape" = false ]; then
      hook_block "Remove useEffect.\nReact Query, zustand, event handlers, or useTransition cover all valid use cases.\nReplace with the appropriate alternative.\n\nIf absolutely necessary, add: // allow-useEffect: [explain why]\nSee setup-react-rules REFERENCE.md"
    fi
  fi
fi

# ── Check 2: Ban raw HTML elements (TSX files only) ────────────

case "$file_path" in
  *.tsx|*.jsx)
    raw_element=""
    # <button> is a warn (not block) — sometimes needed as a wrapper for clickable cards
    if echo "$added_lines" | grep -qE '<button[[:space:]>]'; then
      hook_warn "Prefer <Button> from @/components/ui/button over raw <button>.\\nIf wrapping a card for click handling, use <Card asChild> or <div role=\\\"button\\\"> with keyboard handler."
    fi
    if echo "$added_lines" | grep -qE '<input[[:space:]/>]'; then raw_element="<input> → <Input> from @/components/ui/input"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<select[[:space:]>]'; then raw_element="<select> → <Select> from @/components/ui/select"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<textarea[[:space:]>]'; then raw_element="<textarea> → <Textarea> from @/components/ui/textarea"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<dialog[[:space:]>]'; then raw_element="<dialog> → <Dialog> from @/components/ui/dialog"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<table[[:space:]>]'; then raw_element="<table> → <Table> from @/components/ui/table"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<label[[:space:]>]'; then raw_element="<label> → <Label> from @/components/ui/label"; fi

    if [ -n "$raw_element" ]; then
      hook_block "Use component library instead of raw HTML elements.\\n$raw_element"
    fi
    ;;
esac

# ── Check 3: Ban TypeScript escape hatches ──────────────────────

if echo "$added_lines" | grep -qE '\bas\s+any\b'; then
  hook_block "Remove \`as any\` cast.\nType erasure hides bugs and breaks refactoring.\nFix the type properly — this applies everywhere, including tests."
fi

if echo "$added_lines" | grep -qE '\bas\s+Record<string,\s*(any|unknown)>'; then
  hook_block "Remove \`as Record<string, any/unknown>\` cast.\nIt erases type structure just like \`as any\`.\nUse a concrete interface or type guard instead."
fi

if echo "$added_lines" | grep -qF '@ts-ignore'; then
  hook_block "@ts-ignore is banned. Fix the type error instead of suppressing it."
fi

if echo "$added_lines" | grep -qF '@ts-expect-error'; then
  hook_block "@ts-expect-error is banned.\nWe require fully type-safe code with no escape hatches.\nFix the underlying type error."
fi

# ── Check 4: Ban all type assertions except 'as const' (opt-in) ──
# Enable via: export REACT_RULES_BAN_TYPE_ASSERTIONS=1

if [ "${REACT_RULES_BAN_TYPE_ASSERTIONS:-}" = "1" ]; then
  # Match TypeScript type assertions: `value as Type` or `value as unknown`
  # Exclude: `as const`, `as const satisfies`, `import X as Y`
  # Only match non-import lines with type assertion patterns
  _non_import_lines=$(echo "$added_lines" | grep -v '^\+\?import ' || true)
  if [ -n "$_non_import_lines" ] && \
     echo "$_non_import_lines" | grep -qE '\)\s+as\s+[A-Z]|\b\w+\s+as\s+[A-Z]|\bas\s+unknown\b|\bas\s+never\b' && \
     ! echo "$_non_import_lines" | grep -qE '\bas\s+const\b'; then
    # Check for escape hatch
    has_escape=false
    if grep -qE '//\s*allow-type-assertion:' "$file_path" 2>/dev/null; then
      has_escape=true
    fi

    if [ "$has_escape" = false ]; then
      hook_block "Remove type assertion (\`as X\`).\nAssertions bypass the type system and hide bugs.\nUse type guards, generics, or schema validation.\n\nAllowed: \`as const\`, \`as const satisfies\`\nEscape hatch: // allow-type-assertion: [reason]\nSee setup-react-rules REFERENCE.md"
    fi
  fi
fi

# ── Check 5: Ban visual style overrides on registry components ────

case "$file_path" in
  *.tsx|*.jsx)
    # Only flag when a registry component AND a visual override class are on the SAME LINE.
    # Must be actual diff lines (starting with +), not the whole file scan.
    # Skip this check entirely when scanning full file (no diff available) — too many false positives.
    _has_diff=$(git diff HEAD -- "$file_path" 2>/dev/null || true)
    if [ -n "$_has_diff" ]; then
      _diff_added=$(echo "$_has_diff" | grep '^+' | grep -v '^+++' || true)
      if echo "$_diff_added" | grep -E '<(Button|Input|Select|Alert|Dialog|Card|Badge|Table|Label|Textarea)[[:space:]]' | grep -qE 'className=.*\b(bg-|border-|shadow-|rounded-)'; then
        hook_warn "Visual style override on registry component detected — I hope you know what you are doing.\nIf this is intentional theming (bg-sidebar, border-input), proceed. If overriding with raw colors (bg-red-500), use the variant prop instead."
      fi
    fi
    ;;
esac

# ── Check 6: Navigation — prefer Link over onClick+navigate ─────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE 'onClick.*navigate\('; then
      hook_block "Use Link instead of onClick + navigate().\nBreaks accessibility (right-click, screen readers) and TanStack Router basePath.\nUse <Button asChild><Link to=\\\"/path\\\">...</Link></Button>."
    fi
    ;;
esac

# ── Check 7: Button must have handler or purpose ────────────────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE '<Button[[:space:]>]' && \
       ! echo "$added_lines" | grep -qE '<Button[^>]*(onClick|asChild|type="submit"|disabled)'; then
      hook_block "Button has no handler.\nA button without an action is likely a bug.\nAdd onClick, asChild, type=\\\"submit\\\", or disabled."
    fi
    ;;
esac

# ── Check 8: Alert — no icon inside AlertTitle ──────────────────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE '<AlertTitle>.*<.*Icon' || \
       echo "$added_lines" | grep -qE '<AlertTitle>.*<svg'; then
      hook_block "Do not add icons inside <AlertTitle>.\nThe <Alert> component already renders an icon automatically.\nUse the icon prop on <Alert> to customize: <Alert icon={<CustomIcon />}>."
    fi
    ;;
esac

# ── Check 9: Protobuf — wrap spreads with create() (v2 only) ────

# Only flag lines that BOTH spread AND reference a protobuf type on the same line.
# Importing schemas (e.g. import { FooSchema } from '...') is not spreading.
if echo "$added_lines" | grep -E '\.\.\.[a-zA-Z]+' | grep -qE '(Message|Request|Response)\b' && \
   ! echo "$added_lines" | grep -E '\.\.\.[a-zA-Z]+' | grep -qE 'create\('; then
  if [ -f "package.json" ] && grep -q '"@bufbuild/protobuf"' package.json 2>/dev/null; then
    proto_version=$(grep -oE '"@bufbuild/protobuf":\s*"[\^~]?2' package.json 2>/dev/null || true)
    if [ -n "$proto_version" ]; then
      hook_block "Wrap protobuf spread with create().\nSpreading without create() drops \$typeName, breaking serialization in @bufbuild/protobuf v2.\nUse: create(MyMessageSchema, { ...existingMessage, field: newValue })"
    fi
  fi
fi

# ── Check 11: Icon-only buttons need aria-label ──────────────────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE '<Button[^>]*>[[:space:]]*<[A-Z][a-zA-Z]*Icon' && \
       ! echo "$added_lines" | grep -qE '<Button[^>]*aria-label'; then
      hook_block "Add aria-label to icon-only button.\nScreen readers cannot derive meaning from an icon alone.\nAdd aria-label: <Button aria-label=\\\"Settings\\\" variant=\\\"ghost\\\" size=\\\"icon\\\"><SettingsIcon /></Button>"
    fi
    ;;
esac

# ── Check 12: No outline removal (breaks keyboard navigation) ────

# Allow outline-none when paired with focus-visible replacement (ring-*, outline-*)
if (echo "$added_lines" | grep -qE 'outline[[:space:]]*:[[:space:]]*(none|0)' || \
    echo "$added_lines" | grep -qE 'outline-none') && \
   ! echo "$added_lines" | grep -qE 'focus-visible:(outline|ring)'; then
  hook_block "Do not remove focus outlines.\nRemoving outlines breaks keyboard navigation accessibility.\nUse focus-visible styles: focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring"
fi

# ── Check 13: React Compiler — no manual memoization ────────────
# Only runs if React Compiler is actually installed in this project

_has_react_compiler=false
if [ -f "package.json" ] && grep -q 'babel-plugin-react-compiler' package.json 2>/dev/null; then
  _has_react_compiler=true
fi

if [ "$_has_react_compiler" = true ]; then
case "$file_path" in
  *.tsx|*.jsx)
    has_no_memo=false
    if head -5 "$file_path" | grep -qF "'use no memo'" || head -5 "$file_path" | grep -qF '"use no memo"'; then
      has_no_memo=true
    fi

    # In annotation mode, skip files without 'use memo' (compiler isn't active for them)
    if [ "${REACT_COMPILER_MODE:-infer}" = "annotation" ]; then
      if ! head -5 "$file_path" | grep -qF "'use memo'" && ! head -5 "$file_path" | grep -qF '"use memo"'; then
        has_no_memo=true
      fi
    fi

    if [ "$has_no_memo" = false ]; then
      found_memo=""
      if echo "$added_lines" | grep -qE '\buseMemo\b'; then found_memo="useMemo"; fi
      if [ -z "$found_memo" ] && echo "$added_lines" | grep -qE '\buseCallback\b'; then found_memo="useCallback"; fi
      if [ -z "$found_memo" ] && echo "$added_lines" | grep -qE '\bReact\.memo\b|\bmemo\('; then found_memo="React.memo"; fi

      if [ -n "$found_memo" ]; then
        hook_block "Remove manual $found_memo.\nReact Compiler auto-memoizes; manual memoization is redundant.\nDelete the $found_memo call, or add 'use no memo' directive at file top."
      fi
    fi
    ;;
esac
fi  # end _has_react_compiler

# ── Check 14: Ban dangerouslySetInnerHTML (TSX/JSX only) ──────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qF 'dangerouslySetInnerHTML'; then
      has_escape=false
      if [ -f "$file_path" ]; then
        if grep -qE '//\s*allow-dangerouslySetInnerHTML:' "$file_path"; then
          has_escape=true
        fi
      fi

      if [ "$has_escape" = false ]; then
        hook_block "dangerouslySetInnerHTML is banned — XSS risk.\nUnsanitized HTML injection is a top-tier vulnerability.\nSanitize with DOMPurify or use a safe rendering approach.\n\nIf absolutely necessary, add: // allow-dangerouslySetInnerHTML: [explain why]"
      fi
    fi
    ;;
esac

# ── Check 15: Ban eval() and new Function() ──────────────────

if echo "$added_lines" | grep -qE '\beval\(|\bnew Function\('; then
  hook_block "eval() and new Function() are banned — code injection risk.\nOWASP A03: Injection.\nUse JSON.parse() for data, or a safe alternative."
fi

# ── Check 16: Ban .innerHTML assignment (TSX/JSX only) ────────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE '\.innerHTML\s*='; then
      hook_block "Direct .innerHTML assignment is banned — XSS risk.\nUse React rendering, element.textContent, or the Sanitizer API (setHTML) for safe HTML insertion."
    fi
    ;;
esac

# ── Check 17: Ban inline style={{}} in TSX/JSX (use Tailwind) ────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE 'style=\{\{'; then
      hook_warn "Inline style={{}} detected — I hope you know what you are doing.\nInline styles bypass Tailwind and break design consistency.\nUse Tailwind CSS utility classes instead. If truly necessary (dynamic positioning from JS), proceed with caution."
    fi
    ;;
esac

# ── Check 18: Ban class components ───────────────────────────────

if echo "$added_lines" | grep -qE 'extends\s+(React\.)?(Component|PureComponent)\b'; then
  hook_block "Use functional components instead of class components.\nReact Compiler requires functional components for auto-memoization.\nConvert to a function component."
fi

# ── Check 19: Ban barrel imports (re-exports from index files) ────

if echo "$added_lines" | grep -qE "from\s+['\"]\.\.?/[^'\"]*['\"]" && \
   echo "$added_lines" | grep -qE "from\s+['\"]\.\.?/[^'\"]*(/index)?['\"]"; then
  # Check if the import path resolves to a directory (barrel re-export)
  import_paths=$(echo "$added_lines" | grep -oE "from\s+['\"](\.\./[^'\"]+|\.\/[^'\"]+)['\"]" | grep -oE "['\"][^'\"]+['\"]" | tr -d "'" | tr -d '"' || true)
  if [ -n "$import_paths" ]; then
    dir=$(dirname "$file_path")
    for imp in $import_paths; do
      resolved="$dir/$imp"
      if [ -d "$resolved" ] || [ -f "$resolved/index.ts" ] || [ -f "$resolved/index.tsx" ] || [ -f "$resolved/index.js" ]; then
        hook_warn "Barrel import detected: \`$imp\`.\nBarrel re-exports increase bundle size and slow builds.\nImport directly from the source file."
        break
      fi
    done
  fi
fi

# ── Check 20: Ban addEventListener without passive for scroll/touch/wheel ──

if echo "$added_lines" | grep -qE "addEventListener\s*\(\s*['\"](scroll|touchstart|touchmove|wheel)['\"]" && \
   ! echo "$added_lines" | grep -qE "passive\s*:\s*true"; then
  hook_block "Add { passive: true } to scroll/touch/wheel event listener.\nNon-passive listeners block the main thread and cause scroll jank.\nPass { passive: true } as the third argument to addEventListener."
fi

# ── Check 21: Ban static imports of heavy deps (suggest dynamic import) ──

if echo "$added_lines" | grep -qE "^[+]?import\s.*from\s+['\"]" | grep -qE "(chart\.js|d3|three|pdf-lib|plotly\.js|recharts)['\"/]" 2>/dev/null || \
   echo "$added_lines" | grep -qE "from\s+['\"](chart\.js|d3|three|pdf-lib|plotly\.js|recharts)['\"/]"; then
  hook_warn "Use dynamic import for heavy dependency.\nStatic imports of large libraries bloat the initial bundle.\nUse React.lazy() or dynamic import() instead."
fi

# ── Check 22: handleSubmit must have error callback ────────────────

case "$file_path" in
  *.tsx|*.jsx)
    # Match handleSubmit(onSubmit) without a second arg — no comma after first arg
    # Good: handleSubmit(onSubmit, onError) — has comma = has error callback
    if echo "$added_lines" | grep -qE 'handleSubmit\([a-zA-Z_]+\)' && \
       ! echo "$added_lines" | grep -qE 'handleSubmit\([a-zA-Z_]+,'; then
      hook_warn "Add error callback to handleSubmit.\nWithout it, form submission errors are silently swallowed.\nUse handleSubmit(onSubmit, onError) — always handle the error case."
    fi
    ;;
esac

# ── Check 23: Ban React.FC / React.FunctionComponent ──────────────

if echo "$added_lines" | grep -qE '\bReact\.FC\b|\bReact\.FunctionComponent\b|:\s*FC[<\s>]'; then
  hook_warn "Prefer plain function declarations over React.FC.\nReact.FC adds implicit children and doesn't support generics cleanly.\nUse: function MyComponent(props: Props) { ... }"
fi

# ── Check 24: Ban cloneElement ────────────────────────────────────

if echo "$added_lines" | grep -qE 'cloneElement\(|React\.cloneElement'; then
  hook_warn "Avoid cloneElement — fragile for compound components.\nUse Context-based composition or render props instead."
fi

# ── Check 25: Warn on biome-ignore (sudo pattern) ─────────────────

if echo "$added_lines" | grep -qE '//\s*biome-ignore|/\*\s*biome-ignore'; then
  hook_warn "biome-ignore detected — I hope you know what you are doing.\nThe linter exists for a reason. If this is truly necessary, proceed with caution."
fi

# ── Check 26: Warn on tree-shaking killers ────────────────────────

# Allow import * as React (legitimate) but warn on other namespace imports
if echo "$added_lines" | grep -qE 'import \* as \w+ from' && \
   ! echo "$added_lines" | grep -qE 'import \* as React from'; then
  hook_warn "Namespace import (import * as) prevents tree-shaking.\nImport specific exports instead: import { foo, bar } from 'package'."
fi

if echo "$added_lines" | grep -qE "export \* from ['\"]"; then
  hook_warn "Re-exporting entire modules (export * from) prevents tree-shaking.\nExport specific items instead."
fi

# ── Check 27: Warn on deprecated package imports ─────────────────

if echo "$added_lines" | grep -qE "from\s+['\"]react-beautiful-dnd['\"/]"; then
  hook_warn "react-beautiful-dnd is archived by Atlassian.\nUse @dnd-kit/core or react-aria drag instead."
fi

if echo "$added_lines" | grep -qE "from\s+['\"]framer-motion['\"/]"; then
  hook_warn "framer-motion has been renamed to 'motion'.\nUse: import { motion } from 'motion'"
fi

# ── Checks 28-29 (raw hex/rgb, !important) moved to tailwind-check.sh ──

exit 0
