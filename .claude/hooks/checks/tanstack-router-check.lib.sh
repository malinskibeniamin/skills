#!/bin/bash
# Extracted check logic for tanstack-router-check.sh. Source ../_hook-lib.sh before this file.

run_tanstack_router_check() {
hook_filter_extensions "ts|tsx" || return 0

added_lines="$(
  set +e
  hook_get_added_lines
  _status=$?
  if [ "$_status" -eq 0 ]; then
    printf '%s' "$added_lines"
  fi
  return 0
)"

_route_candidate_files() {
  local dir base stem short
  dir=$(dirname "$file_path")
  base=$(basename "$file_path")
  stem="${base%.*}"
  short="$stem"
  case "$short" in
    *.page) short="${short%.page}" ;;
  esac

  printf '%s\n' "$file_path"
  printf '%s\n' "$dir/$short.tsx" "$dir/$short.ts" "$dir/$short.route.tsx" "$dir/$short.route.ts"
  printf '%s\n' "$dir/route.tsx" "$dir/route.ts" "$dir/index.tsx" "$dir/index.ts" "$dir/__root.tsx" "$dir/__root.ts"
}

_route_has_validate_search() {
  local candidate seen
  seen=""
  while IFS= read -r candidate; do
    [ -z "$candidate" ] && continue
    case "
$seen
" in
      *"
$candidate
"*) continue ;;
    esac
    seen="$seen
$candidate"
    [ -f "$candidate" ] || continue
    if grep -qF 'validateSearch' "$candidate" 2>/dev/null; then
      return 0
    fi
  done < <(_route_candidate_files)
  return 1
}

_has_sibling_route_test() {
  local dir base stem short suffix
  dir=$(dirname "$file_path")
  base=$(basename "$file_path")
  stem="${base%.*}"
  short="$stem"
  case "$short" in
    *.page) short="${short%.page}" ;;
  esac
  for name in "$stem" "$short"; do
    [ -z "$name" ] && continue
    for suffix in browser.test.tsx browser.test.ts integration.test.tsx integration.test.ts; do
      [ -f "$dir/$name.$suffix" ] && return 0
    done
  done
  return 1
}

if [ -n "$added_lines" ]; then

# ── Check 1: Ban react-router-dom imports ─────────────────────────────

if echo "$added_lines" | grep -qE "from\s+['\"]react-router-dom['\"/]"; then
  hook_block "react-router-dom banned. Use TanStack Router: useNavigate, useParams({from}), useSearch(validateSearch), <Link>."
fi

# ── Check 2: Ban window.location for navigation ──────────────────────

if echo "$added_lines" | grep -qE 'window\.location\.(href|assign|replace)\s*[=(]'; then
  hook_block "No window.location nav (full reload). Use navigate({to}) or <Link> from @tanstack/react-router."
fi

# ── Check 2b: Ban navigate(-1) / history.back() ─────────────────────

if echo "$added_lines" | grep -qE 'navigate\(\s*-1\s*\)|history\.back\(\)|history\.go\(\s*-'; then
  hook_warn "navigate(-1) can exit app if no history. Use explicit route path."
fi

# ── Check 3: Ban URLSearchParams in client code ──────────────────────

if echo "$added_lines" | grep -qE '\bnew URLSearchParams\b|searchParams\.(get|set|append)\b'; then
  _is_client_file=false
  if echo "$file_path" | grep -qE '/(routes|components|pages|hooks|stores)/'; then
    _is_client_file=true
  fi
  file_content="${file_content:-$(cat "$file_path" 2>/dev/null || true)}"
  if echo "$file_content" | grep -qE "@tanstack/react-router|from ['\"]react"; then
    _is_client_file=true
  fi
  if [ "$_is_client_file" = true ]; then
    hook_block "No URLSearchParams in client code. Use TanStack Router validateSearch+zod and Route.useSearch()."
  fi
fi

# ── Check 4: Warn on window.location.reload() ────────────────────────

if echo "$added_lines" | grep -qE '(window\.)?location\.reload\(\)'; then
  hook_warn "No hard reloads (blank flash, loses state). Use router.invalidate() or queryClient.invalidateQueries()."
fi

# ── Check 5: Warn on window.location reads ────────────────────────────

if echo "$added_lines" | grep -qE 'window\.location\.(search|pathname|hash|origin)\b'; then
  hook_warn "No window.location reads. Use useParams({from}) or useSearch({from}) for type-safe access. For origin, use router basePath or env config."
fi

# ── Check 5b: Catch bare location.href (without window. prefix) ──────

bare_location=$(echo "$added_lines" | grep -E '\blocation\.(href|assign|replace|reload)\b' | grep -vE 'window\.location' || true)
if [ -n "$bare_location" ]; then
  hook_warn "Bare location.href detected. Use TanStack Router navigate({to}) or <Link>. For external redirects, use window.open() sparingly with user confirmation."
fi

# ── Check 5c: Warn on window.open() for OAuth/redirect flows ─────────

if echo "$added_lines" | grep -qE 'window\.open\('; then
  hook_warn "window.open() detected. For OAuth redirects, prefer server-side redirect or TanStack Router navigate. If needed, document why in comment."
fi

# ── Check 6: Ban strict: false in router hook calls ───────────────────

if echo "$added_lines" | grep -qE 'strict:\s*false'; then
  file_content=$(cat "$file_path")
  if echo "$file_content" | grep -qE "from\s+['\"]@tanstack/react-router"; then
    hook_block "No strict:false. Use { from: '/route/\$param' } for typed params."
  fi
fi

# ── Check 7: Ban empty-args useParams/useSearch/useLoaderData/useRouteContext ─

if echo "$added_lines" | grep -qE '\b(useParams|useSearch|useLoaderData|useRouteContext)\(\s*\)'; then
  if ! echo "$added_lines" | grep -qE 'Route\.(useParams|useSearch|useLoaderData|useRouteContext)\(\s*\)'; then
    file_content=$(cat "$file_path")
    if echo "$file_content" | grep -qE "from\s+['\"]@tanstack/react-router"; then
      match=$(echo "$added_lines" | grep -oE '\b(useParams|useSearch|useLoaderData|useRouteContext)\(\s*\)' | head -1)
      hook_block "$match needs { from: '/route/\$param' } for type safety. Or use Route.$match."
    fi
  fi
fi

# ── Check 8: Warn on exported components from route files ──────────────

if echo "$file_path" | grep -qE '/routes/'; then
  _split_file_candidate=false
  _route_check_base=$(basename "$file_path")
  case "$_route_check_base" in
    *.page.ts|*.page.tsx|route.ts|route.tsx|index.ts|index.tsx|__root.ts|__root.tsx) ;;
    *)
      if echo "$_route_check_base" | grep -qE '(-parts|[.]parts|[.]dialogs?|[.]checklists?)\.tsx?$'; then
        _split_file_candidate=true
      else
        file_content="${file_content:-$(cat "$file_path" 2>/dev/null || true)}"
        if ! echo "$file_content" | grep -qE 'create(File|Root)?Route|export[[:space:]]+const[[:space:]]+Route\b'; then
          if echo "$file_content" | grep -qE '(^|[[:space:]])(export[[:space:]]+)?(function|const)[[:space:]]+[A-Z][A-Za-z0-9_]*|export[[:space:]]+default[[:space:]]+function[[:space:]]+[A-Z]'; then
            _split_file_candidate=true
          fi
        fi
      fi
      ;;
  esac
  if [ "$_split_file_candidate" = false ]; then
    non_route_exports=$(echo "$added_lines" | grep -E 'export\s+(function|const)\s+[A-Z]' | grep -v 'export\s*const\s*Route\b' || true)
    if [ -n "$non_route_exports" ]; then
      hook_warn "No component exports from route files (breaks code splitting). Move to separate files."
    fi
  fi
fi

# ── Check 9: Missing validateSearch when useSearch is used ────────────

if echo "$added_lines" | grep -qE '\buseSearch\b'; then
  if echo "$file_path" | grep -qE '/routes/'; then
    if ! _route_has_validate_search; then
      hook_block "useSearch requires validateSearch on route. Add zod schema in the route file or sibling route file: validateSearch: z.object({...})."
    fi
  fi
fi

# ── Check 9b: routeApi.useSearch({ select }) in tested route pages ────
# In route page/components with browser or integration coverage, prefer the
# typed hook with explicit route source. The routeApi form made two regressions
# harder to spot because the component did not make the validated route source
# obvious at the call site.

if echo "$added_lines" | grep -qE '[A-Za-z_$][A-Za-z0-9_$]*[.]useSearch[[:space:]]*[(][[:space:]]*[{][^}]*select[[:space:]]*:'; then
  if echo "$file_path" | grep -qE '/routes/|[.]page[.]tsx$'; then
    if _has_sibling_route_test; then
      hook_warn "routeApi.useSearch({ select }) in tested route component. Prefer useSearch({ from: '/route', select }) so the validated route source is explicit." "router-routeapi-use-search-select"
    fi
  fi
fi

# ── Check 10: Router + Query cache ownership ─────────────────────
# If a route loader primes TanStack Query, components should still consume
# the data via useQuery/useSuspenseQuery so Query has an active observer.
# Do not force suspense: useQuery is fine for deferred/non-blocking data.

if echo "$file_path" | grep -qE '/routes/'; then
  file_content="${file_content:-$(cat "$file_path" 2>/dev/null || true)}"

  if echo "$file_content" | grep -qE 'queryClient\.(prefetchQuery|ensureQueryData|fetchQuery)|queryOptions\('; then
    if echo "$added_lines" | grep -qE 'Route\.useLoaderData\(|\buseLoaderData\('; then
      if ! hook_has_escape "router-query-loader-data"; then
        hook_warn "Router loader is priming TanStack Query, but component reads loader data. Prefer useQuery() or useSuspenseQuery() so Query has an active observer. Escape: // allow: router-query-loader-data [reason]"
      fi
    fi
  fi
fi

# ── Check 11: Disable router preload cache when Query owns cache ──
# TanStack Router has its own preload cache. When QueryClient is in router
# context, use defaultPreloadStaleTime: 0 so only Query controls caching.

if echo "$added_lines" | grep -qE 'createRouter\s*\(' || echo "$added_lines" | grep -qE 'context\s*:\s*\{[^}]*queryClient'; then
  file_content="${file_content:-$(cat "$file_path" 2>/dev/null || true)}"
  if echo "$file_content" | grep -qE 'createRouter\s*\(' && echo "$file_content" | grep -qE 'context\s*:\s*\{[^}]*queryClient|context:\s*\{[^}]*queryClient|queryClient\s*[,}]'; then
    if ! echo "$file_content" | grep -qE 'defaultPreloadStaleTime\s*:\s*0|defaultPreloadStaleTime:\s*0\b'; then
      if ! hook_has_escape "router-query-preload-cache"; then
        hook_warn "Router uses QueryClient context. Add defaultPreloadStaleTime: 0 so TanStack Query is the single cache owner. Escape: // allow: router-query-preload-cache [reason]"
      fi
    fi
  fi
fi

# ── Check 12: Typed root context for QueryClient ──────────────────
# If router context passes queryClient, root route should type it with
# createRootRouteWithContext so loaders can access context.queryClient safely.

if echo "$added_lines" | grep -qE 'createRootRoute\s*\(|context\s*:\s*\{[^}]*queryClient'; then
  file_content="${file_content:-$(cat "$file_path" 2>/dev/null || true)}"
  if echo "$file_content" | grep -qE 'context\s*:\s*\{[^}]*queryClient' && echo "$file_content" | grep -qE 'createRootRoute\s*\('; then
    if ! echo "$file_content" | grep -qE 'createRootRouteWithContext'; then
      if ! hook_has_escape "router-query-root-context"; then
        hook_warn "Router passes queryClient context. Use createRootRouteWithContext<{ queryClient: QueryClient }>() so loaders get typed context. Escape: // allow: router-query-root-context [reason]"
      fi
    fi
  fi
fi

fi

_absorbed_generated_file=false
case "$file_path" in
  *.gen.ts|*.gen.tsx|*.gen.js|*_pb.ts|*_pb.js|*_connectquery.ts) _absorbed_generated_file=true ;;
esac
if head -5 "$file_path" 2>/dev/null | grep -qE '(@generated|auto-generated|DO NOT EDIT)'; then
  _absorbed_generated_file=true
fi

_absorbed_test_file=false
case "$file_path" in
  *.test.*|*.spec.*|*/__tests__/*) _absorbed_test_file=true ;;
esac

# ── absorbed from hook-location-check.sh (4.28 family consolidation) ──
# ── Check 1: Ban custom hook definitions in route files ──────────
# Custom hooks (function use*) must live in /hooks/ directory,
# not inline in route files.
# Detect route files by path OR content (supports any directory structure).

if [ "$_absorbed_generated_file" = false ] && [ -n "$added_lines" ]; then
  is_route=false
  if echo "$file_path" | grep -qE '/routes/'; then
    is_route=true
  elif grep -qE 'createFileRoute|createRoute|createLazyRoute' "$file_path" 2>/dev/null; then
    is_route=true
  fi

  if [ "$is_route" = true ]; then
    if echo "$added_lines" | grep -qE '^\+?(export\s+)?(function\s+use[A-Z]|const\s+use[A-Z]\w*\s*=)'; then
      if ! hook_has_escape "inline-hook"; then
        hook_warn "Custom hook defined in route file. Move to /hooks/ directory. Escape: // allow: inline-hook [reason]"
      fi
    fi
  fi
fi

# ── absorbed from file-size-check.sh (4.28 family consolidation) ──
# ── Check 1: Warn when route files exceed 300 LOC ───────────────
# Large route components should be split. Suggest /improve architecture.
# Detect route files by path OR content (supports any directory structure).

if [ "$_absorbed_generated_file" = false ] && [ "$_absorbed_test_file" = false ]; then
  is_route=false
  if echo "$file_path" | grep -qE '/routes/'; then
    is_route=true
  elif grep -qE 'createFileRoute|createRoute|createLazyRoute' "$file_path" 2>/dev/null; then
    is_route=true
  fi

  if [ "$is_route" = true ]; then
    loc=$(wc -l < "$file_path" | tr -d ' ')
    if [ "$loc" -gt 300 ]; then
      hook_warn "Route file is ${loc} LOC (limit: 300). Split into smaller components or use /improve architecture."
    fi
  fi
fi

# ── absorbed from split-file-convention-check.sh (4.28 family consolidation) ──
if [ "$_absorbed_generated_file" = false ] && [ "$_absorbed_test_file" = false ]; then
  case "$file_path" in
    */routes/*)
      base=$(basename "$file_path")
      file_content=$(cat "$file_path" 2>/dev/null || true)

      case "$base" in
        *.page.ts|*.page.tsx|route.ts|route.tsx|index.ts|index.tsx|__root.ts|__root.tsx) ;;
        *)
          if echo "$base" | grep -qE '(-parts|[.]parts|[.]dialogs?|[.]checklists?)\.tsx?$'; then
            hook_block "Split-file convention: route UI files must be either .page.tsx in routes/ or named components under components/. Avoid -parts/.dialogs/.checklist suffix mixes." "split-file-convention"
          fi

          # Route declaration files can be named by path, but split UI components should
          # not live beside them under ad-hoc names.
          if ! echo "$file_content" | grep -qE 'create(File|Root)?Route|export[[:space:]]+const[[:space:]]+Route\b'; then
            if echo "$file_content" | grep -qE '(^|[[:space:]])(export[[:space:]]+)?(function|const)[[:space:]]+[A-Z][A-Za-z0-9_]*|export[[:space:]]+default[[:space:]]+function[[:space:]]+[A-Z]'; then
              hook_block "Split-file convention: route page components stay as *.page.tsx in routes/; reusable pieces move to components/." "split-file-convention"
            fi
          fi
          ;;
      esac
      ;;
  esac
fi

# ── Check: clamp URL-sourced pagination indices ───────────────────
# A stale/oversized ?page= fed straight into table state renders an
# empty table ("no results" lie). Clamp against data length.

if echo "$added_lines" | grep -qE 'page(Index)?\s*:\s*(search|searchParams|params)\.' ; then
  if ! echo "$file_content" | grep -qE 'Math\.(min|max)|clamp|pageCount'; then
    if ! hook_has_escape "clamp-page-index"; then
      hook_warn "URL-sourced page index fed into table state without clamping — a stale ?page=999 renders an empty table even when data exists. Clamp against page count. Escape: // allow: clamp-page-index [reason]" "clamp-page-index"
    fi
  fi
fi

return 0
}
