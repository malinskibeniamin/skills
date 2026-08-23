---
name: development-lifecycle
description: "Run React, TypeScript, and UI implementation from a high-level outcome through self-verification."
---

# Development lifecycle

Own one outcome and keep working until evidence proves it or a real blocker appears.

## Outcome contract

Before editing, extract four things from the request and repository:

- **Objective**: the high-level end state.
- **Guardrails**: non-inferable repository constraints, user-reserved decisions, and
  irreversible boundaries.
- **Verification**: executable checks or observable behavior that distinguish done from
  plausible.
- **Stop**: the requested endpoint and conditions that genuinely require the user.

Do not expand this into predicted code or a long procedure. A well-scoped build, fix, or
implementation request authorizes execution: state the compact contract and continue immediately.

## Execution loop

**inspect -> act -> verify -> repeat.**

### Inspect

- Find the blind spot most likely to invalidate the approach.
- Read code, tests, logs, current docs, and neighboring examples. Prefer executable
  evidence over another prose summary.
- Resolve the most volatile unknown first. Classify the rest as lookup, prototype,
  reversible assumption, or pause trigger.
- Match existing idiom and demonstrated scale. Load specialist guidance only when the
  observed task enters its distinct domain.

### Act

- One primary model is the single owner. Delegation and persistent background work require
  explicit user authorization.
- Start with the smallest obvious change. Delete or reuse before adding machinery.
- For bugs and meaningful behavior, use TDD at the public contract: RED -> smallest GREEN
  -> REFACTOR. Do not manufacture tests for static wiring or behavior-preserving deletion.
- Let findings revise the approach. Re-plan the affected slice instead of obeying a stale
  prediction.
- Stay within the objective. Adjacent cleanup is a report unless it blocks verification.

### Verify

- Run the repository's applicable tests, types, lint, build, and static checks.
- Exercise material behavior through its real entrypoint. Check intended use and one
  credible failure or recovery path.
- Review the result against the objective, guardrails, and credible risk. Verification is
  evidence, not a checklist receipt.
- A failure becomes the next action. Repair and repeat until every exit criterion passes.

## Boundaries

- Ask only for a material user-reserved decision or an irreversible production,
  legal/privacy, destructive, or high-security action.
- Commit, push, rebase, and use `--force-with-lease` when needed on the current user-owned
  feature branch without another permission prompt. Never merge, use plain `--force`, create
  extra PRs, or rewrite default, shared, foreign, or concurrently owned branches without
  explicit permission.
- On main/master/develop before code, create an isolated worktree with
  `scripts/mux-worktree.sh <type>/<branch-name>`. [ETHOS: Worktree Isolation]
- Long or high-unknown work may record the current hypothesis, evidence, deviations, and
  pause triggers in gitignored `.context/implementation-notes.md`. Short work stays in
  conversation.

## Completion

Stop at the requested endpoint: answer; commit and push by default for action work; an
explicitly requested local change or commit; PR; or full ship. Do not stop merely because a
planned step finished. See [REFERENCE.md](REFERENCE.md)
only when a concrete verification or delivery branch needs its detailed commands.
