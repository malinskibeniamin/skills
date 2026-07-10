#!/bin/bash
# Extracted check logic for edit-loop-check.sh. Source ../_hook-lib.sh before this file.

run_edit_loop_check() {

# ── Track edits per file, warn after threshold ──────────────────
# 104 sessions had 5+ edits to same file. After 8 edits, inject
# guidance to re-read and fix all issues at once.
#
# Uses per-file counter files for O(1) lookup instead of grep on
# a growing append-only file.

_counters_dir="$_hook_session_dir/edit-counts"
mkdir -p "$_counters_dir" 2>/dev/null || return 0

# Use full path with / replaced to avoid basename collisions
# (src/components/Button.tsx vs src/pages/Button.tsx)
_file_key=$(echo "$file_path" | tr '/' '__')
_counter_file="$_counters_dir/$_file_key"

_current=$(cat "$_counter_file" 2>/dev/null || echo "0")
_current=$(echo "$_current" | tr -d '[:space:]')
_new_count=$((_current + 1))
echo "$_new_count" > "$_counter_file"

if [ "$_new_count" -eq 12 ]; then
  hook_warn "You've edited $(basename "$file_path") 12 times this session. Step back: re-read the full file, identify ALL remaining issues, fix them in one pass."
elif [ "$_new_count" -eq 20 ]; then
  hook_warn "20 edits to $(basename "$file_path"). Approach is wrong. Re-read file and consider a different strategy (different abstraction, split file, or revert and restart)."
fi

return 0
}
