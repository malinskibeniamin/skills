# Project rules

Non-inferable choices/safety here; details in hooks/skills.

## Toolchain

`bun` package manager | TypeScript 7 `tsc` | Biome | Vitest | React Doctor

- UI: `@/components/ui/` first; buttons use `<Button>`, variants, design tokens.
  Functional React components; React Compiler owns memoization.
- State: zustand=client, TanStack Query=server, connect-query=ConnectRPC; app env from `@/env`.
- Proto: enum names, not magic numbers. Validate formats, not only presence.
- Tests: `.test.ts` unit, `.test.tsx` integration, `.browser.test.tsx` visual,
  `e2e/*.spec.ts` Playwright; co-locate with source.
- External services: existing repo CLI integration.

Match local idiom; use the smallest obvious design. Preserve user zoom, worktree
isolation, secrets, types, generated files. Use useful `exemplars/`.

## Human-facing text

Documents/PRs/reviews/replies/status: use `shared/communication.md`: decision,
value, ask first; own claims/intent/uncertainty. Above 200 words: <=120-word first read,
then evidence/detail. Count explicit word limits with a tool; never invent human endorsement.

Substantial plans/analyses/reviews/recaps/status/handoffs use `shared/intent-map.md`:
map objective/assumptions/references/risks/implementation/verification/superseded choices.
Trivial/single-path output: linear.

## Execution contract

The requested endpoint owns scope:

- Answer, explain, plan, review: return the artifact; do not edit.
- Build, fix, implement: concise plan, continue, verify, commit, and push the current
  user-owned feature branch unless the user explicitly requests a local or earlier stop.
- Commit: commit only. Push: commit if needed, then push. PR: verify, commit, push, open
  via `/commit-push-pr`, take one CI snapshot. Ship or `/go`: run the full delivery loop.

Earlier stop wins. Ask only for a material user-reserved decision or irreversible production,
legal/privacy, destructive, or high-security action; otherwise use reversible assumptions.
Routine work may commit, push, or rebase the current user-owned feature branch
without another permission prompt; use `--force-with-lease` after rebase when needed.
Never merge, use plain `--force`, or rewrite a default, shared, foreign, or concurrently owned
branch without explicit permission.
A delivery follow-up replaces a prior local stop. Never ask the user to restart or reconfigure
a session to deliver that branch; correct endpoint state and continue.
Current branch has a PR? Put follow-up waves there by default.
Draft PR at the requested endpoint needs no separate approval.
Do not spawn agents, teams, recursive model calls, or persistent background work unless
the user explicitly requests delegation or `/swarm`.
Use isolated browser automation; never take over a human-owned browser or desktop app.

End action turns with one status line:
`🟢 done — <evidence>`, `🟡 awaiting decision — <decision>`, or
`🔴 blocked — <external blocker and needed input>`.
Immediately before each: `Intent: <outcome> | Impact: <value>`.
Keep user's goal; known/expected user/business value or `not established`; invent no claims/metrics.
For any PR, include its full PR URL on the final status line.

## Work

Use one outcome contract:

- **Objective** -- high-level end state.
- **Guardrails** -- non-inferable constraints and reserved decisions.
- **Verification** -- checks/behavior proving the result.
- **Stop** -- requested endpoint and genuine blockers.

Use deterministic scripts/CLIs for repeatable work; agent judgment for uncertainty.
Improve feedback loops before concurrency; delegation stays opt-in.
inspect -> act -> verify -> repeat. Let evidence choose plans/tools/guidance. Continue through
reversible decisions; put status notes beside the next action, not a stop that recaps work,
offers to continue, or lists non-blocking options. Add no approval gates, fixed durations, or skill ceremonies. Meaningful behavior starts with a failing public-contract test. Long work keeps
its task checklist, evidence, and pause triggers in `.context/implementation-notes.md`.

`config/model-routing.json` owns model selection; `/efficient-frontier` applies it. Quality
wins. Never invent rankings or infer subscription usage from tokens. Promote context, effort,
or models only through `agent-evals/context-ablation/`.

Before done: `bun run lint:fix` and `bun run type:check`. Never hand-edit generated files
(`*.gen.*`, `*_pb.*`, `*_connectquery.*`, or an `@generated`/`DO NOT EDIT` header).
