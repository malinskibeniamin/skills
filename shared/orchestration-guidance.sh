#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

# PostToolUse hook: inject file-aware guidance on Edit/Write and track
# file categories for the orchestration-stop.sh quality gate.
# Target: <10ms (file path matching + 1 line append).

hook_parse_edit_write

_session_dir="/tmp/hook-session-${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}"
mkdir -p "$_session_dir" 2>/dev/null || true
session_files="$_session_dir/files"
_seen_file="$_session_dir/guidance-seen"
guidance=""

# ── package.json change detection (before extension filter) ──────

if [ "$(basename "$file_path")" = "package.json" ]; then
  if ! grep -qF "deps" "$_seen_file" 2>/dev/null; then
    echo "deps" >> "$_seen_file" 2>/dev/null || true
    echo "{\"suppressOutput\":true,\"systemMessage\":\"[DEPS] Deps changed. Check changelogs, run npm audit, verify compat.\"}" >&2
  fi
  exit 0
fi

hook_filter_extensions "ts|tsx|js|jsx"
hook_skip_generated

# Emit guidance for a category only once per session.
# File tracking (for orchestration-stop) always happens regardless.
_guidance_once() {
  local category="$1"
  local msg="$2"
  if grep -qF "$category" "$_seen_file" 2>/dev/null; then
    return  # already emitted this category
  fi
  echo "$category" >> "$_seen_file" 2>/dev/null || true
  guidance="$msg"
}

# ── Test file written ────────────────────────────────────────────

case "$file_path" in
  *.test.tsx|*.test.ts|*.integration.tsx|*.integration.ts|*.unit.ts)
    echo "test:$file_path" >> "$session_files" 2>/dev/null || true
    _guidance_once "test" "[TEST] userEvent.setup(), getByRole, no setTimeout, await waitFor() for async."
    ;;
esac

# ── E2E spec written ─────────────────────────────────────────────

if echo "$file_path" | grep -qE 'e2e/.*\.spec\.ts$'; then
  echo "spec:$file_path" >> "$session_files" 2>/dev/null || true
  _guidance_once "e2e" "[E2E] Import from ./fixtures/base (axe-core). data-testid selectors. No page.waitForTimeout."
fi

# ── New component created (TSX in components dir, Write tool) ────

if [ -z "$guidance" ]; then
  case "$file_path" in
    */components/*.tsx|*/components/*.jsx)
      echo "component:$file_path" >> "$session_files" 2>/dev/null || true
      _guidance_once "component" "[COMPONENT] Design system components, keyboard navigable, aria-label on icons, co-located test."
      ;;
  esac
fi

# ── Route file written ──────────────────────────────────────────

if [ -z "$guidance" ]; then
  if echo "$file_path" | grep -qE '/routes/.*\.tsx$'; then
    echo "route:$file_path" >> "$session_files" 2>/dev/null || true
    _guidance_once "route" "[ROUTE] Only export Route config (code splitting). validateSearch+zod for search params."
  fi
fi

# ── Store file written ──────────────────────────────────────────

if [ -z "$guidance" ]; then
  # Match store files precisely: /stores/ dir, *Store.ts, *-store.ts — not "restore", "StoreLocator"
  if echo "$file_path" | grep -qE '/stores/|Store\.(ts|tsx)$|-store\.(ts|tsx)$'; then
    echo "store:$file_path" >> "$session_files" 2>/dev/null || true
    _guidance_once "store" "[STORE] create<T>()() double-parens, useShallow for selectors, persist middleware."
  fi
fi

# Security detection removed — too many false positives on common filenames
# (useSession.ts, TokenInput.tsx, etc.). Security checks are handled by
# react-rules-check.sh (eval, innerHTML, dangerouslySetInnerHTML bans).

# ── Track all JSX/TSX source files for co-located test check ────

case "$file_path" in
  *.tsx|*.jsx)
    if ! echo "$file_path" | grep -qE '(\.test\.|\.spec\.|\.unit\.|\.integration\.)'; then
      echo "jsx:$file_path" >> "$session_files" 2>/dev/null || true
    fi
    ;;
esac

# ── Anti-pattern warnings for test files ─────────────────────────

case "$file_path" in
  *.test.*|*.spec.*|*.integration.*|*.unit.*)
    # Warn on setTimeout/waitForTimeout in tests (causes flaky tests)
    if [ -f "$file_path" ]; then
      file_content=$(cat "$file_path" 2>/dev/null || true)
      if echo "$file_content" | grep -qE 'setTimeout|waitForTimeout|sleep\(' 2>/dev/null; then
        guidance="$guidance No setTimeout in tests. Use await waitFor(() => expect(...))."
      fi
      # Flag data-testid overuse
      testid_count=$(grep -c 'data-testid\|getByTestId' "$file_path" 2>/dev/null | head -1 || echo "0")
      testid_count="${testid_count:-0}"
      if [ "$testid_count" -gt 5 ]; then
        guidance="$guidance High data-testid usage ($testid_count). Prefer getByRole/getByLabelText."
      fi
    fi
    ;;
esac

# ── Error boundary / Suspense nudges (source TSX only) ───────────

case "$file_path" in
  *.tsx|*.jsx)
    if ! echo "$file_path" | grep -qE '(\.test\.|\.spec\.|\.unit\.|\.integration\.)'; then
      file_content="${file_content:-$(cat "$file_path" 2>/dev/null || true)}"

      # Route files with data fetching but no errorComponent
      if echo "$file_path" | grep -qE '/routes/' && \
         echo "$file_content" | grep -qE 'loader|useQuery|useSuspenseQuery' && \
         ! echo "$file_content" | grep -qE 'errorComponent|ErrorBoundary|ErrorComponent'; then
        guidance="$guidance [RESILIENCE] Route fetches data but has no errorComponent."
      fi

      # React.lazy without Suspense
      if echo "$file_content" | grep -qE 'React\.lazy\(|lazy\(' && \
         ! echo "$file_content" | grep -qE '<Suspense|Suspense>'; then
        guidance="$guidance [RESILIENCE] React.lazy() without <Suspense>. Add fallback."
      fi

      # Query hooks without loading/error/empty state handling
      # Only fire in component files (*.tsx with JSX return), not in custom hooks (use*.ts)
      if ! echo "$file_path" | grep -qE '/hooks/|/use[A-Z]'; then
        if echo "$file_content" | grep -qE 'useQuery|useSuspenseQuery' && \
           echo "$file_content" | grep -qE 'return.*<' && \
           ! echo "$file_content" | grep -qE 'isLoading|isPending|isError|fallback|Skeleton|Spinner|EmptyState'; then
          guidance="$guidance [COMPLETENESS] Query hook — handle loading, error, and empty states."
        fi
      fi
    fi
    ;;
esac

# Observability nudge removed — too broad, fired on nearly every component.
# aria-label is already enforced by accessibility-check.sh for icon buttons.

# ── Redpanda registry nudges (only if redpandaKit enabled) ──────

if hook_config_enabled "general.redpandaKit" 2>/dev/null && [ -f "$file_path" ]; then
  file_content="${file_content:-$(cat "$file_path" 2>/dev/null || true)}"

  # useProtoForm nudge — only for ConnectRPC projects, not REST/Zod
  if echo "$file_content" | grep -qE 'useForm|react-hook-form' && \
     echo "$file_content" | grep -qE '@connectrpc|@buf/|_pb'; then
    guidance="$guidance Consider useProtoForm for proto-backed forms — auto-validates from .proto annotations."
  fi

  # Typography nudge — raw h1-h6 and p tags
  if echo "$file_content" | grep -qE '<h[1-6][[:space:]>]|<p[[:space:]>]'; then
    guidance="$guidance Use Heading/Text components from registry instead of raw HTML headings/paragraphs."
  fi

  # Key-value pattern nudge
  if echo "$file_content" | grep -qiE 'key.*value.*pair|labels|tags|metadata.*form'; then
    guidance="$guidance Consider KeyValueField + BadgeGroup for key-value metadata editing."
  fi

  # Loading/empty state component nudges
  if echo "$file_content" | grep -qE 'Loading\.\.\.|loading\.\.\.|isLoading' && \
     ! echo "$file_content" | grep -qE 'Skeleton|Spinner'; then
    guidance="$guidance Use Skeleton or Spinner from registry for loading states."
  fi

  if echo "$file_content" | grep -qiE 'no data|no results|nothing.*found|empty.*state' && \
     ! echo "$file_content" | grep -qE 'Empty'; then
    guidance="$guidance Use Empty component from registry for empty states."
  fi

  # Toast/notification nudge
  if echo "$file_content" | grep -qE 'toast\(|notification\(|alert\(' && \
     ! echo "$file_content" | grep -qE 'sonner|Sonner'; then
    guidance="$guidance Use Sonner from registry for toast notifications."
  fi

  # JSON display nudge
  if echo "$file_content" | grep -qE 'JSON\.stringify.*<pre|<pre.*JSON|formatJSON' && \
     ! echo "$file_content" | grep -qE 'JSONViewer|JsonViewer'; then
    guidance="$guidance Use JSONViewer from registry instead of JSON.stringify + pre."
  fi

  # Code display nudge
  if echo "$file_content" | grep -qE '<pre><code|<pre.*className.*code|highlight\.js|prism' && \
     ! echo "$file_content" | grep -qE 'CodeBlock|CodeEditor|CodeTabs'; then
    guidance="$guidance Use CodeBlock from registry for code display."
  fi

  # Confirm dialog nudge
  if echo "$file_content" | grep -qE 'window\.confirm\(|confirm\(' && \
     ! echo "$file_content" | grep -qE 'AlertDialog'; then
    guidance="$guidance Use AlertDialog from registry instead of window.confirm()."
  fi

  # Copy button nudge
  if echo "$file_content" | grep -qE 'navigator\.clipboard|writeText\(|copyToClipboard' && \
     ! echo "$file_content" | grep -qE 'CopyButton'; then
    guidance="$guidance Use CopyButton from registry for copy-to-clipboard."
  fi

  # File upload nudge
  if echo "$file_content" | grep -qE 'type="file"|<input.*file|FileReader|ondrop.*file' && \
     ! echo "$file_content" | grep -qE 'Dropzone'; then
    guidance="$guidance Use Dropzone from registry for file uploads."
  fi

  # Status indicator nudge
  if echo "$file_content" | grep -qiE 'status.*dot|status.*badge|health.*indicator|state.*icon' && \
     ! echo "$file_content" | grep -qE 'StatusBadge|StatusDot'; then
    guidance="$guidance Use StatusBadge or StatusDot from registry for status indicators."
  fi

  # Stepper/wizard nudge
  if echo "$file_content" | grep -qiE 'step.*wizard|multi.?step|step.*form|currentStep|activeStep' && \
     ! echo "$file_content" | grep -qE 'Stepper'; then
    guidance="$guidance Use Stepper from registry for multi-step wizards."
  fi

  # UI Registry sync nudge — when editing a registry component, also update upstream
  if echo "$file_path" | grep -qE 'redpanda-ui/|components/redpanda-ui/'; then
    if [ -d "linked-repos/ui-registry" ]; then
      component_name=$(basename "$file_path" .tsx)
      guidance="$guidance [REGISTRY SYNC] You're editing a registry component. Also update the source in linked-repos/ui-registry/ to keep in sync, then open a PR against the ui-registry repo."
    fi
  fi
fi

# ── Output guidance (warn, not block) ───────────────────────────

if [ -n "$guidance" ]; then
  echo "{\"suppressOutput\":true,\"systemMessage\":\"$guidance\"}" >&2
fi

exit 0
