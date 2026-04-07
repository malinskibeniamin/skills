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

# ── Ban 100vh (use 100dvh for mobile) ────────────────────────────

case "$file_path" in
  *.css|*.scss|*.sass|*.less)
    if echo "$added_lines" | grep -qE '\b100vh\b'; then
      hook_warn "Use 100dvh instead of 100vh.\n100vh does not account for mobile browser chrome (address bar), causing overflow.\n100dvh adapts to the dynamic viewport height."
    fi
    ;;
esac

# ── Ban width: 100vw (causes horizontal scrollbar) ───────────────

case "$file_path" in
  *.css|*.scss|*.sass|*.less)
    if echo "$added_lines" | grep -qE 'width:\s*100vw'; then
      hook_warn "Use width: 100% instead of 100vw.\n100vw includes scrollbar width and causes horizontal overflow when the page has a vertical scrollbar."
    fi
    ;;
esac

# ── Ban user-scalable=no (WCAG zoom violation) ──────────────────

if echo "$added_lines" | grep -qE 'user-scalable\s*=\s*no'; then
  hook_block "Do not disable pinch-to-zoom (user-scalable=no).\nThis is a WCAG 1.4.4 violation — users must be able to zoom.\nRemove user-scalable=no from the viewport meta tag."
fi

exit 0
