---
name: visual-review
description: Review customer-facing surfaces from visual evidence. Use when web, mobile, CLI, TUI, desktop, reports, onboarding, forms, or other visible behavior changes.
---

Browser-based frontend review. [REFERENCE.md](REFERENCE.md): **Design language handles**, modes and standalone use.

## Flow

Apply [proportionate verification](../shared/verifiability.md#proportionate-verification).
Routine copy/style edits need focused rendering; reuse dogfood evidence.
Expand devices/states/reports only for changed assumptions.

Web UI: load [better-interface](../jakubkrehel-skills/better-interface/SKILL.md).

1. Find: resolve PR base (stack parent) and inspect merge-base...HEAD, staged, unstaged, and relevant untracked changes; `git diff --name-only HEAD` misses commits. Map routes/components to URLs, CLI/reports to commands. Include shadcn/ui or `@/components/ui`, shared consumers, copy, styles, assets, indirect data/config effects. Cover every visible change.
2. Context: read tokens/theme and one surface; classify brand/product.
3. Collect: use repo tools, `scripts/skills-browser.sh`, Playwright, fixtures, screenshots, and output. `/quantify-impact` for direct metrics only.
4. review lanes: hierarchy/task flow; accessibility/performance; ship quality/system fit. Scored/repeated comparisons: [calibration](REFERENCE.md#review-calibration).
5. Hats: Product: user value; Design: hierarchy; Engineering: resilience; QA: reproducible evidence.
6. Trace UI lifecycle: idle/unrequested -> pending/loading/submitting -> success/error -> settled/dismissed. Require side-effect success confirmed and failed side effects persistent.
7. Stress affected risks: viewports, keyboard/focus, loading/empty/error/dense-data, forms/toasts, console/network. Expand browsers, motion, colors, zoom, RTL, themes or throttling only when warranted/required.
8. Close: cite evidence, name design handles, fix/accept P0-P1, and record deterministic Automation candidates.

Content/layout stress: Call the Skill tool with "break-ui". Reuse dogfood fixtures
and captures; test only uncovered cases. Preserve the read-only or authorized-fix endpoint.

Implemented/release: use [PR visual evidence](../commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)
only when helpful/required. Review snapshot diffs before updates; rerun normally.
Annotate hard-to-find deltas only; read-only: report gaps. Screenshots are not tests.

Approved-image matches/visual fixes: [target and evidence checks](REFERENCE.md#target-and-evidence-checks).

Rendered behavior first. Lifecycle beats screenshot. State beats happy path. Motion is interaction. Accessibility automation is partial. Automate worthwhile recurring checks.

`/excalidraw-diagram` as needed; screenshots primary, Mermaid fallback.

## Output

Concise Markdown inline; omit empty tables. Separate HTML only when requested.

```markdown
## Visual review
State trace: | Surface | Trigger | Pending | Success | Error | Persistence | Evidence |
Findings: | Severity | Hat | Surface | Evidence | Impact | Fix | Automate? |
Design findings: | Severity | Surface | Handle | Current read | Desired read | Adjustment |
Automation candidates: <hook/eval/test>
```

P0 blocks use/security/data loss/infinite loop; P1 blocks PR. Finish after resolution/acceptance, evidence, and tracked repeatable gaps.
