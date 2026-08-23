---
name: go
description: "Ship completed work through verification, review, PR, and CI."
disable-model-invocation: true
---

# Go -- shipping exit contract

User-invoked full-delivery endpoint. Keep working until the requested artifact is shipped
and its verification is clean, or a real external blocker is evidenced.

## Exit contract

Resolve these from the request and live repository state:

- **Objective**: the shipped behavior or change.
- **Guardrails**: branch, privacy, destructive-action, and user-reserved boundaries.
- **Verification**: repository checks plus observable behavior at the real entrypoint.
- **Delivery**: commit, remote branch, PR, and CI state required by the request.
- **Stop**: every criterion passes, or an external dependency makes progress impossible.

## Loop

**Inspect -> verify -> repair -> repeat** until verification passes.

1. Inspect the full branch diff and requested endpoint. Include committed, staged,
   unstaged, and untracked work; do not ship unrelated files.
2. Run every applicable repository-native check. Frontend work normally includes focused
   tests, `bun run type:check`, and `bun run lint:fix`; Go work includes documented tests,
   vet, and build checks.
3. Exercise every material runnable change through its real user or public entrypoint.
   Check intended use and one credible break or recovery path. Tests do not replace this.
4. For a customer-facing surface, inspect the rendered or terminal result, important
   states, accessibility, console/errors, and relevant viewport or platform risks.
5. Review once against the objective, guardrails, semantic density, and credible risk.
   Repair concrete findings, then invalidate and rerun the affected evidence.
6. If the change claims measurable impact, repeat the same baseline/candidate scenario.
   Do not invent a benchmark when no decision-useful measure exists.

For dependency version upgrades, verify the lockfile, clean install/build, and every
affected call site against current primary documentation.

Do not manufacture a second review, cleanup pass, skill invocation, or agent call. Keep a
single owner in the primary context.
A different model or delegated lane requires explicit user authorization.

## Deliver

Follow [commit-push-pr/REFERENCE.md](../commit-push-pr/REFERENCE.md) for explicit staging,
commit format, push, draft PR creation, reviewer guidance, and the PR body. Rebase and use
`--force-with-lease` when needed without another permission prompt on the current user-owned
feature branch. Never merge, use plain `--force`, or rewrite a default, shared, foreign,
or concurrently owned branch without explicit permission.

If `gh stack view --json` identifies a stack, review and verify the current layer against its
parent. Ship the whole stack only when explicitly requested through `/stacked-prs`; an ordinary
PR endpoint must not publish other unsubmitted layers.

- Bind review and verification to current `HEAD`; later edits invalidate that evidence.
- Monitor CI only because this command is the explicit full-delivery endpoint. Repair a
  failure, replay affected verification, push, and continue.
- Resolve every existing human review thread; `pr-feedback-completeness-stop` enforces the
  zero-unresolved condition. Human feedback has no cap. Do not poll for future feedback
  after the current set is resolved.
- Stop self-review as soon as it is clean. Repeated noisy findings are evidence to hand off,
  not a reason for arbitrary rounds.
- Extra recap, history-cleanup, or follow-up artifacts require an explicit request.

## Done

- Requested behavior observed at its real entrypoint, or a non-runnable reason recorded.
- Applicable checks pass without warnings on current `HEAD`.
- Current human feedback is resolved.
- Requested commit, push, PR, and CI endpoint exists.
- No uncommitted or untracked work is hidden.
- Final response includes evidence and ends with exactly one status line.

On the default branch, create an isolated worktree with
`scripts/mux-worktree.sh <type>/<name>` before delivery. [ETHOS: Worktree Isolation]
