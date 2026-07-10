#!/bin/bash
# Extracted check logic for react-rules-check.sh. Source ../_hook-lib.sh before this file.

run_react_rules_check() {

_react_rules_skip_ui_dirs=false
if [ -z "${UI_LIB_DIRS:-}" ]; then
  _react_rules_ui_dirs="components/ui"
  _root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  [ -d "$_root/redpanda-ui" ] && _react_rules_ui_dirs="$_react_rules_ui_dirs|redpanda-ui"
  [ -d "$_root/src/components/redpanda-ui" ] && _react_rules_ui_dirs="$_react_rules_ui_dirs|redpanda-ui"
  [ -d "$_root/src/ui" ] && _react_rules_ui_dirs="$_react_rules_ui_dirs|src/ui"
  [ -d "$_root/packages/ui" ] && _react_rules_ui_dirs="$_react_rules_ui_dirs|packages/ui"
else
  _react_rules_ui_dirs="$UI_LIB_DIRS"
fi
if echo "$file_path" | grep -qE "/($_react_rules_ui_dirs)/"; then
  _repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  if [ -f "$_repo_root/registry.json" ]; then
    # Registry repo — remind to rebuild registry
    if [ "${HOOK_COLLECT:-0}" = "1" ]; then
      _hook_collect_emit "warn" "ui-registry-warn" "You are editing a UI registry component. Remember to rebuild registry.json and update CHANGELOG.md when done."
    else
      echo '{"suppressOutput":true,"systemMessage":"You are editing a UI registry component. Remember to rebuild registry.json and update CHANGELOG.md when done."}' >&2
    fi
  elif [ -f "$_repo_root/components.json" ] || [ -f "$_repo_root/cli.json" ]; then
    # Consumer repo — warn that this is a registry-sourced component
    _component=$(basename "$file_path")
    if [ "${HOOK_COLLECT:-0}" = "1" ]; then
      _hook_collect_emit "warn" "ui-registry-warn" "WARNING: You are modifying '$_component' which comes from the UI registry. Local changes will be overwritten on next registry pull. If this change is intentional, submit a PR upstream to the UI registry repo instead."
    else
      echo "{"suppressOutput":true,"systemMessage":"WARNING: You are modifying '$_component' which comes from the UI registry. Local changes will be overwritten on next registry pull. If this change is intentional, submit a PR upstream to the UI registry repo instead."}" >&2
    fi
  fi
  _react_rules_skip_ui_dirs=true
fi

hook_skip_generated || return 0
hook_filter_extensions "ts|tsx|mdx" || return 0
hook_get_added_lines || return 0

if [ "$_react_rules_skip_ui_dirs" = false ]; then

# ── Check 1: useEffect misuse — delegated to React Doctor ────────
# React Doctor's state-and-effects family (no-fetch-in-effect, no-derived-state-effect,
# no-effect-chain, no-mirror-prop-effect, no-event-handler, ...) owns effect-misuse
# detection with AST precision. The old blanket opt-in ban is retired.

# ── Check 2: raw HTML elements — delegated to Biome ─────────────
# Biome a11y/correctness noRestrictedElements (ultracite preset + starter-kit
# config) owns the raw <button>/<input>/<select>/<h*>/<p>/... bans. Do not
# re-add them here; one owner per rule.

# ── Check 2b: Name useEffect callbacks ──────────────────────────
# useEffect(function syncDocumentTitle() { ... }, [title]) not useEffect(() => {

case "$file_path" in
  *.tsx|*.jsx|*.ts)
    if echo "$added_lines" | grep -qE 'useEffect\(\s*\(\)\s*=>' && \
       ! echo "$added_lines" | grep -qE 'useEffect\(\s*function\s+\w+'; then
      if ! hook_has_escape "named-effect"; then
        hook_warn "Name useEffect callback: useEffect(function syncX() { ... }, [deps]). Aids debugging. Escape: // allow: named-effect [reason]"
      fi
    fi
    ;;
esac

# ── Check 3+4: (moved to ts-no-escape-hatches-check.sh — as any, @ts-ignore,
#     @ts-expect-error, and all type assertions. Single owner for cast bans.) ──

# ── Check 5: Button should not restyle gradient/radius/shadow ────

case "$file_path" in
  *.tsx|*.jsx|*.mdx)
    _button_added=$(printf '%s\n' "$added_lines" | sed 's/^+//')
    if echo "$_button_added" | grep -E '<Button[[:space:]>]' | grep -qE 'className=.*(bg-gradient-|from-[a-z]+-[0-9]|via-[a-z]+-[0-9]|to-[a-z]+-[0-9]|rounded|shadow)'; then
      if ! hook_has_escape "button-visual-override" && ! hook_has_escape "design-token"; then
        hook_block "Button gradient/radius/shadow override detected. Use Button variant/size or add a registry variant. Escape: // allow: button-visual-override [reason]"
      fi
    fi
    ;;
esac

# ── Check 5b: Registry palette/gradient overrides ────────────────

case "$file_path" in
  *.tsx|*.jsx|*.mdx)
    _registry_added=$(printf '%s\n' "$added_lines" | sed 's/^+//')
    if [ -n "$_registry_added" ]; then
      _registry_component_pattern='<(Button|Input|Select|Alert|Dialog|Card|Badge|Table|Label|Textarea|Tabs|Tooltip|Popover|DropdownMenu|Sheet|Accordion|Avatar|Checkbox|Switch|Slider|Progress|Separator|Skeleton|Toast|Toaster|Command|Calendar|ScrollArea|AspectRatio|RadioGroup|Toggle|ToggleGroup)[[:space:]>]'
      _hardcoded_palette_colors='red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose|slate|gray|zinc|neutral|stone|white|black'
      _palette_or_gradient_pattern="className=.*(bg-($_hardcoded_palette_colors)-|text-($_hardcoded_palette_colors)-|border-($_hardcoded_palette_colors)-|from-($_hardcoded_palette_colors)-|via-($_hardcoded_palette_colors)-|to-($_hardcoded_palette_colors)-|bg-gradient-)"
      if echo "$_registry_added" | grep -E "$_registry_component_pattern" | grep -qE "$_palette_or_gradient_pattern"; then
        if ! hook_has_escape "registry-visual-override" && ! hook_has_escape "design-token"; then
          hook_block "Registry component has hardcoded palette or gradient override. Use variant props/design tokens. Escape: // allow: registry-visual-override [reason]"
        fi
      fi
      if echo "$_registry_added" | grep -E "$_registry_component_pattern" | grep -qE 'className=.*\b(bg-|border-|shadow-|rounded-)'; then
        if ! hook_has_escape "registry-visual-override" && ! hook_has_escape "design-token"; then
          hook_warn "Visual override on registry component. Use variant prop or design token. Escape: // allow: registry-visual-override [reason]"
        fi
      fi
    fi
    ;;
esac

# ── Check 5c: Inline gradient/blur/z-index visual traps ──────────

case "$file_path" in
  *.tsx|*.jsx|*.mdx)
    _visual_added=$(printf '%s\n' "$added_lines" | sed 's/^+//')
    if echo "$_visual_added" | grep -qE 'backgroundImage[[:space:]]*:[[:space:]]*.*linear-gradient\('; then
      if ! hook_has_escape "inline-gradient" && ! hook_has_escape "design-token"; then
        hook_block "Inline backgroundImage linear-gradient detected. Use Tailwind/theme gradient tokens. Escape: // allow: inline-gradient [reason]"
      fi
    fi
    if echo "$_visual_added" | grep -qE '(backdropFilter|filter)[[:space:]]*:[[:space:]]*.*blur\('; then
      if ! hook_has_escape "blur-effect"; then
        hook_warn "Inline filter/backdropFilter blur detected. Prefer tokenized Tailwind blur/backdrop-blur or remove decorative blur. Escape: // allow: blur-effect [reason]"
      fi
    fi
    if echo "$_visual_added" | grep -qE '(z-\[(999|9999)\]|zIndex[[:space:]]*:[[:space:]]*(999|9999)\b)'; then
      if ! hook_has_escape "z-index"; then
        hook_warn "Arbitrary z-index 999/9999 detected. Use z-layer tokens or fix stacking context. Escape: // allow: z-index [reason]"
      fi
    fi
    ;;
esac

# ── Check 5d: Nested/card-like containers and image motion ───────

case "$file_path" in
  *.tsx|*.jsx|*.mdx)
    _composition_added=$(printf '%s\n' "$added_lines" | sed 's/^+//')
    _composition_one_line=$(printf '%s\n' "$_composition_added" | tr '\n' ' ')
    if echo "$_composition_one_line" | grep -qE '<Card[[:space:]>].*<(Card|div|section|article)[^>]*className=.*(rounded|border|shadow|bg-card|bg-background)'; then
      if ! hook_has_escape "nested-card"; then
        hook_warn "Nested Card/card-like container detected. Flatten layout or use Card sections, not card-in-card chrome. Escape: // allow: nested-card [reason]"
      fi
    fi
    if echo "$_composition_added" | grep -E '<(img|Image)[[:space:]>]' | grep -qE 'className=.*((group-)?hover:(scale|rotate|translate|skew)-|transition-transform)'; then
      if ! hook_has_escape "image-hover-transform"; then
        hook_warn "Image hover transform detected. Prefer non-layout-shifting affordance or tokenized interaction pattern. Escape: // allow: image-hover-transform [reason]"
      fi
    fi
    ;;
esac

# ── Check 5e: autoFocus surprises ────────────────────────────────

case "$file_path" in
  *.tsx|*.jsx|*.mdx)
    if echo "$added_lines" | grep -qE '\bautoFocus\b'; then
      if ! hook_has_escape "autoFocus"; then
        hook_warn "autoFocus can steal focus unexpectedly. Prefer explicit focus management after user intent. Escape: // allow: autoFocus [reason]"
      fi
    fi
    ;;
esac

# ── Check 6: Navigation — prefer Link over onClick+navigate ─────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE 'onClick.*navigate\('; then
      hook_block "Use <Link> not onClick+navigate(). Breaks a11y+basePath. Use <Button asChild><Link to=\\\"/path\\\">...</Link></Button>."
    fi
    ;;
esac

# ── Check 7: Button must have handler or purpose ────────────────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE '<Button[[:space:]>]' && \
       ! echo "$added_lines" | grep -qE '<Button[^>]*(onClick|asChild|type="submit"|disabled)'; then
      hook_block "Button needs purpose: onClick, asChild, type=\\\"submit\\\", or disabled."
    fi
    ;;
esac

# ── Check 8: Alert — no icon inside AlertTitle ──────────────────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE '<AlertTitle>.*<.*Icon' || \
       echo "$added_lines" | grep -qE '<AlertTitle>.*<svg'; then
      hook_block "No icons in <AlertTitle>. <Alert> renders icons auto. Use icon prop."
    fi
    ;;
esac

# ── Check 9: Protobuf — wrap spreads with create() (v2 only) ────

if echo "$added_lines" | grep -E '\.\.\.[a-zA-Z]+' | grep -qE '(Message|Request|Response)\b' && \
   ! echo "$added_lines" | grep -E '\.\.\.[a-zA-Z]+' | grep -qE 'create\('; then
  if [ -f "package.json" ] && grep -q '"@bufbuild/protobuf"' package.json 2>/dev/null; then
    proto_version=$(grep -oE '"@bufbuild/protobuf":\s*"[\^~]?2' package.json 2>/dev/null || true)
    if [ -n "$proto_version" ]; then
      hook_block "Wrap protobuf spread with create(). Spreading drops \$typeName. Use: create(Schema, { ...existing, field: val })"
    fi
  fi
fi

# ── Check 11: Icon-only buttons need aria-label ──────────────────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE '<Button[^>]*>[[:space:]]*<[A-Z][a-zA-Z]*Icon' && \
       ! echo "$added_lines" | grep -qE '<Button[^>]*aria-label'; then
      hook_block "Icon-only button needs aria-label for screen readers."
    fi
    ;;
esac

# ── Check 12: outline removal — delegated to React Doctor design/no-outline-none ──

# ── Check 13: (moved to react-compiler-check.sh — memoization) ──

# ── Check 14: Ban dangerouslySetInnerHTML (TSX/JSX only) ──────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qF 'dangerouslySetInnerHTML'; then
      if ! hook_has_escape "dangerouslySetInnerHTML"; then
        hook_block "dangerouslySetInnerHTML banned — XSS. Use DOMPurify. Escape: // allow: dangerouslySetInnerHTML [reason]"
      fi
    fi
    ;;
esac

# ── Check 15: Ban eval() and new Function() ──────────────────

if echo "$added_lines" | grep -qE '\beval\(|\bnew Function\('; then
  hook_block "eval()/new Function() banned — injection risk. Use JSON.parse() for data."
fi

# ── Check 16: Ban .innerHTML assignment (TSX/JSX only) ────────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE '\.innerHTML\s*='; then
      hook_block ".innerHTML banned — XSS. Use textContent or Sanitizer API (setHTML)."
    fi
    ;;
esac

# ── Check 17: Ban inline style={{}} in TSX/JSX (use Tailwind) ────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE 'style=\{\{'; then
      hook_warn "Inline style={{}} detected. Use Tailwind classes."
    fi
    ;;
esac

# ── Check 18: Ban class components ───────────────────────────────

if echo "$added_lines" | grep -qE 'extends\s+(React\.)?(Component|PureComponent)\b'; then
  hook_block "Functional components only. Class components incompatible with React Compiler."
fi

# ── Check 19: Ban barrel imports (re-exports from index files) ────

if echo "$added_lines" | grep -qE "from\s+['\"]\.\.?/[^'\"]*['\"]" && \
   echo "$added_lines" | grep -qE "from\s+['\"]\.\.?/[^'\"]*(/index)?['\"]"; then
  import_paths=$(echo "$added_lines" | grep -oE "from\s+['\"](\.\./[^'\"]+|\.\/[^'\"]+)['\"]" | grep -oE "['\"][^'\"]+['\"]" | tr -d "'" | tr -d '"' || true)
  if [ -n "$import_paths" ]; then
    dir=$(dirname "$file_path")
    for imp in $import_paths; do
      resolved="$dir/$imp"
      if [ -d "$resolved" ] || [ -f "$resolved/index.ts" ] || [ -f "$resolved/index.tsx" ] || [ -f "$resolved/index.js" ]; then
        hook_warn "Barrel import: \`$imp\`. Import from source file directly."
        break
      fi
    done
  fi
fi

# ── Check 20: Ban addEventListener without passive for scroll/touch/wheel ──

if echo "$added_lines" | grep -qE "addEventListener\s*\(\s*['\"](scroll|touchstart|touchmove|wheel)['\"]" && \
   ! echo "$added_lines" | grep -qE "passive\s*:\s*true"; then
  hook_block "Add { passive: true } to scroll/touch/wheel listener. Non-passive blocks main thread."
fi

# ── Check 21: Ban static imports of heavy deps ──────────────────

if echo "$added_lines" | grep -qE "^[+]?import\s.*from\s+['\"]" | grep -qE "(chart\.js|d3|three|pdf-lib|plotly\.js|recharts)['\"/]" 2>/dev/null || \
   echo "$added_lines" | grep -qE "from\s+['\"](chart\.js|d3|three|pdf-lib|plotly\.js|recharts)['\"/]"; then
  hook_warn "Heavy dep — use React.lazy() or dynamic import()."
fi

# ── Check 22: handleSubmit must have error callback ────────────────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE 'handleSubmit\([a-zA-Z_]+\)' && \
       ! echo "$added_lines" | grep -qE 'handleSubmit\([a-zA-Z_]+,'; then
      hook_warn "Add error callback: handleSubmit(onSubmit, onError). Errors swallowed without it."
    fi
    ;;
esac

# ── Check 23: Ban React.FC / React.FunctionComponent ──────────────

if echo "$added_lines" | grep -qE '\bReact\.FC\b|\bReact\.FunctionComponent\b|:\s*FC[<\s>]'; then
  hook_warn "Prefer function MyComponent(props: Props) over React.FC."
fi

# ── Check 24: Ban cloneElement ────────────────────────────────────

if echo "$added_lines" | grep -qE 'cloneElement\(|React\.cloneElement'; then
  hook_warn "Avoid cloneElement. Use Context or render props."
fi

# ── Check 25: (moved to ts-no-escape-hatches-check.sh — biome-ignore) ──

# ── Check 26: Warn on tree-shaking killers ────────────────────────

if echo "$added_lines" | grep -qE 'import \* as \w+ from' && \
   ! echo "$added_lines" | grep -qE 'import \* as React from'; then
  hook_warn "Namespace import (import *) prevents tree-shaking. Import specific exports."
fi

if echo "$added_lines" | grep -qE "export \* from ['\"]"; then
  hook_warn "export * prevents tree-shaking. Export specific items."
fi

# ── Check 27: Warn on deprecated package imports ─────────────────

if echo "$added_lines" | grep -qE "from\s+['\"]react-beautiful-dnd['\"/]"; then
  hook_warn "react-beautiful-dnd archived. Use @dnd-kit/core or react-aria drag."
fi

if echo "$added_lines" | grep -qE "from\s+['\"]framer-motion['\"/]"; then
  hook_warn "framer-motion renamed to 'motion'. Use: import { motion } from 'motion'."
fi

# ── Check 28: Suggest structuredClone over JSON roundtrip ────────

if echo "$added_lines" | grep -qF 'JSON.parse(JSON.stringify('; then
  hook_warn "Use structuredClone() not JSON.parse(JSON.stringify()). Handles Date/Map/Set."
fi

# ── Check 29: Suggest .requestSubmit() over .submit() ───────────

if echo "$added_lines" | grep -qE '\.submit\(\)' && \
   ! echo "$added_lines" | grep -qE '\.requestSubmit\(\)'; then
  hook_warn "Use .requestSubmit() not .submit(). submit() bypasses validation."
fi

# ── Check 30: Ban delete on arrays ───────────────────────────────

if echo "$added_lines" | grep -qE 'delete\s+\w+\['; then
  hook_warn "No delete on arrays (sparse holes). Use .filter() or Array.with()."
fi

# ── Check 31: parseInt without radix ─────────────────────────────

if echo "$added_lines" | grep -qE 'parseInt\([^,)]+\)' && \
   ! echo "$added_lines" | grep -qE 'parseInt\([^)]*,'; then
  hook_warn "parseInt() no radix. Use Number() or parseInt(str, 10)."
fi

# ── Check 32: div role="button" → use <Button> ────────────────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE '<div[^>]*role=["'"'"']button["'"'"']'; then
      hook_warn "Use <Button> not <div role=\"button\">. Native kbd/focus/a11y."
    fi
    ;;
esac

# ── Check 33: setTimeout with string argument ───────────────────

if echo "$added_lines" | grep -qE 'setTimeout\s*\(\s*['"'"'"`]'; then
  hook_block "No strings in setTimeout (uses eval). Pass function: setTimeout(() => { ... }, delay)."
fi

# ── Check 34: === NaN is always false ────────────────────────────

if echo "$added_lines" | grep -qE '===?\s*NaN\b'; then
  hook_block "=== NaN always false. Use Number.isNaN(value)."
fi

# ── Check 35: reset-state-on-prop-change — delegated to React Doctor
#     (state-and-effects/no-reset-all-state-on-prop-change, no-adjust-state-on-prop-change) ──

# ── Check 36: Ban node:assert in test files ───────────────────────

case "$file_path" in
  *.test.ts|*.test.tsx|*.spec.ts|*.spec.tsx|*.integration.ts|*.integration.tsx)
    if echo "$added_lines" | grep -qE "from\s+['\"]node:assert"; then
      hook_block "Use vitest assert not node:assert. import { assert } from 'vitest'."
    fi
    ;;
esac

# ── Check 37: (moved to test-convention-check.sh — user.type()) ──

fi

# ── absorbed from disabled-button-tooltip-check.sh (4.28 family consolidation) ──
# ── Check: disabled Button without wrapping Tooltip ──────────────
# A11y: disabled buttons should explain why via tooltip.
# Pattern: <Button disabled> without surrounding <Tooltip>.

case "$file_path" in
  *.tsx)
    _disabled_tooltip_test_file=false
    case "$file_path" in
      *.test.*|*.spec.*|*/__tests__/*) _disabled_tooltip_test_file=true ;;
    esac
    if [ "$_disabled_tooltip_test_file" = false ]; then
      if echo "$added_lines" | grep -qE '<Button[^>]*disabled'; then
        # Check if there's a Tooltip wrapper nearby in the file
        file_content=$(cat "$file_path")
        # Simple heuristic: if file has Tooltip import and disabled Button,
        # assume it's handled. If no Tooltip import, warn.
        if ! echo "$file_content" | grep -qE "Tooltip|TooltipTrigger|TooltipProvider"; then
          if ! hook_has_escape "disabled-tooltip"; then
            hook_warn "Disabled <Button> without Tooltip. Add tooltip explaining why button is disabled (a11y). Escape: // allow: disabled-tooltip [reason]" "disabled-button-tooltip"
          fi
        fi
      fi
    fi
    ;;
esac

return 0
}
