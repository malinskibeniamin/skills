#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_skip_ui_dirs
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
      hook_block "useEffect (and useLayoutEffect/useInsertionEffect) is banned. Use alternatives:\n- React Query / TanStack Query for data fetching\n- zustand for global state management\n- Event handlers (onClick, onSubmit) for user interactions\n- useRef + event-based patterns\n- useTransition / useDeferredValue for concurrent features\n\nIf absolutely necessary, add: // allow-useEffect: [explain why]"
    fi
  fi
fi

# ── Check 2: Ban raw HTML elements (TSX files only) ────────────

case "$file_path" in
  *.tsx|*.jsx)
    raw_element=""
    if echo "$added_lines" | grep -qE '<button[[:space:]>]'; then raw_element="<button> → <Button> from @/components/ui/button"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<input[[:space:]/>]'; then raw_element="<input> → <Input> from @/components/ui/input"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<select[[:space:]>]'; then raw_element="<select> → <Select> from @/components/ui/select"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<textarea[[:space:]>]'; then raw_element="<textarea> → <Textarea> from @/components/ui/textarea"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<dialog[[:space:]>]'; then raw_element="<dialog> → <Dialog> from @/components/ui/dialog"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<table[[:space:]>]'; then raw_element="<table> → <Table> from @/components/ui/table"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<label[[:space:]>]'; then raw_element="<label> → <Label> from @/components/ui/label"; fi

    if [ -n "$raw_element" ]; then
      echo "{\"suppressOutput\":true,\"systemMessage\":\"Do not use raw HTML elements. Use your component library instead:\\n$raw_element\"}" >&2
      exit 2
    fi
    ;;
esac

# ── Check 3: Ban TypeScript escape hatches ──────────────────────

if echo "$added_lines" | grep -qE '\bas\s+any\b'; then
  hook_block "\\\"as any\\\" is banned. Fix the type properly instead of casting to any. This applies everywhere, including tests."
fi

if echo "$added_lines" | grep -qF '@ts-ignore'; then
  hook_block "@ts-ignore is banned. Fix the type error instead of suppressing it."
fi

if echo "$added_lines" | grep -qF '@ts-expect-error'; then
  hook_block "@ts-expect-error is banned. Fix the type error instead of suppressing it. We want fully type-safe code with no escape hatches."
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
      hook_block "Type assertions (\`as X\`) are banned. Use type guards, generics, or schema validation instead:\n\n// BAD\nconst user = response as User\nconst id = value as string\n\n// GOOD — type guard\nif (isUser(response)) { ... }\n\n// GOOD — schema validation\nconst user = userSchema.parse(response)\n\n// GOOD — generic\nfunction getItem<T>(key: string): T { ... }\n\nAllowed: \`as const\`, \`as const satisfies\`\nEscape hatch: // allow-type-assertion: [reason]"
    fi
  fi
fi

# ── Check 5: Ban visual style overrides on registry components ────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE '<(Button|Input|Select|Alert|Dialog|Card|Badge|Table|Label|Textarea)[[:space:]]' && \
       echo "$added_lines" | grep -qE 'className=.*\b(bg-|text-|border-|shadow-|rounded-)'; then
      echo '{"suppressOutput":true,"systemMessage":"Do not override visual styles (bg-*, text-*, border-*, shadow-*) on registry components. Use the component variant prop instead. Layout classes (mt-4, flex-1, w-full, gap-2) are fine."}' >&2
      exit 2
    fi
    ;;
esac

# ── Check 6: Navigation — prefer Link over onClick+navigate ─────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE 'onClick.*navigate\('; then
      echo '{"suppressOutput":true,"systemMessage":"Do not use onClick + navigate() for navigation. Use <Button asChild><Link to=\"/path\">...</Link></Button> instead.\nWhy: Better accessibility (right-click, screen readers), respects TanStack Router basePath."}' >&2
      exit 2
    fi
    ;;
esac

# ── Check 7: Button must have handler or purpose ────────────────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE '<Button[[:space:]>]' && \
       ! echo "$added_lines" | grep -qE '<Button[^>]*(onClick|asChild|type="submit"|disabled)'; then
      echo '{"suppressOutput":true,"systemMessage":"Button appears to have no handler. Buttons must have onClick, asChild (for Link wrapping), type=\"submit\" (in forms), or disabled. A button with no handler is likely a bug."}' >&2
      exit 2
    fi
    ;;
esac

# ── Check 8: Alert — no icon inside AlertTitle ──────────────────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE '<AlertTitle>.*<.*Icon' || \
       echo "$added_lines" | grep -qE '<AlertTitle>.*<svg'; then
      echo '{"suppressOutput":true,"systemMessage":"Do not add icons inside <AlertTitle>. The <Alert> component already renders an icon. Use the icon prop on <Alert> to customize it:\n<Alert icon={<CustomIcon />}>"}' >&2
      exit 2
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
      echo '{"suppressOutput":true,"systemMessage":"When spreading protobuf messages, wrap with create() to preserve $typeName:\n\n// Wrong\nconst msg = { ...existingMessage, field: newValue }\n\n// Correct\nconst msg = create(MyMessageSchema, { ...existingMessage, field: newValue })\n\nRequired for @bufbuild/protobuf v2."}' >&2
      exit 2
    fi
  fi
fi

# ── Check 11: Icon-only buttons need aria-label ──────────────────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE '<Button[^>]*>[[:space:]]*<[A-Z][a-zA-Z]*Icon' && \
       ! echo "$added_lines" | grep -qE '<Button[^>]*aria-label'; then
      echo '{"suppressOutput":true,"systemMessage":"Icon-only buttons must have aria-label for screen readers:\n\n<Button aria-label=\"Settings\" variant=\"ghost\" size=\"icon\"><SettingsIcon /></Button>"}' >&2
      exit 2
    fi
    ;;
esac

# ── Check 12: No outline removal (breaks keyboard navigation) ────

if echo "$added_lines" | grep -qE 'outline[[:space:]]*:[[:space:]]*(none|0)' || \
   echo "$added_lines" | grep -qE 'outline-none'; then
  echo '{"suppressOutput":true,"systemMessage":"Do not remove focus outlines (outline: none / outline-none). This breaks keyboard navigation accessibility. Use focus-visible styles instead:\n\nfocus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring"}' >&2
  exit 2
fi

# ── Check 13: React Compiler — no manual memoization ────────────

case "$file_path" in
  *.tsx|*.jsx)
    has_no_memo=false
    if head -5 "$file_path" | grep -qF "'use no memo'" || head -5 "$file_path" | grep -qF '"use no memo"'; then
      has_no_memo=true
    fi

    if [ "$has_no_memo" = false ]; then
      found_memo=""
      if echo "$added_lines" | grep -qE '\buseMemo\b'; then found_memo="useMemo"; fi
      if [ -z "$found_memo" ] && echo "$added_lines" | grep -qE '\buseCallback\b'; then found_memo="useCallback"; fi
      if [ -z "$found_memo" ] && echo "$added_lines" | grep -qE '\bReact\.memo\b|\bmemo\('; then found_memo="React.memo"; fi

      if [ -n "$found_memo" ]; then
        echo "{\"suppressOutput\":true,\"systemMessage\":\"React Compiler is enabled — manual $found_memo is unnecessary. The compiler auto-memoizes. Remove $found_memo or add 'use no memo' directive at the file top if needed.\"}" >&2
        exit 2
      fi
    fi
    ;;
esac

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
        echo '{"suppressOutput":true,"systemMessage":"dangerouslySetInnerHTML is banned — XSS risk. Sanitize with DOMPurify or use a safe rendering approach.\n\n// BAD\n<div dangerouslySetInnerHTML={{ __html: userContent }} />\n\n// GOOD — sanitize first\nimport DOMPurify from '\''dompurify'\''\n<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userContent) }} />\n\nIf absolutely necessary, add: // allow-dangerouslySetInnerHTML: [explain why]\n\nWCAG/OWASP: Unsanitized HTML injection is a top-10 vulnerability."}' >&2
        exit 2
      fi
    fi
    ;;
esac

# ── Check 15: Ban eval() and new Function() ──────────────────

if echo "$added_lines" | grep -qE '\beval\(|\bnew Function\('; then
  echo '{"suppressOutput":true,"systemMessage":"eval() and new Function() are banned — code injection risk. Use JSON.parse() for data, or a safe alternative.\n\nOWASP A03: Injection"}' >&2
  exit 2
fi

# ── Check 16: Ban .innerHTML assignment (TSX/JSX only) ────────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE '\.innerHTML\s*='; then
      echo '{"suppressOutput":true,"systemMessage":"Direct .innerHTML assignment is banned — XSS risk. Use React'\''s rendering or DOMPurify.\n\n// BAD\nelement.innerHTML = userContent\n\n// GOOD\nelement.textContent = userContent"}' >&2
      exit 2
    fi
    ;;
esac

# ── Check 17: Ban inline style={{}} in TSX/JSX (use Tailwind) ────

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE 'style=\{\{'; then
      echo '{"suppressOutput":true,"systemMessage":"Inline style={{}} is banned. Use Tailwind CSS utility classes instead.\n\n// BAD\n<div style={{ marginTop: 16, color: \"red\" }}>\n\n// GOOD\n<div className=\"mt-4 text-red-500\">"}' >&2
      exit 2
    fi
    ;;
esac

# ── Checks 18-19 (raw hex/rgb, !important) moved to tailwind-check.sh ──
# tailwind-check.sh covers CSS/SCSS/SASS/LESS + TSX/JSX files

exit 0
