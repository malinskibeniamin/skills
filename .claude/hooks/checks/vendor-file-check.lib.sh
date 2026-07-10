#!/bin/bash
# Extracted check logic for vendor-file-check.sh. Source ../_hook-lib.sh before this file.

run_vendor_file_check() {
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
      hook_block "Editing vendor/registry file in $_dir/. These are CLI-installed — don't modify directly. If fixing pre-existing lint, skip the file." "vendor-file-check"
    fi
  fi

  # Also check for @generated marker in first 5 lines
  if [ -f "$file_path" ]; then
    _header=$(head -5 "$file_path" 2>/dev/null || true)
    if echo "$_header" | grep -qE '@generated|DO NOT EDIT|AUTO-GENERATED'; then
      hook_block "Editing auto-generated file. Regenerate from source instead of editing directly." "vendor-file-check"
    fi
  fi
fi

# ── absorbed from ui-registry-warn.sh (4.28 family consolidation) ──
# PostToolUse hook: warn ONCE per session when editing UI registry files.
# Fires on Edit/Write for any file in a UI component directory.
# Non-blocking — return 0 so other hooks still run on the file.

if [ -f "$file_path" ]; then
  # ── Detect UI component directories ────────────────────────────
  # Same detection as hook_skip_ui_dirs || return 0 but for warning, not skipping.

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

      # ── Emit warning (single owner of the registry-edit warn) ─────
      # Registry repo (registry.json): edits here ARE upstream — remind to
      # rebuild. Consumer repo (components.json/cli.json): edits get
      # overwritten on the next pull — steer to an upstream PR.

      component_name=$(basename "$file_path")
      dir_matched=$(echo "$file_path" | grep -oE "($_ui_dirs)" | head -1)
      _vendor_repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

      if [ -f "$_vendor_repo_root/registry.json" ]; then
        hook_warn "[UI REGISTRY] Editing '$component_name' in the registry source. Rebuild registry.json and update CHANGELOG.md when done." "ui-registry-warn"
      else
        # Consumer repo (components.json / cli.json) or unmarked checkout.
        hook_warn "[UI REGISTRY] Modifying '$component_name' ($dir_matched/). Registry-sourced — local changes overwritten on next pull. PR upstream instead." "ui-registry-warn"
      fi
    fi
  fi
fi

return 0
}
