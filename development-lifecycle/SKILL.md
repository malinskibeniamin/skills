---
name: development-lifecycle
description: "Run React, TypeScript, and UI implementation from a high-level outcome through self-verification."
---

Own one outcome until evidence proves it or a real blocker appears.

## Outcome contract

Before editing state:

- **Objective** -- high-level end state.
- **Guardrails** -- non-inferable constraints, reserved decisions, irreversible boundaries.
- **Verification** -- checks or observable behavior that distinguish done from plausible.
- **Stop** -- requested endpoint and true user blockers.

Do not predict code or write a ceremony. A scoped build/fix/implementation request authorizes execution: give the concise contract and continue immediately.

## Loop

**inspect -> act -> verify -> repeat**

### Inspect

Find the blind spot most likely to invalidate the approach. Read code, tests, logs, current docs, and nearby examples; prefer executable evidence. Resolve the volatile unknown first; classify others as lookup, prototype, reversible assumption, or pause trigger. Match existing idiom and demonstrated scale; load specialist guidance only for its observed domain.

### Act

One primary model is the single owner; delegation/background work needs explicit authorization. Make the smallest obvious change; delete/reuse before adding. Meaningful behavior uses TDD at the public contract: RED -> smallest GREEN -> REFACTOR; static wiring or behavior-preserving deletion may use focused verification only. Re-plan the affected slice when evidence changes. Adjacent cleanup is a report unless it blocks verification.

### Verify

Run applicable repo tests, types, lint, build, and static checks. Exercise material behavior at its real entrypoint plus one credible failure/recovery path. Review against objective, guardrails, and credible risk. A failure becomes the next action; repair and repeat.

Missing repeatable entrypoint: prove with a disposable harness, then route the durable gap to `/create-verification-skill`.

## Boundaries

Ask only for a material user-reserved decision or irreversible production, legal/privacy, destructive, or high-security action. On the current user-owned branch, commit, push, rebase, and `--force-with-lease` without another prompt. Never merge, plain-force, add PRs, or rewrite default/shared/foreign/concurrent branches without explicit permission.

Before code on main/master/develop, create an isolated worktree with `scripts/mux-worktree.sh <type>/<branch-name>`. [ETHOS: Worktree Isolation]

High-unknown work may record hypothesis, evidence, deviations, and pause triggers in ignored `.context/implementation-notes.md`; short work stays in conversation.

## Completion

Stop at the requested answer, local, commit, push, PR, or ship endpoint when every exit criterion passes; not when a plan step ends. Read [REFERENCE.md](REFERENCE.md) only for an active verification/delivery branch.
