#!/bin/bash
set -euo pipefail
_lib="$(dirname "$0")/_hook-lib.sh"; if [ -f "$_lib" ]; then source "$_lib"; else _m="${TMPDIR:-/tmp}/frontend-skills-broken.${CLAUDE_SESSION_ID:-fs}"; [ -f "$_m" ] || { echo "[frontend-skills] _hook-lib.sh unavailable - run: /plugin install frontend-skills --force" >&2; touch "$_m" 2>/dev/null; }; exit 0; fi

# Extract file path directly — don't use hook_parse_edit_write which
# exits on non-existent files. Vendor paths need checking even for Write (new files).
_hook_input=$(cat)
_hook_tool_name=$(echo "$_hook_input" | jq -r '.tool_name // empty' 2>/dev/null || true)

if [ "$_hook_tool_name" != "Edit" ] && [ "$_hook_tool_name" != "Write" ]; then
  exit 0
fi

file_path=$(echo "$_hook_input" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
if [ -z "$file_path" ]; then
  exit 0
fi

# ── Scope: frontend files only (skip Go, Python, backend, etc.) ──
_vendor_frontend_file=false
case "$file_path" in
  *.ts|*.tsx|*.css|*.scss|*.mdx) _vendor_frontend_file=true ;;
esac

# ── Block edits to vendor/registry/generated UI library directories ──
# These files are installed by CLIs (fumadocs, shadcn, redpanda-ui registry)
# and should not be modified directly. Pre-existing lint errors in these dirs
# are not our problem.

if [ "$_vendor_frontend_file" = true ]; then
  _blocked_dirs="redpanda-ui|components/ui/registry|vendor|fumadocs"

  if echo "$file_path" | grep -qE "/($_blocked_dirs)/"; then
    # Allow escape hatch for intentional vendor patches
    if [ -f "$file_path" ] && grep -qE '//\s*allow:\s*vendor-edit' "$file_path" 2>/dev/null; then
      :
    else
      _dir=$(echo "$file_path" | grep -oE "($_blocked_dirs)" | head -1)
      echo "{\"suppressOutput\":true,\"systemMessage\":\"Editing vendor/registry file in $_dir/. These are CLI-installed — don't modify directly. If fixing pre-existing lint, skip the file.\"}" >&2
      exit 2
    fi
  fi

  # Also check for @generated marker in first 5 lines
  if [ -f "$file_path" ]; then
    _header=$(head -5 "$file_path" 2>/dev/null || true)
    if echo "$_header" | grep -qE '@generated|DO NOT EDIT|AUTO-GENERATED'; then
      echo '{"suppressOutput":true,"systemMessage":"Editing auto-generated file. Regenerate from source instead of editing directly."}' >&2
      exit 2
    fi
  fi
fi

# ── absorbed from ui-registry-warn.sh (4.28 family consolidation) ──
# PostToolUse hook: warn ONCE per session when editing UI registry files.
# Fires on Edit/Write for any file in a UI component directory.
# Non-blocking — exit 0 so other hooks still run on the file.

if [ -f "$file_path" ]; then
  # ── Detect UI component directories ────────────────────────────
  # Same detection as hook_skip_ui_dirs but for warning, not skipping.

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
    # ── Warn once per session ──────────────────────────────────────

    _seen_file="$_hook_session_dir/ui-registry-warned"

    if [ ! -f "$_seen_file" ]; then
      touch "$_seen_file" 2>/dev/null || true

      # ── Emit warning ───────────────────────────────────────────────

      component_name=$(basename "$file_path")
      dir_matched=$(echo "$file_path" | grep -oE "($_ui_dirs)" | head -1)

      hook_warn "[UI REGISTRY] Modifying '$component_name' ($dir_matched/). Registry-sourced — local changes overwritten on next pull. PR upstream instead." "ui-registry-warn"
    fi
  fi
fi

exit 0
