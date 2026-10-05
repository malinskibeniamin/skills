---
name: development-lifecycle
description: "Run React, TypeScript, and UI implementation from a high-level outcome through self-verification."
---

Own one outcome. Use [communication](../shared/communication.md) and [dependency loading](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Outcome contract

Before editing:

- **Objective** -- high-level end state.
- **Guardrails** -- non-inferable constraints, reserved decisions, irreversible boundaries.
- **Verification** -- checks or observable behavior that distinguish done from plausible.
- **Stop** -- requested endpoint and true user blockers.

State contract; build/fix/implementation: continue immediately.

## Loop

**inspect -> act -> verify -> repeat**

### Inspect

Resolve the blind spot/volatile unknown from source evidence. Classify lookup, prototype, reversible assumption, or pause trigger; match existing idiom and demonstrated scale.

Before edits, load [quantify-impact](../quantify-impact/SKILL.md) for useful evidence. For visible changes, capture base/surfaces using [PR visual evidence](../commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5). Tiny copy/shared-UI effects count.

### Act

A single owner; delegation/background work needs explicit authorization. Make the smallest obvious change; delete/reuse before adding. Load [tdd](../tdd/SKILL.md) for meaningful behavior at the public contract: RED -> smallest GREEN -> REFACTOR; static wiring or behavior-preserving deletion may use focused verification only. Re-plan the affected slice when evidence changes. Adjacent cleanup is a report unless it blocks verification.

### Verify

Run repo tests, types, lint, build, and static checks. Load [dogfood](../dogfood/SKILL.md) for material runnable behavior; exercise its real entrypoint plus one credible failure/recovery path. Review objective, guardrails, credible risk. A failure becomes the next action; repair and repeat.

Missing repeatable entrypoint: prove with a disposable harness, then route the durable gap to `/create-verification-skill`.

## Boundaries

Ask only for user-reserved decisions or irreversible production, legal/privacy, destructive, or high-security actions. On the current user-owned branch, commit, push, rebase, and `--force-with-lease` without another prompt. Never merge, plain-force, add PRs, or rewrite default/shared/foreign/concurrent branches without explicit permission.

Before code on main/master/develop, create an isolated worktree with `scripts/mux-worktree.sh <type>/<branch-name>`. [ETHOS: Worktree Isolation]

Keep evidence/pause triggers in ignored `.context/implementation-notes.md`.

## Completion

Stop at the requested endpoint when every exit criterion passes. Read [REFERENCE.md](REFERENCE.md) for verification/delivery; load [commit-push-pr](../commit-push-pr/SKILL.md) for requested Git delivery.
