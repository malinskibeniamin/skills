# TanStack Router Reference

## tanstack-router-gen.sh

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

# Check if the file is in a routes directory
# Customize this pattern to match your project's routes location
if ! echo "$file_path" | grep -qE '/routes/'; then
  exit 0
fi

# Only trigger for TS/TSX files
case "$file_path" in
  *.ts|*.tsx) ;;
  *) exit 0 ;;
esac

# Regenerate route tree silently
bun run generate:routes > /dev/null 2>&1 || true

echo '{"suppressOutput":true}'
exit 0
```

## tanstack-router-check.sh

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

# ── Check 1: Ban react-router-dom imports ─────────────────────────────

if echo "$added_lines" | grep -qE "from\s+['\"]react-router-dom['\"/]"; then
  echo '{"suppressOutput":true,"systemMessage":"react-router-dom is banned. This project uses TanStack Router.\n\nMigrate to TanStack Router equivalents:\n- useNavigate → useNavigate from @tanstack/react-router\n- useParams → useParams from @tanstack/react-router (with { from } param)\n- useSearchParams → useSearch from @tanstack/react-router (with validateSearch)\n- <Link> → <Link> from @tanstack/react-router\n- <Routes>/<Route> → file-based routing"}' >&2
  exit 2
fi

# ── Check 2: Ban window.location for navigation ──────────────────────

if echo "$added_lines" | grep -qE 'window\.location\.(href|assign|replace)\s*[=(]'; then
  echo '{"suppressOutput":true,"systemMessage":"Do not use window.location for navigation — it causes a full page reload and breaks SPA routing.\n\nUse TanStack Router instead:\n- navigate({ to: '\''/path'\'' }) for programmatic navigation\n- <Link to=\"/path\"> for declarative navigation\n- router.navigate() from useRouter()"}' >&2
  exit 2
fi

# ── Check 3: Ban URLSearchParams globally ─────────────────────────────
# (before window.location warns, since URLSearchParams often appears alongside window.location.search)

if echo "$added_lines" | grep -qE '\bnew URLSearchParams\b|searchParams\.(get|set|append)\b'; then
  echo '{"suppressOutput":true,"systemMessage":"URLSearchParams is banned. Use TanStack Router search params with nuqs for URL query state:\n\n// BAD\nconst params = new URLSearchParams(window.location.search)\nconst page = params.get('\''page'\'')\n\n// GOOD — in route definition\nvalidateSearch: z.object({ page: z.number().default(1) })\n\n// GOOD — in component with nuqs\nimport { useQueryState, parseAsInteger } from '\''nuqs'\''\nconst [page, setPage] = useQueryState('\''page'\'', parseAsInteger.withDefault(1))"}' >&2
  exit 2
fi

# ── Check 4: Warn on window.location.reload() ────────────────────────

if echo "$added_lines" | grep -qE '(window\.)?location\.reload\(\)'; then
  echo '{"suppressOutput":true,"systemMessage":"Avoid hard page reloads — causes blank screen flash and loses client state.\n\nPrefer:\n- router.invalidate() to refetch route data\n- queryClient.invalidateQueries() to refresh server state\n- router.navigate({ to: router.state.location.href }) for a soft refresh"}' >&2
  # Warn only — do not block
  exit 0
fi

# ── Check 5: Warn on window.location reads ────────────────────────────

if echo "$added_lines" | grep -qE 'window\.location\.(search|pathname|hash)\b'; then
  echo '{"suppressOutput":true,"systemMessage":"Avoid reading window.location directly. Use TanStack Router hooks for type-safe access:\n- window.location.pathname → useParams({ from: '\''/route/$param'\'' })\n- window.location.search → useSearch({ from: '\''/route'\'' }) with validateSearch\n- window.location.hash → useSearch() with hash in search params\n\nFor URL query state management, use nuqs."}' >&2
  # Warn only — do not block
  exit 0
fi

# ── Check 6: Ban strict: false in router hook calls ───────────────────

if echo "$added_lines" | grep -qE 'strict:\s*false'; then
  # Verify it's in a router hook context by checking file imports
  file_content=$(cat "$file_path")
  if echo "$file_content" | grep -qE "from\s+['\"]@tanstack/react-router"; then
    echo '{"suppressOutput":true,"systemMessage":"strict: false is banned in TanStack Router hooks — it disables type safety.\n\nAlways use the typed form with { from }:\n\n// BAD — untyped\nconst params = useParams({ strict: false })\n\n// GOOD — fully typed\nconst { id } = useParams({ from: '\''/users/$id'\'' })"}' >&2
    exit 2
  fi
fi

# ── Check 7: Ban empty-args useParams/useSearch/useLoaderData/useRouteContext ─

if echo "$added_lines" | grep -qE '\b(useParams|useSearch|useLoaderData|useRouteContext)\(\s*\)'; then
  # Allow Route.useParams() — component-scoped is already typed
  if ! echo "$added_lines" | grep -qE 'Route\.(useParams|useSearch|useLoaderData|useRouteContext)\(\s*\)'; then
    file_content=$(cat "$file_path")
    if echo "$file_content" | grep -qE "from\s+['\"]@tanstack/react-router"; then
      match=$(echo "$added_lines" | grep -oE '\b(useParams|useSearch|useLoaderData|useRouteContext)\(\s*\)' | head -1)
      echo "{\"suppressOutput\":true,\"systemMessage\":\"$match without arguments loses type safety. Always provide { from } for type narrowing:\\n\\n// BAD — untyped\\nconst params = useParams()\\n\\n// GOOD — typed to specific route\\nconst { id } = useParams({ from: '/users/\$id' })\\n\\nOr use the Route-scoped version: Route.useParams()\"}" >&2
      exit 2
    fi
  fi
fi

# ── Check 8: Missing validateSearch when useSearch is used ────────────

if echo "$added_lines" | grep -qE '\buseSearch\b'; then
  # Check if this is a route file
  if echo "$file_path" | grep -qE '/routes/'; then
    file_content=$(cat "$file_path")
    if ! echo "$file_content" | grep -qF 'validateSearch'; then
      echo '{"suppressOutput":true,"systemMessage":"useSearch requires validateSearch in the route definition for type-safe search params.\n\nAdd a zod schema to your route:\n\nimport { z } from '\''zod'\''\n\nexport const Route = createFileRoute('\''/your-route/'\'')({\n  validateSearch: z.object({\n    page: z.number().default(1),\n    filter: z.string().optional(),\n  }),\n  component: YourComponent,\n})"}' >&2
      exit 2
    fi
  fi
fi

exit 0
```

## Customization

The routes directory pattern defaults to `/routes/`. If your project uses a different convention, update the grep pattern in both hook scripts:

```bash
# Examples:
if ! echo "$file_path" | grep -qE '/routes/'; then    # default
if ! echo "$file_path" | grep -qE '/pages/'; then     # pages-based
if ! echo "$file_path" | grep -qE '/app/routes/'; then # nested
```

## Type-Safe Search Params with nuqs

For complex URL query state, use [nuqs](https://nuqs.47ng.com/) with TanStack Router:

```tsx
import { useQueryState, parseAsInteger, parseAsString } from 'nuqs'

function UsersPage() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1))
  const [filter, setFilter] = useQueryState('filter', parseAsString)

  return (
    <div>
      <input value={filter ?? ''} onChange={(e) => setFilter(e.target.value)} />
      <button onClick={() => setPage(page + 1)}>Next</button>
    </div>
  )
}
```
