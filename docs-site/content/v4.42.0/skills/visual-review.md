---
description: "Review customer-facing surfaces from visual evidence. Use when web, mobile, CLI, TUI, desktop, reports, onboarding, forms, or other visible behavior changes."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["visual review"]}
sidebar: {"label":"/visual-review"}
title: "/visual-review"
type: "skill"
---
![Diagram of the /visual-review skill](/diagrams/skills/visual-review.svg)

[Open the editable Excalidraw source](/diagrams/skills/visual-review.excalidraw)


Browser-based frontend review: product, design, engineering, and QA hats. [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/visual-review/REFERENCE.md): **Design language handles**. Modes: `plan`, `implemented`, `regression`, `release`. Standalone trigger OK.

## Flow

Web UI: load [better-interface](https://github.com/malinskibeniamin/skills/blob/v4.42.0/jakubkrehel-skills/better-interface/SKILL.md).

1. Find: resolve PR base (stack parent) and inspect merge-base...HEAD, staged, unstaged, and relevant untracked changes; `git diff --name-only HEAD` misses commits. Map routes/components to URLs, CLI/reports to commands. Include shadcn/ui or `@/components/ui`, shared consumers, copy, styles, assets, indirect data/config effects. Cover every visible change.
2. Context: read tokens/theme and one surface; classify brand/product.
3. Collect: use repo tools, `scripts/skills-browser.sh`, Playwright, fixtures, screenshots, and output. `/quantify-impact` for direct metrics only.
4. review lanes: hierarchy/task flow; accessibility/performance; ship quality/system fit. Scored/repeated comparisons: [calibration](https://github.com/malinskibeniamin/skills/blob/v4.42.0/visual-review/REFERENCE.md#review-calibration).
5. Hats: Product: user value; Design: hierarchy; Engineering: resilience; QA: reproducible evidence.
6. Trace UI lifecycle: idle/unrequested -> pending/loading/submitting -> success/error -> settled/dismissed. Require side-effect success confirmed and failed side effects persistent.
7. Stress: Chromium desktop and Chromium mobile; `Tab, Shift+Tab, Enter, Space, Escape`; loading, empty, error, dense-data; form submit path; notification/toast path; console/network. As risk warrants add Firefox desktop, WebKit, reduced motion, forced colors, text zoom, RTL/localized-long-text, slow network/media throttling, and themes.
8. Close: cite evidence, name design handles, fix/accept P0-P1, and record deterministic Automation candidates.

Content/layout stress: Call the Skill tool with "break-ui". Reuse dogfood fixtures
and captures; test only uncovered cases. Preserve the read-only or authorized-fix endpoint.

Implemented/release: use [PR visual evidence](https://github.com/malinskibeniamin/skills/blob/v4.42.0/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5): reconcile every affected surface/state with captures and visual tests, inspect snapshot diffs before updating intended baselines, rerun normally, and refresh evidence after edits. Screenshots are not tests; tests are not before/after evidence.

HTML first. Lifecycle beats screenshot. State beats happy path. Motion is interaction. Content stress wins. Accessibility automation is partial. Performance is visual. If seen twice, automate.

`/excalidraw-diagram` as needed; screenshots primary, Mermaid fallback.

## Output

Use concise Markdown. For release/non-trivial review, write `$TMPDIR/visual-review-<timestamp>.html`.

```markdown
## Visual review
State trace: | Surface | Trigger | Pending | Success | Error | Persistence | Evidence |
Findings: | Severity | Hat | Surface | Evidence | Impact | Fix | Automate? |
Design findings: | Severity | Surface | Handle | Current read | Desired read | Adjustment |
Automation candidates: <hook/eval/test>
```

P0 blocks use/security/data loss/infinite loop; P1 blocks PR. Finish after resolution/acceptance, evidence, and tracked repeatable gaps.
