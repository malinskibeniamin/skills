---
name: pr
description: "Use when writing a PR body or keeping an open session PR's scope, business value, and evidence current."
metadata:
  credits:
    skill: show-me
    author: Dex Horthy
    organisation: Humanlayer
    url: "https://github.com/humanlayer/skills/blob/main/plugins/show-me/skills/show-me/SKILL.md"
---

Read [the reader-attention contract](../shared/communication.md). The complete [Matt Pocock source](../vendor/mattpocock/upstream/skills/engineering/pr/SKILL.md) and [original credits](../vendor/mattpocock/upstream/skills/engineering/pr/CREDITS.md) are pinned with the full skill suite. This local adaptation retains the PR body, evidence and existing-session ownership rules below.

## Existing PR

At start/resume, after material scope, implementation, or evidence changes, and before handoff:

1. Find open PRs linked to this conversation/session/chat; otherwise use `gh pr view` for this branch. Verify open state, repository/head/base and ownership; no unrelated recent PRs or implicit creation.
2. Compare the published body with the **full PR diff**, original objective and current verification, not the latest turn/commit; compare stack layers with their parents. Check visual captures, callouts, and legend for staleness per [visual annotations](../commit-push-pr/REFERENCE.md#visual-annotations).
3. Load [quantify-impact](../quantify-impact/SKILL.md) separately; reassess business value and product/codebase impact. Reuse valid evidence, rerun invalid comparisons, remove unsupported claims; unknown value is `not established`.
4. For authorized write/delivery work, refresh affected captures, callouts, and legend together; update the opening sentence to cover the full current change and replace stale bullets in place with concise beneficiary, value, decisive evidence and material risks. Preserve human intent/required evidence; link detail, skip accurate descriptions, omit session logs.
5. Re-read edited hosted bodies against the published head. Read-only: report drift, no edit. Local/no-push: defer publication; unpublished work is not delivered.

## Body template

Use this template for the PR body:

```markdown
<one sentence capturing the entire change and why it matters>

- Review: <optional focus or decision; omit if none>
- Testing: <decisive checks and observed results; before -> after; gaps>
- Risk: <affected contracts, failure modes, rollout limits, and how to revert>
```

## Sections

The opening sentence is the required first read, not a preamble; follow the
[PR attention budget](../shared/communication.md#match-the-artifact). Keep only supporting
detail below it. The topics below are author guidance, not required PR headings.
Link or collapse long receipts; retain required visual media inline immediately after the
opening. Use the user's domain language from `GLOSSARY.md`.

### Summary

Add reviewer focus only when useful; do not repeat the opening sentence. Separate core
changes from generated or mechanical files; name useful review entry points without a
file-by-file inventory. Distinguish observed results from expectations.

Use the PR body as the operator digest: behavior/value, decisive evidence, domain decisions,
remaining risk/recovery and next action; link detail for resumption. Separate HTML or visual
recap artifacts need an explicit request; retain full-diff review and required visual evidence.

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

Place visuals beside their supporting text. Show only load-bearing calls, files, props, states, and boundaries.

### Evidence

Concrete evidence that the change works. Prefer a short command/result; show before/after
when it clarifies the change, not as an automatic media requirement. Name checks not run and
remaining uncertainty; passing tests are not evidence of human review or consensus.

Use [visual annotations](../commit-push-pr/REFERENCE.md#visual-annotations) for hard-to-find deltas;
[UI change maps](SUMMARY-VIEWS.md#ui-change-maps) for broad UI only when helpful. Avoid duplicate captures/recaps.

For backend/API/Protobuf/contract, architecture, data-flow or workflow changes without
explanatory screenshots/video, include [backend diagrams](../excalidraw-diagram/PR-WORKFLOW.md)
inline after the opening; refresh stale maintained diagrams. Prefer Excalidraw, with inline
Mermaid when rendering/hosting fails. Keep test evidence: a diagram explains, not proves.
Use the [visual-evidence contract](../commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)
for scoped exceptions and the hosted-body completion gate.

Select media per [commit-push-pr visual evidence](../commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5).
Record real flows only when interaction/motion needs it or requested; stills/results suffice otherwise.
Evidence earns its place by the question it answers, not media tier. Keep results concise and actual.

### Merge Danger

Name the rollback path and classify the change as a one-way or two-way door. Two-way doors are cheap to undo; destructive or hard-to-reverse decisions are one-way doors.

Name affected users, callers, contracts, and credible failure modes, including shared consumers.
