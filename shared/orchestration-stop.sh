#!/bin/bash
set -eo pipefail

# Stop hook: comprehensive quality gate. Reads file categories tracked by
# orchestration-guidance.sh and runs targeted checks. Blocks until truly done.
#
# Set ORCHESTRATION_STRICT=0 to disable blocking (e.g., during prototyping).
# Default: on (blocks on missing tests, security issues, async leaks).

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
if [ ! -d ".git" ]; then exit 0; fi
if [ -z "$changed" ] && [ ! -f "$session_files" ]; then
  exit 0
fi

# Gate 1 (async leaks) is owned by test-perf-stop.sh; Gate 1b (related
# tests) is owned by typecheck-stop.sh. One Stop-time owner per rule —
# concurrent Stop hooks double-running vitest was pure waste (issue #54).

# ── Gate 2: JSX/TSX source changed → verify co-located test ─────

if [ -f "$session_files" ] && grep -q "^jsx:" "$session_files" 2>/dev/null; then
  jsx_files=$(grep "^jsx:" "$session_files" | cut -d: -f2- | sort -u)
  for f in $jsx_files; do
    # Skip files that don't need tests
    if echo "$f" | grep -qE '(index\.|layout\.|middleware\.|types/|\.d\.ts|__root|\.gen\.|providers?\.|constants?\.|theme\.|context\.|config\.)'; then
      continue
    fi
    base="${f%.*}"
    has_test=false
    for suffix in test.tsx test.ts integration.tsx unit.ts spec.ts; do
      if [ -f "${base}.${suffix}" ]; then
        has_test=true
        break
      fi
    done
    if [ "$has_test" = false ]; then
      short_name=$(basename "$f")
      issues="$issues\n- NO TEST: $short_name. Run /tdd and add a sibling test before finishing."
    fi
  done
fi

# ── Gate 3: New source files → verify they have tests ────────────

# Session-scoped: only consider new files this session created
_all_new=$(git diff --name-only --diff-filter=A HEAD 2>/dev/null | grep -E '\.(ts|tsx)$' | grep -vE '(\.test\.|\.spec\.|\.unit\.|\.integration\.|\.d\.ts$|\.gen\.|index\.|layout\.|middleware\.|types/|__root)' || true)
if hook_has_session_tracking 2>/dev/null && [ -n "$_all_new" ]; then
  # Intersect new files with session-touched files
  _touched="$_hook_session_dir/session-touched-files"
  if [ -f "$_touched" ]; then
    _repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    # Defense-in-depth: skip secondary-worktree paths before normalizing.
    # _hook-lib.sh filters at write time; guard here for stale entries.
    _touched_norm=$(
      while IFS= read -r _p; do
        [ -z "$_p" ] && continue
        if type _hook_in_secondary_worktree &>/dev/null && _hook_in_secondary_worktree "$_p"; then
          continue
        fi
        echo "${_p#"${_repo_root}"/}"
      done < "$_touched" | sort -u
    )
    new_files=$(comm -12 <(echo "$_all_new" | sort) <(echo "$_touched_norm") 2>/dev/null || echo "$_all_new")
  else
    new_files="$_all_new"
  fi
else
  new_files="$_all_new"
fi
if [ -n "$new_files" ]; then
  for f in $new_files; do
    base="${f%.*}"
    has_test=false
    for suffix in test.tsx test.ts integration.tsx unit.ts spec.ts; do
      if [ -f "${base}.${suffix}" ] || echo "$changed" | grep -q "${base}.${suffix}"; then
        has_test=true
        break
      fi
    done
    if [ "$has_test" = false ]; then
      short_name=$(basename "$f")
      issues="$issues\n- NEW SOURCE WITHOUT TEST: $short_name. Run /tdd and add a sibling test before finishing."
    fi
  done
fi

# ── Gate 4: Security-sensitive files → extra scrutiny ────────────

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

# Check if source changed but no test files were touched
# Use tr -d to strip newlines — grep -c can embed \n when $changed has trailing blank lines
changed_source_count=$(echo "$changed" | grep -E '\.(ts|tsx)$' | grep -vcE '(\.test\.|\.spec\.)' 2>/dev/null | tr -d '[:space:]')
changed_source_count="${changed_source_count:-0}"
changed_test_count=$(echo "$changed" | grep -cE '\.(test|spec)\.(ts|tsx)$' 2>/dev/null | tr -d '[:space:]')
changed_test_count="${changed_test_count:-0}"
if [ "$changed_source_count" -gt 0 ] 2>/dev/null && [ "$changed_test_count" -eq 0 ] 2>/dev/null; then
  issues="$issues\n- SOURCE CHANGED WITHOUT TEST CHANGE. Run /tdd; add or update behavior tests before finishing."
fi

# Hard issues (async leaks, security, failing tests, missing tests) → write to shared findings
if [ -n "$issues" ]; then
  hook_stop_finding "$(printf "Orchestration:%b" "$issues")"
fi

# Clean up session tracking
rm -f "$session_files" 2>/dev/null || true

exit 0
