---
name: development-lifecycle
description: "Run React, TypeScript, and UI implementation from a high-level outcome through self-verification."
---

For multi-step delivery, read [Poteto](../shared/POTETO-NATIVE.md#execution).

`/work`: one outcome. Before edits, read [author delivery](../shared/delivery-workflow.md) for ownership, isolation and endpoints.
Use [communication](../shared/communication.md#admit-work-by-priority); [helpers](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Outcome contract

State:

- **Objective** -- outcome.
- **Guardrails** -- non-inferable/reserved bounds.
- **Verification** -- observable behavior.
- **Stop** -- endpoint/blockers.

Build/fix/implement: continue immediately; [auto-setup](../shared/review-enforcement.md) within endpoint.

## Loop

**inspect -> act -> verify -> repeat**

### Inspect

Read tickets/body/labels/comments; title, clarify refs. Resolve blind spot/volatile unknowns via lookup/probe/reversible assumption/pause; match repo idiom/demonstrated scale.

Read rules/scripts/configs/CI; note baseline failures; keep tools.

T3/Effect work: resolve [native context](../shared/T3CODE-NATIVE.md#resolve-context)
(`work`); use target guidance/scoped checks.

Load [change evidence](../shared/change-evidence.md) and owners.
Assess risk; capture bases only for useful/required comparisons. Reuse checks.

Fixed-eval search: [hill-climb](../hill-climb/SKILL.md).

[Figma/image](../jakubkrehel-skills/build-design/SKILL.md).

### Act

A single owner; delegation/background need explicit consent. Smallest functional diff; local conventions.
The user owns the codebase; own this change, not unrelated redesign. Diagnose ordinary
tool failures and retry safe checks; read back uncertain writes before repeating them.
Continue independent work while an open question waits; respect deliberate access boundaries.
Use [tdd](../tdd/SKILL.md) for uncovered regressions; else reuse checks. Re-plan only the affected
slice; no speculative abstractions or adjacent cleanup.

Per batch: scoped format/fix + lint -> types/tests. Inspect; repair/rerun. Reuse hooks only for identical inputs/coverage; keep project-wide types.

Imports: [checks](../shared/check-loop.md).

### Verify

Handoff: repo gates; scoped checks never replace them. Load [dogfood](../dogfood/SKILL.md) for material runnable behavior: real entrypoint + credible failure/recovery. Review objective/guardrails/credible risk; green checks do not prove intent. A failure becomes the next action; repair/repeat. Unrelated baseline failures: report, never claim a pass.

Fix causes, not gates: never weaken checks/tests/strictness to pass. Bad rules need a tooling rationale and known-bad/valid cases. Missing entrypoint: disposable harness; durable gap: `/create-verification-skill`.

## Boundaries

Ask only for user-reserved decisions or irreversible production, legal/privacy, destructive,
or high-security actions. Keep local checkpoints for long tasks, not routine evidence/checklist files.

## Completion

Run [author delivery](../shared/delivery-workflow.md): inline self-review, evidence, publication and requested CI/feedback. Reuse checks; stop only at the requested endpoint when every exit criterion passes. [Refactor](REFERENCE.md#refactor-branch).
