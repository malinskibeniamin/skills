#!/bin/bash
# Extracted check logic for accessibility-check.sh. Source ../_hook-lib.sh before this file.
#
# Biome (ultracite preset) owns the single-element a11y rules; do not re-add them here:
#   <img> alt            -> a11y/useAltText
#   clickable div/span   -> a11y/useKeyWithClickEvents + a11y/noStaticElementInteractions + a11y/useFocusableInteractive
#   combobox ARIA props  -> a11y/useAriaPropsForRole
#   label association    -> a11y/noLabelWithoutControl
# This hook keeps only cross-element / cross-attribute / wording checks Biome cannot express.

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

# ── Check: Ban role="dialog" without aria-label/aria-labelledby ────

if echo "$added_lines" | grep -qE 'role\s*=\s*["{]dialog'; then
  if ! echo "$added_lines" | grep -qE 'aria-label(ledby)?\s*=' && ! echo "$file_content" | grep -qE 'role=.*dialog.*aria-label|aria-label.*role=.*dialog'; then
    hook_block "role=\\\"dialog\\\" needs aria-label or aria-labelledby."
    return 0
  fi
fi

# ── Check: accessible names describe the action ─────────────────

if echo "$added_lines" | grep -qiE "aria-label[[:space:]]*=[[:space:]]*['\"][^'\"]*\\b(icon|button|image|graphic)\\b[^'\"]*['\"]"; then
  hook_warn "Accessible names should describe the action, not the element type. Use 'Search' not 'Search icon'." "a11y-name-action"
  return 0
fi

# ── Check: placeholder-only controls ────────────────────────────

_placeholder_controls=$(printf '%s\n' "$added_lines" | grep -Ei '<(input|textarea)\b[^>]*placeholder[[:space:]]*=' || true)
if [ -n "$_placeholder_controls" ]; then
  while IFS= read -r _control_line; do
    [ -z "$_control_line" ] && continue
    _has_accessible_name=false

    if printf '%s\n' "$_control_line" | grep -qE 'aria-label(ledby)?[[:space:]]*='; then
      _has_accessible_name=true
    fi

    _control_id=$(printf '%s\n' "$_control_line" | sed -nE "s/.*(^|[[:space:]])id[[:space:]]*=[[:space:]]*['\"]([^'\"]+)['\"].*/\\2/p" | head -1)
    if [ -n "$_control_id" ] && printf '%s\n' "$file_content" | grep -qE "<label[^>]*(htmlFor|for)[[:space:]]*=[[:space:]]*['\"]$_control_id['\"]"; then
      _has_accessible_name=true
    fi
    if printf '%s\n' "$_control_line" | grep -qE '\bid[[:space:]]*=[[:space:]]*\{' && printf '%s\n' "$file_content" | grep -qE '<label[^>]*(htmlFor|for)[[:space:]]*=[[:space:]]*\{'; then
      _has_accessible_name=true
    fi

    if printf '%s\n' "$_control_line" | grep -qE '<label\b[^>]*>.*<(input|textarea)\b.*</label>'; then
      _has_accessible_name=true
    fi

    if [ "$_has_accessible_name" = false ]; then
      hook_block "Placeholder cannot replace a label. Add a visible label association with htmlFor/id, aria-labelledby, or aria-label for icon-only controls." "a11y-placeholder-label"
      return 0
    fi
  done <<< "$_placeholder_controls"
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

# ── Check: nested interactive elements ───────────────────────────
# Button inside TooltipTrigger, Link inside Button, etc.

if echo "$added_lines" | grep -qE '<(Button|button)[^>]*>.*<(Button|button|a |Link )'; then
  hook_warn "Possible nested interactive elements. Buttons/links inside buttons break a11y." "a11y-nested-interactive"
  return 0
fi

return 0
}
