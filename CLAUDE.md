# Project rules

Keep non-inferable choices/safety boundaries; hooks/skills own details.

## Toolchain and local choices

Local scripts/configs/component policy own commands/paths. Below are defaults, not
migration instructions; read [repo navigation](shared/repo-navigation.md) for unfamiliar code/conflicts.

`bun` package manager | TypeScript 7 `tsc` | Biome | Vitest | React Doctor

- UI: `@/components/ui/` first; buttons use `<Button>`, variants, design tokens.
  Functional React components; React Compiler owns memoization.
- State: zustand=client, TanStack Query=server, connect-query=ConnectRPC; app env from `@/env`.
- Proto: enum names, not magic numbers. Validate formats, not only presence.
- Tests: `.test.ts` unit, `.test.tsx` integration, `.browser.test.tsx` visual,
  `e2e/*.spec.ts` Playwright; co-locate with source.
- External services use the repository's existing CLI integration.

Match local idiom; use the smallest obvious design. Preserve user zoom, worktree
isolation, secrets, types, generated files. Use `exemplars/`.

## Human-facing text

Human-facing text uses `shared/communication.md`: decision,
value, ask first; own claims, intent, uncertainty. Above 200 words: <=120-word first read,
then evidence/detail. Count explicit word limits with a tool; never invent human endorsement.

Substantial plans/analyses/reviews/recaps/status/handoffs use `shared/intent-map.md`:
map objective, assumptions, references, risks, implementation, verification, superseded choices.
Trivial/single-path output stays linear.

## Execution contract

Requested endpoint owns scope:

- Answer, explain, plan, review: return the artifact; do not edit.
- Build, fix, implement: concise plan, continue, verify, commit, and push the current
  user-owned feature branch unless the user explicitly requests a local or earlier stop.
- Commit: commit only. Push: commit if needed, then push. PR: verify, commit, push, open
  via `/commit-push-pr`, take one CI snapshot. Ship or `/go`: run the full delivery loop.

An earlier stop wins. Ask only for material user-reserved decisions or irreversible production,
legal/privacy, destructive, or high-security actions. Otherwise use reversible assumptions;
commit, push, or rebase the current user-owned feature branch without another permission prompt.
Use `--force-with-lease` after rebase when needed.
Never merge, use plain `--force`, or rewrite a default, shared, foreign, or concurrently owned
branch without explicit permission.
A delivery follow-up replaces a prior local stop. Never ask the user to restart or reconfigure
a session to deliver that branch; correct endpoint state and continue.
Put follow-up waves in the current PR by default.
Draft PRs at the requested PR endpoint need no separate approval.
Do not spawn agents, teams, recursive model calls, or persistent background work unless
the user explicitly requests delegation or `/swarm`.
Isolate browser automation; never take over human-owned browsers/desktop apps.

End action turns with exactly one status line:
`🟢 done — <evidence>`, `🟡 awaiting decision — <decision>`, or
`🔴 blocked — <external blocker and needed input>`.
For any PR, include its full PR URL on the final status line.

## Work

Actions use one outcome contract:

- **Objective** -- end state.
- **Guardrails** -- non-inferable constraints/reserved decisions.
- **Verification** -- observable proof.
- **Stop** -- requested endpoint/genuine blockers.

Repeatable work uses deterministic scripts/CLIs; uncertainty uses agent judgment.
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
