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

# Skip redpanda-ui directory
if echo "$file_path" | grep -qF '/redpanda-ui/'; then
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

# ── Check 1: Ban useEffect/useLayoutEffect/useInsertionEffect ──

if echo "$added_lines" | grep -qE '\b(useEffect|useLayoutEffect|useInsertionEffect)\b'; then
  # Check for escape hatch: // allow-useEffect: [reason]
  has_escape=false
  if [ -f "$file_path" ]; then
    if grep -qE '//\s*allow-useEffect:' "$file_path"; then
      has_escape=true
    fi
  fi

  if [ "$has_escape" = false ]; then
    echo '{"suppressOutput":true,"systemMessage":"useEffect (and useLayoutEffect/useInsertionEffect) is banned. Use alternatives:\n- React Query / TanStack Query for data fetching\n- zustand for global state management\n- Event handlers (onClick, onSubmit) for user interactions\n- useRef + event-based patterns\n- useTransition / useDeferredValue for concurrent features\n\nIf absolutely necessary, add: // allow-useEffect: [explain why]"}' >&2
    exit 2
  fi
fi

# ── Check 2: Ban raw HTML elements (TSX files only) ────────────

case "$file_path" in
  *.tsx|*.jsx)
    raw_element=""
    if echo "$added_lines" | grep -qE '<button[[:space:]>]'; then raw_element="<button> → <Button> from @/redpanda-ui/button"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<input[[:space:]/>]'; then raw_element="<input> → <Input> from @/redpanda-ui/input"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<select[[:space:]>]'; then raw_element="<select> → <Select> from @/redpanda-ui/select"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<textarea[[:space:]>]'; then raw_element="<textarea> → <Textarea> from @/redpanda-ui/textarea"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<dialog[[:space:]>]'; then raw_element="<dialog> → <Dialog> from @/redpanda-ui/dialog"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<table[[:space:]>]'; then raw_element="<table> → <Table> from @/redpanda-ui/table"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<label[[:space:]>]'; then raw_element="<label> → <Label> from @/redpanda-ui/label"; fi
    if [ -z "$raw_element" ] && echo "$added_lines" | grep -qE '<form[[:space:]>]'; then raw_element="<form> → <AutoForm> from @/redpanda-ui/auto-form (see https://redpanda-ui-registry.netlify.app/docs/auto-form)"; fi

    if [ -n "$raw_element" ]; then
      echo "{\"suppressOutput\":true,\"systemMessage\":\"Do not use raw HTML elements. Use redpanda-ui components instead:\\n$raw_element\\n\\nRegistry: https://redpanda-ui-registry.netlify.app/\"}" >&2
      exit 2
    fi
    ;;
esac

# ── Check 3: Ban Chakra UI / legacy imports ─────────────────────

if echo "$added_lines" | grep -qE "from\s+['\"]@chakra-ui/"; then
  echo '{"suppressOutput":true,"systemMessage":"@chakra-ui/react is banned. Use redpanda-ui components instead (Tailwind + shadcn based).\nRegistry: https://redpanda-ui-registry.netlify.app/"}' >&2
  exit 2
fi

if echo "$added_lines" | grep -qE "from\s+['\"]@redpanda-data/ui['\"/]"; then
  echo '{"suppressOutput":true,"systemMessage":"@redpanda-data/ui is legacy (Chakra-based). Use the new redpanda-ui registry components instead (Tailwind + shadcn).\nRegistry: https://redpanda-ui-registry.netlify.app/"}' >&2
  exit 2
fi

# ── Check 4: Ban TypeScript escape hatches ──────────────────────

if echo "$added_lines" | grep -qE '\bas\s+any\b'; then
  echo '{"suppressOutput":true,"systemMessage":"\"as any\" is banned. Fix the type properly instead of casting to any. This applies everywhere, including tests."}' >&2
  exit 2
fi

if echo "$added_lines" | grep -qF '@ts-ignore'; then
  echo '{"suppressOutput":true,"systemMessage":"@ts-ignore is banned. Fix the type error instead of suppressing it."}' >&2
  exit 2
fi

if echo "$added_lines" | grep -qF '@ts-expect-error'; then
  echo '{"suppressOutput":true,"systemMessage":"@ts-expect-error is banned. Fix the type error instead of suppressing it. We want fully type-safe code with no escape hatches."}' >&2
  exit 2
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

if echo "$added_lines" | grep -qE '\.\.\.[a-zA-Z]+' && \
   echo "$added_lines" | grep -qE 'Schema|Message|Request|Response' && \
   ! echo "$added_lines" | grep -qE 'create\('; then
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

exit 0
