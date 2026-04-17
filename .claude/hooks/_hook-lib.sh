#!/bin/bash
# Shared library for Claude Code and Codex hook scripts.
# Source this at the top of PostToolUse and PreToolUse hooks.
# Works with both harnesses — auto-detects protocol differences.
#
# Usage in PostToolUse (Edit|Write) hooks:
#   source "$(dirname "$0")/../../shared/hook-lib.sh"
#   hook_parse_edit_write        # sets: file_path
#   hook_filter_extensions "ts|tsx"
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

# ── Debug mode ───────────────────────────────────────────────────
# Set HOOK_DEBUG=1 to log every decision point to session temp dir.
# Useful for diagnosing hook misfires.
#   tail -f /tmp/hook-session-*/debug.log

_hook_debug_enabled="${HOOK_DEBUG:-}"

_hook_debug() {
  if [ -n "$_hook_debug_enabled" ]; then
    echo "[$(date +%H:%M:%S)] $(basename "$0"): $*" >> "$_hook_session_dir/debug.log" 2>/dev/null || true
  fi
}

# ── Default ERR trap: crash → exit 0, never non-zero without stderr ──
# Hooks must either block cleanly (exit 2 + JSON stderr) or pass (exit 0).
# An unhandled error must NOT produce a mysterious non-zero exit.
# HOOKS_FAIL_CLOSED=1 overrides: crashes become blocks instead of silent passes.

if [ "${HOOKS_FAIL_CLOSED:-}" = "1" ]; then
  trap '_fc_msg="Hook script error in $(basename "$0"). Check hook configuration (missing _hook-lib.sh? jq not installed?)."; echo "{\"suppressOutput\":true,\"systemMessage\":\"$_fc_msg\"}" >&2; exit 2' ERR
else
  trap '_hook_debug "ERR trap fired (line $LINENO, exit $?) — exiting 0 to avoid crash"; exit 0' ERR
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

# ── Structured session log (JSONL) ──────────────────────────────
# Append one JSON line per hook decision. Used by metrics-summary-stop.sh
# and /frontend-skills-stats (alias /hook-audit). Fails silently — never blocks.
_hook_log_file="$_hook_session_dir/structured.jsonl"

# ── Timing capture (portable, zero-fork) ────────────────────────
# Millisecond timing without external calls. Each hook gets start stamp,
# _hook_log_entry emits elapsed ms. Fast on bash 5+, falls back to
# second-resolution on bash 3/4 (macOS default).
#
#   Linux/Homebrew-bash (5+):  EPOCHREALTIME builtin, sub-ms precision
#   macOS default (bash 3.2):  integer seconds via SECONDS var
#   No-fork policy:            never call date/perl/python during hook
#
# Acceptable imprecision: macOS shows 0ms or 1000ms jumps; use sparingly
# in analytics. Upgrade to bash 5 (brew install bash) for precise ms.

SECONDS=0
_hook_time_precision="s"
_hook_start_ms=0
if [ -n "${EPOCHREALTIME:-}" ]; then
  # bash 5+: "1712345678.123456" → 1712345678123 (drop last 3 = μs)
  _hook_start_ms="${EPOCHREALTIME//./}"
  _hook_start_ms="${_hook_start_ms%???}"
  _hook_time_precision="ms"
fi

_hook_elapsed_ms() {
  if [ "$_hook_time_precision" = "ms" ]; then
    local _now="${EPOCHREALTIME//./}"
    _now="${_now%???}"
    echo $((_now - _hook_start_ms))
  else
    # bash 3/4: SECONDS is integer seconds since script start
    echo $((SECONDS * 1000))
  fi
}

_hook_log_entry() {
  local decision="$1" rule="$2" hook="${3:-$(basename "$0" .sh)}"
  local target="${file_path:-}"
  local ms
  ms=$(_hook_elapsed_ms)
  # Strip repo root for privacy — store relative path only
  if [ -n "$target" ]; then
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    target="${target#"$root"/}"
  fi
  printf '{"ts":%d,"ms":%d,"hook":"%s","rule":"%s","decision":"%s","file":"%s"}\n' \
    "$(date +%s)" "$ms" "$hook" "$rule" "$decision" "$target" \
    >> "$_hook_log_file" 2>/dev/null || true
}

# ── Safe JSON string escape ──────────────────────────────────────
# Escapes text for embedding in JSON strings. Uses jq if available,
# falls back to sed. Never fails — returns escaped string or empty.
# Usage: escaped=$(_safe_json_escape "text with \"quotes\" and\nnewlines")

_safe_json_escape() {
  local input="$1"
  # Try jq first (produces a quoted JSON string like "foo\nbar")
  if command -v jq &>/dev/null; then
    printf '%s' "$input" | jq -Rs . 2>/dev/null && return 0
  fi
  # Fallback: manual escape with sed + awk (covers critical chars + newlines)
  # Works on macOS sed (BSD), GNU sed, and Git Bash/WSL
  local escaped
  escaped=$(printf '%s' "$input" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/\\t/g' -e $'s/\r/\\\\r/g' | awk '{if(NR>1) printf "\\n"; printf "%s",$0}')
  printf '"%s"' "$escaped"
}

# ── Secondary-worktree detection ─────────────────────────────────
# Returns 0 (true) if $1 lives inside a secondary git worktree — i.e.,
# the worktree's --git-dir (e.g. .git/worktrees/<name>) differs from the
# shared --git-common-dir (main .git). Returns 1 otherwise (primary
# worktree, non-git path, or git unavailable).
#
# Why: subagents spawned via `Agent(isolation: "worktree")` inherit the
# parent's CLAUDE_SESSION_ID, so their PostToolUse hooks write to the
# parent's session_dir. Without this check, subagent file writes land
# in the parent's session-touched-files and trip lifecycle-stop hooks.
_hook_in_secondary_worktree() {
  local f="$1" dir gd gc
  dir=$(dirname "$f" 2>/dev/null) || return 1
  [ -d "$dir" ] || return 1
  gd=$(git -C "$dir" rev-parse --git-dir 2>/dev/null) || return 1
  gc=$(git -C "$dir" rev-parse --git-common-dir 2>/dev/null) || return 1
  gd=$(cd "$dir" 2>/dev/null && cd "$gd" 2>/dev/null && pwd -P 2>/dev/null) || return 1
  gc=$(cd "$dir" 2>/dev/null && cd "$gc" 2>/dev/null && pwd -P 2>/dev/null) || return 1
  [ -n "$gd" ] && [ -n "$gc" ] && [ "$gd" != "$gc" ]
}

# ── PostToolUse: Parse stdin, gate on Edit|Write, extract file_path ──

hook_parse_edit_write() {
  _hook_input=$(cat)
  _hook_tool_name=$(echo "$_hook_input" | jq -r '.tool_name // empty' 2>/dev/null || true)

  if [ "$_hook_tool_name" != "Edit" ] && [ "$_hook_tool_name" != "Write" ]; then
    exit 0
  fi

  file_path=$(echo "$_hook_input" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)

  if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
    _hook_debug "skip: file_path empty or missing ($file_path)"
    exit 0
  fi

  _hook_debug "parse: $file_path"

  # Track which files this session touches (for session-scoped Stop hooks).
  # Skip files in secondary worktrees — they belong to a subagent scope,
  # not the main session. Otherwise the main Stop hook sees phantom writes.
  if _hook_in_secondary_worktree "$file_path"; then
    _hook_debug "skip session-touched-files: secondary worktree ($file_path)"
  else
    echo "$file_path" >> "$_hook_session_dir/session-touched-files" 2>/dev/null || true
  fi
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
    _hook_debug "skip: extension mismatch (wanted $exts, got ${file_path##*.})"
    exit 0
  fi
}

# ── Skip test files ──────────────────────────────────────────────

hook_skip_tests() {
  case "$file_path" in
    *.test.*|*.spec.*) _hook_debug "skip: test file"; exit 0 ;;
  esac
  if echo "$file_path" | grep -qE '/__tests__/'; then
    _hook_debug "skip: __tests__ directory"
    exit 0
  fi
}

# ── Skip auto-generated files ────────────────────────────────────

hook_skip_generated() {
  case "$file_path" in
    *.gen.ts|*.gen.tsx|*.gen.js) _hook_debug "skip: generated (.gen)"; exit 0 ;;
    *_pb.ts|*_pb.js) _hook_debug "skip: generated (_pb)"; exit 0 ;;
    *_connectquery.ts) _hook_debug "skip: generated (_connectquery)"; exit 0 ;;
  esac
  # Skip files with @generated marker
  if head -5 "$file_path" 2>/dev/null | grep -qE '(@generated|auto-generated|DO NOT EDIT)'; then
    _hook_debug "skip: generated (@generated marker)"
    exit 0
  fi
}

# ── Skip component library directories (auto-detect + UI_LIB_DIRS) ──

hook_skip_ui_dirs() {
  if [ -z "${UI_LIB_DIRS:-}" ]; then
    _ui_dirs="components/ui"
    _root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    [ -d "$_root/redpanda-ui" ] && _ui_dirs="$_ui_dirs|redpanda-ui"
    [ -d "$_root/src/components/redpanda-ui" ] && _ui_dirs="$_ui_dirs|redpanda-ui"
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
    repo_root=$(cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" && pwd -P)
    local touched_normalized
    # Resolve symlinks (macOS /var → /private/var) then strip repo root
    touched_normalized=$(while IFS= read -r f; do
      _real=$(cd "$(dirname "$f")" 2>/dev/null && echo "$(pwd -P)/$(basename "$f")" || echo "$f")
      echo "${_real#"$repo_root"/}"
    done < "$touched_file" | sort -u)

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

# ── Escape hatch: unified // allow: rule-name ────────────────────
# Checks for both new format: // allow: rule-name [reason]
# and legacy format: // allow-rule-name: [reason]
# Usage:  hook_has_escape "useEffect" && exit 0

hook_has_escape() {
  local rule="$1"
  local target="${2:-$file_path}"
  [ -f "$target" ] || return 1
  # New unified format: // allow: rule-name
  if grep -qE "//\s*allow:\s*$rule\b" "$target" 2>/dev/null; then
    _hook_debug "escape hatch found: allow: $rule"
    return 0
  fi
  # Legacy format: // allow-rule-name:
  if grep -qE "//\s*allow-$rule:" "$target" 2>/dev/null; then
    _hook_debug "escape hatch found (legacy): allow-$rule"
    return 0
  fi
  return 1
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
  _hook_debug "BLOCK [$label]: $msg"
  _hook_track_violation "$label"
  _hook_log_entry "block" "$label"
  if [ "$_hook_verbosity" != "quiet" ]; then
    echo "{\"suppressOutput\":true,\"systemMessage\":\"$msg\"}" >&2
  fi
  exit 2
}

# ── PostToolUse: Warn with systemMessage (exit 0) ───────────────

hook_warn() {
  local msg="$1"
  local label="${2:-$(basename "$0" .sh)}"
  _hook_debug "WARN [$label]: $msg"
  _hook_track_violation "$label"
  _hook_log_entry "warn" "$label"
  if [ "$_hook_verbosity" = "normal" ]; then
    echo "{\"suppressOutput\":true,\"systemMessage\":\"$msg\"}" >&2
  fi
  exit 0
}

# ── PostToolUse: Silent info (JSONL only, no UI) ────────────────
# Logged for analytics but not shown to Claude. Use for telemetry-style
# signals (pattern seen, suggestion noted) where no action is required.
hook_info() {
  local label="${1:-$(basename "$0" .sh)}"
  _hook_debug "INFO [$label]"
  _hook_log_entry "info" "$label"
  exit 0
}

# ── PostToolUse: Nudge (contextual hint, suppressed under terse) ─
# Softer than warn. Used when a pattern MAY be suboptimal but context
# determines correctness. Output-style: brief, no remediation required.
hook_nudge() {
  local msg="$1"
  local label="${2:-$(basename "$0" .sh)}"
  _hook_debug "NUDGE [$label]: $msg"
  _hook_track_violation "$label"
  _hook_log_entry "nudge" "$label"
  if [ "$_hook_verbosity" = "normal" ]; then
    echo "{\"suppressOutput\":true,\"systemMessage\":\"[nudge] $msg\"}" >&2
  fi
  exit 0
}

# ── PostToolUse: Block-strict (requires escape-hatch justification) ─
# Harder than block. Even with escape marker, still logged + requires
# reason comment on same line. Use for security-critical rules.
hook_block_strict() {
  local msg="$1"
  local label="${2:-$(basename "$0" .sh)}"
  _hook_debug "BLOCK-STRICT [$label]: $msg"
  _hook_track_violation "$label"
  _hook_log_entry "block-strict" "$label"
  echo "{\"suppressOutput\":true,\"systemMessage\":\"[STRICT] $msg — no escape hatch for this rule.\"}" >&2
  exit 2
}

# ── LSP-style structured diagnostic (opt-in) ────────────────────
# Emits machine-parseable diagnostic with range + fix. Claude can apply
# fixes without re-running grep. Hooks opt in by calling hook_emit_diagnostic
# instead of hook_block/hook_warn. Falls back to prose if caller skips.
#
# Usage:
#   hook_emit_diagnostic \
#     --severity error \
#     --range "$line:$col-$endline:$endcol" \
#     --rule "no-as-any" \
#     --msg "Replace 'as any' with proper type" \
#     --fix-replace "as FooType"
hook_emit_diagnostic() {
  local severity="" range="" rule="" msg="" fix_replace=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --severity) severity="$2"; shift 2 ;;
      --range) range="$2"; shift 2 ;;
      --rule) rule="$2"; shift 2 ;;
      --msg) msg="$2"; shift 2 ;;
      --fix-replace) fix_replace="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  _hook_track_violation "$rule"
  _hook_log_entry "diagnostic" "$rule"

  local fix_json=""
  if [ -n "$fix_replace" ]; then
    local escaped
    escaped=$(_safe_json_escape "$fix_replace")
    fix_json=",\"fix\":{\"replace\":$escaped}"
  fi

  local msg_json
  msg_json=$(_safe_json_escape "$msg")

  echo "{\"suppressOutput\":true,\"systemMessage\":\"[$severity:$rule] $msg — range:$range\",\"hookSpecificOutput\":{\"diagnostic\":{\"severity\":\"$severity\",\"range\":\"$range\",\"rule\":\"$rule\",\"msg\":$msg_json$fix_json}}}" >&2

  [ "$severity" = "error" ] && exit 2
  exit 0
}

# ── PreToolUse (Bash): Parse stdin, extract command ──────────────

hook_parse_bash() {
  _hook_input=$(cat)
  _hook_tool_name=$(echo "$_hook_input" | jq -r '.tool_name // empty' 2>/dev/null || true)

  if [ "$_hook_tool_name" != "Bash" ]; then
    exit 0
  fi

  command=$(echo "$_hook_input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)

  if [ -z "$command" ]; then
    exit 0
  fi
}

# ── PreToolUse: Deny with permissionDecision (exit 2) ────────────

hook_deny() {
  local msg="$1"
  local label="${2:-$(basename "$0" .sh)}"
  _hook_debug "DENY [$label]: $msg"
  _hook_track_violation "$label"
  _hook_log_entry "deny" "$label"
  echo "{\"hookSpecificOutput\":{\"permissionDecision\":\"deny\"},\"systemMessage\":\"$msg\"}" >&2
  exit 2
}

# ── Stop hook: Block with decision (exit 2) ──────────────────────

hook_stop_block() {
  local msg="$1"
  local reason
  reason=$(_safe_json_escape "$msg")
  echo "{\"decision\":\"block\",\"reason\":$reason}" >&2
  exit 2
}

# ── Stop hook: Append finding to shared file (no block) ──────────
# Quality-gate pattern: each Stop hook reports findings, then
# quality-gate-stop.sh aggregates and blocks ONCE with all issues.
# This avoids serial blocking where each hook blocks independently.

hook_stop_finding() {
  local msg="$1"
  # Delimiter separates findings so quality-gate-stop.sh can count issues (not lines)
  printf '%s\n---\n' "$msg" >> "$_hook_session_dir/stop-findings" 2>/dev/null || true
}

# ── Stop hook: Save test results for sharing across hooks ────────
# typecheck-stop.sh saves vitest output here so orchestration-stop
# and test-perf-stop can read it instead of re-running vitest.

hook_stop_save_test_results() {
  local status="$1"  # PASS or FAIL
  local output="$2"  # full vitest output (optional)
  echo "$status" > "$_hook_session_dir/shared-test-status" 2>/dev/null || true
  if [ -n "$output" ]; then
    echo "$output" > "$_hook_session_dir/shared-test-output" 2>/dev/null || true
  fi
}

hook_stop_get_test_status() {
  cat "$_hook_session_dir/shared-test-status" 2>/dev/null || echo ""
}
