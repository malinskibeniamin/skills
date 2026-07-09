#!/bin/bash
# Extracted check logic for orchestration-guidance.sh. Source ../_hook-lib.sh before this file.

run_orchestration_guidance() {
# PostToolUse hook: track edited-file categories for the
# orchestration-stop.sh quality gate. Tracking only.
#
# Policy (2026-07 audit): the per-category guidance strings and
# REDPANDA_KIT registry nudges that used to live here were removed —
# they restated CLAUDE.md rules and duplicated error-boundary-check,
# unhappy-path-check, test-convention-check, file-changed-deps, and
# registry-check. One rule, one enforcement point.
# Target: <10ms (path matching + 1 line append).


_session_dir="/tmp/hook-session-${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}"
mkdir -p "$_session_dir" 2>/dev/null || true
session_files="$_session_dir/files"

hook_filter_extensions "ts|tsx" || return 0
hook_skip_generated || return 0

# ── Category tracking (consumed by orchestration-stop.sh) ────────

case "$file_path" in
  *.test.tsx|*.test.ts|*.integration.tsx|*.integration.ts|*.unit.ts)
    echo "test:$file_path" >> "$session_files" 2>/dev/null || true
    ;;
esac

if echo "$file_path" | grep -qE 'e2e/.*\.spec\.ts$'; then
  echo "spec:$file_path" >> "$session_files" 2>/dev/null || true
fi

case "$file_path" in
  */components/*.tsx|*/components/*.jsx)
    echo "component:$file_path" >> "$session_files" 2>/dev/null || true
    ;;
esac

if echo "$file_path" | grep -qE '/routes/.*\.tsx$'; then
  echo "route:$file_path" >> "$session_files" 2>/dev/null || true
fi

# Match store files precisely: /stores/ dir, *Store.ts, *-store.ts — not "restore", "StoreLocator"
if echo "$file_path" | grep -qE '/stores/|Store\.(ts|tsx)$|-store\.(ts|tsx)$'; then
  echo "store:$file_path" >> "$session_files" 2>/dev/null || true
fi

# Track all JSX/TSX source files for co-located test check
case "$file_path" in
  *.tsx|*.jsx)
    if ! echo "$file_path" | grep -qE '(\.test\.|\.spec\.|\.unit\.|\.integration\.)'; then
      echo "jsx:$file_path" >> "$session_files" 2>/dev/null || true
    fi
    ;;
esac

return 0
}
