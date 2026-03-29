# React Rules Reference

## react-rules-check.sh

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

# Skip component library directories
# Auto-detect: check common conventions, override with UI_LIB_DIRS env var (pipe-separated)
if [ -z "${UI_LIB_DIRS:-}" ]; then
  _ui_dirs="components/ui"
  _root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  [ -d "$_root/redpanda-ui" ] && _ui_dirs="$_ui_dirs|redpanda-ui"
  [ -d "$_root/src/ui" ] && _ui_dirs="$_ui_dirs|src/ui"
  [ -d "$_root/packages/ui" ] && _ui_dirs="$_ui_dirs|packages/ui"
else
  _ui_dirs="$UI_LIB_DIRS"
fi
if echo "$file_path" | grep -qE "/($_ui_dirs)/"; then
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
      echo '{"suppressOutput":true,"systemMessage":"useEffect (and useLayoutEffect/useInsertionEffect) is banned. Use alternatives:\n- React Query / TanStack Query for data fetching\n- zustand for global state management\n- Event handlers (onClick, onSubmit) for user interactions\n- useRef + event-based patterns\n- useTransition / useDeferredValue for concurrent features\n\nIf absolutely necessary, add: // allow-useEffect: [explain why]"}' >&2
      exit 2
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

# ── Check 18: Ban raw hex/rgb colors in className (use design tokens) ──

case "$file_path" in
  *.tsx|*.jsx)
    if echo "$added_lines" | grep -qE 'className=.*\[#[0-9a-fA-F]' || \
       echo "$added_lines" | grep -qE 'className=.*\[rgb'; then
      echo '{"suppressOutput":true,"systemMessage":"Do not use raw hex/rgb colors in className. Use Tailwind design tokens or CSS variables instead.\n\n// BAD\n<div className=\"text-[#ff0000] bg-[rgb(0,0,0)]\">\n\n// GOOD\n<div className=\"text-destructive bg-background\">"}' >&2
      exit 2
    fi
    ;;
esac

# ── Check 19: Ban !important in styles ───────────────────────────

if echo "$added_lines" | grep -qE '!important'; then
  echo '{"suppressOutput":true,"systemMessage":"!important is banned — it breaks the Tailwind cascade and makes styles unmaintainable. Fix specificity issues instead."}' >&2
  exit 2
fi

exit 0
```

## Escape Hatch for useEffect

When useEffect is genuinely needed (e.g., WebSocket cleanup, third-party library integration), add a comment on the line before:

```tsx
// allow-useEffect: WebSocket subscription cleanup required
useEffect(() => {
  const ws = new WebSocket(url)
  return () => ws.close()
}, [url])
```

The hook checks for `// allow-useEffect:` anywhere in the file. A reason is required for code review.

## Raw HTML → Component Library Mapping

| Banned | Replacement | Import (shadcn/ui convention) |
|--------|-------------|-------------------------------|
| `<button>` | `<Button>` | `@/components/ui/button` |
| `<input>` | `<Input>` | `@/components/ui/input` |
| `<select>` | `<Select>` | `@/components/ui/select` |
| `<textarea>` | `<Textarea>` | `@/components/ui/textarea` |
| `<dialog>` | `<Dialog>` | `@/components/ui/dialog` |
| `<table>` | `<Table>` | `@/components/ui/table` |
| `<label>` | `<Label>` | `@/components/ui/label` |
| `<form>` | `<AutoForm>` | `@/components/ui/auto-form` |

Note: `<a>` is allowed (TanStack Router Link can't always be used).
