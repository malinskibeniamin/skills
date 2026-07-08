#!/bin/bash
# Extracted check logic for copyright-check.sh. Source ../_hook-lib.sh before this file.

run_copyright_check() {
hook_filter_extensions "ts|tsx" || return 0
hook_skip_generated || return 0
hook_skip_tests || return 0

# ── Only fire on NEW files (not in HEAD) ─────────────────────────
if git show HEAD:"$file_path" &>/dev/null 2>&1; then
  return 0  # Existing file, skip
fi

# ── Check: copyright header in first 5 lines ────────────────────
_year=$(date +%Y)
if ! head -5 "$file_path" | grep -qiE 'copyright|license'; then
  # Session-scoped: remind once
  _marker="$_hook_session_dir/copyright-reminded"
  if [ ! -f "$_marker" ]; then
    touch "$_marker"
    hook_warn "New file missing copyright header. Add: // Copyright ${_year} Redpanda Data, Inc." "copyright-header"
    return 0
  fi
fi

return 0
}
