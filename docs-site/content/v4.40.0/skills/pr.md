---
description: "Use when writing a PR body or keeping an open session PR's scope, business value, and evidence current."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["pr"]}
sidebar: {"label":"/pr"}
title: "/pr"
type: "skill"
---
![Diagram of the /pr skill](/diagrams/skills/pr.svg)

[Open the editable Excalidraw source](/diagrams/skills/pr.excalidraw)


Read [the reader-attention contract](https://github.com/malinskibeniamin/skills/blob/v4.40.0/shared/communication.md).

## Existing PR

At start/resume, after material scope, implementation, or evidence changes, and before handoff:

1. Find open PRs linked to this conversation/session/chat; otherwise use `gh pr view` for this branch. Verify open state, repository/head/base and ownership; no unrelated recent PRs or implicit creation.
2. Compare the published body with the **full PR diff**, original objective and current verification, not the latest turn/commit; compare stack layers with their parents.
3. Load [quantify-impact](https://github.com/malinskibeniamin/skills/blob/v4.40.0/quantify-impact/SKILL.md) separately; reassess business value and product/codebase impact. Reuse valid evidence, rerun invalid comparisons, remove unsupported claims; unknown value is `not established`.
4. For authorized write/delivery work, replace stale bullets in place with concise change, beneficiary, value, decisive evidence and material risks. Preserve human intent/required evidence; link detail, skip accurate descriptions, omit session logs.
5. Re-read edited hosted bodies against the published head. Read-only: report drift, no edit. Local/no-push: defer publication; unpublished work is not delivered.

## Body template

Use this template for the PR body:

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

Choose the smallest view from [SUMMARY-VIEWS.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/pr/SUMMARY-VIEWS.md).

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

For backend architecture, data flow, API contract, or workflow changes, follow [backend diagrams](https://github.com/malinskibeniamin/skills/blob/v4.40.0/excalidraw-diagram/PR-WORKFLOW.md) and invoke `excalidraw-diagram`. Include a focused before/after comparison and editable source link; refresh relevant maintained diagrams. Diagram failures warn and continue, never block the PR or replace test evidence.

For any frontend change, a before/after video of the real UI flow (clicks, typing, resulting state; never a still page) playing inline, plus screenshots, is S-tier and required. Put it right after the summary so reviewers see the change before reading about it. Capture, compose, and host it per [commit-push-pr visual evidence](https://github.com/malinskibeniamin/skills/blob/v4.40.0/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5).

Execution-based evidence is A-tier. Test results, console output. Show the exact test that now fails and passes, using pseudocode.

### Merge Danger

Name the rollback path. Two-way doors are cheap to undo; destructive or hard-to-reverse decisions are one-way doors.

Name affected users, callers, contracts, and credible failure modes, including shared consumers.
