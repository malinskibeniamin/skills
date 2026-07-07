---
name: visual-review
description: Reviews customer-facing surfaces with product, design, engineering, and QA hats from visual evidence. Use when web UI, mobile screens, CLI/TUI, desktop, generated reports, onboarding, forms, or user-visible behavior changes.
---

# Visual Review

Repo/code changes: run `/deslop` before commit, push, PR, or merge.
Surface review for anything user sees/uses. Evidence > opinion. Browser-based frontend review common; CLI/TUI/report output counts. Design language handles turn vague taste into actionable adjustments. Details: [REFERENCE.md](REFERENCE.md).

## When

Standalone trigger OK: `/visual-review`. Before PR/release for surface diffs: `*.tsx|jsx|css|scss|html|mdx`, routes/pages/app/components/ui, shadcn/ui or `@/components/ui`, Tailwind/theme/tokens, forms/dialogs/popovers/tables/toasts/nav/media/animation/scroll, CLI/TUI/mobile/desktop/report output. Skip only docs/test/type/backend-only or explicit reason.

Modes: `plan`, `implemented`, `regression`, `release`.

Builder.io artifacts: `plan` mode may publish `/visual-plan`; implemented/release diffs may feed `/visual-recap`; competing visual directions go through `/plan-arbiter`; browser/platform claims that depend on current APIs go through `/read-the-damn-docs`. These augment visual evidence; they do not replace this review.

## Flow

1. Infer surfaces from hints or `git diff --name-only HEAD`: routes/components -> URL/test; CLI/report -> command/output. If blocked, ask one question.
2. Design context bootstrap: inspect existing tokens/theme and one representative component/surface before judging; preserve system intent unless evidence says drift hurts users.
3. Collect evidence with project tools first: `scripts/skills-browser.sh`, Playwright, `bun run dev`, local route/component fixtures, and CLI fixtures. Never ask user to verify manually when tools can.
4. Classify surface register: brand surface (distinctive impression, art direction, narrative) or product surface (trust, consistency, task flow, standard affordances). If unclear, state assumption.
5. Apply review lanes: critique lane (read/hierarchy), audit lane (a11y/perf/responsive), polish lane (ship quality/design-system fit).
6. Hats: Product: user value, clarity, task success, expectations, friction. Design: hierarchy, spacing, affordance, copy, state quality, taste. Engineering: resilience under async stress, races, platform/perf. QA: reproducible evidence, unhappy paths, regression, automation.
7. Design language handles: name the handle before the fix: hierarchy, density, rhythm, anchor, negative space, leading, measure, visual weight, affordance, scan path. Use [REFERENCE.md](REFERENCE.md) to translate vague notes into current read, desired read, magnitude, and implementation knobs.
7a. Index articulation pass: classify taste notes by vocabulary lane before fixing -- typography, color, iconography, layout, interaction, motion, accessibility, information architecture, copywriting, or components. Prefer precise terms like CTA, front-loading, accessible names, DOM order, label association, touch target, duration, semantic token, optical centre, and tabular nums over vague taste words.
7b. Taste research pass: apply the Impeccable/Emil operating loop from [REFERENCE.md](REFERENCE.md): context first, named dimension pass, pre-ship gauntlet, motion decision framework, and component craft heuristics for toasts, drawers, destructive holds, clip-path reveals, and animation restraint.
8. Trace UI lifecycle for each changed surface: idle/unrequested -> pending/loading/submitting -> success/error -> settled/dismissed. Check what appears, disappears, disables, persists, announces, and re-enables. Form submit: keep form visible while pending; disable duplicate submit; only close/reset/navigate after success; show all errors inline and non-dismissible until resolved.
9. Minimum matrix: Chromium desktop; Chromium mobile; keyboard-only Tab, Shift+Tab, Enter, Space, Escape; console/network scan; loading, empty, error, dense-data; form submit path; notification/toast path. Non-web: narrow/wide, color/no-color, error/empty/slow. Prefer Firefox desktop; WebKit; reduced motion; dark/light; forced colors; text zoom or larger default font; RTL/localized-long-text; back/forward; slow network/media throttling.
10. Inspect: overflow/clipping/sticky/safe-area/`100vh`/virtual keyboard/writing mode/CLS/dense data; captions/headers still explain tables; CSS shorthand/complex layout; accessible names/labels/native semantics; ARIA only when needed; no aria-label on static/generic elements; password managers/autofill; disabled vs aria-disabled; focus trap/return; no surprise autofocus; buttons/links do not nest; requestSubmit; toasts announced, not sole carrier for critical actions; side-effect success confirmed; failed side effects persistent; long-running work shows progress/estimate when possible; strikethrough, emoji, generated content; SVG/icons/images named or decorative; Firefox/Safari/WebView; bfcache; smooth scrolling, scroll snapping, scrollIntoView; interaction blocking; native-control behaviour; feature detection; responsive images; responsive video/media; stable aspect ratio; LCP/CLS/INP/long interaction; font loading; third-party embeds/scripts.
11. Heuristics: HTML first. Lifecycle beats screenshot. State beats happy path. Motion is interaction. Content stress wins. Accessibility automation is partial. Performance is visual. If seen twice, automate.

## Output

Concise report. Non-trivial/release: write/open `$TMPDIR/visual-review-<timestamp>.html` (fallback `/tmp`).

```markdown
## Visual review
Status: ready | needs fixes | blocked
Changed UI: <routes/components/commands/surfaces>
Checked: <browser/viewport/state/terminal list>
State trace: | Surface | Trigger | Pending | Success | Error | Persistence/dismissal | Evidence |
Findings: | Severity | Hat | Surface | Evidence | Why it matters | Fix | Automate? |
Design findings: | Severity | Surface | Vocabulary lane | Handle | Current read | Desired read | Evidence/callout | Adjustment | Implementation knobs |
Screenshots: | View | Browser | Path | Notes |
PR notes: <rows usable in /commit-push-pr screenshot table>
HTML report: <absolute path or skip reason>
Automation candidates: <hook/eval/test/docs candidates; hook only deterministic source/workflow smells>
```

Severity: P0 blocks use/security/data loss/infinite loop. P1 fix before PR. P2 low-risk improvement. P3/nit advisory. Finish when P0/P1 fixed or accepted, evidence captured or skipped with reason, deterministic repeats tracked as hook/eval/test follow-up.
