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
4. For authorized write/delivery work, refresh affected captures, callouts, and legend together; preserve the human opening (flag stale intent for author editing), refresh agent-drafted openings and replace stale agent bullets in place with concise beneficiary, value, decisive evidence and material risks. Refresh the [human-review handoff](../shared/review-contract.md#human-review-handoff), including review routing, recovery and detection gaps. Preserve human intent/required evidence; link detail, skip accurate descriptions, omit session logs.
5. Re-read edited hosted bodies against the published head. Read-only: report drift, no edit. Local/no-push: defer publication; unpublished work is not delivered.

## Body template

Use a concise, human-readable outcome title, following repository title conventions.
The title and opening line belong to the human author: preserve supplied wording.
When drafting for them, label the title/line as agent-drafted pending human editing;
never claim human authorship or endorsement. Authorized draft publication can proceed.
On upkeep, preserve human text and flag changed intent rather than silently rewriting it.

Keep this order: one-line change/why -> before/after screenshot table for UI changes ->
clickable prototype when useful -> agent description in one collapsed `<details>`.
The optional prototype link may sit immediately before the table. Omit inapplicable
visual/prototype sections instead of publishing placeholders. Use this body shape:

```markdown
<one human-authored line about the change and why, or an explicitly labeled agent draft>

| Before | After |
| --- | --- |
| ![Previous state](<hosted-before-image>) | ![New state](<hosted-after-image>) |

[Try the prototype](<reviewer-accessible-url>) — <states/variants; access requirement>

<details>
<summary>Agent-generated description</summary>

- Lane / Review: <beneficiary, scope, closest-review paths and owner routing/gaps>
- Testing: <commands, observed results, real-entrypoint evidence and gaps>
- Risk / Rollback: <failure modes, blast radius, recovery, detection and gaps>

<verified model/harness attribution when required>

</details>
```

Put a short **visible warning** before the details for failed/blocked verification,
material risks, costly rollback or detection gaps; collapse routine receipts, not blockers.
Assess all five [human-review handoff](../shared/review-contract.md#human-review-handoff)
criteria inside the agent description without adding five boilerplate headings.
Keep required references, acceptance criteria and repository-specific fields.

For UI changes, use comparable real base/candidate captures per the
[visual-evidence contract](../commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5).
Explain an unavailable or inapplicable comparison; never invent a before state or use
placeholder URLs as evidence. For non-UI changes, omit the screenshot table and retain
applicable diagram evidence. A prototype complements, not replaces, screenshots or tests.

### Clickable review prototypes

When interaction, hard-to-reach app states or alternative approaches benefit from hands-on
review, link a [UI prototype](../prototype/UI.md#shareable-review-prototype).
Use real app components/fonts/tokens/theme providers in a lightweight website; isolate
Electron/native/backend boundaries with labeled fixtures. Reviewers should reach the
relevant state without checking out a branch or arranging the full app environment.
For an open design question, expose meaningfully different approaches with shareable
variant/state URLs; a settled small edit needs neither variants nor a new prototype.

Deploy only through the target repository's documented, approved SSO-gated Quick Site
(or equivalent private preview) workflow. Discover its command/config; Shopify's
[Quick](https://shopify.engineering/quick) is inspiration, not access to infrastructure
or a portable deployment command. If hosting/SSO is unavailable, retain the runnable
artifact, report the gap and use screenshots; do not silently publish publicly or add
hosting/auth infrastructure. Verify reviewer access, link target state and asset loading;
check logged-out access is denied before calling it SSO-gated. Identify simulated behavior
and unverified access. Keep the URL/artifact tied to the reviewed revision; refresh it or
mark it stale after relevant changes. Follow [prototype retention](../prototype/SKILL.md#retention).

## Sections

The opening sentence is the required first read, not a preamble; follow the
[PR attention budget](../shared/communication.md#match-the-artifact). Keep only supporting
detail below it. The topics below are author guidance, not required PR headings.
Keep agent detail collapsed per the body template; retain required visual media inline after the
opening and any essential warning. Use the user's domain language from `GLOSSARY.md`.

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
for UI changes per the body template; for other changes, include media only when useful. Name checks not run and
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
Apply the handoff rubric's error-detection assessment alongside recovery; keep material
visibility gaps explicit rather than treating passing tests or a rollback plan as detection.
