#!/bin/bash
set -eo pipefail

# Stop hook: inspect session-classified security files and enforce findings.
#
# Set ORCHESTRATION_STRICT=0 to disable blocking (e.g., during prototyping).
# Default: on.

if [ "${ORCHESTRATION_STRICT:-1}" = "0" ]; then
  exit 0
fi

# Source hook-lib for session-scoped file tracking (before deriving the
# session dir, so the lib's worktree-hashed fallback wins over a bare $$)
source "$(dirname "$0")/source-hook-lib.sh" 2>/dev/null || true
# Codex passes session_id on stdin; adopt it so this reader sees the same
# dir the per-edit producers wrote to (no-op under Claude Code env ids).
type hook_adopt_stdin_session &>/dev/null && hook_adopt_stdin_session


session_files="${_hook_session_dir:-/tmp/hook-session-${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}}/files"

# Session-scoped: only check files this session touched
if type hook_session_changed_files &>/dev/null; then
  changed=$(hook_session_changed_files)
else
  changed=$(git diff --name-only HEAD 2>/dev/null || true)
fi
issues=""

# Pre-flight checks
if ! git rev-parse --is-inside-work-tree &>/dev/null; then exit 0; fi
if [ -z "$changed" ] && [ ! -f "$session_files" ]; then
  exit 0
fi

# ── Security-sensitive files → extra scrutiny ──────────────────

if [ -f "$session_files" ] && grep -q "^security:" "$session_files" 2>/dev/null; then
  security_files=$(grep "^security:" "$session_files" | cut -d: -f2- | sort -u)
  for f in $security_files; do
    if [ -f "$f" ]; then
      # eval/new Function/innerHTML/dangerouslySetInnerHTML are owned by
      # react-rules-check.lib.sh at edit time — no Stop-time re-scan.
      if grep -qE "(password|secret|api.?key)\s*[:=]\s*['\"][^'\"]{3,}" "$f" 2>/dev/null; then
        short_name=$(basename "$f")
        issues="$issues\n- SECURITY: $short_name — hardcoded secrets. @/env."
      fi
    fi
  done
fi

# ── Decision ─────────────────────────────────────────────────────

# Security issues write to shared findings.
if [ -n "$issues" ]; then
  hook_stop_finding "$(printf "Orchestration:%b" "$issues")"
fi

# Clean up session tracking
rm -f "$session_files" 2>/dev/null || true

exit 0
