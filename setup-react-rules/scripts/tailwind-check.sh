#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "css|scss|sass|less|tsx|jsx"
hook_get_added_lines

# ── Ban !important (breaks Tailwind cascade) ─────────────────────

if echo "$added_lines" | grep -qE '!important'; then
  hook_block "!important is banned — it breaks the Tailwind cascade and makes styles unmaintainable. Fix specificity issues instead."
fi

# ── Ban raw hex/rgb in CSS files ──────────────────────────────────

case "$file_path" in
  *.css|*.scss|*.sass|*.less)
    if echo "$added_lines" | grep -qE '#[0-9a-fA-F]{3,8}\b' && \
       ! echo "$added_lines" | grep -qE '@(apply|theme|layer)'; then
      hook_block "Do not use raw hex colors in stylesheets. Use Tailwind CSS variables or design tokens instead.\n\n// BAD\n.card { color: #ff0000; }\n\n// GOOD\n.card { color: var(--destructive); }"
    fi
    ;;
esac

exit 0
