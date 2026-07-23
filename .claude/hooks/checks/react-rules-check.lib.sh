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
# Registry-edit warning is owned by vendor-file-check.lib.sh (single owner);
# here the match only flags library code so component-level checks skip it.
if echo "$file_path" | grep -qE "/($_react_rules_ui_dirs)/"; then
  _react_rules_skip_ui_dirs=true
fi

hook_skip_generated || return 0
hook_filter_extensions "ts|tsx|mdx" || return 0
hook_get_added_lines || return 0

# Comment-only lines can't violate JSX rules, and multiline tags only parse
# in a joined view — hard blocks below use these instead of raw added_lines
# (line-anchored greps false-blocked comments and missed multiline <Button>).
_react_code_added=$(printf '%s\n' "$added_lines" | grep -vE '^[[:space:]]*(//|/?\*|\{/\*)' || true)
_react_joined_added=$(printf '%s\n' "$_react_code_added" | tr '\n' ' ')

if [ "$_react_rules_skip_ui_dirs" = false ]; then

# ── Check 1: useEffect misuse — delegated to React Doctor ────────
# React Doctor's state-and-effects family (no-fetch-in-effect, no-derived-state-effect,
# no-effect-chain, no-mirror-prop-effect, no-event-handler, ...) owns effect-misuse
# detection with AST precision. The old blanket opt-in ban is retired.

# ── Check 2: raw HTML elements — delegated to Biome ─────────────
# Biome a11y/correctness noRestrictedElements (ultracite preset + starter-kit
# config) owns the raw <button>/<input>/<select>/<h*>/<p>/... bans. Do not
# re-add them here; one owner per rule.

# ── Check 2a: sizes="auto" requires lazy loading ────────────────

case "$file_path" in
  *.tsx|*.jsx|*.mdx)
    if printf '%s\n' "$_react_code_added" | grep -qE "sizes[[:space:]]*=[[:space:]]*['\"]auto['\"]"; then
      _react_invalid_auto_sized_imgs() {
        if command -v perl >/dev/null 2>&1; then perl -0pe 's{/\*.*?\*/}{}gs'; else cat; fi |
          grep -vE '^[[:space:]]*//' | tr '\n' ' ' | grep -oE '<img[[:space:]][^>]*>' | grep -E "sizes[[:space:]]*=[[:space:]]*['\"]auto['\"]" | grep -vE "loading[[:space:]]*=[[:space:]]*['\"]lazy['\"]" || true
      }
      _current_invalid_imgs=$(printf '%s' "$file_content" | _react_invalid_auto_sized_imgs)
      _head_invalid_imgs=""
      _repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
      case "$file_path" in
        "$_repo_root"/*)
          _head_content=$(git show "HEAD:${file_path#"$_repo_root"/}" 2>/dev/null || true)
          _head_invalid_imgs=$(printf '%s' "$_head_content" | _react_invalid_auto_sized_imgs)
          ;;
      esac
      _current_count=$(printf '%s\n' "$_current_invalid_imgs" | grep -c . || true)
      _head_count=$(printf '%s\n' "$_head_invalid_imgs" | grep -c . || true)
      if [ "${_current_count:-0}" -gt "${_head_count:-0}" ]; then
        hook_block_strict "Literal sizes=\"auto\" on <img> requires loading=\"lazy\"." "react-rules-auto-sizes-lazy"
      fi
    fi
    ;;
esac

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

# ── Check 2c: Compose dynamic className values with cn/clsx ──────

case "$file_path" in
  *.tsx|*.jsx|*.mdx)
    if printf '%s' "$_react_joined_added" | grep -qE 'className[[:space:]]*=[[:space:]]*[{][[:space:]]*`[^`]*[$][{]'; then
      _react_classname_code=$(printf '%s\n' "$added_lines" | perl -0pe 's{/\*.*?\*/}{}gs' | grep -vE '^[[:space:]]*[+]?[[:space:]]*//' | tr '\n' ' ' || true)
      if printf '%s' "$_react_classname_code" | grep -qE 'className[[:space:]]*=[[:space:]]*[{][[:space:]]*`[^`]*[$][{]'; then
        hook_block_strict 'Do not interpolate className template literals. Compose classes with cn(...) or clsx(...).'
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
      # Honor tailwind-check's gradient escape too — one escape hatch must
      # quiet every hook that fires on the same line.
      if ! hook_has_escape "button-visual-override" && ! hook_has_escape "design-token" && ! hook_has_escape "gradient"; then
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
      # Hardcoded palette/gradient utilities are owned by tailwind-check.lib.sh
      # (it bans them on ANY element); this check keeps only the component
      # semantics: registry components take variant props, not className chrome.
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
    # Joined view catches multiline handlers; [^}]* keeps the match inside
    # one handler expression so an unrelated navigate() elsewhere in the
    # hunk can't pair with an innocent onClick.
    if printf '%s' "$_react_joined_added" | grep -qE 'onClick(=\{|:)[^}]*navigate\('; then
      hook_block "Use <Link> not onClick+navigate(). Breaks a11y+basePath. Use <Button asChild><Link to=\\\"/path\\\">...</Link></Button>."
    fi
    ;;
esac

# ── Check 7: Button must have handler or purpose ────────────────
# Judge complete opening tags only — a hunk that adds `<Button` while the
# props live on unchanged lines outside the diff cannot be judged.

case "$file_path" in
  *.tsx|*.jsx)
    _button_tags=$(printf '%s\n' "$_react_joined_added" | grep -oE '<Button[^>]*>' || true)
    if [ -n "$_button_tags" ] && \
       printf '%s\n' "$_button_tags" | grep -qvE '(onClick|asChild|type="submit"|disabled)'; then
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
    _icon_buttons=$(printf '%s\n' "$_react_joined_added" | grep -oE '<Button[^>]*>[[:space:]]*<[A-Z][a-zA-Z]*Icon' || true)
    if [ -n "$_icon_buttons" ] && \
       printf '%s\n' "$_icon_buttons" | grep -qv 'aria-label'; then
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

# ── Check 18b: Ban dead-stack imports (see /stack-registry) ───────
# Unbanned dead stacks get resurrected by LLM authors. Chakra and
# react-router-dom are banned elsewhere; this owns the rest.

if echo "$added_lines" | grep -qE "from\s+['\"](mobx|mobx-react|mobx-react-lite)['\"/]"; then
  hook_block "MobX is a banned dead stack. Client state: zustand (create<T>()(), useShallow); server state: connect-query."
fi
if echo "$added_lines" | grep -qE "from\s+['\"](react-intl)['\"/]|<FormattedMessage\b"; then
  hook_block "react-intl/FormattedMessage is a banned dead stack. Use plain strings (docs-editor reviewed); no i18n dictionary machinery."
fi
if echo "$added_lines" | grep -qE "from\s+['\"](formik)['\"/]"; then
  hook_block "Formik is a banned dead stack. Use react-hook-form with proto-driven or zod resolvers; select mode for validation before submit and reValidateMode for corrections after submit."
fi
if echo "$added_lines" | grep -qE "from\s+['\"](yup)['\"/]"; then
  hook_block "Yup is a banned dead stack. Validation: protovalidate for proto-backed forms, zod for route search schemas. Keep the lesson: validate format, not presence."
fi
if echo "$added_lines" | grep -qE "from\s+['\"]nuqs['\"/]"; then
  hook_block "nuqs is banned — the router owns search-param typing. Use TanStack validateSearch + Route.useSearch()."
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

# ── Check: submit-button contract — never native disabled on validity ──
# Validity-disabled submits hide WHY the form won't submit and are invisible
# to screen readers. Keep submit clickable and surface errors via a form
# error summary, or soft-disable with aria-disabled + tooltip. Native
# disabled is only legitimate for in-flight state (isPending/isSubmitting).

case "$file_path" in
  *.tsx)
    _submit_test_file=false
    case "$file_path" in
      *.test.*|*.spec.*|*/__tests__/*) _submit_test_file=true ;;
    esac
    if [ "$_submit_test_file" = false ]; then
      if echo "$added_lines" | grep -qE 'type="submit"[^>]*\bdisabled=\{|disabled=\{[^}]*\}[^>]*type="submit"'; then
        _submit_disabled_expr=$(echo "$added_lines" | grep -oE 'disabled=\{[^}]*\}' | head -1)
        if ! echo "$_submit_disabled_expr" | grep -qE 'isPending|isSubmitting|isLoading|isMutating'; then
          if ! hook_has_escape "submit-disabled"; then
            hook_block "Never native-disable submit on validity (disabled={!isValid} hides why). Keep it clickable + render a form error summary, or use aria-disabled + Tooltip. Native disabled is for in-flight state only (isPending/isSubmitting). Escape: // allow: submit-disabled [reason]"
          fi
        fi
      fi

      # Non-submit disabled Button: prefer a reason the user can perceive.
      if echo "$added_lines" | grep -qE '<Button[^>]*\bdisabled\b' && \
         ! echo "$added_lines" | grep -qE 'type="submit"'; then
        file_content=$(cat "$file_path")
        if ! echo "$file_content" | grep -qE "Tooltip|TooltipTrigger|TooltipProvider|disabledReason|aria-disabled"; then
          if ! hook_has_escape "disabled-tooltip"; then
            hook_warn "Disabled <Button> without a perceivable reason. Prefer a disabledReason prop / wrapping Tooltip / aria-disabled explaining why (a11y). Escape: // allow: disabled-tooltip [reason]" "disabled-button-tooltip"
          fi
        fi
      fi
    fi
    ;;
esac

# ── Check: no component/type definitions inside a component body ──
# Components defined in render remount every parent render (state loss,
# focus loss); types declared in render are noise. Hoist to module scope.

case "$file_path" in
  *.tsx)
    if [ "${_submit_test_file:-false}" = false ]; then
      _render_defs=$(echo "$added_lines" | grep -E '^\s{2,}(const\s+[A-Z][A-Za-z0-9]*\s*=\s*(\([^)]*\)|[A-Za-z0-9_,{}\s]*)\s*=>\s*(\(|<)|(type|interface)\s+[A-Z][A-Za-z0-9]*\s*[={])' || true)
      if [ -n "$_render_defs" ]; then
        if ! hook_has_escape "def-in-render"; then
          hook_warn "Component/type defined inside a component body — remounts on every render (state/focus loss). Hoist to module scope or its own file. Escape: // allow: def-in-render [reason]" "def-in-render"
        fi
      fi
    fi
    ;;
esac

# ── Check: numeric display truthiness — 0 renders as the empty fallback ──
# `value ? value : '-'` (or && chains) hides legitimate zeros ("quota set
# to 0 renders as No limit"). Numeric display fallbacks must use == null.

if echo "$added_lines" | grep -qE "\{[a-zA-Z0-9_.?]*\b(count|total|size|bytes|rate|limit|quota|balance|amount|lag|usage|price|cost)[a-zA-Z0-9_.?]*\s*\?\s*[^:]+:\s*['\"\`<]" ; then
  if ! echo "$added_lines" | grep -qE '==\s*null|!=\s*null|isFinite|Number\.isNaN'; then
    if ! hook_has_escape "numeric-truthiness"; then
      hook_warn "Numeric display uses truthiness — 0 will render the fallback (a real 0 becomes 'not configured'). Use value == null ? fallback : value. Escape: // allow: numeric-truthiness [reason]" "numeric-truthiness"
    fi
  fi
fi

# ── Check: no new barrel files under components/ ──────────────────
# index.ts re-export barrels defeat code splitting and tree shaking;
# the convention is direct imports from source files.

case "$file_path" in
  */components/*/index.ts|*/components/*/index.tsx|*/components/index.ts|*/components/index.tsx)
    if echo "$added_lines" | grep -qE '^\s*export\s+(\*|\{)' && \
       ! echo "$added_lines" | grep -qE 'export\s+(default|const|function|type|interface|class)\b'; then
      if ! hook_has_escape "barrel-file"; then
        hook_block "New barrel file under components/ — re-export barrels defeat code splitting and make imports ambiguous. Import from source files directly. Escape: // allow: barrel-file [reason]"
      fi
    fi
    ;;
esac

return 0
}
