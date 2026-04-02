#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

# PostToolUse hook: inject file-aware guidance on Edit/Write and track
# file categories for the orchestration-stop.sh quality gate.
# Target: <10ms (file path matching + 1 line append).

hook_parse_edit_write
hook_filter_extensions "ts|tsx|js|jsx"
hook_skip_generated

guidance=""
session_files="/tmp/claude-session-files-${CLAUDE_SESSION_ID:-$$}"

# ── Test file written ────────────────────────────────────────────

case "$file_path" in
  *.test.tsx|*.test.ts|*.integration.tsx|*.integration.ts|*.unit.ts)
    echo "test:$file_path" >> "$session_files" 2>/dev/null || true
    guidance="[TEST] Use userEvent.setup() (not fireEvent). Prefer getByRole for a11y, getByTestId for presence in large DOMs. Check for async leaks: no dangling timers or unresolved promises. Wrap async: await waitFor(() => expect(...))."
    ;;
esac

# ── E2E spec written ─────────────────────────────────────────────

if echo "$file_path" | grep -qE 'e2e/.*\.spec\.ts$'; then
  echo "spec:$file_path" >> "$session_files" 2>/dev/null || true
  guidance="[E2E] Import { test, expect } from ./fixtures/base (includes axe-core). Add axe audit on page navigations. Use data-testid for selectors. Avoid page.waitForTimeout — use assertion-based waits."
fi

# ── New component created (TSX in components dir, Write tool) ────

if [ -z "$guidance" ]; then
  case "$file_path" in
    */components/*.tsx|*/components/*.jsx)
      echo "component:$file_path" >> "$session_files" 2>/dev/null || true
      guidance="[COMPONENT] Checklist: design system components (not raw HTML), keyboard navigable, aria-label on icon buttons, co-located test file."
      ;;
  esac
fi

# ── Route file written ──────────────────────────────────────────

if [ -z "$guidance" ]; then
  if echo "$file_path" | grep -qE '/routes/.*\.tsx$'; then
    echo "route:$file_path" >> "$session_files" 2>/dev/null || true
    guidance="[ROUTE] Only export Route config from route files (other exports break code splitting). Use validateSearch with zod for search params. Use Route.useParams()/Route.useSearch()."
  fi
fi

# ── Store file written ──────────────────────────────────────────

if [ -z "$guidance" ]; then
  if echo "$file_path" | grep -qiE 'store'; then
    echo "store:$file_path" >> "$session_files" 2>/dev/null || true
    guidance="[STORE] Use create<T>()() double-parens. useShallow for multi-field selectors. persist middleware (not raw localStorage)."
  fi
fi

# ── Security-sensitive file ─────────────────────────────────────

if echo "$file_path" | grep -qiE 'auth|token|secret|password|credential|session|crypto'; then
  echo "security:$file_path" >> "$session_files" 2>/dev/null || true
  if [ -z "$guidance" ]; then
    guidance="[SECURITY] No secrets in source code (use @/env). No eval/innerHTML/dangerouslySetInnerHTML. Validate all user inputs. Prefer HttpOnly cookies over localStorage for tokens."
  fi
fi

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
        guidance="$guidance Avoid setTimeout/waitForTimeout in tests — causes flaky results. Use condition-based waiting: await waitFor(() => expect(...).toBeVisible())."
      fi
    fi
    ;;
esac

# ── Redpanda registry nudges (only if REDPANDA_KIT=1) ───────────

if [ "${REDPANDA_KIT:-}" = "1" ] && [ -f "$file_path" ]; then
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
fi

# ── Output guidance (warn, not block) ───────────────────────────

if [ -n "$guidance" ]; then
  echo "{\"suppressOutput\":true,\"systemMessage\":\"$guidance\"}" >&2
fi

exit 0
