---
name: accessibility
description: React accessibility patterns -- ARIA labels, keyboard handlers, widget attributes, nested-pressable fixes, AXE testing. Use when building or reviewing components, dialogs, forms, keyboard navigation, or fixing a11y findings.
paths:
  - "src/components/**/*.tsx"
---

# Accessibility Enforcement
## What This Catches

Enforcement is split across three owners -- one owner per rule:

- **Biome (ultracite preset)** -- single-element rules: `<img>` alt (`a11y/useAltText`), clickable `<div>`/`<span>` keyboard support (`a11y/useKeyWithClickEvents` and friends), combobox required ARIA (`a11y/useAriaPropsForRole`), label association (`a11y/noLabelWithoutControl`)
- **React Doctor (Stop hook)** -- structural rules: dialog accessible name (`a11y/dialog-has-accessible-name`), nested interactives (`correctness/html-no-nested-interactive`), redundant name wording like `Search icon` (`a11y/img-redundant-alt`), placeholder-as-label (`a11y/label-has-associated-control`)
- **This hook** -- only the cross-attribute pairings neither engine expresses: `role="tablist"` needs child `role="tab"`; `aria-invalid` needs `aria-describedby`; `data-invalid` (CSS-only) needs `aria-invalid`

Escape hatch: `// allow: a11y-skip [reason]`

## No Nested Pressables

Interactive components ONE pattern -- never both:

**Pattern A: Container clickable** -- no interactive children.
```tsx
<ListCard onClick={handleSelect}>
  <Avatar src={user.avatar} />
  <Text>{user.name}</Text>
  <ChevronRightIcon /> {/* visual indicator only, not a button */}
</ListCard>
```

**Pattern B: Children interactive** -- container not clickable.
```tsx
<ListCard>
  <Avatar src={user.avatar} />
  <Text>{user.name}</Text>
  <DropdownMenu>
    <DropdownMenuTrigger asChild>
      <Button variant="ghost" size="icon"><MoreVerticalIcon /></Button>
    </DropdownMenuTrigger>
  </DropdownMenu>
</ListCard>
```

Why: ambiguous click targets, event bubbling bugs, screen readers can't convey interaction model, touch targets overlap on mobile.

## Visual Checklist

- [ ] Focus rings visible on all interactive elements (min 2px, contrasting color)
- [ ] Hover and focus styles match (no mouse-only affordances)
- [ ] Color not sole means of conveying info
- [ ] DOM order matches reading and tab order; visual CSS reordering has keyboard and screen reader evidence
- [ ] Accessible names match visible intent and action; no "icon", "button", or "image" names
- [ ] Form fields have persistent labels; placeholder only gives examples or formatting hints
- [ ] Dialogs, sheets, and popovers trap focus, return focus on close, and make background inert when modal
- [ ] Error, selected, warning, and success states never rely on color-only state; pair color with text, icon, or shape
- [ ] Touch targets min 44x44 CSS pixels
- [ ] `prefers-reduced-motion` respected for animations
- [ ] reduced motion keeps essential feedback through opacity, color, text, or instant state changes instead of large movement
- [ ] Hover-only effects are gated for touch devices with `@media (hover: hover) and (pointer: fine)`
- [ ] Mobile drawers/sheets handle virtual keyboards with `visualViewport`, safe-area spacing, focus trap, focus return, and background inertness
- [ ] High-risk mobile interactions have physical device or simulator evidence, especially drawers, sheets, swipe gestures, and destructive holds
- [ ] `forced-colors` / high-contrast mode: use `currentcolor` for SVG fills
- [ ] Text resizable to 200% without content loss

Initial setup (install, AXE fixture, hook config): see [SETUP.md](SETUP.md).
