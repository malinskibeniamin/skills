#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "ts|tsx|js|jsx"
hook_get_added_lines

# ── Check 1: Ban react-router-dom imports ─────────────────────────────

if echo "$added_lines" | grep -qE "from\s+['\"]react-router-dom['\"/]"; then
  hook_block "react-router-dom is banned. Use TanStack Router equivalents.\nMigrate: useNavigate, useParams ({ from }), useSearch (validateSearch), <Link>."
fi

# ── Check 2: Ban window.location for navigation ──────────────────────

if echo "$added_lines" | grep -qE 'window\.location\.(href|assign|replace)\s*[=(]'; then
  hook_block "Do not use window.location for navigation (causes full page reload).\nUse navigate({ to: '/path' }) or <Link> from @tanstack/react-router."
fi

# ── Check 3: Ban URLSearchParams globally ─────────────────────────────

if echo "$added_lines" | grep -qE '\bnew URLSearchParams\b|searchParams\.(get|set|append)\b'; then
  hook_block "URLSearchParams is banned. Use TanStack Router search params.\nDefine validateSearch with zod on the route, or use nuqs for URL query state.\n\n// GOOD -- route definition\nvalidateSearch: z.object({ page: z.number().default(1) })\n\n// GOOD -- component with nuqs\nconst [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1))"
fi

# ── Check 4: Warn on window.location.reload() ────────────────────────

if echo "$added_lines" | grep -qE '(window\.)?location\.reload\(\)'; then
  hook_warn "Avoid hard page reloads (blank flash, loses client state).\nUse router.invalidate() or queryClient.invalidateQueries() instead."
fi

# ── Check 5: Warn on window.location reads ────────────────────────────

if echo "$added_lines" | grep -qE 'window\.location\.(search|pathname|hash)\b'; then
  hook_warn "Do not read window.location directly.\nUse useParams({ from }) or useSearch({ from }) for type-safe access. Use nuqs for URL query state."
fi

# ── Check 6: Ban strict: false in router hook calls ───────────────────

if echo "$added_lines" | grep -qE 'strict:\s*false'; then
  file_content=$(cat "$file_path")
  if echo "$file_content" | grep -qE "from\s+['\"]@tanstack/react-router"; then
    hook_block "strict: false disables type safety in TanStack Router hooks.\nAlways use { from: '/route/\$param' } for typed params.\n\n// BAD\nconst params = useParams({ strict: false })\n\n// GOOD\nconst { id } = useParams({ from: '/users/\$id' })"
  fi
fi

# ── Check 7: Ban empty-args useParams/useSearch/useLoaderData/useRouteContext ─

if echo "$added_lines" | grep -qE '\b(useParams|useSearch|useLoaderData|useRouteContext)\(\s*\)'; then
  # Allow Route.useParams() — component-scoped is already typed
  if ! echo "$added_lines" | grep -qE 'Route\.(useParams|useSearch|useLoaderData|useRouteContext)\(\s*\)'; then
    file_content=$(cat "$file_path")
    if echo "$file_content" | grep -qE "from\s+['\"]@tanstack/react-router"; then
      match=$(echo "$added_lines" | grep -oE '\b(useParams|useSearch|useLoaderData|useRouteContext)\(\s*\)' | head -1)
      hook_block "$match without { from } loses type safety.\nPass { from: '/route/\$param' } or use Route.$match instead."
    fi
  fi
fi

# ── Check 8: Warn on exported components from route files (breaks code splitting) ──

if echo "$file_path" | grep -qE '/routes/'; then
  non_route_exports=$(echo "$added_lines" | grep -E 'export\s+(function|const)\s+[A-Z]' | grep -v 'export\s*const\s*Route\b' || true)
  if [ -n "$non_route_exports" ]; then
    hook_warn "Do not export components from route files (breaks code splitting).\nMove helper components to separate files. Only export the Route config."
  fi
fi

# ── Check 9: Missing validateSearch when useSearch is used ────────────

if echo "$added_lines" | grep -qE '\buseSearch\b'; then
  if echo "$file_path" | grep -qE '/routes/'; then
    file_content=$(cat "$file_path")
    if ! echo "$file_content" | grep -qF 'validateSearch'; then
      hook_block "useSearch requires validateSearch in the route definition.\nAdd a zod schema to your route's validateSearch option.\n\nimport { z } from 'zod'\nvalidateSearch: z.object({ page: z.number().default(1) })"
    fi
  fi
fi

exit 0
