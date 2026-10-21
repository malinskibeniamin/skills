---
name: development-lifecycle
description: "Run React, TypeScript, and UI implementation from a high-level outcome through self-verification."
---

Author front door: `/work`. Own one outcome; select helpers automatically. Before edits,
read [author delivery](../shared/delivery-workflow.md) for ownership, isolation and endpoints.
Use [communication](../shared/communication.md) and [load helpers](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

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

Read rules/scripts/configs/CI; record baseline failures; retain tools.

T3/Effect work: resolve [native context](../shared/T3CODE-NATIVE.md#resolve-context)
(`work`); use target guidance and scoped checks throughout.

Before edits, load [change evidence](../shared/change-evidence.md) and owners.
Assess impact; capture base before visible edits, even tiny copy/shared-UI.

### Act

A single owner; explicit consent for delegation/background work. Make the smallest obvious change; delete/reuse. Load [tdd](../tdd/SKILL.md): public contract, RED -> smallest GREEN -> REFACTOR; static wiring/behavior-preserving deletion: focused checks. Re-plan the affected slice with evidence. Report adjacent cleanup unless verification needs it.

Each edit batch: scoped format/fix + lint -> relevant types/tests. Inspect fixes; repair/rerun. Reuse hook results only for identical inputs/coverage; keep sound project-wide types.

### Verify

Handoff: repo final gates; scoped checks never replace them. Load [dogfood](../dogfood/SKILL.md) for material runnable behavior: real entrypoint + credible failure/recovery. Review objective/guardrails/credible risk; green checks do not prove intent. A failure becomes the next action; repair/repeat. Unrelated baseline failures: report, never claim a pass.

Fix causes, not gates: never weaken checks/tests/strictness to pass. Bad rules need a tooling rationale and known-bad/valid cases. Missing entrypoint: disposable harness; durable gap: `/create-verification-skill`.

## Boundaries

Ask only for user-reserved decisions or irreversible production, legal/privacy, destructive, or high-security actions. Track evidence/pause triggers in `.context/implementation-notes.md`.

## Completion

Read and run [author delivery](../shared/delivery-workflow.md): inline self-review, applicable
evidence, publication, and requested CI/feedback follow-through. Reuse current verification;
stop at the requested endpoint when every exit criterion passes. [REFERENCE.md](REFERENCE.md) has probes.
