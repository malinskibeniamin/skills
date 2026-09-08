---
name: visual-review
description: Review customer-facing surfaces from visual evidence. Use when web, mobile, CLI, TUI, desktop, reports, onboarding, forms, or other visible behavior changes.
---

Review customer-facing surfaces with product, design, engineering, and QA hats. Browser-based frontend review is common; mobile screens, CLI/TUI, desktop, and generated reports count. [REFERENCE.md](REFERENCE.md) owns **Design language handles** and detail. Modes: `plan`, `implemented`, `regression`, `release`. Standalone trigger OK.

## Flow

1. **Find:** resolve the PR base (stack parent when applicable) and inspect merge-base...HEAD plus staged, unstaged, and relevant untracked changes; `git diff --name-only HEAD` alone misses committed work. Map routes/components to URLs and CLI/reports to commands. Include shadcn/ui or `@/components/ui`, shared consumers, copy, styles, assets, and indirect data/config effects. No visible change is too small.
2. **Context bootstrap:** read tokens/theme and one surface; classify brand versus product.
3. **Collect:** use repo tools, `scripts/skills-browser.sh`, Playwright, fixtures, screenshots, and output. Use `/quantify-impact` only for direct metrics.
4. Run **review lanes:** critique hierarchy/task flow; audit accessibility/performance; polish ship quality/system fit.
5. **Hats:** Product: user value; Design: hierarchy/copy/states; Engineering: resilience/platform; QA: reproducible evidence/unhappy paths.
6. **Trace UI lifecycle:** idle/unrequested -> pending/loading/submitting -> success/error -> settled/dismissed. Require side-effect success confirmed and failed side effects persistent.
7. **Stress:** Chromium desktop and Chromium mobile; `Tab, Shift+Tab, Enter, Space, Escape`; loading, empty, error, dense-data; form submit path; notification/toast path; console/network. As risk warrants add Firefox desktop, WebKit, reduced motion, forced colors, text zoom, RTL/localized-long-text, slow network/media throttling, and themes.
8. **Close:** cite evidence, name design handles, fix/accept P0-P1, and record deterministic Automation candidates.

Implemented/release: follow [PR visual evidence](../commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5): reconcile every affected surface/state with captures and visual tests, inspect snapshot diffs before updating intended baselines, rerun normally, and refresh evidence after edits. Screenshots are not visual tests; passing tests are not embedded before/after evidence.

HTML first. Lifecycle beats screenshot. State beats happy path. Motion is interaction. Content stress wins. Accessibility automation is partial. Performance is visual. If seen twice, automate.

Use `/excalidraw-diagram` if needed; screenshots primary, Mermaid fallback.

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
