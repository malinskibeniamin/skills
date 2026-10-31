---
description: "Use when React needs ARIA, keyboard, focus, form, or nested-control accessibility."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["accessibility"]}
sidebar: {"label":"/accessibility"}
title: "/accessibility"
type: "skill"
---
![Diagram of the /accessibility skill](/diagrams/skills/accessibility.svg)

[Open the editable Excalidraw source](/diagrams/skills/accessibility.excalidraw)

Manual WCAG checks: load [better-accessibility](https://github.com/malinskibeniamin/skills/blob/v4.42.0/jakubkrehel-skills/better-accessibility/SKILL.md).

One owner per rule:

- **Biome** owns image `alt`, custom-control keyboard support, combobox ARIA and labels.
- **React Doctor** owns structure and naming: dialogs, nested controls, accessible
  names, persistent labels, and described invalid fields.
- **The local hook** only pairs `tablist` with child `tab` roles and `data-invalid` with
  `aria-invalid`.

Do not duplicate checks. Escape hatch: `// allow: a11y-skip [reason]`.

## Interaction contracts

- Prefer native controls and visible text. Custom clickable elements need a role,
  `tabIndex`, and equivalent keyboard behavior.
- Keep clickable containers free of interactive descendants; otherwise use a passive
  container. Never nest pressables.
- Comboboxes expose `aria-expanded` and `aria-controls`; tablists contain tabs.
- Use `aria-label` only without a visible name; it or `aria-labelledby` can replace
  descendant text. Omit redundant words such as `icon` or `button`.
- Form controls have persistent labels. Connect visible errors with `aria-invalid` and a
  current `aria-describedby`; remove stale error IDs when validation clears.
- Unclear names: inspect the accessibility tree; follow
  [WAI-ARIA naming guidance](https://www.w3.org/WAI/ARIA/apg/practices/names-and-descriptions/).

## Visual and focus checks

- Keep a contrasting 2px focus indicator; expose hover actions to keyboard and touch users.
- DOM order matches reading and tab order. Reordered layouts need keyboard and screen-reader
  evidence.
- Modal surfaces trap and restore focus and make the background inert.
- Avoid color-only state; pair color with text, icon, or shape and support forced colors with
  `currentcolor`.
- Keep touch targets at least 44 by 44 CSS pixels. Gate hover-only effects with
  `@media (hover: hover) and (pointer: fine)`.
- For reduced motion, preserve feedback through opacity, color, text, or instant state changes.
- Support 200% text zoom without loss.
- Verify high-risk mobile overlays on a physical device or simulator, including
  `visualViewport`, safe areas, focus, and inertness.

Setup (install, AXE, hooks): [SETUP.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/accessibility/SETUP.md).
