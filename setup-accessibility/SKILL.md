---
name: setup-accessibility
description: Enforce ARIA accessibility via PostToolUse hooks — labels, keyboard handlers, widget attributes, Playwright AXE setup. Use when setting up a11y enforcement, WCAG 2.1 AA compliance, or accessibility testing.
paths:
  - "src/components/**/*.tsx"
---

# Accessibility Enforcement

## What This Catches

- **`<img>` without `alt`** — use `alt=""` for decorative images
- **Mouse-only `onClick` on `<div>`/`<span>`** — requires `role` + `tabIndex` + `onKeyDown`/`onKeyUp`
- **Missing ARIA on widget roles** — `role="combobox"` needs `aria-expanded` + `aria-controls`, `role="dialog"` needs `aria-label`/`aria-labelledby`, `role="tablist"` needs child `role="tab"`

Escape hatch: `// allow: a11y-skip [reason]`

## Visual Checklist

- [ ] Focus rings visible on all interactive elements (min 2px, contrasting color)
- [ ] Hover and focus styles match (no mouse-only affordances)
- [ ] Color is not the only means of conveying information
- [ ] Touch targets at least 44x44 CSS pixels
- [ ] `prefers-reduced-motion` respected for animations
- [ ] `forced-colors` / high-contrast mode: use `currentcolor` for SVG fills
- [ ] Text resizable to 200% without loss of content

For initial setup (install, AXE fixture, hook config): see [SETUP.md](SETUP.md).
