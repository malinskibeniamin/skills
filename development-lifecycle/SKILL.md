---
name: development-lifecycle
description: "Run React, TypeScript, and UI implementation from a high-level outcome through self-verification."
---

For multi-step delivery, read [Poteto](../shared/POTETO-NATIVE.md#execution).

`/work`: one outcome. Before edits, read [author delivery](../shared/delivery-workflow.md).
Use [communication](../shared/communication.md#admit-work-by-priority); [helpers](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Outcome contract

State **Objective** (outcome), **Guardrails** (reserved bounds),
**Verification** (observable behavior), **Stop** (endpoint/blockers).
Before material edits, [derive checks from the original contract](../shared/verifiability.md#verify-against-the-original-contract); carry expectations through repairs/handoffs.

Build/fix/implement: continue immediately; [auto-setup](../shared/review-enforcement.md) within endpoint.

## Loop

**inspect -> act -> verify -> repeat**

### Inspect

Read tickets/body/labels/comments; clarify refs. Resolve blind spot/volatile unknowns: lookup/probe/reversible assumption/pause. Match local idiom/demonstrated scale.

Read rules/scripts/configs/CI; note baseline failures; keep tools.

T3/Effect work: resolve [native context](../shared/T3CODE-NATIVE.md#resolve-context)
(`work`); use target guidance/scoped checks.

Load [change evidence](../shared/change-evidence.md) and owners; assess risk.
Capture needed baselines; reuse checks.

Fixed evals: [hill-climb](../hill-climb/SKILL.md).

[Figma/image](../jakubkrehel-skills/build-design/SKILL.md).

### Act

Use a single owner; explicit consent for delegation/background. Smallest working diff; respect user code and access.
Diagnose tool failures; retry safe checks, verify uncertain writes first. Continue unblocked work.
Uncovered regressions: [tdd](../tdd/SKILL.md); else reuse checks. Re-plan affected slices only;
no speculative abstractions or cleanup.

Per batch: scoped format/fix + lint -> types/tests. Repair/rerun; reuse hooks for identical inputs/coverage only. Keep project-wide types.

Imports: [checks](../shared/check-loop.md).

### Verify

Handoff: repo gates, not just scoped checks. Load [dogfood](../dogfood/SKILL.md): material behavior at the real entrypoint + failure/recovery. Review outcome, guardrails and credible risk; green checks do not prove intent. A failure becomes the next action; repair/repeat. Report unrelated baseline failures.

Fix causes, not gates; keep tests/strictness. Rule changes: tooling rationale + bad/valid controls. Missing entrypoint: disposable harness; recurring gap: `/create-verification-skill`.

## Boundaries

Ask only for user-reserved decisions or irreversible production, legal/privacy, destructive,
or high-security actions. Keep local checkpoints for long tasks, not routine evidence/checklist files.

## Completion

Spec gaps: audit [decision deltas](../shared/decision-deltas.md). Stop at the requested endpoint when every exit criterion passes. [Refactor](REFERENCE.md#refactor-branch).
