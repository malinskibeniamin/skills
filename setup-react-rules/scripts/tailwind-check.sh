#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_skip_generated
hook_filter_extensions "css|scss|sass|less|tsx|jsx|mdx"
hook_get_added_lines

_raw_color_pattern='#[0-9a-fA-F]{3,8}\b|\b(rgba?|hsla?|oklch|oklab|lch|lab)\s*\('
_tailwind_palette='slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose'

# ── Ban !important ─────────────────────────────────────────────────

if echo "$added_lines" | grep -qE '!important'; then
  hook_block "No !important — breaks Tailwind cascade. Fix specificity."
fi

# ── Ban raw colors in CSS files ───────────────────────────────────

case "$file_path" in
  *.css|*.scss|*.sass|*.less)
    if ! hook_has_escape "design-token"; then
      _css_raw_colors=$(echo "$added_lines" \
        | grep -E "$_raw_color_pattern" \
        | grep -Ev '@(apply|theme|layer)|--[A-Za-z0-9_-]+[[:space:]]*:' || true)
      if [ -n "$_css_raw_colors" ]; then
        hook_block "No raw colors in CSS. Use design tokens like var(--destructive). Escape: // allow: design-token [reason]"
      fi
    fi
    ;;
esac

# ── Ban raw colors in JSX/MDX styling ─────────────────────────────

case "$file_path" in
  *.tsx|*.jsx|*.mdx)
    if ! hook_has_escape "design-token"; then
      # Tailwind arbitrary colors bypass the design palette:
      # bg-[#fff], text-[rgb(...)], from-[hsl(...)], and so on.
      if echo "$added_lines" | grep -qiE "\b(bg|text|border|from|via|to|ring|fill|stroke|shadow|accent|caret|decoration)-\[(#|rgba?\s*\(|hsla?\s*\(|oklch\s*\(|oklab\s*\(|lch\s*\(|lab\s*\()"; then
        hook_block "No raw colors in JSX className. Use design tokens (bg-primary, text-foreground, border-border). Escape: // allow: design-token [reason]"
      fi

      # Inline styles with raw colors create one-off palettes outside tokens.
      if echo "$added_lines" | grep -qiE "style=\{\{[^}]*($_raw_color_pattern)"; then
        hook_block "No raw colors in JSX style objects. Move color to design tokens or Tailwind token classes. Escape: // allow: design-token [reason]"
      fi
    fi
    ;;
esac

# ── Ban gradient text and hardcoded gradient palettes ─────────────

if ! hook_has_escape "gradient"; then
  if echo "$added_lines" | grep -qE 'bg-clip-text' && \
     echo "$added_lines" | grep -qE 'text-transparent'; then
    hook_block "Gradient text is decorative and hurts hierarchy. Use solid text color, weight, scale, or spacing. Escape: // allow: gradient [reason]"
  fi

  if echo "$added_lines" | grep -qE 'background-clip[[:space:]]*:[[:space:]]*text' && \
     echo "$added_lines" | grep -qE 'color[[:space:]]*:[[:space:]]*transparent'; then
    hook_block "Gradient text is decorative and hurts hierarchy. Use solid text color, weight, scale, or spacing. Escape: // allow: gradient [reason]"
  fi
fi

if ! hook_has_escape "design-token"; then
  if echo "$added_lines" | grep -qE 'bg-gradient' && \
     echo "$added_lines" | grep -qE "\b(from|via|to)-($_tailwind_palette)-[0-9]{2,3}\b"; then
    hook_block "No hardcoded Tailwind palette gradients. Use theme gradient tokens or semantic color stops. Escape: // allow: design-token [reason]"
  fi

  if echo "$added_lines" | grep -qE 'linear-gradient\(' && \
     echo "$added_lines" | grep -qE "$_raw_color_pattern"; then
    hook_block "No hardcoded gradient colors. Use theme tokens or CSS variables. Escape: // allow: design-token [reason]"
  fi
fi

# ── Ban 100vh (use 100dvh for mobile) ────────────────────────────

case "$file_path" in
  *.css|*.scss|*.sass|*.less)
    if echo "$added_lines" | grep -qE '\b100vh\b'; then
      hook_warn "Use 100dvh not 100vh. 100vh ignores mobile address bar."
    fi
    ;;
esac

# ── Ban width: 100vw (causes horizontal scrollbar) ───────────────

case "$file_path" in
  *.css|*.scss|*.sass|*.less)
    if echo "$added_lines" | grep -qE 'width:\s*100vw'; then
      hook_warn "Use width:100% not 100vw. 100vw includes scrollbar, causes overflow."
    fi
    ;;
esac

# ── Ban user-scalable=no (WCAG zoom violation) ──────────────────

if echo "$added_lines" | grep -qE 'user-scalable\s*=\s*no'; then
  hook_block "user-scalable=no is WCAG 1.4.4 violation. Users must zoom."
fi

exit 0
