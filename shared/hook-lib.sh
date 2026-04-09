#!/bin/bash
# Shared library for Claude Code and Codex hook scripts.
# Source this at the top of PostToolUse and PreToolUse hooks.
# Works with both harnesses — auto-detects protocol differences.
#
# Usage in PostToolUse (Edit|Write) hooks:
#   source "$(dirname "$0")/../../shared/hook-lib.sh"
#   hook_parse_edit_write        # sets: file_path
#   hook_filter_extensions "ts|tsx|js|jsx"
#   hook_get_added_lines         # sets: added_lines
#   ... your checks ...
#   hook_block "Error message"
#
# Usage in PreToolUse (Bash) hooks:
#   source "$(dirname "$0")/../../shared/hook-lib.sh"
#   hook_parse_bash              # sets: command
#   ... your checks ...
#   hook_deny "Error message"
#
# Environment variables:
#   HOOKS_FAIL_CLOSED=1  — treat hook errors (exit 1) as blocks (exit 2)
#                          instead of silently passing. Catches misconfiguration.

# ── Fail-closed mode (inspired by Claude Code iron_gate_closed) ──

if [ "${HOOKS_FAIL_CLOSED:-}" = "1" ]; then
  trap '_fc_msg="Hook script error in $(basename "$0"). Check hook configuration (missing _hook-lib.sh? jq not installed?)."; echo "{\"suppressOutput\":true,\"systemMessage\":\"$_fc_msg\"}" >&2; exit 2' ERR
fi

# ── Session state directory ───────────────────────────────────────
# All session temp files in one directory for clean management.
# Cleanup happens in SessionStart (session-env.sh).
# Works with both Claude Code (CLAUDE_SESSION_ID env var) and
# Codex (session_id in stdin JSON, extracted after first parse).

_hook_session_id="${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}"
_hook_session_dir="/tmp/hook-session-${_hook_session_id}"
mkdir -p "$_hook_session_dir" 2>/dev/null || true

# Violation tracking
_hook_violations_file="$_hook_session_dir/violations"

_hook_track_violation() {
  local label="$1"
  echo "$label" >> "$_hook_violations_file" 2>/dev/null || true
}

# ── PostToolUse: Parse stdin, gate on Edit|Write, extract file_path ──

hook_parse_edit_write() {
  _hook_input=$(cat)
  _hook_tool_name=$(echo "$_hook_input" | jq -r '.tool_name // empty')

  if [ "$_hook_tool_name" != "Edit" ] && [ "$_hook_tool_name" != "Write" ]; then
    exit 0
  fi

  file_path=$(echo "$_hook_input" | jq -r '.tool_input.file_path // empty')

  if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
    exit 0
  fi

  # Track which files this session touches (for session-scoped Stop hooks)
  echo "$file_path" >> "$_hook_session_dir/session-touched-files" 2>/dev/null || true
}

# ── Filter by file extensions (pipe-separated, e.g. "ts|tsx|js|jsx") ──

hook_filter_extensions() {
  local exts="$1"
  local match=false
  local IFS='|'
  for ext in $exts; do
    case "$file_path" in
      *."$ext") match=true; break ;;
    esac
  done
  if [ "$match" = false ]; then
    exit 0
  fi
}

# ── Skip test files ──────────────────────────────────────────────

hook_skip_tests() {
  case "$file_path" in
    *.test.*|*.spec.*) exit 0 ;;
  esac
  if echo "$file_path" | grep -qE '/__tests__/'; then
    exit 0
  fi
}

# ── Skip auto-generated files ────────────────────────────────────

hook_skip_generated() {
  case "$file_path" in
    *.gen.ts|*.gen.tsx|*.gen.js) exit 0 ;;  # TanStack Router routeTree.gen.ts
    *_pb.ts|*_pb.js) exit 0 ;;              # Protobuf generated
    *_connectquery.ts) exit 0 ;;            # Connect Query generated
  esac
  # Skip files with @generated marker
  if head -5 "$file_path" 2>/dev/null | grep -qE '(@generated|auto-generated|DO NOT EDIT)'; then
    exit 0
  fi
}

# ── Skip component library directories (auto-detect + UI_LIB_DIRS) ──

hook_skip_ui_dirs() {
  if [ -z "${UI_LIB_DIRS:-}" ]; then
    _ui_dirs="components/ui"
    _root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    [ -d "$_root/redpanda-ui" ] && _ui_dirs="$_ui_dirs|redpanda-ui"
    [ -d "$_root/src/ui" ] && _ui_dirs="$_ui_dirs|src/ui"
    [ -d "$_root/packages/ui" ] && _ui_dirs="$_ui_dirs|packages/ui"
  else
    _ui_dirs="$UI_LIB_DIRS"
  fi
  if echo "$file_path" | grep -qE "/($_ui_dirs)/"; then
    _repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    if [ -f "$_repo_root/registry.json" ]; then
      # Registry repo — remind to rebuild registry
      echo '{"suppressOutput":true,"systemMessage":"You are editing a UI registry component. Remember to rebuild registry.json and update CHANGELOG.md when done."}' >&2
    elif [ -f "$_repo_root/components.json" ] || [ -f "$_repo_root/cli.json" ]; then
      # Consumer repo — warn that this is a registry-sourced component
      _component=$(basename "$file_path")
      echo "{\"suppressOutput\":true,\"systemMessage\":\"WARNING: You are modifying '$_component' which comes from the UI registry. Local changes will be overwritten on next registry pull. If this change is intentional, submit a PR upstream to the UI registry repo instead.\"}" >&2
    fi
    exit 0
  fi
}

# ── Get added lines from git diff (sets global: added_lines) ────

hook_get_added_lines() {
  local diff_output=""
  diff_output=$(git diff HEAD -- "$file_path" 2>/dev/null) || true

  if [ -z "$diff_output" ]; then
    added_lines=$(cat "$file_path")
  else
    added_lines=$(echo "$diff_output" | grep '^+' | grep -v '^+++' || true)
  fi

  if [ -z "$added_lines" ]; then
    exit 0
  fi
}

# ── Session-scoped changed files (for Stop hooks) ────────────────
# Returns files that: (a) are in current git diff, (b) were touched
# by this session via Edit/Write, and (c) were NOT dirty at session
# start. Falls back to full git diff if tracking data unavailable.
#
# Usage in Stop hooks:
#   source "path/to/hook-lib.sh"
#   session_changed=$(hook_session_changed_files "ts|tsx|js|jsx")
#   if hook_has_session_tracking; then ... fi

hook_session_changed_files() {
  local ext_filter="${1:-}"

  # Get current git diff
  local current_diff
  current_diff=$(git diff --name-only HEAD 2>/dev/null || true)

  if [ -z "$current_diff" ]; then
    return
  fi

  # Apply extension filter if provided
  if [ -n "$ext_filter" ]; then
    current_diff=$(echo "$current_diff" | grep -E "\\.(${ext_filter})$" || true)
  fi

  if [ -z "$current_diff" ]; then
    return
  fi

  local touched_file="$_hook_session_dir/session-touched-files"
  local baseline_file="$_hook_session_dir/dirty-files-baseline"

  # Mode 1: Both touched-files and baseline exist (Claude Code normal)
  # Formula: (current_diff ∩ touched) - baseline
  if [ -f "$touched_file" ]; then
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    local touched_normalized
    touched_normalized=$(sed "s|^${repo_root}/||" "$touched_file" | sort -u)

    local intersected
    intersected=$(comm -12 <(echo "$current_diff" | sort) <(echo "$touched_normalized") 2>/dev/null || true)

    if [ -f "$baseline_file" ] && [ -s "$baseline_file" ]; then
      intersected=$(comm -23 <(echo "$intersected" | sort) <(sort "$baseline_file") 2>/dev/null || echo "$intersected")
    fi

    echo "$intersected"
    return
  fi

  # Mode 2: Only baseline exists (Codex, or Bash-only session)
  # Formula: current_diff - baseline
  if [ -f "$baseline_file" ] && [ -s "$baseline_file" ]; then
    comm -23 <(echo "$current_diff" | sort) <(sort "$baseline_file") 2>/dev/null || echo "$current_diff"
    return
  fi

  # Mode 3: No tracking data (legacy) — return full diff
  echo "$current_diff"
}

# Check if session tracking data exists (safe to call outside subshell)
hook_has_session_tracking() {
  [ -f "$_hook_session_dir/session-touched-files" ] || [ -f "$_hook_session_dir/dirty-files-baseline" ]
}

# ── Filter error output to session-owned files ───────────────────
# For project-wide tools (tsgo, doctor) that cannot target files,
# filters error lines to only those mentioning session-owned files.

hook_filter_errors_to_session() {
  local output="$1"
  local session_files="$2"

  if [ -z "$session_files" ] || [ -z "$output" ]; then
    return
  fi

  # Build grep pattern from file list
  local pattern
  pattern=$(echo "$session_files" | sed 's/[.[\*^$()+?{|]/\\&/g' | paste -sd '|' -)

  echo "$output" | grep -E "$pattern" || true
}

# ── HOOK_VERBOSITY ────────────────────────────────────────────────
# Controls hook output level:
#   normal (default) — all blocks and warns emitted
#   terse            — blocks only, warns suppressed
#   quiet            — all output suppressed (violations still tracked)

_hook_verbosity="${HOOK_VERBOSITY:-normal}"

# ── PostToolUse: Block with systemMessage (exit 2) ──────────────

hook_block() {
  local msg="$1"
  local label="${2:-$(basename "$0" .sh)}"
  _hook_track_violation "$label"
  if [ "$_hook_verbosity" != "quiet" ]; then
    echo "{\"suppressOutput\":true,\"systemMessage\":\"$msg\"}" >&2
  fi
  exit 2
}

# ── PostToolUse: Warn with systemMessage (exit 0) ───────────────

hook_warn() {
  local msg="$1"
  local label="${2:-$(basename "$0" .sh)}"
  _hook_track_violation "$label"
  if [ "$_hook_verbosity" = "normal" ]; then
    echo "{\"suppressOutput\":true,\"systemMessage\":\"$msg\"}" >&2
  fi
  exit 0
}

# ── PreToolUse (Bash): Parse stdin, extract command ──────────────

hook_parse_bash() {
  _hook_input=$(cat)
  _hook_tool_name=$(echo "$_hook_input" | jq -r '.tool_name // empty')

  if [ "$_hook_tool_name" != "Bash" ]; then
    exit 0
  fi

  command=$(echo "$_hook_input" | jq -r '.tool_input.command // empty')

  if [ -z "$command" ]; then
    exit 0
  fi
}

# ── PreToolUse: Deny with permissionDecision (exit 2) ────────────

hook_deny() {
  local msg="$1"
  local label="${2:-$(basename "$0" .sh)}"
  _hook_track_violation "$label"
  echo "{\"hookSpecificOutput\":{\"permissionDecision\":\"deny\"},\"systemMessage\":\"$msg\"}" >&2
  exit 2
}

# ── Stop hook: Block with decision (exit 2) ──────────────────────

hook_stop_block() {
  local msg="$1"
  echo "{\"decision\":\"block\",\"reason\":\"$msg\"}" >&2
  exit 2
}
