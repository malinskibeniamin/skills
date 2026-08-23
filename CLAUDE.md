# Project rules

Lean by design. Keep here only purpose, safety boundaries, and choices a capable model
cannot infer. Hooks teach mechanical violations; path-scoped skills hold deep guidance.

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

Match surrounding code: its idiom, naming, comment density, and abstractions. Prefer the
smallest obvious design for demonstrated requirements. Preserve user zoom, worktree
isolation, secrets, type safety, and generated files.
Load one matching `exemplars/` file when it is a higher-fidelity reference than prose.

## Human-facing text

Lead with decision/result/action. Keep only evidence, impact, constraints, trade-offs,
correction, verification, rollout, blockers, and next steps that change it; omit restatement,
praise, narration, repetition, and obvious comments.

Substantial plans, analyses, reviews, recaps, status, and handoffs use
`shared/intent-map.md`: result/decision first; map objective, assumptions, references,
risks, implementation, verification, superseded choices. Keep trivial/
single-path output linear.

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
a session to deliver that branch; correct endpoint state and continue. Store inferred delivery
endpoints only in lifecycle state, never developer context.
Do not spawn agents, teams, recursive model calls, or persistent background work unless
the user explicitly requests delegation or `/swarm`.
Use isolated browser automation; never take over a human-owned browser or desktop app.

End action turns with exactly one status line:
`🟢 done — <evidence>`, `🟡 awaiting decision — <decision>`, or
`🔴 blocked — <external blocker and needed input>`.

## Work

For action work, establish one outcome contract:

- **Objective** -- the end state, stated at a high level.
- **Guardrails** -- only non-inferable constraints and reserved decisions.
- **Verification** -- tests, commands, or observable behavior that prove the result.
- **Stop** -- the requested endpoint and conditions that genuinely block progress.

Then inspect -> act -> verify -> repeat. Let evidence choose plans, tools, and guidance. Continue
through reversible decisions; add no approval gates, fixed durations, or skill ceremonies.
Meaningful behavior starts with a failing public-contract test. Long or high-unknown work may
record evidence, deviations, and pause triggers in `.context/implementation-notes.md`.

`config/model-routing.json` owns model selection; `/efficient-frontier` applies it. Quality
wins. Never invent rankings or infer subscription usage from tokens. Promote context, effort,
or models only through `agent-evals/context-ablation/`.

Run `bun run lint:fix` and `bun run type:check` before done. Generated files
(`*.gen.*`, `*_pb.*`, `*_connectquery.*`, or an `@generated`/`DO NOT EDIT` header) are
never hand-edited.
