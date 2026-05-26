---
name: visual-review
description: Browser-based frontend review for changed UI. Use before PRs with React/route/CSS changes to inspect screenshots, states, a11y, console errors, and cross-browser/mobile regressions.
---

# Visual Review

Browser-based QA for changed UI. Hooks catch static smells; this catches composed UI regressions that require seeing and interacting. See [REFERENCE.md](REFERENCE.md) for environment fingerprinting, platform risk map, and ecosystem wiring.

## When to run

Run before `/commit-push-pr` when diff touches rendered UI:

- `*.tsx`, `*.jsx`, `*.css`, `*.scss`, `*.html`
- `src/routes/`, `src/pages/`, `src/app/`, `src/components/`, `components/ui/`
- Tailwind/theme/config files that affect visuals

Skip only for docs-only, test-only, type-only, backend-only, or with explicit skip reason.

## Inputs

Accept route/component hints from the user. If omitted:

1. inspect `git diff --name-only HEAD`
2. map route files to URLs when obvious
3. map component edits to nearest affected route/story/test
4. if route cannot be inferred, ask one concise question

## Review matrix

Minimum:

- Chromium desktop
- Chromium mobile viewport
- keyboard-only pass: Tab, Shift+Tab, Enter, Space, Escape
- console/network error scan
- loading, empty, error, dense-data state where reachable
- form submit path when form UI changed
- notification/toast path when feedback UI changed

Prefer when feasible:

- Firefox desktop
- WebKit/mobile Safari equivalent
- reduced motion
- dark/light mode
- high contrast or forced colors for affected controls
- text zoom or larger default font when typography/layout changed
- RTL or localized-long-text sample when copy/layout changed
- back/forward navigation when route/search/theme/storage changed
- slow network/media throttling when images/video/loading changed

Use existing project scripts first (`scripts/skills-browser.sh`, Playwright, `bun run dev`). Never ask the user to verify visual UI manually when tools can do it.

## What to inspect

### Layout and visual polish

- horizontal overflow, clipped popovers, sticky/fixed overlap
- safe-area issues on mobile bottom/top UI
- viewport unit bugs: `100vh`, virtual keyboard, scrollbars, writing mode
- layout shift from skeletons, images, lazy video, fonts, accordions, tabs
- broken dense tables/cards/lists; captions/headers still explain tables
- dark/light contrast and token consistency
- text scaling, zoom, system font and OS default font behaviour
- CSS shorthand/complex layout edits remain readable and intentional

### Accessibility and semantics

- accessible names match visible intent
- native semantics first; ARIA only when needed
- `aria-label` is not used on static/generic elements and does not hide better visible text
- labels connect to inputs; password managers/autofill still work
- disabled vs `aria-disabled` behaviour is clear and keyboard-safe
- focus order, focus trap, Escape/close paths, no surprise autofocus
- buttons/links do not nest; links look and behave like links
- dialogs, popovers, custom selects, tabs, tables, forms
- forms submit correctly via Enter, buttons, and `requestSubmit()`-style paths
- toasts/notifications are announced, persistent enough, and not sole carrier for critical actions
- text effects, transforms, uppercase, strikethrough, emoji, generated content do not harm screen-reader output
- SVG/icons/images have meaningful names or are hidden decoratively

### Browser and platform behaviour

- Firefox/Safari differences, not just Chromium
- viewport/virtual-keyboard issues on mobile forms
- bfcache/back-forward state for theme/auth/search params
- smooth scrolling, scroll snapping, `scrollIntoView`, overscroll, and scrollbar-gutter side effects
- view-transition/reduced-motion behaviour and interaction blocking
- popover/dialog/select/native-control behaviour across browsers
- unsupported Baseline/new platform features have fallback or feature detection
- in-app browser/WebView quirks when relevant to product usage

### Performance-sensitive UI

- responsive images dimensions/sizes/lazy/preload rules
- responsive video/media has controls, captions where needed, and stable aspect ratio
- important images not hidden as CSS backgrounds when they need priority/alt
- large data URLs/assets, render-blocking additions, third-party embeds/scripts
- obvious Core Web Vitals risks: LCP image, CLS, INP/long interaction
- animation cost: transform/opacity preferred, no motion that ignores reduced-motion
- font loading: fallback, size-adjust/layout shift, oversized custom fonts

## Durable review heuristics

Use these as prompts, not all as mandatory checks:

- **HTML first**: prefer native controls and attributes before custom ARIA widgets.
- **User agents vary**: verify browser diversity for layout, native controls, fonts, scroll, media.
- **State beats happy path**: every changed view needs at least one unhappy state looked at.
- **Motion is interaction**: transitions, scroll animation, and smooth scrolling can break focus, timing, and reduced-motion expectations.
- **Content stress wins**: long text, localized strings, empty values, many rows, missing images, and slow media reveal more than perfect mock data.
- **Accessibility automation is partial**: axe is a floor; inspect names, focus, semantics, announcements, and keyboard behaviour manually.
- **Performance is visual**: layout shift, delayed LCP, blocked clicks, font swap, and heavy third-party UI are user-visible bugs.
- **If seen twice, automate**: repeated deterministic misses become hook/eval candidates.

## Output

Return concise report:

```markdown
## Visual review

Status: ready | needs fixes | blocked

Changed UI:
- <route/component>

Checked:
- <browser/viewport/state list>

Findings:
| Severity | Area | Finding | Evidence | Fix |
|---|---|---|---|---|
| P1 | /route mobile | ... | screenshot/console/a11y | ... |

Screenshots:
| View | Browser | Path | Notes |
|---|---|---|---|

PR notes:
- <rows usable in /commit-push-pr screenshot table>

Automation candidates:
- <repeatable misses worth hook/eval/docs>
```

Severity:

- P0: blocks use/security/data loss
- P1: should fix before PR
- P2: fix if low-risk, otherwise note
- P3: advisory

## Finish criteria

- P0/P1 fixed or explicitly accepted by user
- screenshot evidence captured for visual changes when app is runnable
- skip reasons recorded when any matrix item cannot run
- recurring deterministic issue suggested as hook/eval follow-up
