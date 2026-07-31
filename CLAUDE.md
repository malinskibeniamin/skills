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

## Execution contract

The requested endpoint owns scope:

- Answer, explain, plan, review: return the artifact; do not edit.
- Build, fix, implement: concise plan, continue, verify locally; no commit or push.
- Commit: commit only. Push: commit if needed, then push. PR: verify, commit, push, open
  via `/commit-push-pr`, take one CI snapshot. Ship or `/go`: run the full delivery loop.

An explicit earlier stop wins. Ask only for a material user-reserved decision or an
irreversible production, legal/privacy, destructive, or high-security action. Otherwise
make reversible assumptions and proceed. Never merge or force-push without permission.
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

Then inspect -> act -> verify -> repeat. Let evidence choose the plan, tools, and any
specialist guidance. Continue immediately through reversible decisions; do not insert
approval gates, fixed task durations, or skill ceremonies. Meaningful behavior starts with
a failing public-contract test. Long or high-unknown work may record evidence, deviations,
and pause triggers in gitignored `.context/implementation-notes.md`.

Model selection is data-driven in `config/model-routing.json`; `/efficient-frontier`
applies it. Quality wins. Do not invent capability rankings or infer subscription usage
from token counts. Promote context, effort, or model changes only through
`agent-evals/context-ablation/`.

Run `bun run lint:fix` and `bun run type:check` before done. Generated files
(`*.gen.*`, `*_pb.*`, `*_connectquery.*`, or an `@generated`/`DO NOT EDIT` header) are
never hand-edited.
