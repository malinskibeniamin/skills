#!/bin/bash
# Extracted check logic for orchestration-guidance.sh. Source ../_hook-lib.sh before this file.

run_orchestration_guidance() {
# PostToolUse hook: mark security-sensitive files for orchestration-stop.sh.
# Target: <10ms (path matching + 1 line append).


_session_dir="${_hook_session_dir:-/tmp/hook-session-${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}}"
mkdir -p "$_session_dir" 2>/dev/null || true
session_files="$_session_dir/files"

hook_filter_extensions "ts|tsx" || return 0
hook_skip_generated || return 0

# Track only the category the Stop consumer owns.
case "$file_path" in
  */auth/*|*/security/*|*/crypto/*|*/credentials/*|*/secrets/*|*/src/env.ts|src/env.ts)
    echo "security:$file_path" >> "$session_files" 2>/dev/null || true
    ;;
esac

return 0
}
