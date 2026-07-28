<!-- GENERATED from CLAUDE.md + .agents/codex-appendix.md by scripts/generate-agents-md.sh -- do not edit by hand -->
# Project Rules

Lean by design: only rules that are neither machine-enforced nor inferable. Hooks, Biome (ultracite), and React Doctor teach at violation time; path-scoped skills (accessibility, connect-query, tanstack-router, e2e-testing, ux-copy, registry-workflow) auto-load the deep guidance. Do not re-add enforced rules here.

## Toolchain

`bun` pkg | TypeScript 7 `tsc` typecheck | Biome lint/fmt | React Doctor (Stop hook) React patterns | `--force-with-lease` | safe rm: node_modules dist .next build .cache .turbo coverage
External services via CLI, not MCP: Jira `acli` | Google `gog` | browser `agent-browser` | CI `gh` | Buildkite `bk` | Box `box` | M365 `m365`

## Code Quality

Less code, more meaning: choose the smallest obvious design before writing | deletion is delivery | design for demonstrated scale | add branches, abstractions, defenses, and tests only for required behavior or credible risk | clarity beats code golf | `bun run lint:fix` + `bun run type:check` pre-done

## Stack conventions (chosen, not inferable)

- UI: `@/components/ui/` registry first, `<Button>` for every button, variant props + design tokens (`bg-primary`, `var(--destructive)`) -- fix specificity at source, never restyle registry components inline
- State: zustand = client, TanStack Query = server, connect-query for ConnectRPC | env via `@/env` (t3-env+zod, declare in `src/env.ts`)
- Proto: enums by name, never magic numbers | Functional components only (Compiler)
- Validate format, not presence: URL regex, enum membership, UPPER_SNAKE patterns
- Tests: `.test.ts` unit | `.test.tsx` integration | `.browser.test.tsx` visual | `e2e/*.spec.ts` Playwright | co-locate with source

## Execution contract

The user's requested endpoint defines scope and done:

- Answer, explain, plan, or review: return that artifact; do not edit.
- Build/fix/implement: state a concise plan, then continue immediately as the single owner. Stop after verified local changes; do not commit or push.
- Commit: commit only. Push: commit if needed, then push; do not open a PR.
- Make/open/create a PR: verify, commit, push, open the PR, take one CI status snapshot, then stop. Push is an implied prerequisite, not a separate permission.
- Ship, `/go`, or plow ahead: run the full delivery loop requested.

An explicit endpoint or earlier stop point wins. Stay inside requested acceptance criteria; report adjacent improvements without editing them. Pause only for a user-reserved decision or destructive, irreversible, production, legal/privacy, or high-security risk.

Action turns end with exactly one final status line: `🟢 done — <evidence>`, `🟡 awaiting decision — <specific decision>`, or `🔴 blocked — <external blocker and needed input>`. Remaining work, failed checks, and routine ambiguity are not blockers: continue. Before final status, stop every background task, agent, timer, watcher, and process created this turn unless the user explicitly asked it to persist. Never schedule delayed work without an explicit request.

Do not spawn subagents, recursive model calls, agent teams, or background sessions unless the user explicitly requests delegation or invokes `/swarm`. Skill activation alone is not consent. The sole default exception is one bounded, foreground, awaited cross-model review for non-trivial PR/ship work.

Use isolated browser automation only. Never close, restart, resize, or take over a human-owned browser or desktop app; if isolation is unavailable, report the blocked verification.

## Lifecycle (MANDATORY -- hooks enforce)

Use the smallest lifecycle that reaches the requested endpoint.

1. **Understand** -- explore; ask only blocking questions
2. **Plan** -- concise for ordinary work; exact path/code/output for decision-heavy work
3. **Implement** -- bugs and meaningful behavior use `/tdd`: fail -> pass -> refactor. Trivial wiring stays direct. Match the shape, not the size, of the matching `exemplars/` file
4-6. **Ship only when requested** -- verify -> review -> `/commit-push-pr` -> requested CI endpoint

Alias: `/work` = full lifecycle. `/go` = phase 4-6 (ship tail).

### Effort + model routing

Default `high`. Fable-5: `high` or lower ONLY (`xhigh`/`max` furnaces, worse output). Never inject `ultrathink`.

Rank cost/intel/taste (1-10 higher better; cost = pay): Fable-5 1/10/9 | Opus-5 5/8/9 | Sonnet-5 6/5/5 | GPT-5.6 Sol (codex) 8/9/6 | GPT-5.6 Terra 9/6/5 | GPT-5.6 Luna 10/3/2. Taste = UI/UX, code quality, API, copy. GPT-5.5 retired (5.6 GA).

Model character: Sol = ultimate robot/tool/AI assistant, efficient exhaustive instruction-following, turn every stone | Fable = smartest, broadest, best frontend and gorgeous visible code; extremely complex work plus initial sketches/wireframes/prototypes before cheaper execution | Opus = low-harness default with Fable-like taste, less intelligence, lower cost.

GPT-5.6 variants (effort floors are hard): **Sol** = the workhorse -- actual implementation at `xhigh`, Opus-work adversarial review at `high`, plan and Sol-only review at `xhigh`. **Terra** = budget non-code work -- posting PR comments and test-runner/CI chores at `medium`|`high`; never product code or review. **Luna** = last resort for cheap tool loops far from code at `high`; never development or review.

Claude taste quota ladder (higher of 5h/7d): 0-20% Fable high | 21-35% Fable medium | 36-50% Fable low | 51-75% Opus xhigh | 76-90% Opus medium | 91-95% Opus low | 96-100% or missing/stale no Claude. Re-check `/stay-within-limits` before every wave and every Claude review dispatch; never reuse a review profile.

Ships -> intelligence > taste > cost (tiebreaker) | below bar -> rerun smarter, don't ask | user-facing -> taste >= 7 | token furnaces -> codex | **single owner**: the selected primary model implements; no automatic implementation pair or background delegation | **Cross-model review at non-trivial PR/ship endpoints**: one awaited pass; author model never solely reviews its own work; use a DIFFERENT family when available; Sol high checks Opus/Fable work, clean-context Sol xhigh is the fallback | **NEVER Haiku** | GPT via `/codex` CLI only | Claude via per-invocation `model` + `effort`.

### Long-running work

Foreground by default. Use background execution or Monitor only when the user requested persistence or active streaming. Join or stop it before final status. A PR request takes one `gh pr checks <n>` snapshot; `/go`, ship, or explicit babysitting may use `gh pr checks <n> --watch`. Never sleep-poll.

## Auto-Generated (never edit)

`*.gen.ts`/`*.gen.tsx` | `*_pb.ts`/`*_pb.js` | `*_connectquery.ts` | `@generated`/`DO NOT EDIT` first 5 line

## Codex-specific

### Commits

`type(scope): description` -- feat|fix|refactor|style|test|docs|chore|perf|ci|build|revert. Scope required. Lowercase, 5-72 chars. (Codex has no conventional-commits deny hook on every event; state the format here.)

### Runtime notes

- Hooks arrive per-call (no PostToolBatch); behavior is generated to parity from skill-manifest.json.
- `process.env` allowed only in build/test configs; app code goes through `@/env`.
- Subagent output enforcement is best effort; follow `agents/references/findings-schema.md` for review findings.

### Native delegation

- In native Codex, do not spawn subagents or start a recursive `codex exec` unless the user explicitly requests subagents, delegation, parallel agent work, or invokes `/swarm`. Skill activation alone is not consent. `/work`, `/go`, `/review`, `/grilling`, `/resilience-review`, and `/plow-ahead` do not grant it.
- Without consent, run required review and planning axes inline in the root context. Report them as inline, never independent or cross-family. Parallel shell and tool calls remain allowed.
- Spawned agents may not create descendants without separate authorization for nested delegation.
- Preserve the user's selected model and reasoning effort. Do not rewrite Codex config or enable experimental multi-agent flags as part of this policy.

### Native stop boundaries

- Honor the endpoint-aware execution contract above. A well-scoped build/fix/implement
  request continues after its concise plan and stops at verified local changes. Stop for plan
  approval only when the user requested planning/grilling or a material reserved decision remains.
- A PR request ends after opening the PR and taking one CI status snapshot. `/go`, ship, or
  explicit babysitting owns any CI remediation loop. `/plow-ahead` is not delegation consent.
  Do not poll for later human feedback unless the user asks.
- `ccusage` token/cost reports are not Codex subscription-quota evidence. Use a host meter or user-reported value; otherwise usage is unknown and report `Codex usage unavailable to the harness`. Never infer quota from session tokens. Do not guess reset time. Sol xhigh review/plan checks remain ungated; other unknown-usage agent waves checkpoint after one explicitly requested wave.
