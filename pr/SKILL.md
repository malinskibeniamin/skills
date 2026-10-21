---
name: pr
description: "Use when writing a PR body."
metadata:
  credits:
    skill: show-me
    author: Dex Horthy
    organisation: Humanlayer
    url: "https://github.com/humanlayer/skills/blob/main/plugins/show-me/skills/show-me/SKILL.md"
---

Read [the reader-attention contract](../shared/communication.md). Use this template for the PR body:

```markdown
## Summary

<outcome and why it matters to the affected user or caller>
<reviewer focus or specific question; say if no special input is needed>
<smallest useful diagram, diff-sketch, or tree>

## Evidence

<frontend: before/after flow video playing inline (user-attachments URL), then screenshot table>

- **Before:** <screenshot/output/failing test run>
  **After:** <screenshot/output/passing test run>

## Merge Danger

**Door:** <one-way or two-way>

<optional: description>

**Blast Radius:** <affected users, callers, or contracts>

<rollback path and unresolved risks, when applicable>
```

## Sections

Skip all preambles and keep prose brief. Use the user's domain language from `GLOSSARY.md`.

### Summary

Lead with value and reviewer focus, not a changelog. Separate core changes from generated
or mechanical files; name useful review entry points without a file-by-file inventory. Distinguish observed results from expectations.
Then pick the smallest view that makes the key point clear; omit a visual that adds no understanding.

Choose the smallest view from [SUMMARY-VIEWS.md](SUMMARY-VIEWS.md).

#### Changed decisions

Surface material departures from a recorded plan or outcome contract when
scope, contracts, verification, or rollout risk changes. Reuse existing notes or intent maps:
prior choice -> new evidence -> current choice -> review consequence.
Keep the PR self-contained; omit empty histories and never invent a prior plan or agreement.

Session excerpts are optional context. Use only relevant,
authorized, redacted excerpts accessible to reviewers; otherwise give safe standalone rationale.
Do not widen sharing or execution access just to provide a link. Session length or turn count proves
neither correctness nor diligence; verify claims against the current diff and execution evidence.

#### Guidance

Place visuals beside their supporting text. Show only load-bearing calls, files, props, states, and boundaries.

Use only views that change understanding.

### Evidence

Concrete evidence that the change works. Show a before and after. Name checks not run and
remaining uncertainty; passing tests are not evidence of human review or consensus.

For backend architecture, data flow, API contract, or workflow changes, follow [backend diagrams](../excalidraw-diagram/PR-WORKFLOW.md) and invoke `excalidraw-diagram`. Include a focused before/after comparison and editable source link; refresh relevant maintained diagrams. Diagram failures warn and continue, never block the PR or replace test evidence.

For any frontend change, a before/after video of the real UI flow (clicks, typing, resulting state; never a still page) playing inline, plus screenshots, is S-tier and required. Put it right after the summary so reviewers see the change before reading about it. Capture, compose, and host it per [commit-push-pr visual evidence](../commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5).

Execution-based evidence is A-tier. Test results, console output. Show the exact test that now fails and passes, using pseudocode.

### Merge Danger

Name the rollback path. Two-way doors are cheap to undo; destructive or hard-to-reverse decisions are one-way doors.

Name affected users, callers, contracts, and credible failure modes, including shared consumers.
