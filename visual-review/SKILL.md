---
name: visual-review
description: Reviews customer-facing surfaces with product, design, engineering, and QA hats using visual or interaction evidence. Use when changes affect web UI, mobile screens, CLI/TUI output, desktop apps, generated reports, onboarding flows, forms, or any user-visible behavior before PRs or releases.
---

# Visual Review

Multi-hat review for changed customer-facing surfaces. Browser-based frontend review remains the common path; terminal output, snapshots, and generated reports count too. Hooks catch static smells; this catches product, design, interaction, and resilience bugs that need seeing or trying. See [REFERENCE.md](REFERENCE.md) and [HTML-REPORT.md](HTML-REPORT.md).
## Run

Standalone trigger OK: `/visual-review`. Also run before `/commit-push-pr` when diff touches rendered UI: `*.tsx`, `*.jsx`, `*.css`, `*.scss`, `*.html`; `src/routes/`, `src/pages/`, `src/app/`, `src/components/`, `components/ui/`; Tailwind/theme/config files that affect visuals. Also run for customer-facing CLI/TUI/mobile/desktop/report output. Skip only docs-only, test-only, type-only, backend-only, or explicit skip reason.

Modes:
- `plan`: before build; product/design risk review.
- `implemented`: after diff; evidence-based review.
- `regression`: bug fix; before/after behavior.
- `release`: PR-ready report.
## Inputs

Accept route/component/command/surface hints. If omitted: inspect `git diff --name-only HEAD`; map route files to URLs when obvious; map component edits to nearest affected route/story/test; map CLI/TUI/report edits to commands or generated output; if surface cannot be inferred, ask one concise question.
## Review hats
- Product: user value, clarity, task success, friction, competitive quality.
- Design: hierarchy, spacing, affordance, copy, visual consistency, taste, states.
- Engineering: resilience under slow network, async races, platform/browser/device risk, performance.
- QA: reproducible evidence, unhappy paths, regression risk, automation candidates.
## Review matrix
Minimum:
- Chromium desktop; Chromium mobile viewport; keyboard-only pass: Tab, Shift+Tab, Enter, Space, Escape.
- console/network error scan; loading, empty, error, dense-data state where reachable.
- form submit path when form UI changed; notification/toast path when feedback UI changed.
- For non-web surfaces: capture command output/screenshot, narrow/wide terminal, color/no-color, error/empty/slow path.
Prefer when feasible:
- Firefox desktop; WebKit/mobile Safari equivalent.
- reduced motion; dark/light mode; high contrast or forced colors.
- text zoom or larger default font when typography/layout changed.
- RTL or localized-long-text sample when copy/layout changed.
- back/forward navigation when route/search/theme/storage changed.
- slow network/media throttling when images/video/loading changed.
Use project scripts first: `scripts/skills-browser.sh`, Playwright, `bun run dev`, Storybook, CLI fixtures. Never ask user to verify a customer-facing surface manually when tools can.
## Inspect
### Layout/polish
- horizontal overflow; clipped popovers; sticky/fixed overlap; safe-area issues on mobile bottom/top UI.
- viewport unit bugs: `100vh`, virtual keyboard, scrollbars, writing mode.
- layout shift from skeletons, images, lazy video, fonts, accordions, tabs.
- broken dense tables/cards/lists; captions/headers still explain tables.
- dark/light contrast and token consistency; text scaling, zoom, system font and OS default font behaviour.
- CSS shorthand/complex layout edits remain readable and intentional.
### A11y/semantics
- accessible names match visible intent; native semantics first; ARIA only when needed.
- `aria-label` not used on static/generic elements and not hiding visible text.
- labels connect to inputs; password managers/autofill still work.
- disabled vs `aria-disabled` behaviour clear and keyboard-safe.
- focus order, focus trap, Escape/close paths, no surprise autofocus.
- buttons/links do not nest; links look and behave like links.
- dialogs, popovers, custom selects, tabs, tables, forms.
- forms submit correctly via Enter, buttons, and `requestSubmit()`-style paths.
- toasts/notifications announced, persistent enough, not sole carrier for critical actions.
- text effects, transforms, uppercase, strikethrough, emoji, generated content do not harm screen-reader output.
- SVG/icons/images have meaningful names or are hidden decoratively.
### Browser/platform/perf
- Firefox/Safari differences, not just Chromium; in-app browser/WebView quirks when relevant.
- viewport/virtual-keyboard issues on mobile forms; bfcache/back-forward state for theme/auth/search params.
- smooth scrolling, scroll snapping, `scrollIntoView`, overscroll, and scrollbar-gutter side effects.
- view-transition/reduced-motion behaviour and interaction blocking.
- popover/dialog/select/native-control behaviour across browsers.
- unsupported Baseline/new platform features have fallback or feature detection.
- responsive images dimensions/sizes/lazy/preload rules; responsive video/media controls, captions, stable aspect ratio.
- important images not hidden as CSS backgrounds when they need priority/alt; large data URLs/assets, third-party embeds/scripts.
- obvious Core Web Vitals risks: LCP image, CLS, INP/long interaction; font loading shift; transform/opacity animations.
## Heuristics

HTML first. User agents vary. State beats happy path. Motion is interaction. Content stress wins. Accessibility automation is partial. Performance is visual. If seen twice, automate.
## Output

Return concise report and, for non-trivial/release mode, write an HTML report to `$TMPDIR/visual-review-<timestamp>.html` (fallback `/tmp`) and open it. Report format:
```markdown
## Visual review
Status: ready | needs fixes | blocked
Changed UI: <routes/components/commands/surfaces>
Checked: <browser/viewport/state/terminal list>
Findings: | Severity | Hat | Surface | Evidence | Why it matters | Fix | Automate? |
Screenshots: | View | Browser | Path | Notes |
PR notes: <rows usable in /commit-push-pr screenshot table>
HTML report: <absolute path or skip reason>
Automation candidates: <repeatable misses worth hook/eval/docs>
```

Severity: P0 blocks use/security/data loss/infinite loop. P1 fix before PR. P2 low-risk improvement. P3/nit advisory.
## Finish

P0/P1 fixed or user accepted. Screenshot/terminal evidence captured for customer-facing changes when runnable. Skip reasons recorded for unrun matrix items. Recurring deterministic issue suggested as hook/eval follow-up.
