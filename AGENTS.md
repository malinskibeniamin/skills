<!-- GENERATED from CLAUDE.md + .agents/codex-appendix.md by scripts/generate-agents-md.sh -- do not edit by hand -->
# Project rules

## Toolchain

`bun` | TypeScript 7 `tsc` | Biome | Vitest | React Doctor

Local scripts/configs/component policy own commands/paths; these are defaults, not
migration instructions. For unfamiliar code/conflicts, read
[repo navigation](shared/repo-navigation.md).

- UI: `@/components/ui/` first; buttons: `<Button>`, variants/tokens.
  Functional React components; React Compiler owns memoization.
- State: zustand=client, TanStack Query=server, connect-query=ConnectRPC; app env from `@/env`.
- Proto: enum names, not magic numbers. Validate formats, not only presence.
- Tests: `.test.ts` unit, `.test.tsx` integration, `.browser.test.tsx` visual,
  `e2e/*.spec.ts` Playwright; co-locate with source.
- Services: repo CLI. LaunchDarkly flags: `ldcli` only; read `shared/ldcli.md`.

Match local idiom and the smallest obvious design. Preserve zoom, worktree isolation,
secrets, types, generated files; use `exemplars/`.

## Human-facing text

Human-facing text: `shared/communication.md` -- decision/value/ask first; own claims,
intent, uncertainty. Above 200 words: <=120-word brief, then detail.
Count explicit word limits with a tool; never invent human endorsement.

Substantial plans/analyses/reviews/recaps/status/handoffs: `shared/intent-map.md` maps
objective/assumptions/references/risks/implementation/verification/superseded choices.
Trivial/single-path output stays linear.

## Execution contract

Endpoint owns scope:

- Answer, explain, plan, review: return the artifact; do not edit.
- Build, fix, implement: plan, continue, verify, commit, push the current user-owned
  feature branch unless explicitly told to stop earlier.
- Commit: commit only. Push: commit if needed, then push. PR: verify, commit, push, open
  via `/commit-push-pr`, take one CI snapshot. Ship or `/go`: run the full delivery loop.

Earlier stop wins. Ask only for user-reserved or irreversible production,
legal/privacy, destructive, or high-security decisions; otherwise assume reversibly.
Commit/push/rebase owned features without another permission prompt.
Behind-base PRs: fetch/rebase, resolve routine conflicts, verify, lease-push automatically.
Push CI fix or rebase now (`--force-with-lease`).
Never merge, use plain `--force`, or rewrite default/shared/foreign/concurrent branches
without explicit permission.
Delivery follow-ups replace prior local stops. Recover endpoint state; never request a
session restart/reconfiguration. Keep follow-ups in the current PR. Drafts need no approval.
For push/PR/ship, verify committed scope and HEAD on origin; local-only is incomplete.
Report genuine external blockers.
Finished-agent reports or Git showing uncommitted/unpushed work mean incomplete delivery.
Recover verified scope via `shared/remote-completion.md`; preserve explicit local stops,
unrelated work, and active owners.
Do not spawn agents, teams, recursive model calls, or persistent background work unless
the user explicitly requests delegation or `/swarm`.
Isolate browser automation; never take over human-owned browsers/desktop apps.

End actions with one status line:
`🟢 done — <evidence>`, `🟡 awaiting decision — <decision>`, or
`🔴 blocked — <external blocker and needed input>`.
Immediately before each: `Intent: <outcome> | Impact: <value>`.
Keep user's goal; known/expected user/business value or `not established`; invent no claims/metrics.
For any PR, include its full PR URL on the final status line.

## Work

One outcome contract:

- **Objective** -- end state.
- **Guardrails** -- non-inferable constraints/reserved decisions.
- **Verification** -- checks/behavior proving success.
- **Stop** -- requested endpoint/genuine blockers.

Use deterministic scripts/CLIs for repeatable work; agent judgment for uncertainty.
Improve feedback loops before concurrency; delegation stays opt-in.
inspect -> act -> verify -> repeat. Evidence chooses plans/tools/guidance. Continue reversible
decisions; pair status with the next action, not recaps/offers/non-blocking options.
Add no approval gates, fixed durations, or skill ceremonies. Meaningful behavior starts with a failing public-contract test. Long work keeps checklist/evidence/pause triggers in `.context/implementation-notes.md`.

`config/model-routing.json` owns model selection; `/efficient-frontier` applies it. Quality
wins. Never invent rankings or infer usage from tokens. Promote context, effort,
or models only through `agent-evals/context-ablation/`.

Before done: `bun run lint:fix` + `bun run type:check`. Never hand-edit generated files
(`*.gen.*`, `*_pb.*`, `*_connectquery.*`, or an `@generated`/`DO NOT EDIT` header).

## Codex-specific

### Commits

`type(scope): description` -- feat|fix|refactor|style|test|docs|chore|perf|ci|build|revert. Scope required. Lowercase, 5-72 chars. (Codex has no conventional-commits deny hook on every event; state the format here.)

### Runtime notes

- Hooks arrive per-call; `codex-edit-dispatch.sh` adapts edits to the shared batch protocol.
- `process.env` allowed only in build/test configs; app code goes through `@/env`.
- Subagent output enforcement is best effort; follow `agents/references/findings-schema.md` for review findings.

### Code exploration

- Follow repo-root `shared/repo-navigation.md` for source precedence, TraceDecay exploration, and bounded fallback.
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
- `ccusage` token/cost reports are not Codex subscription-quota evidence. Use a host meter or user-reported value; otherwise usage is unknown and report `Codex usage unavailable to the harness`. Never infer quota from session tokens. Do not guess reset time. Keep the owner-selected Opus/Sol `xhigh` routes; unknown usage never invents a 50% effort gate. Authorized unknown-usage agent waves checkpoint after one explicitly requested wave.
