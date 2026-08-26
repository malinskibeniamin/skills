---
name: visual-review
description: Review customer-facing surfaces from visual evidence. Use when web, mobile, CLI, TUI, desktop, reports, onboarding, forms, or other visible behavior changes.
---

Review customer-facing surfaces with product, design, engineering, and QA hats. Browser-based frontend review is common; mobile screens, CLI/TUI, desktop, and generated reports count. [REFERENCE.md](REFERENCE.md) owns **Design language handles** and detail. Modes: `plan`, `implemented`, `regression`, `release`. Standalone trigger OK.

## Flow

1. **Find:** use hints or `git diff --name-only HEAD`; map routes/components to URLs and CLI/reports to commands. Include shadcn/ui or `@/components/ui`.
2. **Context bootstrap:** read tokens/theme and one surface; classify brand versus product.
3. **Collect:** use repo tools, `scripts/skills-browser.sh`, Playwright, fixtures, screenshots, and output. Use `/quantify-impact` only for direct metrics.
4. Run **review lanes:** critique hierarchy/task flow; audit accessibility/performance; polish ship quality/system fit.
5. **Hats:** Product: user value; Design: hierarchy/copy/states; Engineering: resilience/platform; QA: reproducible evidence/unhappy paths.
6. **Trace UI lifecycle:** idle/unrequested -> pending/loading/submitting -> success/error -> settled/dismissed. Require side-effect success confirmed and failed side effects persistent.
7. **Stress:** Chromium desktop and Chromium mobile; `Tab, Shift+Tab, Enter, Space, Escape`; loading, empty, error, dense-data; form submit path; notification/toast path; console/network. As risk warrants add Firefox desktop, WebKit, reduced motion, forced colors, text zoom, RTL/localized-long-text, slow network/media throttling, and themes.
8. **Close:** cite evidence, name design handles, fix/accept P0-P1, and record deterministic Automation candidates.

Check: safe-area/virtual keyboard; writing mode; captions/headers still explain tables; CSS shorthand/complex layout; ARIA only when needed, not on static/generic elements; password managers/autofill; `aria-disabled`; no surprise autofocus; buttons/links do not nest; `requestSubmit`; toasts not sole carrier for critical actions; strikethrough, emoji, generated content; SVG/icons/images; smooth scrolling, scroll snapping, `scrollIntoView`; interaction blocking; native-control behaviour; feature detection; WebView/bfcache; responsive images and responsive video/media with stable aspect ratio; INP/long interaction; font loading; third-party embeds/scripts.

HTML first. Lifecycle beats screenshot. State beats happy path. Motion is interaction. Content stress wins. Accessibility automation is partial. Performance is visual. If seen twice, automate.

When screenshots are insufficient, use `/excalidraw-diagram`; screenshots primary, Mermaid fallback.

## Output

Write concise Markdown. For release/non-trivial review, create `$TMPDIR/visual-review-<timestamp>.html`.

```markdown
## Visual review
State trace: | Surface | Trigger | Pending | Success | Error | Persistence | Evidence |
Findings: | Severity | Hat | Surface | Evidence | Impact | Fix | Automate? |
Design findings: | Severity | Surface | Handle | Current read | Desired read | Adjustment |
Automation candidates: <hook/eval/test>
```

P0 blocks use/security/data loss/infinite loop; P1 blocks PR. Finish after resolution/acceptance, evidence, and tracked repeatable gaps.
