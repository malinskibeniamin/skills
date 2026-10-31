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


For multi-step delivery, read [Poteto](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-NATIVE.md#execution).

`/work`: one outcome; select helpers. Before edits, read [author delivery](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/delivery-workflow.md) for ownership, isolation and endpoints.
Use [communication](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/communication.md) and [load helpers](https://github.com/malinskibeniamin/skills/blob/v4.42.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Outcome contract

State:

- **Objective** -- outcome.
- **Guardrails** -- non-inferable/reserved bounds.
- **Verification** -- observable behavior.
- **Stop** -- endpoint/blockers.

Build/fix/implement: continue immediately; [auto-setup](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/review-enforcement.md) within endpoint.

## Loop

**inspect -> act -> verify -> repeat**

### Inspect

Read tickets/body/labels/comments; title, clarify refs. Resolve blind spot/volatile unknowns via lookup/probe/reversible assumption/pause; match repo idiom/demonstrated scale.

Read rules/scripts/configs/CI; note baseline failures; keep tools.

T3/Effect work: resolve [native context](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/T3CODE-NATIVE.md#resolve-context)
(`work`); use target guidance/scoped checks.

Load [change evidence](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/change-evidence.md) and owners.
Assess impact; capture base before visible edits, even tiny copy/shared-UI.

[Figma/image](https://github.com/malinskibeniamin/skills/blob/v4.42.0/jakubkrehel-skills/build-design/SKILL.md).

### Act

A single owner; delegation/background work need explicit consent. Implement requested behavior using local conventions. Load [tdd](https://github.com/malinskibeniamin/skills/blob/v4.42.0/tdd/SKILL.md): public contract, RED -> smallest GREEN -> REFACTOR; wiring/behavior-preserving deletion: focused checks. Re-plan the affected slice with evidence; adjacent cleanup only for verification.

Each edit batch: scoped format/fix + lint -> relevant types/tests. Inspect fixes; repair/rerun. Reuse hook results only for identical inputs/coverage; keep sound project-wide types.

### Verify

Handoff: repo gates; scoped checks never replace them. Load [dogfood](https://github.com/malinskibeniamin/skills/blob/v4.42.0/dogfood/SKILL.md) for material runnable behavior: real entrypoint + credible failure/recovery. Review objective/guardrails/credible risk; green checks do not prove intent. A failure becomes the next action; repair/repeat. Unrelated baseline failures: report, never claim a pass.

Fix causes, not gates: never weaken checks/tests/strictness to pass. Bad rules need a tooling rationale and known-bad/valid cases. Missing entrypoint: disposable harness; durable gap: `/create-verification-skill`.

## Boundaries

Ask only for user-reserved decisions or irreversible production, legal/privacy, destructive, or high-security actions. Track evidence/pause triggers in `.context/implementation-notes.md`.

## Completion

Run [author delivery](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/delivery-workflow.md): inline self-review, evidence, publication and requested CI/feedback. Reuse verification; stop only at the requested endpoint when every exit criterion passes. [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/development-lifecycle/REFERENCE.md) has probes.
