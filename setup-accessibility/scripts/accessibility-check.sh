#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "tsx|jsx"
hook_get_added_lines

# Read full file for context
file_content=$(cat "$file_path")

# Allow escape hatch: // allow-a11y-skip: [reason]
if echo "$file_content" | grep -qE '//\s*allow-a11y-skip:'; then
  exit 0
fi

# ── Check 1: Ban <img> without alt ──────────────────────────────────

if echo "$added_lines" | grep -qE '<img\b' && ! echo "$added_lines" | grep -qE '<img\b[^>]*\balt\s*='; then
  hook_block "Add alt attribute to <img> elements.\nUse a descriptive string, or alt=\\\"\\\" for decorative images.\n\nWCAG 1.1.1: All non-text content must have a text alternative."
fi

# ── Check 2: Ban clickable div/span without keyboard support ────────

if echo "$added_lines" | grep -qE '<(div|span)\b[^>]*\bonClick\b'; then
  has_keyboard=false
  has_role=false
  has_tabindex=false

  if echo "$added_lines" | grep -qE '<(div|span)\b[^>]*\bon(KeyDown|KeyUp|KeyPress)\b'; then
    has_keyboard=true
  fi
  if echo "$added_lines" | grep -qE '<(div|span)\b[^>]*\brole\s*='; then
    has_role=true
  fi
  if echo "$added_lines" | grep -qE '<(div|span)\b[^>]*\btabIndex\b'; then
    has_tabindex=true
  fi

  if [ "$has_keyboard" = false ] || [ "$has_role" = false ] || [ "$has_tabindex" = false ]; then
    hook_block "Clickable <div>/<span> needs role, tabIndex, and onKeyDown.\nAdd all three, or prefer <button> instead.\n\nWCAG 2.1.1: All functionality must be keyboard-operable."
  fi
fi

# ── Check 3: Ban role="combobox" without required ARIA attributes ──

if echo "$added_lines" | grep -qE 'role\s*=\s*["{]combobox'; then
  missing=""
  if ! echo "$file_content" | grep -qE 'aria-expanded\s*='; then
    missing="aria-expanded"
  fi
  if ! echo "$file_content" | grep -qE 'aria-controls\s*='; then
    missing="$missing${missing:+, }aria-controls"
  fi
  if [ -n "$missing" ]; then
    hook_block "role=\\\"combobox\\\" is missing required ARIA: $missing.\nAdd aria-expanded and aria-controls at minimum.\n\nSee REFERENCE.md for the complete combobox ARIA pattern."
  fi
fi

# ── Check 4: Ban role="tablist" without role="tab" children ─────────

if echo "$added_lines" | grep -qE 'role\s*=\s*["{]tablist'; then
  if ! echo "$file_content" | grep -qE 'role\s*=\s*["{]tab[^l]'; then
    hook_block "role=\\\"tablist\\\" requires children with role=\\\"tab\\\".\nAdd role=\\\"tab\\\" to each tab and role=\\\"tabpanel\\\" to each panel.\n\nSee REFERENCE.md for the complete tabs ARIA pattern."
  fi
fi

# ── Check 5: Ban role="dialog" without aria-label/aria-labelledby ──

if echo "$added_lines" | grep -qE 'role\s*=\s*["{]dialog'; then
  if ! echo "$added_lines" | grep -qE 'aria-label(ledby)?\s*=' && ! echo "$file_content" | grep -qE 'role=.*dialog.*aria-label|aria-label.*role=.*dialog'; then
    hook_block "role=\\\"dialog\\\" must have aria-label or aria-labelledby.\nAdd aria-labelledby pointing to the dialog's heading element.\n\nWCAG 2.4.3: Focus order must be meaningful."
  fi
fi

exit 0
