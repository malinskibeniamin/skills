#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

# PostToolUse hook: warn ONCE per session when editing UI registry files.
# Fires on Edit/Write for any file in a UI component directory.
# Non-blocking — exit 0 so other hooks still run on the file.

hook_parse_edit_write

# ── Detect UI component directories ────────────────────────────
# Same detection as hook_skip_ui_dirs but for warning, not skipping.

if [ -z "${UI_LIB_DIRS:-}" ]; then
  _ui_dirs="components/ui"
  _root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  [ -d "$_root/redpanda-ui" ] && _ui_dirs="$_ui_dirs|redpanda-ui"
  [ -d "$_root/src/ui" ] && _ui_dirs="$_ui_dirs|src/ui"
  [ -d "$_root/packages/ui" ] && _ui_dirs="$_ui_dirs|packages/ui"
else
  _ui_dirs="$UI_LIB_DIRS"
fi

if ! echo "$file_path" | grep -qE "/($_ui_dirs)/"; then
  exit 0
fi

# ── Warn once per session ──────────────────────────────────────

_seen_file="$_hook_session_dir/ui-registry-warned"

if [ -f "$_seen_file" ]; then
  exit 0
fi

touch "$_seen_file" 2>/dev/null || true

# ── Emit warning ───────────────────────────────────────────────

component_name=$(basename "$file_path")
dir_matched=$(echo "$file_path" | grep -oE "($_ui_dirs)" | head -1)

hook_warn "[UI REGISTRY] You are modifying '$component_name' in the UI component directory ($dir_matched/).\\nThese components are registry-sourced. Local-only changes WILL be overwritten on the next registry pull.\\n\\nTo keep the upstream source of truth in sync:\\n1. Make the same change in the upstream UI registry repo\\n2. Open a PR against the UI registry\\n3. After merge, pull updated components into consumer repos" "ui-registry-warn"
