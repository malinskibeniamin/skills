---
name: visual-review
description: Reviews customer-facing surfaces with product, design, engineering, and QA hats using visual or interaction evidence. Use when changes affect web UI, mobile screens, CLI/TUI, desktop, generated reports, onboarding, forms, or user-visible behavior before PRs/releases.
---

# Visual Review

Multi-hat review for changed customer-facing surfaces. Browser-based frontend review common path; terminal output, snapshots, generated reports count too. Hooks catch static smells; this catches product/design/interaction/resilience bugs needing eyes or use. See [REFERENCE.md](REFERENCE.md), [HTML-REPORT.md](HTML-REPORT.md), [EXAMPLES.md](EXAMPLES.md).

## Run
Standalone trigger OK: `/visual-review`. Before `/commit-push-pr` when diff touches rendered UI: `*.tsx`, `*.jsx`, `*.css`, `*.scss`, `*.html`; `src/routes/`, `src/pages/`, `src/app/`, `src/components/`, `components/ui/`; Tailwind/theme/config files that affect visuals. Also for CLI/TUI/mobile/desktop/report output. Skip only docs-only, test-only, type-only, backend-only, or explicit skip reason.

Modes: `plan` before build; `implemented` after diff; `regression` for bug before/after; `release` for PR report.

## Inputs
Accept route/component/command/surface hints. If omitted: inspect `git diff --name-only HEAD`; map routes -> URLs, components -> route/story/test, CLI/TUI/report edits -> commands/output. If unclear, ask one concise question.

## Hats
- Product: user value, clarity, task success, friction, competitive quality.
- Design: hierarchy, spacing, affordance, copy, visual consistency, taste, states.
- Engineering: resilience under slow network, async races, platform/browser/device risk, performance.
- QA: reproducible evidence, unhappy paths, regression risk, automation candidates.

## Matrix
Minimum:
- Chromium desktop; Chromium mobile viewport; keyboard-only: Tab, Shift+Tab, Enter, Space, Escape.
- console/network scan; loading, empty, error, dense-data state where reachable.
- form submit path when form UI changed; notification/toast path when feedback UI changed.
- Non-web: command output/screenshot, narrow/wide terminal, color/no-color, error/empty/slow path.

Prefer:
- Firefox desktop; WebKit/mobile Safari equivalent.
- reduced motion; dark/light mode; high contrast or forced colors.
- text zoom or larger default font when typography/layout changed.
- RTL or localized-long-text sample when copy/layout changed.
- back/forward navigation when route/search/theme/storage changed.
- slow network/media throttling when images/video/loading changed.

Use project scripts first: `scripts/skills-browser.sh`, Playwright, `bun run dev`, Storybook, CLI fixtures. Never ask user to verify customer-facing surface manually when tools can.

## Inspect
Layout/polish: overflow; clipped popovers; sticky/fixed overlap; safe-area; `100vh`; virtual keyboard; scrollbars; writing mode; skeleton/image/font/lazy-video CLS; dense tables/cards/lists; captions/headers still explain tables; token consistency; text scaling; system fonts; CSS shorthand/complex layout.

A11y/semantics: accessible names match visible intent; native semantics; ARIA only when needed; aria-label not used on static/generic elements; labels connect; password managers/autofill; disabled vs `aria-disabled`; focus order/trap/return; Escape; no surprise autofocus; buttons/links do not nest; dialogs/popovers/selects/tabs/tables/forms; Enter/requestSubmit; toasts announced, persistent, not sole carrier for critical actions; strikethrough, emoji, generated content; SVG/icons/images named or decorative.

Browser/platform/perf: Firefox/Safari/WebView; mobile forms; bfcache/back-forward; smooth scrolling, scroll snapping, `scrollIntoView`, overscroll, scrollbar-gutter; view transitions; reduced motion; interaction blocking; native-control behaviour; feature detection; responsive images; responsive video/media controls, captions, stable aspect ratio; LCP/CLS/INP/long interaction; font loading; third-party embeds/scripts; transform/opacity animations.

## Heuristics
HTML first. User agents vary. State beats happy path. Motion is interaction. Content stress wins. Accessibility automation is partial. Performance is visual. If seen twice, automate.

## Output
Return concise report. Non-trivial/release mode: write HTML report to `$TMPDIR/visual-review-<timestamp>.html` (fallback `/tmp`) and open.

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
P0/P1 fixed or accepted. Evidence captured when runnable. Skip reasons for unrun matrix. Recurring deterministic issue -> hook/eval/test follow-up.
