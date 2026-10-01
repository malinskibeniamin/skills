# Project rules

Keep only non-inferable choices and safety boundaries here; hooks and skills teach details.

## Toolchain and local choices

`bun` package manager | TypeScript 7 `tsc` | Biome | Vitest | React Doctor

- UI: use `@/components/ui/` first, `<Button>` for buttons, variant props and design
  tokens. Functional React components; let React Compiler own memoization.
- State: zustand for client state, TanStack Query for server state, connect-query for
  ConnectRPC. Application environment variables come from `@/env`.
- Proto: enum names, not magic numbers. Validate formats, not only presence.
- Tests: `.test.ts` unit, `.test.tsx` integration, `.browser.test.tsx` visual,
  `e2e/*.spec.ts` Playwright; co-locate with source.
- External services use the repository's existing CLI integration.

Match surrounding idiom and use the smallest obvious design. Preserve
user zoom, worktree isolation, secrets, type safety, and generated files. Load a matching
`exemplars/` file when more useful than prose.

## Human-facing text

Lead with decision/result/action, why it matters, and the reader's ask. Own claims; preserve
author intent and uncertainty. For human-facing documents, PRs, reviews, replies, and status,
use `shared/communication.md`: above 200 words, a <=120-word first read, then evidence/detail.
Count explicit word limits with a tool; never invent human endorsement.

Substantial plans, analyses, reviews, recaps, status, and handoffs use
`shared/intent-map.md`: map objective, assumptions, references, risks,
implementation, verification, superseded choices. Keep trivial/single-path output linear.

## Execution contract

The requested endpoint owns scope:

- Answer, explain, plan, review: return the artifact; do not edit.
- Build, fix, implement: concise plan, continue, verify, commit, and push the current
  user-owned feature branch unless the user explicitly requests a local or earlier stop.
- Commit: commit only. Push: commit if needed, then push. PR: verify, commit, push, open
  via `/commit-push-pr`, take one CI snapshot. Ship or `/go`: run the full delivery loop.

An earlier stop wins. Ask only for a material user-reserved decision or irreversible production,
legal/privacy, destructive, or high-security action; otherwise use reversible assumptions.
Routine work may commit, push, or rebase the current user-owned
feature branch without another permission prompt; after rebase, use `--force-with-lease` when needed.
Never merge, use plain `--force`, or rewrite a default, shared, foreign, or concurrently owned
branch without explicit permission.
A delivery follow-up replaces a prior local stop. Never ask the user to restart or reconfigure
a session to deliver that branch; correct endpoint state and continue.
When a PR exists for the current branch, put follow-up waves into the current PR by default.
Creating a draft PR at the requested PR endpoint needs no separate approval.
Do not spawn agents, teams, recursive model calls, or persistent background work unless
the user explicitly requests delegation or `/swarm`.
Use isolated browser automation; never take over a human-owned browser or desktop app.

End action turns with exactly one status line:
`🟢 done — <evidence>`, `🟡 awaiting decision — <decision>`, or
`🔴 blocked — <external blocker and needed input>`.
For any PR, include its full PR URL on the final status line for every status.

## Work

Action work uses one outcome contract:

- **Objective** -- the end state, stated at a high level.
- **Guardrails** -- only non-inferable constraints and reserved decisions.
- **Verification** -- tests, commands, or observable behavior that prove the result.
- **Stop** -- the requested endpoint and conditions that genuinely block progress.

Use deterministic scripts/CLIs for repeatable work; reserve agent judgment for uncertainty.
Improve feedback loops before adding concurrency; delegation remains opt-in.
Then inspect -> act -> verify -> repeat. Let evidence choose plans, tools, and guidance. Continue
through reversible decisions; put status notes beside the next action, not in a stop that recaps
it, offers to continue, or lists non-blocking options. Add no approval gates, fixed durations, or
skill ceremonies. Meaningful behavior starts with a failing public-contract test. Long work keeps
its task checklist, evidence, and pause triggers in `.context/implementation-notes.md`.

`config/model-routing.json` owns model selection; `/efficient-frontier` applies it. Quality
wins. Never invent rankings or infer subscription usage from tokens. Promote context, effort,
or models only through `agent-evals/context-ablation/`.

Run `bun run lint:fix` and `bun run type:check` before done. Generated files
(`*.gen.*`, `*_pb.*`, `*_connectquery.*`, or an `@generated`/`DO NOT EDIT` header) are
never hand-edited.
