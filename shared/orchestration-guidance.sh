#!/bin/bash
set -euo pipefail
_lib="$(dirname "$0")/_hook-lib.sh"; if [ -f "$_lib" ]; then source "$_lib"; else _m="${TMPDIR:-/tmp}/frontend-skills-broken.${CLAUDE_SESSION_ID:-fs}"; [ -f "$_m" ] || { echo "[frontend-skills] _hook-lib.sh unavailable - run: /plugin install frontend-skills --force" >&2; touch "$_m" 2>/dev/null; }; exit 0; fi

# PostToolUse hook: mark security-sensitive files for orchestration-stop.sh.
# Target: <10ms (path matching + 1 line append).

hook_parse_edit_write

_session_dir="${_hook_session_dir:-/tmp/hook-session-${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}}"
mkdir -p "$_session_dir" 2>/dev/null || true
session_files="$_session_dir/files"

hook_filter_extensions "ts|tsx"
hook_skip_generated

# Track only the category the Stop consumer owns.
case "$file_path" in
  */auth/*|*/security/*|*/crypto/*|*/credentials/*|*/secrets/*|*/src/env.ts|src/env.ts)
    echo "security:$file_path" >> "$session_files" 2>/dev/null || true
    ;;
esac

exit 0
