---
name: accessibility
description: Use for React ARIA, keyboard, focus, form, or nested-control accessibility.
paths:
  - "src/components/**/*.tsx"
---

# Accessibility

One owner per rule:

- **Biome** owns element semantics: image `alt`, keyboard support for custom controls,
  combobox ARIA, and label association.
- **React Doctor** owns structure and naming: dialogs, nested controls, accessible
  names, persistent labels, and described invalid fields.
- **The local hook** only pairs `tablist` with child `tab` roles and `data-invalid` with
  `aria-invalid`.

Do not duplicate checks. Escape hatch: `// allow: a11y-skip [reason]`.

## Interaction contracts

- Prefer native controls and visible text. Custom clickable elements need a role,
  `tabIndex`, and equivalent keyboard behavior.
- Use either a clickable container without interactive descendants or a passive container
  with interactive children. Never nest pressables.
- Comboboxes expose `aria-expanded` and `aria-controls`; tablists contain tabs.
- Use `aria-label` only without a visible name; it or `aria-labelledby` can replace
  descendant text. Omit redundant words such as `icon` or `button`.
- Form controls have persistent labels. Connect visible errors with `aria-invalid` and a
  current `aria-describedby`; remove stale error IDs when validation clears.
- Inspect the accessibility tree when naming is unclear. Follow the
  [WAI-ARIA naming guidance](https://www.w3.org/WAI/ARIA/apg/practices/names-and-descriptions/).

## Visual and focus checks

- Keep a contrasting 2px focus indicator; expose hover actions to keyboard and touch users.
- DOM order matches reading and tab order. Reordered layouts need keyboard and screen-reader
  evidence.
- Modal surfaces trap and restore focus and make the background inert.
- Pair color state with text, icon, or shape and support forced colors with
  `currentcolor`.
- Keep touch targets at least 44 by 44 CSS pixels. Gate hover-only effects with
  `@media (hover: hover) and (pointer: fine)`.
- For reduced motion, preserve feedback through opacity, color, text, or instant state changes.
- Support 200% text zoom without loss.
- Verify high-risk mobile overlays on a physical device or simulator, including
  `visualViewport`, safe areas, focus, and inertness.

Initial setup (install, AXE fixture, hook config): see [SETUP.md](SETUP.md).
