---
name: development-lifecycle
description: "Run React, TypeScript, and UI implementation from a high-level outcome through self-verification."
---

Author front door: `/work`. Own one outcome; select helpers automatically. Before edits,
read [author delivery](../shared/delivery-workflow.md) for ownership, isolation and endpoints.
Use [communication](../shared/communication.md) and [dependency loading](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Outcome contract

Before editing:

- **Objective** -- high-level end state.
- **Guardrails** -- non-inferable constraints, reserved decisions, irreversible boundaries.
- **Verification** -- checks or observable behavior proving the outcome.
- **Stop** -- requested endpoint and true user blockers.

State contract; build/fix/implementation: continue immediately.
[Auto-setup consumer safeguards](../shared/review-enforcement.md) within the endpoint.

## Loop

**inspect -> act -> verify -> repeat**

### Inspect

Fetch named tickets (body, labels, comments); state the title. Clarify ambiguous references.
Resolve the blind spot/volatile unknown from source evidence. Classify lookup, prototype, reversible assumption, or pause trigger; match existing idiom and demonstrated scale.

For T3 checkouts or Effect work, resolve [native context](../shared/T3CODE-NATIVE.md#resolve-context)
with entrypoint `work`; use the returned target guidance and scoped checks throughout this loop.

Before edits, load [change evidence routing](../shared/change-evidence.md) and applicable owners.
Assess impact proportionally; capture base before visible edits, including tiny copy/shared-UI effects.

### Act

A single owner; delegation/background work needs explicit authorization. Make the smallest obvious change; delete/reuse. Load [tdd](../tdd/SKILL.md) for meaningful behavior at the public contract: RED -> smallest GREEN -> REFACTOR; static wiring or behavior-preserving deletion may use focused verification only. Re-plan the affected slice when evidence changes. Adjacent cleanup is a report unless it blocks verification.

### Verify

Run repo tests, types, lint, build, and static checks. Load [dogfood](../dogfood/SKILL.md) for material runnable behavior; exercise its real entrypoint plus one credible failure/recovery path. Review objective, guardrails, credible risk. A failure becomes the next action; repair and repeat.

No repeatable entrypoint: prove with a disposable harness; route durable gaps to `/create-verification-skill`.

## Boundaries

Ask only for user-reserved decisions or irreversible production, legal/privacy, destructive, or high-security actions. Keep evidence/pause triggers in ignored `.context/implementation-notes.md`.

## Completion

Read and run [author delivery](../shared/delivery-workflow.md): inline self-review, applicable
evidence, publication, and requested CI/feedback follow-through. Reuse current verification;
stop at the requested endpoint when every exit criterion passes. [REFERENCE.md](REFERENCE.md) holds task-specific probes.
