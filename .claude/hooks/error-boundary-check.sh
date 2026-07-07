#!/bin/bash
set -euo pipefail
_lib="$(dirname "$0")/_hook-lib.sh"; if [ -f "$_lib" ]; then source "$_lib"; else _m="${TMPDIR:-/tmp}/frontend-skills-broken.${CLAUDE_SESSION_ID:-fs}"; [ -f "$_m" ] || { echo "[frontend-skills] _hook-lib.sh unavailable - run: /plugin install frontend-skills --force" >&2; touch "$_m" 2>/dev/null; }; exit 0; fi

hook_parse_edit_write
hook_filter_extensions "ts|tsx"
hook_skip_generated
hook_skip_tests

# ── Check 1: Route files with loader must have errorComponent ────
# Routes that fetch data need error boundaries to handle failures
# gracefully instead of crashing the entire app.

file_content=$(cat "$file_path")

# ── Check 0a: React.lazy without Suspense ────────────────────────
# (moved from orchestration-guidance.sh in the 2026-07 audit; this hook
# is the single owner of error/loading-boundary rules)

if echo "$file_content" | grep -qE 'React\.lazy\(|[^A-Za-z_]lazy\(' && \
   ! echo "$file_content" | grep -qE '<Suspense|Suspense>'; then
  if ! hook_has_escape "lazy-suspense"; then
    hook_warn "React.lazy() without <Suspense> in this file. Wrap the lazy component or note the boundary location. Escape: // allow: lazy-suspense [reason]" "lazy-suspense"
  fi
fi

# ── Check 0b: Query in component without loading/error/empty ─────
# Components rendering query results must handle non-success states.
# Skip custom hooks (use*.ts, /hooks/) -- state handling is the consumer's job.

if ! echo "$file_path" | grep -qE '/hooks/|/use[A-Z]'; then
  if echo "$file_content" | grep -qE 'useQuery|useSuspenseQuery' && \
     echo "$file_content" | grep -qE 'return.*<' && \
     ! echo "$file_content" | grep -qE 'isLoading|isPending|isError|fallback|Skeleton|Spinner|EmptyState|ErrorState'; then
    if ! hook_has_escape "query-states"; then
      hook_warn "Query result rendered without loading/error/empty handling (isLoading/isPending/isError/fallback). Escape: // allow: query-states [reason]" "query-states"
    fi
  fi
fi

# Detect route file by path or content (supports any directory structure)
is_route=false
if echo "$file_path" | grep -qE '/routes/'; then
  is_route=true
elif echo "$file_content" | grep -qE 'createFileRoute|createRoute|createLazyRoute'; then
  is_route=true
fi

if [ "$is_route" = false ]; then
  exit 0
fi

# Check if route has a loader (data fetching)
has_loader=false
if echo "$file_content" | grep -qE '\bloader\s*:|loaderFn\s*:|beforeLoad\s*:'; then
  has_loader=true
fi

if [ "$has_loader" = true ]; then
  if ! echo "$file_content" | grep -qE '\berrorComponent\s*:'; then
    # Check if a parent layout route might provide the error boundary
    # Layout routes: $name.tsx, __root.tsx, _layout.tsx patterns
    dir=$(dirname "$file_path")
    has_parent_boundary=false
    for parent in "$dir/../"*.tsx "$dir/__root.tsx" "$dir/_"*.tsx; do
      if [ -f "$parent" ] && grep -qE '\berrorComponent\s*:' "$parent" 2>/dev/null; then
        has_parent_boundary=true
        break
      fi
    done

    if [ "$has_parent_boundary" = false ]; then
      if ! hook_has_escape "error-boundary"; then
        hook_block "Route with loader has no errorComponent. Add errorComponent to handle fetch failures gracefully. Escape: // allow: error-boundary [reason]"
      fi
    fi
  fi
fi

exit 0
