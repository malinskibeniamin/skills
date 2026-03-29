#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../../shared/hook-lib.sh"

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
  hook_block "a11y: <img> must have an alt attribute.\n\n// BAD\n<img src=\\\"photo.jpg\\\" />\n\n// GOOD — descriptive\n<img src=\\\"photo.jpg\\\" alt=\\\"Team photo from offsite\\\" />\n\n// GOOD — decorative (empty alt hides from screen readers)\n<img src=\\\"divider.png\\\" alt=\\\"\\\" />\n\nWCAG 1.1.1: All non-text content must have a text alternative."
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
    hook_block "a11y: Clickable <div>/<span> must have role, tabIndex, and keyboard handler.\n\n// BAD — mouse-only, invisible to assistive tech\n<div onClick={handleClick}>Click me</div>\n\n// GOOD — but prefer <button> when possible\n<div role=\\\"button\\\" tabIndex={0} onClick={handleClick} onKeyDown={(e) => { if (e.key === \\\"Enter\\\" || e.key === \\\" \\\") handleClick(); }}>Click me</div>\n\nWCAG 2.1.1: All functionality must be operable through a keyboard interface."
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
    hook_block "a11y: role=\\\"combobox\\\" is missing required ARIA attributes: $missing.\\n\\nCombobox requires:\\n- aria-expanded (\\\"true\\\"/\\\"false\\\")\\n- aria-controls (ID of the popup listbox)\\n- aria-autocomplete (\\\"none\\\"/\\\"list\\\"/\\\"both\\\"/\\\"inline\\\")\\n- aria-activedescendant (ID of focused option, when popup is open)\\n\\nSee REFERENCE.md for the complete combobox ARIA pattern."
  fi
fi

# ── Check 4: Ban role="tablist" without role="tab" children ─────────

if echo "$added_lines" | grep -qE 'role\s*=\s*["{]tablist'; then
  if ! echo "$file_content" | grep -qE 'role\s*=\s*["{]tab[^l]'; then
    hook_block "a11y: role=\\\"tablist\\\" requires child elements with role=\\\"tab\\\" and associated role=\\\"tabpanel\\\".\\n\\nTabs pattern requires:\\n- tablist: container with role=\\\"tablist\\\", aria-label\\n- tab: each tab with role=\\\"tab\\\", aria-selected, aria-controls\\n- tabpanel: each panel with role=\\\"tabpanel\\\", aria-labelledby\\n\\nKeyboard: Arrow keys move between tabs, Tab moves to panel.\\n\\nSee REFERENCE.md for the complete tabs ARIA pattern."
  fi
fi

# ── Check 5: Ban role="dialog" without aria-label/aria-labelledby ──

if echo "$added_lines" | grep -qE 'role\s*=\s*["{]dialog'; then
  if ! echo "$added_lines" | grep -qE 'aria-label(ledby)?\s*=' && ! echo "$file_content" | grep -qE 'role=.*dialog.*aria-label|aria-label.*role=.*dialog'; then
    hook_block "a11y: role=\\\"dialog\\\" must have aria-label or aria-labelledby.\\n\\n// BAD\\n<div role=\\\"dialog\\\">...</div>\\n\\n// GOOD\\n<div role=\\\"dialog\\\" aria-modal=\\\"true\\\" aria-labelledby=\\\"dialog-title\\\">\\n  <h2 id=\\\"dialog-title\\\">Confirm Delete</h2>\\n</div>\\n\\nAlso required:\\n- aria-modal=\\\"true\\\" for modal dialogs\\n- Focus must move into dialog on open\\n- Escape key must close the dialog\\n\\nWCAG 2.4.3: Focus order must be meaningful."
  fi
fi

exit 0
