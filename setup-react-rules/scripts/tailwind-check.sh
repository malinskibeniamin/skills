#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "css|scss|sass|less|tsx|jsx"
hook_get_added_lines

# ── Ban !important (breaks Tailwind cascade) ─────────────────────

if echo "$added_lines" | grep -qE '!important'; then
  hook_block "Do not use !important (breaks Tailwind cascade).\nFix the specificity issue instead of forcing with !important."
fi

# ── Ban raw hex/rgb in CSS files ──────────────────────────────────

case "$file_path" in
  *.css|*.scss|*.sass|*.less)
    if echo "$added_lines" | grep -qE '#[0-9a-fA-F]{3,8}\b' && \
       ! echo "$added_lines" | grep -qE '@(apply|theme|layer)'; then
      hook_block "Do not use raw hex colors in stylesheets.\nUse Tailwind CSS variables or design tokens: var(--destructive)."
    fi
    ;;
esac

exit 0
