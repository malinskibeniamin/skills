---
name: mobile-native
description: "Fix mobile web viewport, touch, safe-area, keyboard, scrolling, or PWA chrome issues. Use for phone-specific web behavior, not React Native or Swift."
---

Remove browser/platform friction without disabling accessibility. Adapted from Emil
Kowalski; [provenance](../shared/EMIL-SKILLS-CREDITS.md).
Review requests stay read-only; fixes follow project TDD and delivery gates.

## Diagnose and scope

For responsive grouping, RTL and safe-area structure, read
[interface compatibility](../shared/INTERFACES.md#better-layout), then
[better-layout](../jakubkrehel-skills/better-layout/SKILL.md).
For font rendering or input zoom, use [better-typography](../jakubkrehel-skills/better-typography/SKILL.md)
without disabling user scaling or replacing this skill's device checks.

Identify the reported phone/browser, layout, input path, keyboard/PWA mode, and supported
devices. Reproduce before changing defaults. Use capability queries rather than user-agent
sniffing; touch and mouse can coexist. Existing UI primitives and tokens remain owners.

| Symptom | Narrow correction |
|---|---|
| Sticky hover after tap | Gate decorative hover with `(hover: hover) and (pointer: fine)`; keep focus/press feedback |
| Tap highlight competes with designed feedback | Scope transparent tap highlight to controls only after equivalent feedback exists |
| Bottom action under browser chrome | `100dvh` for the app shell; `100svh` for stable hero content |
| Input focus zoom | At least 16 CSS px computed input text; retain user scaling |
| Press feels late | CSS `:active`/pointer-down feedback; keep activation on accessible click/submit |
| Scroll chains behind a sheet | `overscroll-behavior: contain` on the actual scroller |
| Notch/home indicator covers content | `viewport-fit=cover`, then padding with `env(safe-area-inset-*, 0px)` |
| Control label selected while dragging | Scope `user-select: none` to that control; keep readable content selectable |
| Custom horizontal gesture fights scrolling | Local `touch-action: pan-y pinch-zoom`; preserve vertical scroll and pinch zoom |
| Theme chrome mismatches | Theme metadata consistent with actual resolved app theme |

Read [PLATFORM.md](PLATFORM.md) for keyboard, gesture, overscroll, and PWA details.
Check current browser support before applying optional viewport/meta features.

## Preserve function

- Keep `width=device-width, initial-scale=1`; preserve pinch zoom and large text.
  Never set `user-scalable=no` or cap zoom at `maximum-scale=1`.
- Restrict gesture ownership to its handle/surface. Preserve pinch zoom when setting
  `touch-action`; `none` is not a general drag fix. Prefer native scroll/snap when it works.
- Do not replace `click` with `pointerdown` activation: press feedback differs from
  committing an action. Keyboard activation, scrolling away, and `pointercancel` must work.
- Root overscroll changes are product-specific. Keep browser refresh/scroll behavior
  on documents; contain only the app region that owns the gesture.
- Preserve copy/select, link context menus, focus rings, and semantic control roles.
  Keep listeners passive unless a narrowly justified cancellation actually needs otherwise.

## Verify

Replay touch and keyboard journeys, pinch zoom/200% text, portrait/landscape, open keyboard,
address-bar expansion/collapse, nested scrolling, and supported light/dark/PWA modes.
Browser emulation checks layout; record which behaviors were confirmed on physical hardware.
If hardware is unavailable, report code/emulation evidence and the remaining phone checks.
Do not expose the dev server on the network solely to satisfy this skill.

Report symptom -> changed declaration -> observed behavior, plus unverified device paths.
