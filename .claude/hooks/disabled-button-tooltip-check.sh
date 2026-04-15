#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "tsx"
hook_skip_generated
hook_skip_tests
hook_get_added_lines

# ── Check: disabled Button without wrapping Tooltip ──────────────
# A11y: disabled buttons should explain why via tooltip.
# Pattern: <Button disabled> without surrounding <Tooltip>.

if echo "$added_lines" | grep -qE '<Button[^>]*disabled'; then
  # Check if there's a Tooltip wrapper nearby in the file
  file_content=$(cat "$file_path")
  # Simple heuristic: if file has Tooltip import and disabled Button,
  # assume it's handled. If no Tooltip import, warn.
  if ! echo "$file_content" | grep -qE "Tooltip|TooltipTrigger|TooltipProvider"; then
    if ! hook_has_escape "disabled-tooltip"; then
      hook_warn "Disabled <Button> without Tooltip. Add tooltip explaining why button is disabled (a11y). Escape: // allow: disabled-tooltip [reason]" "disabled-button-tooltip"
    fi
  fi
fi

exit 0
