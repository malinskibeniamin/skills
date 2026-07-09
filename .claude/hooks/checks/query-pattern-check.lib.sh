#!/bin/bash
# Extracted check logic for query-pattern-check.sh. Source ../_hook-lib.sh before this file.

run_query_pattern_check() {
hook_filter_extensions "ts|tsx" || return 0
hook_skip_generated || return 0
hook_skip_tests || return 0
hook_get_added_lines || return 0

file_content=$(cat "$file_path" 2>/dev/null || true)

# Source material: @tanstack/eslint-plugin-query v5.100.14 rules inspected:
# exhaustive-deps, stable-query-client, no-rest-destructuring,
# no-unstable-deps, no-void-query-fn, property order, prefer-query-options.
# Vendored here as lightweight project hooks; no ESLint runtime dependency.

# ── Existing project checks ──────────────────────────────────────

if echo "$added_lines" | grep -qE '\.refetchQueries\('; then
  if ! hook_has_escape "refetch-queries"; then
    hook_warn "Prefer invalidateQueries() over refetchQueries(). Invalidation lets React Query decide optimal refetch timing. Escape: // allow: refetch-queries [reason]" "query-pattern-refetch"
    return 0
  fi
fi

no_await=$(echo "$added_lines" | grep -E 'invalidateQueries\(' | grep -vE 'await|return' || true)
if [ -n "$no_await" ]; then
  if ! hook_has_escape "await-invalidate"; then
    hook_warn "Always await invalidateQueries() — without await, subsequent code may see stale cache. Escape: // allow: await-invalidate [reason]" "query-pattern-await"
    return 0
  fi
fi

# ── TanStack ESLint intent: stable-query-client ───────────────────
# A QueryClient created during render is unstable and can wipe cache.

if echo "$added_lines" | grep -qE 'new[[:space:]]+QueryClient[[:space:]]*\('; then
  if hook_has_escape "unstable-query-client"; then
    :
  elif ! echo "$added_lines" | grep -qE 'useState[[:space:]]*\([^\n]*new[[:space:]]+QueryClient|useMemo[[:space:]]*\([^\n]*new[[:space:]]+QueryClient'; then
    if echo "$file_content" | grep -qE 'function[[:space:]]+[A-Z][A-Za-z0-9_]*[[:space:]]*\(|const[[:space:]]+[A-Z][A-Za-z0-9_]*[[:space:]]*=.*=>|<[A-Za-z][A-Za-z0-9.]*'; then
      hook_block "TanStack Query: QueryClient must be stable. Create it outside components or via React.useState(() => new QueryClient()). Escape: // allow: unstable-query-client [reason]"
      return 0
    fi
  fi
fi

# ── TanStack ESLint intent: no-rest-destructuring ─────────────────
# Rest destructuring observes every query result property → excess renders.

if echo "$added_lines" | grep -qE '\{[^}\n]*\.\.\.[A-Za-z_$][A-Za-z0-9_$]*[^}\n]*\}[[:space:]]*=[[:space:]]*(use(Query|InfiniteQuery|SuspenseQuery|SuspenseInfiniteQuery)|[A-Za-z_$][A-Za-z0-9_$]*Query\b)'; then
  if ! hook_has_escape "query-rest-destructure"; then
    hook_warn "TanStack Query: avoid rest destructuring query results; it subscribes to all result changes. Destructure only fields used. Escape: // allow: query-rest-destructure [reason]" "query-pattern-rest"
    return 0
  fi
fi

# ── TanStack ESLint intent: no-unstable-deps ──────────────────────
# Query hook return object is not referentially stable. Dependency arrays
# should contain destructured fields, not the whole query object.

query_vars=$(printf '%s\n%s' "$file_content" "$added_lines" | grep -oE '[A-Za-z_$][A-Za-z0-9_$]*[[:space:]]*=[[:space:]]*use(Query|InfiniteQuery|SuspenseQuery|SuspenseInfiniteQuery)[[:space:]]*\(' | sed -E 's/[[:space:]]*=.*//' | sort -u || true)
if [ -n "$query_vars" ]; then
  while IFS= read -r qv; do
    [ -z "$qv" ] && continue
    if echo "$added_lines" | grep -qE '\[[^]]*\b'"$qv"'\b[^]]*\]'; then
      if ! hook_has_escape "unstable-query-deps"; then
        hook_block "TanStack Query: '$qv' query result is not stable. Destructure fields and put those fields in hook dependency arrays. Escape: // allow: unstable-query-deps [reason]"
        return 0
      fi
    fi
  done <<< "$query_vars"
fi

# ── TanStack ESLint intent: no-void-query-fn ──────────────────────
# queryFn must return data; block common block-body forms with no return.

if echo "$added_lines" | tr '\n' ' ' | grep -qE 'queryFn[[:space:]]*:[[:space:]]*(async[[:space:]]*)?\([^)]*\)[[:space:]]*=>[[:space:]]*\{[^}]*\}'; then
  query_fn_blocks=$(echo "$added_lines" | tr '\n' ' ' | grep -oE 'queryFn[[:space:]]*:[[:space:]]*(async[[:space:]]*)?\([^)]*\)[[:space:]]*=>[[:space:]]*\{[^}]*\}' || true)
  if [ -n "$query_fn_blocks" ] && ! echo "$query_fn_blocks" | grep -qE '\breturn\b'; then
    hook_block "TanStack Query: queryFn must return a value. Add return/implicit expression; undefined query data breaks cache semantics."
    return 0
  fi
fi

# ── TanStack ESLint intent: exhaustive-deps (low-noise subset) ───
# Warn only when we can see a direct queryFn call argument that is missing
# from a literal queryKey in the same edited chunk. Ambiguous cases pass.

compact_added=$(echo "$added_lines" | tr '\n' ' ')
if echo "$compact_added" | grep -qE 'queryKey[[:space:]]*:[[:space:]]*\[[^]]*\].*queryFn[[:space:]]*:'; then
  if ! hook_has_escape "query-key-deps"; then
    query_key_literal=$(echo "$compact_added" | sed -nE 's/.*queryKey[[:space:]]*:[[:space:]]*\[([^]]*)\].*/\1/p' | head -1)
    query_fn_args=$(echo "$compact_added" | sed -nE 's/.*queryFn[[:space:]]*:[^=]*=>[[:space:]]*(return[[:space:]]+)?[A-Za-z_$][A-Za-z0-9_$]*[[:space:]]*\(([^)]*)\).*/\2/p' | head -1)
    if [ -n "$query_fn_args" ]; then
      missing_deps=""
      candidates=$(echo "$query_fn_args" | tr ',' '\n' | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' | grep -E '^[A-Za-z_$][A-Za-z0-9_$]*$' | grep -Ev '^(signal|pageParam|meta|context|ctx|client|queryClient)$' || true)
      while IFS= read -r dep; do
        [ -z "$dep" ] && continue
        if ! echo "$query_key_literal" | grep -qE '(^|[^A-Za-z0-9_$])'"$dep"'([^A-Za-z0-9_$]|$)'; then
          missing_deps="${missing_deps}${missing_deps:+, }$dep"
        fi
      done <<< "$candidates"
      if [ -n "$missing_deps" ]; then
        hook_warn "TanStack Query: queryFn uses $missing_deps but queryKey does not include it. Add it to queryKey or escape: // allow: query-key-deps [reason]" "query-pattern-key-deps"
        return 0
      fi
    fi
  fi
fi

# ── TanStack ESLint intent: inference-sensitive property order ────
# Type inference is better when mutation callbacks and infinite query fns
# appear in the order TanStack expects.

if echo "$added_lines" | tr '\n' ' ' | grep -qE 'useMutation\([^{]*\{[^}]*on(Error|Settled)[^}]*onMutate'; then
  hook_warn "TanStack Query: put onMutate before onError/onSettled in useMutation options for reliable inference." "query-pattern-mutation-order"
  return 0
fi

if echo "$added_lines" | tr '\n' ' ' | grep -qE '(useInfiniteQuery|useSuspenseInfiniteQuery|infiniteQueryOptions)\([^{]*\{[^}]*get(Next|Previous)PageParam[^}]*queryFn'; then
  hook_warn "TanStack Query: put queryFn before getPreviousPageParam/getNextPageParam in infinite query options for reliable inference." "query-pattern-infinite-order"
  return 0
fi

# ── TanStack ESLint intent: prefer-query-options (strict) ─────────
# High-value subset only: nudge duplicated queryKey/queryFn object literals.

if echo "$added_lines" | grep -qE 'use(Query|InfiniteQuery|SuspenseQuery|SuspenseInfiniteQuery)\([[:space:]]*\{' && echo "$added_lines" | grep -qE 'queryKey[[:space:]]*:.*queryFn[[:space:]]*:|queryFn[[:space:]]*:.*queryKey[[:space:]]*:'; then
  if ! hook_has_escape "inline-query-options"; then
    hook_warn "TanStack Query: consider queryOptions()/infiniteQueryOptions() to co-locate queryKey and queryFn for reuse. Escape: // allow: inline-query-options [reason]" "query-pattern-options"
    return 0
  fi
fi

# ── absorbed from mutation-onerror-check.sh (4.28 family consolidation) ──
# ── Check: mutate()/mutateAsync() must include onError callback ──
# Silent mutation failures = data loss risk. Users must see feedback.

# Gate: only check files with mutation usage
if echo "$file_content" | grep -qE 'useMutation|mutate\(|mutateAsync\('; then
  # Check for mutate/mutateAsync calls in added lines without onError
  mutation_calls=$(echo "$added_lines" | grep -E '\b(mutate|mutateAsync)\s*\(' || true)

  if [ -n "$mutation_calls" ]; then
    # Check if onError exists anywhere in the mutation setup (file-level check)
    has_onerror=false
    if echo "$file_content" | grep -qE 'onError\s*[:=(\[]'; then
      has_onerror=true
    fi

    if [ "$has_onerror" = false ]; then
      if ! hook_has_escape "mutation-onerror"; then
        hook_block "mutate()/mutateAsync() without onError callback. Add onError to show user feedback on failure. Use ConnectError.from(error) + formatToastErrorMessageGRPC(). Escape: // allow: mutation-onerror [reason]"
        return 0
      fi
    fi
  fi
fi

# ── absorbed from mutation-side-effect-check.sh (4.28 family consolidation) ──
# ── Check 1: Side-effect fetch calls should use useMutation ──────
# fetch() with method: DELETE/POST/PUT/PATCH outside mutationFn
# should be wrapped in useMutation for proper loading/error state.
# Only fire in React component/route/hook files, not utility/lib files.

# Gate: only check files that are React components or hooks
is_react_file=false
if echo "$file_path" | grep -qE '/(routes|components|hooks|pages|features)/'; then
  is_react_file=true
elif echo "$file_content" | grep -qE "from\s+['\"]react['\"]|from\s+['\"]@tanstack/"; then
  is_react_file=true
fi

if [ "$is_react_file" = true ]; then
  # Check added lines for side-effect fetch calls
  side_effect_fetches=$(echo "$added_lines" | grep -E "method:\s*['\"]?(DELETE|POST|PUT|PATCH)['\"]?" || true)

  if [ -n "$side_effect_fetches" ]; then
    # Count side-effect methods in new code vs mutationFn wrappers in new code.
    # File-level useMutation check is too broad — a file can have one mutation
    # but add new raw fetches that bypass it.
    new_fetch_count=$(echo "$side_effect_fetches" | wc -l | tr -d '[:space:]')
    new_mutation_count=$(echo "$added_lines" | grep -cE 'mutationFn|useMutation' 2>/dev/null || true)
    new_mutation_count=${new_mutation_count:-0}
    new_mutation_count=$(echo "$new_mutation_count" | tr -d '[:space:]')

    if [ "$new_fetch_count" -gt "$new_mutation_count" ]; then
      if ! hook_has_escape "inline-mutation"; then
        hook_warn "Side-effect fetch (DELETE/POST/PUT/PATCH) without useMutation. ${new_fetch_count} fetch(es) but only ${new_mutation_count} mutation wrapper(s) in new code. Wrap in useMutation hook. Escape: // allow: inline-mutation [reason]"
        return 0
      fi
    fi
  fi
fi

return 0
}
