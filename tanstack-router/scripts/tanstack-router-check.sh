#!/bin/bash
set -euo pipefail
_lib="$(dirname "$0")/_hook-lib.sh"; if [ -f "$_lib" ]; then source "$_lib"; else _m="${TMPDIR:-/tmp}/frontend-skills-broken.${CLAUDE_SESSION_ID:-fs}"; [ -f "$_m" ] || { echo "[frontend-skills] _hook-lib.sh unavailable - run: /plugin install frontend-skills --force" >&2; touch "$_m" 2>/dev/null; }; exit 0; fi

hook_parse_edit_write
hook_filter_extensions "ts|tsx"
hook_get_added_lines

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

_route_primes_query() {
  local candidate content seen
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
    content=$(cat "$candidate" 2>/dev/null || true)
    if echo "$content" | grep -qE '\bloader[[:space:]]*:' && echo "$content" | grep -qE 'queryClient\.(prefetchQuery|ensureQueryData|fetchQuery)|queryOptions\('; then
      return 0
    fi
  done < <(_route_candidate_files)
  return 1
}

_route_option_body() {
  local option="$1"
  awk -v option="$option" '
    BEGIN { active = 0; arrow = 0; body = 0; depth = 0; emitted = 0 }
    !active && $0 ~ "(^|[{,])[[:space:]]*" option "[[:space:]]*:" { active = 1 }
    active {
      buffer = buffer $0 ORS
      line = $0
      if (!arrow && index(line, "=>")) {
        arrow = 1
        sub(/^.*=>/, "", line)
      } else if (!arrow) {
        if (line ~ /,[[:space:]]*$/ || line ~ /^[[:space:]]*}?[)][,;]?[[:space:]]*$/) exit
        next
      }

      opens = gsub(/{/, "{", line)
      closes = gsub(/}/, "}", line)
      if (opens > 0) body = 1
      depth += opens - closes

      if ((body && depth <= 0) || (!body && line ~ /,[[:space:]]*$/)) {
        printf "%s", buffer
        emitted = 1
        exit
      }
    }
    END { if (arrow && !emitted) printf "%s", buffer }
  ' <<< "$file_content"
}

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
    hook_block "No URLSearchParams in client code. Use TanStack Router validateSearch+zod or nuqs."
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

unscoped_route_hooks=$(echo "$added_lines" | sed -E 's/[A-Za-z_$][A-Za-z0-9_$]*\.(useParams|useSearch|useLoaderData|useRouteContext)\([[:space:]]*\)//g' | grep -E '\b(useParams|useSearch|useLoaderData|useRouteContext)\(\s*\)' || true)
if [ -n "$unscoped_route_hooks" ]; then
  file_content=$(cat "$file_path")
  if echo "$file_content" | grep -qE "from\s+['\"]@tanstack/react-router"; then
    match=$(echo "$unscoped_route_hooks" | grep -oE '\b(useParams|useSearch|useLoaderData|useRouteContext)\(\s*\)' | head -1)
    hook_block "$match needs { from: '/route/\$param' } for type safety. Or use a typed route API.$match."
  fi
fi

# ── Check 8: Warn on exported components from route files ──────────────

if echo "$file_path" | grep -qE '/routes/'; then
  non_route_exports=$(echo "$added_lines" | grep -E 'export\s+(function|const)\s+[A-Z]' | grep -v 'export\s*const\s*Route\b' || true)
  if [ -n "$non_route_exports" ]; then
    hook_warn "No component exports from route files (breaks code splitting). Move to separate files."
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

# ── Check 13: Loader dependencies name only data inputs ──────────
# Returning the full search object reruns loaders for unrelated URL state and
# makes the component/loader Query identity easier to drift.

file_content="${file_content:-$(cat "$file_path" 2>/dev/null || true)}"
file_compact=$(printf '%s' "$file_content" | tr '\n' ' ')

if echo "$file_compact" | grep -qE 'loaderDeps[[:space:]]*:[[:space:]]*\([[:space:]]*\{[[:space:]]*search[[:space:]]*\}[[:space:]]*\)[[:space:]]*=>[[:space:]]*search\b'; then
  if ! hook_has_escape "router-loader-deps-search"; then
    hook_warn "loaderDeps returns the whole search object. Return only query-relevant, used search fields so unrelated URL state does not reload data. Escape: // allow: router-loader-deps-search [reason]"
  fi
fi

# ── Check 14: Query observers consume loader-owned dependencies ──
# A component that rebuilds Query options from useSearch can silently diverge
# from the loader. useLoaderDeps exposes the exact validated loader inputs.

if echo "$file_content" | grep -qE '\b(useQuery|useSuspenseQuery)\b' && echo "$file_content" | grep -qE '\b(useSearch|Route\.useSearch|[A-Za-z_$][A-Za-z0-9_$]*\.useSearch)\b' && _route_primes_query; then
  if ! echo "$file_content" | grep -qE '\b(useLoaderDeps|Route\.useLoaderDeps|[A-Za-z_$][A-Za-z0-9_$]*\.useLoaderDeps)\b'; then
    if ! hook_has_escape "router-query-search-identity"; then
      hook_warn "Query options are rebuilt from route search. For loader-prefetched data, derive options from loader dependencies with useLoaderDeps or consume version-supported shared options from route context. Escape: // allow: router-query-search-identity [reason]"
    fi
  fi
fi

# ── Check 15: beforeLoad remains replay-safe ──────────────────────
# Preloads and navigations run their own beforeLoad chains. Observable effects
# here can duplicate even when the underlying loader work is shared.

before_load_body=$(_route_option_body "beforeLoad")
if [ -n "$before_load_body" ] && echo "$before_load_body" | grep -qE '\b(analytics|telemetry)\.|\b(track|capture|identify)\s*\(|\btoast\.|\.mutate(Async)?\s*\(|\bfetch\s*\(|queryClient\.(prefetchQuery|ensureQueryData|fetchQuery|setQueryData|invalidateQueries|removeQueries|cancelQueries)\s*\('; then
  if ! hook_has_escape "router-before-load-side-effect"; then
    hook_warn "beforeLoad contains a side effect or data fetch and can run separately for preload and navigation. Keep it replay-safe: authentication, redirect, or context only. Escape: // allow: router-before-load-side-effect [reason]"
  fi
fi

# ── Check 16: Redirects remain route control flow ─────────────────
# The loader navigate argument is deprecated in current Router APIs, and an
# imperative navigation can race the route attempt that started it.

loader_body=$(_route_option_body "loader")
if [ -n "$loader_body" ] && echo "$loader_body" | grep -qE '\bnavigate\s*\('; then
  if ! hook_has_escape "router-loader-navigate"; then
    hook_block "Do not navigate imperatively inside a loader. Throw redirect({ to: ... }) so Router reduces the route attempt as control flow. Escape only for version-matched legacy Router: // allow: router-loader-navigate [reason]"
  fi
fi

# ── Check 17: Direct loader fetches use Router cancellation ───────
# Query-backed loaders keep Query as resource owner. Direct fetches should use
# the Router flight signal, which aborts only after its last consumer releases.

if [ -n "$loader_body" ] && echo "$loader_body" | grep -qE '\bfetch\s*\(' && ! echo "$loader_body" | grep -qE '\b(queryClient|queryOptions)\b'; then
  if ! echo "$loader_body" | grep -qF 'abortController.signal'; then
    if ! hook_has_escape "router-loader-abort"; then
      hook_warn "Direct loader fetch does not forward abortController.signal. Use the Router-owned signal so shared preload/navigation work stops only when unused. Escape: // allow: router-loader-abort [reason]"
    fi
  fi
fi

# ── Check 18: DOM effects wait for framework render ───────────────
# onResolved owns navigation completion, but only onRendered proves the route
# tree committed to the framework DOM.

if echo "$added_lines" | grep -qE "subscribe\s*\([[:space:]]*['\"]onResolved['\"]" && echo "$added_lines" | grep -qE '\b(document\.|focus\s*\(|scrollIntoView\s*\(|getBoundingClientRect\s*\(|querySelector\s*\()'; then
  if ! hook_has_escape "router-resolved-dom"; then
    hook_warn "DOM-dependent work is subscribed to onResolved. Use onRendered for focus, scrolling, or measurement after the route tree commits. Escape: // allow: router-resolved-dom [reason]"
  fi
fi

exit 0
