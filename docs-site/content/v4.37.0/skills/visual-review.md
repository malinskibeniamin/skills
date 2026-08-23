---
title: "/visual-review"
description: "Review customer-facing surfaces from visual evidence. Use when web, mobile, CLI, TUI, desktop, reports, onboarding, forms, or other visible behavior changes."
type: skill
sidebar:
  label: "/visual-review"
---
![Diagram of the /visual-review skill](/diagrams/skills/visual-review.svg)

[Open the editable Excalidraw source](/diagrams/skills/visual-review.excalidraw)

Review customer-facing surfaces with product, design, engineering, and QA hats.
Browser-based frontend review is common; mobile screens, CLI/TUI, desktop, and generated
reports also count. Read [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/visual-review/REFERENCE.md) for the evidence matrix, design
language, platform checks, report contract, and house taste.

Modes: `plan`, `implemented`, `regression`, `release`. Standalone trigger OK.

## Flow

1. **Find surfaces:** use hints or `git diff --name-only HEAD`; map routes/components to
   URLs and CLI/report changes to commands. Include shadcn/ui or `@/components/ui`.
2. **Bootstrap context:** read tokens/theme and one representative surface. Classify brand
   versus product register before judging.
3. **Collect evidence:** use repo tools, `scripts/skills-browser.sh`, Playwright, fixtures,
   screenshots, and command output. Run `/quantify-impact` when a direct UI value or
   performance metric exists; skip measurement ceremony for tiny changes.
4. **Run review lanes:** critique (hierarchy and task flow), audit (accessibility,
   responsive behavior, performance), polish (ship quality and system fit).
5. **Apply hats:** Product: user value and friction. Design: hierarchy, affordance, copy,
   states, taste. Engineering: resilience, timing, platform, performance.
   QA: reproducible evidence, unhappy paths, regression, automation.
6. **Trace UI lifecycle:** idle/unrequested -> pending/loading/submitting -> success/error -> settled/dismissed.
   Verify side-effect success confirmed and failed side effects persistent.
7. **Stress the matrix:** Chromium desktop and mobile; keyboard Tab, Shift+Tab, Enter,
   Space, Escape; loading, empty, error, dense-data; form submit path; notification/toast
   path; console/network. Add Firefox desktop, WebKit, reduced motion, forced colors, text
   zoom, RTL/localized-long-text, slow network/media throttling, and dark/light when risk
   warrants.
8. **Report and close:** cite evidence, name design handles, fix P0/P1 or record acceptance,
   and capture deterministic repeats as Automation candidates.

Use the reference checklist for safe-area and virtual keyboard behavior, writing mode,
tables, CSS shorthand/complex layout, ARIA only when needed, static/generic elements,
password managers/autofill, `aria-disabled`, focus, nested buttons/links, `requestSubmit`,
toasts, media, WebView, bfcache, scrolling, native-control behaviour, feature detection,
responsive images/video, aspect ratio, INP/long interaction, font loading, and third-party
embeds/scripts.

Heuristics: HTML first. Lifecycle beats screenshot. State beats happy path. Motion is interaction.
Content stress wins. Accessibility automation is partial. Performance is visual. If seen twice, automate.

## Flow maps

When screenshots cannot explain a non-trivial state journey, UI/system boundary, or
before/after structure, use `/excalidraw-diagram` for one concise flow map. Keep
screenshots as the primary evidence; the map explains relationships, not pixels. Embed
its inline SVG or data-encoded PNG in the HTML report and report the adjacent editable
`.excalidraw` path.
For a simple graph or unavailable canvas, use Mermaid as the fallback and record the limit.

## Output

Write a concise report. For non-trivial or release review, create
`$TMPDIR/visual-review-<timestamp>.html`.

```markdown
## Visual review
Status: ready | needs fixes | blocked
Changed UI: <surfaces>
Checked: <browser/viewport/state/terminal evidence>
State trace: | Surface | Trigger | Pending | Success | Error | Persistence/dismissal | Evidence |
Findings: | Severity | Hat | Surface | Evidence | Why it matters | Fix | Automate? |
Design findings: | Severity | Surface | Handle | Current read | Desired read | Adjustment |
Screenshots: | View | Browser | Path | Notes |
Impact: <Proven impact table + verdict, or why measurement was not useful>
Automation candidates: <deterministic hook/eval/test candidates>
```

P0 blocks use/security/data loss/infinite loop. P1 blocks PR. Finish when P0/P1 are fixed or
accepted, evidence is captured or explicitly skipped, and repeatable gaps are tracked.
