#!/bin/bash
# Extracted check logic for tailwind-check.sh. Source ../_hook-lib.sh before this file.

run_tailwind_check() {
hook_skip_generated || return 0
hook_filter_extensions "css|scss|sass|less|tsx|jsx|mdx" || return 0
hook_get_added_lines || return 0

_raw_color_pattern='#[0-9a-fA-F]{3,8}\b|\b(rgba?|hsla?|oklch|oklab|lch|lab)\s*\('
_tailwind_palette='slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose'
_tailwind_chromatic_palette='red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose'
_tailwind_color_utility='(bg|text|border|border-[trblxy]|ring|ring-offset|fill|stroke|from|via|to|accent|caret|decoration|outline|shadow|divide|placeholder)'
_tailwind_palette_color='(black|white|('"$_tailwind_palette"')-[0-9]{2,3})'
_tailwind_palette_color_class='(^|[^[:alnum:]_-])!?'"$_tailwind_color_utility"'-'"$_tailwind_palette_color"'(/[0-9]{1,3})?\b'
_tailwind_gray_text_class='(^|[^[:alnum:]_-])!?text-(slate|gray|zinc|neutral|stone)-[0-9]{2,3}(/[0-9]{1,3})?\b'
_tailwind_chromatic_bg_class='(^|[^[:alnum:]_-])!?bg-('"$_tailwind_chromatic_palette"')-[0-9]{2,3}(/[0-9]{1,3})?\b'
_tailwind_semantic_bg_class='(^|[^[:alnum:]_-])!?bg-(primary|secondary|accent|destructive|muted|card|popover)(/[0-9]{1,3})?\b'
_tailwind_translucent_bg_class="(^|[^[:alnum:]_-])!?bg-((black|white)/[0-9]{1,2}|(${_tailwind_palette})-[0-9]{2,3}/[0-9]{1,2}|(background|foreground|card|popover|primary|secondary|muted|accent|destructive|border|input|ring)/[0-9]{1,2}|\\[(rgba?|hsla?)\\()|(^|[^[:alnum:]_-])!?bg-opacity-[0-9]{1,2}\\b"

_tw_line_has_pair() {
  local first="$1" second="$2"
  echo "$added_lines" | grep -E "$first" | grep -qE "$second" || \
    echo "$added_lines" | grep -E "$second" | grep -qE "$first"
}

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

# ── Ban one-off color utilities and contrast-hostile pairings ───

if ! hook_has_escape "design-token"; then
  if _tw_line_has_pair "$_tailwind_chromatic_bg_class" "$_tailwind_gray_text_class"; then
    hook_block "No gray text on colored backgrounds. Use paired foreground tokens like text-primary-foreground. Escape: // allow: design-token [reason]"
  fi

  if _tw_line_has_pair "$_tailwind_semantic_bg_class" "$_tailwind_gray_text_class"; then
    hook_block "No gray text on semantic backgrounds. Use the matching foreground token, for example text-primary-foreground or text-muted-foreground. Escape: // allow: design-token [reason]"
  fi
fi

# ── Ban glassmorphism treatments ────────────────────────────────

if ! hook_has_escape "visual-design"; then
  if _tw_line_has_pair '(^|[^[:alnum:]_-])!?backdrop-blur\b' "$_tailwind_translucent_bg_class"; then
    hook_block "No glassmorphism: backdrop blur plus translucent backgrounds reduces consistency and contrast. Use solid surfaces. Escape: // allow: visual-design [reason]"
  fi
fi

# ── Ban hardcoded Tailwind palette color utilities ──────────────

if ! hook_has_escape "design-token"; then
  if echo "$added_lines" | grep -qE "$_tailwind_palette_color_class"; then
    hook_block "No hardcoded Tailwind palette color utilities. Use semantic tokens like bg-primary, text-foreground, border-border. Escape: // allow: design-token [reason]"
  fi
fi

# ── Warn on deterministic visual-design smells ─────────────────

if ! hook_has_escape "visual-design"; then
  if echo "$added_lines" | grep -qE '(^|[^[:alnum:]_-])!?((border-[lr]-(4|8|[1-9][0-9]))|(border-[lr]-(primary|secondary|accent|destructive|muted|foreground|background|card|popover|border)))\b'; then
    hook_warn "Avoid side-stripe accent borders. Prefer spacing, hierarchy, or tokenized surface states. Escape: // allow: visual-design [reason]"
  fi

  if _tw_line_has_pair '(^|[^[:alnum:]_-])!?(rounded-(2xl|3xl|full)\b|rounded-[trbl][rltb]?-(2xl|3xl|full)\b|rounded-\[[^]]+\])' '(<(section|input|textarea|select)\b|<Card\b|card|shadow-|border|p-[4-9]|p-1[0-9])'; then
    hook_warn "Avoid over-rounded cards, sections, and inputs. Use standard radius tokens unless the component requires a pill shape. Escape: // allow: visual-design [reason]"
  fi

  if _tw_line_has_pair '(^|[^[:alnum:]_-])!?border(-border)?([^[:alnum:]_-]|$)' '(^|[^[:alnum:]_-])!?shadow-(lg|xl|2xl)\b'; then
    hook_warn "Avoid ghost-card styling: border plus large shadow. Pick either a subtle border or a restrained shadow. Escape: // allow: visual-design [reason]"
  fi

  if echo "$added_lines" | grep -qE '(^|[^[:alnum:]_-])!?text-(6xl|7xl|8xl|9xl)\b|(^|[^[:alnum:]_-])!?text-\[((7[2-9]|[89][0-9]|[1-9][0-9]{2,})px|([5-9]|[1-9][0-9]+)rem)\]'; then
    hook_warn "Oversized hero text classes are hard to reuse responsively. Prefer type scale tokens and responsive steps. Escape: // allow: visual-design [reason]"
  fi

  if echo "$added_lines" | grep -qE '(^|[^[:alnum:]_-])!?(-tracking-\[(0?\.0[6-9]|0?\.[1-9]|[1-9][0-9]*(\.[0-9]+)?)(em|rem|px)\]|tracking-\[-(0?\.0[6-9]|0?\.[1-9]|[1-9][0-9]*(\.[0-9]+)?)(em|rem|px)\])'; then
    hook_warn "Extreme negative tracking hurts readability. Use normal tracking or a type token. Escape: // allow: visual-design [reason]"
  fi
fi

# ── Warn on deterministic motion-craft smells ──────────────────

if ! hook_has_escape "motion-design"; then
  if echo "$added_lines" | grep -qiE '(^|[^[:alnum:]_-])!?transition-all\b|transition[[:space:]]*:[[:space:]]*all\b'; then
    hook_warn "Motion craft: avoid transition-all. Transition only transform/opacity or the specific property that should move. Escape: // allow: motion-design [reason]" "motion-transition-all"
  fi

  if echo "$added_lines" | grep -qiE '(^|[^[:alnum:]_-])!?duration-(500|700|1000)\b|duration-\[(30[1-9]|3[1-9][0-9]|[4-9][0-9]{2}|[1-9][0-9]{3,})ms\]|transition[^;]*(30[1-9]|3[1-9][0-9]|[4-9][0-9]{2}|[1-9][0-9]{3,})ms|transition[^;]*[1-9][0-9]*s'; then
    hook_warn "Motion craft: common UI animation should stay under 300ms unless distance or platform convention justifies more. Escape: // allow: motion-design [reason]" "motion-duration"
  fi

  _ease_in_lines=$(printf '%s\n' "$added_lines" \
    | grep -qiE '\bease-in\b|transition-timing-function[[:space:]]*:[[:space:]]*ease-in\b' \
    && printf '%s\n' "$added_lines" | grep -viE 'ease-in-out' || true)
  if [ -n "$_ease_in_lines" ]; then
    hook_warn "Motion craft: avoid ease-in for common UI entry/exit. Prefer short ease-out, ease-in-out for morphing, or instant feedback. Escape: // allow: motion-design [reason]" "motion-ease-in"
  fi

  if echo "$added_lines" | grep -qE '(^|[^[:alnum:]_-])!?scale-0\b|scale\(0\)'; then
    hook_warn "Motion craft: avoid scale(0) entry. Start near final size so text and edges stay credible. Escape: // allow: motion-design [reason]" "motion-scale-zero"
  fi

  if echo "$added_lines" | grep -qiE 'transition(-property)?[[:space:]]*:[^;]*(width|height|top|right|bottom|left|margin|padding)|transition-\[(width|height|top|right|bottom|left|margin|padding)\]'; then
    hook_warn "Motion craft: layout property animation risks jank. Prefer transform/opacity, clip-path for reveals, or an instant state change. Escape: // allow: motion-design [reason]" "motion-layout-property"
  fi

  if echo "$added_lines" | grep -qE '(^|[^[:alnum:]_-])!?animate-bounce\b'; then
    hook_warn "Motion craft: bounce animation usually steals attention. Use purposeful, short feedback or remove it. Escape: // allow: motion-design [reason]" "motion-bounce"
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


# ── Warn on 100vh arbitrary classes in JSX/MDX ───────────────────

case "$file_path" in
  *.tsx|*.jsx|*.mdx)
    if ! hook_has_escape "visual-design"; then
      if echo "$added_lines" | grep -qE '(^|[^[:alnum:]_-])!?(h|min-h|max-h|size)-\[100vh\]|\[(height|min-height|max-height):100vh\]'; then
        hook_warn "Use 100dvh not h-[100vh]/min-h-[100vh]. 100vh ignores mobile address bar. Escape: // allow: visual-design [reason]"
      fi
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

# ── user-scalable=no — delegated to React Doctor design/no-disabled-zoom ──

return 0
}
