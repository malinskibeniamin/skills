#!/bin/bash
# Extracted check logic for accessibility-check.sh. Source ../_hook-lib.sh before this file.
#
# Biome (ultracite preset) owns the single-element a11y rules; do not re-add them here:
#   <img> alt            -> a11y/useAltText
#   clickable div/span   -> a11y/useKeyWithClickEvents + a11y/noStaticElementInteractions + a11y/useFocusableInteractive
#   combobox ARIA props  -> a11y/useAriaPropsForRole
#   label association    -> a11y/noLabelWithoutControl
# React Doctor (Stop hook, a11y category) owns the structural rules; do not re-add:
#   dialog accessible name  -> a11y/dialog-has-accessible-name
#   nested interactives     -> correctness/html-no-nested-interactive
#   redundant name wording  -> a11y/img-redundant-alt
#   placeholder-as-label    -> a11y/label-has-associated-control
# This hook keeps only the cross-attribute pairings neither engine expresses.

run_accessibility_check() {
hook_filter_extensions "tsx|jsx" || return 0
hook_get_added_lines || return 0

# Read full file for context
file_content=$(cat "$file_path")

# Allow escape hatch: // allow: a11y-skip [reason]
if hook_has_escape "a11y-skip"; then
  return 0
fi

# ── Check: Ban role="tablist" without role="tab" children ───────────

if echo "$added_lines" | grep -qE 'role\s*=\s*["{]tablist'; then
  if ! echo "$file_content" | grep -qE 'role\s*=\s*["{]tab[^l]'; then
    hook_block "role=\\\"tablist\\\" needs children with role=\\\"tab\\\" + role=\\\"tabpanel\\\"."
    return 0
  fi
fi

# ── Check: aria-invalid without aria-describedby ─────────────────

if echo "$added_lines" | grep -qE 'aria-invalid'; then
  if ! echo "$file_content" | grep -qE 'aria-describedby'; then
    hook_warn "aria-invalid without aria-describedby. Add error description reference for screen readers." "a11y-describedby"
    return 0
  fi
fi

# ── Check: data-invalid without aria-invalid ─────────────────────
# data-invalid is a styling hook, not an ARIA attribute.
# Screen readers need aria-invalid to announce error state.

if echo "$added_lines" | grep -qE 'data-invalid'; then
  if ! echo "$file_content" | grep -qE 'aria-invalid'; then
    hook_warn "data-invalid used without aria-invalid. data-invalid is CSS-only — add aria-invalid for screen reader support. WCAG 3.3.1." "a11y-data-invalid"
    return 0
  fi
fi

return 0
}
