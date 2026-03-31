---
name: setup-accessibility
description: Enforce ARIA accessibility via PostToolUse hooks — labels, keyboard handlers, widget attributes, Playwright AXE setup. Use when setting up a11y enforcement, WCAG 2.1 AA compliance, or accessibility testing.
---

# Setup Accessibility

## What This Sets Up

PostToolUse hook on Edit/Write catching accessibility anti-patterns in TSX/JSX:

- **Ban `<img>` without `alt`** — images must have `alt` text (use `alt=""` for decorative images)
- **Ban mouse-only event handlers** — `onClick` on non-interactive elements (`<div>`, `<span>`) requires `role`, `tabIndex`, and `onKeyDown`/`onKeyUp`
- **Ban missing ARIA attributes on widget roles** — `role="combobox"` needs `aria-expanded` + `aria-controls`, `role="dialog"` needs `aria-label`/`aria-labelledby`, `role="tablist"` needs child `role="tab"` elements

Also includes:
- **Playwright AXE** test setup for automated WCAG 2.1 AA scanning
- **ARIA Patterns Reference** — correct markup for combobox, tabs, dialog, accordion, and more

## Steps

### 1. Install Playwright AXE

```bash
bun add -D @axe-core/playwright --yarn
```

### 2. Create hook script

Copy [`scripts/accessibility-check.sh`](scripts/accessibility-check.sh) and [`scripts/_hook-lib.sh`](scripts/_hook-lib.sh) into `.claude/hooks/`. Make executable.

### 3. Configure hook in `.claude/settings.json`

Add to hooks config: **PostToolUse** (matcher: `Edit|Write`): `.claude/hooks/accessibility-check.sh`

### 4. Create accessibility test helper

Write the test fixture from [REFERENCE.md](REFERENCE.md) into your test utilities.

### 5. Verify

- [ ] Hook blocks `<div onClick>` without `role` + `tabIndex` + keyboard handler
- [ ] Hook blocks `<img>` without `alt`
- [ ] Hook blocks `role="combobox"` without `aria-expanded`
- [ ] Hook skips non-TSX/JSX files
- [ ] `@axe-core/playwright` is installed
- [ ] Accessibility test helper runs against a sample page

### 6. Commit

Stage all files and commit: `Add accessibility enforcement hook + Playwright AXE setup`
