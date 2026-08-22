<!-- GENERATED from CLAUDE.md + .agents/codex-appendix.md by scripts/generate-agents-md.sh -- do not edit by hand -->
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
- Build, fix, implement: concise plan, continue, verify, commit, and push the current
  user-owned feature branch unless the user explicitly requests a local or earlier stop.
- Commit: commit only. Push: commit if needed, then push. PR: verify, commit, push, open
  via `/commit-push-pr`, take one CI snapshot. Ship or `/go`: run the full delivery loop.

An explicit earlier stop wins. Ask only for a material user-reserved decision or an
irreversible production, legal/privacy, destructive, or high-security action. Otherwise
make reversible assumptions and proceed. Routine work may commit, push, or rebase the current
user-owned feature branch without another permission prompt; after a rebase, use
`--force-with-lease` when needed. Never merge, use plain `--force`, or rewrite a default,
shared, foreign, or concurrently owned branch without explicit permission.
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

## Codex-specific

### Commits

`type(scope): description` -- feat|fix|refactor|style|test|docs|chore|perf|ci|build|revert. Scope required. Lowercase, 5-72 chars. (Codex has no conventional-commits deny hook on every event; state the format here.)

### Runtime notes

- Hooks arrive per-call; `codex-edit-dispatch.sh` adapts edits to the shared batch protocol.
- `process.env` allowed only in build/test configs; app code goes through `@/env`.
- Subagent output enforcement is best effort; follow `agents/references/findings-schema.md` for review findings.

### Code exploration

- Use the TraceDecay graph before broad shell search or whole-file reads: start with context or symbol search, then use callers, callees, affected tests, or test maps for relationships.
- Use `tracedecay tool` as the CLI fallback when MCP is unavailable. Fall back to scoped `rg` and file reads only when the index is unavailable or stale, or when generated and ignored artifacts are outside the graph.
- Treat TraceDecay savings as local estimates, not Codex usage, quota, or billing evidence. In linked worktrees, confirm the active project and branch before relying on graph results.

### Native delegation

- In native Codex, do not spawn subagents or start a recursive `codex exec` unless the user explicitly requests subagents, delegation, parallel agent work, or invokes `/swarm`. Skill activation alone is not consent. `/work`, `/go`, `/review`, `/grilling`, `/resilience-review`, and `/plow-ahead` do not grant it.
- Without consent, run required review and planning axes inline in the root context. Report them as inline, never independent or cross-family. Parallel shell and tool calls remain allowed.
- Spawned agents may not create descendants without separate authorization for nested delegation.
- Preserve the user's selected model and reasoning effort. Do not rewrite Codex config or enable experimental multi-agent flags as part of this policy.

### Native stop boundaries

- Honor the endpoint-aware execution contract above. A well-scoped build/fix/implement
  request continues after its concise plan through commit and push; an explicit local,
  no-commit, or no-push instruction stops earlier. Stop for plan approval only when the user
  requested planning/grilling or a material reserved decision remains.
- A PR request ends after opening the PR and taking one CI status snapshot. `/go`, ship, or
  explicit babysitting owns any CI remediation loop. `/plow-ahead` is not delegation consent.
  Do not poll for later human feedback unless the user asks.
- `ccusage` token/cost reports are not Codex subscription-quota evidence. Use a host meter or user-reported value; otherwise usage is unknown and report `Codex usage unavailable to the harness`. Never infer quota from session tokens. Do not guess reset time. Sol xhigh review/plan checks remain ungated; other unknown-usage agent waves checkpoint after one explicitly requested wave.
