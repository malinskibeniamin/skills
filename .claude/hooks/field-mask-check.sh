#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "ts|tsx|js|jsx"
hook_skip_generated
hook_skip_tests
hook_get_added_lines

# ── Check 1: Warn on hardcoded FieldMask paths arrays ────────────
# Static paths arrays in FieldMask can drift when proto schema changes.
# Suggest computing paths dynamically from dirty/changed fields.

if echo "$added_lines" | grep -qE 'FieldMaskSchema|FieldMask'; then
  # Count hardcoded path strings in the paths array
  # Pattern: paths: ['field_one', 'field_two', ...]
  path_count=$(echo "$added_lines" | grep -oE "paths:\s*\[" -A 20 | grep -c "'[a-z_]*'" 2>/dev/null || echo "0")

  if [ "$path_count" -gt 4 ]; then
    if ! hook_has_escape "field-mask"; then
      hook_warn "FieldMask with ${path_count}+ hardcoded paths. Consider computing from dirty fields: Object.keys(form.formState.dirtyFields). Escape: // allow: field-mask [reason]"
    fi
  fi
fi

exit 0
