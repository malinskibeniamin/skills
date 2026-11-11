---
description: "Run React, TypeScript, and UI implementation from a high-level outcome through self-verification."
related: ["/skills/tdd","/skills/review"]
search: {"boost":3,"keywords":["development lifecycle","work","implementation","development workflow"]}
sidebar: {"label":"/development-lifecycle"}
title: "/development-lifecycle"
type: "skill"
---
![Diagram of the /development-lifecycle skill](/diagrams/skills/development-lifecycle.svg)

[Open the editable Excalidraw source](/diagrams/skills/development-lifecycle.excalidraw)


For multi-step delivery, read [Poteto](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/POTETO-NATIVE.md#execution).

`/work`: one outcome. Before edits, read [author delivery](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/delivery-workflow.md).
Use [communication](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/communication.md#admit-work-by-priority); [helpers](https://github.com/malinskibeniamin/skills/blob/v4.45.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Outcome contract

State **Objective** (outcome), **Guardrails** (reserved bounds),
**Verification** (observable behavior), **Stop** (endpoint/blockers).

Build/fix/implement: continue immediately; [auto-setup](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/review-enforcement.md) within endpoint.

## Loop

**inspect -> act -> verify -> repeat**

### Inspect

Read tickets/body/labels/comments; clarify refs. Resolve blind spot/volatile unknowns: lookup/probe/reversible assumption/pause. Match local idiom/demonstrated scale.

Read rules/scripts/configs/CI; note baseline failures; keep tools.

T3/Effect work: resolve [native context](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/T3CODE-NATIVE.md#resolve-context)
(`work`); use target guidance/scoped checks.

Load [change evidence](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/change-evidence.md) and owners; assess risk.
Capture needed baselines; reuse checks.

Fixed evals: [hill-climb](https://github.com/malinskibeniamin/skills/blob/v4.45.0/hill-climb/SKILL.md).

[Figma/image](https://github.com/malinskibeniamin/skills/blob/v4.45.0/jakubkrehel-skills/build-design/SKILL.md).

### Act

Use a single owner; explicit consent for delegation/background. Smallest working diff.
User-owned code; own this change, not unrelated redesign. Diagnose tool failures; retry safe checks,
read back uncertain writes before retrying; continue independent work while questions wait.
Respect deliberate access boundaries.
Uncovered regressions: [tdd](https://github.com/malinskibeniamin/skills/blob/v4.45.0/tdd/SKILL.md); otherwise reuse checks. Re-plan affected
slices only; no speculative abstractions/adjacent cleanup.

Per batch: scoped format/fix + lint -> types/tests. Repair/rerun; reuse hooks for identical inputs/coverage only. Keep project-wide types.

Imports: [checks](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/check-loop.md).

### Verify

Handoff: repo gates; scoped checks never replace them. Load [dogfood](https://github.com/malinskibeniamin/skills/blob/v4.45.0/dogfood/SKILL.md) for material runnable behavior: real entrypoint + credible failure/recovery. Review objective/guardrails/credible risk; green checks do not prove intent. A failure becomes the next action; repair/repeat. Unrelated baseline failures: report, never claim a pass.

Fix causes, not gates; keep tests/strictness. Rule changes: tooling rationale + bad/valid controls. Missing entrypoint: disposable harness; recurring gap: `/create-verification-skill`.

## Boundaries

Ask only for user-reserved decisions or irreversible production, legal/privacy, destructive,
or high-security actions. Keep local checkpoints for long tasks, not routine evidence/checklist files.

## Completion

Author delivery: self-review, evidence, publication, requested CI/feedback. Reuse checks; stop at requested endpoint when every exit criterion passes. [Refactor](https://github.com/malinskibeniamin/skills/blob/v4.45.0/development-lifecycle/REFERENCE.md#refactor-branch).
