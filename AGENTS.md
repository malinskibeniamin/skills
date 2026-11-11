<!-- GENERATED from CLAUDE.md + .agents/codex-appendix.md by scripts/generate-agents-md.sh -- do not edit by hand -->
# Project rules

## Toolchain

`bun` | TS 7 `tsc`/tsrs | Biome | Vitest | React Doctor

Local policy wins.
[Navigation](shared/repo-navigation.md).

- UI: `@/components/ui/` first; buttons: `<Button>`, variants/tokens.
  Functional React components; React Compiler owns memoization.
- State: zustand=client, TanStack Query=server, connect-query=ConnectRPC; app env from `@/env`.
- Proto: enum names, not magic numbers. Validate formats, not only presence.
- Tests: `.test.ts` unit, `.test.tsx` integration, `.browser.test.tsx` visual,
  `e2e/*.spec.ts` Playwright; co-locate with source.
- Services: repo CLI. LaunchDarkly flags: `ldcli` only; read `shared/ldcli.md`.

Follow local idioms. Preserve zoom, worktree isolation,
secrets, types, generated files; use `exemplars/`.

[Code quality](shared/verifiability.md).

## Human-facing text

`shared/communication.md`: decision/value/ask first; own claims, intent,
uncertainty. Above 200 words: <=120-word brief, then detail.
Tool-count word limits; never invent human endorsement.

Substantial artifacts: `shared/intent-map.md` maps objective, assumptions, references,
risks, implementation, verification and superseded choices. Trivial/single-path output stays linear.

## Execution contract

Endpoint owns scope:

- Answer, explain, plan, review: return the artifact; do not edit.
- Build, fix, implement: plan, continue, verify, commit, push the user-owned
  feature branch unless explicitly told to stop earlier.
- Commit: commit only. Push: commit, push. PR: verify, commit, push, open via `/commit-push-pr`.
  PR/draft: automatic upkeep via `shared/delivery-workflow.md`; publication is not readiness.

Earlier stop wins. Ask for reserved/irreversible production, legal/privacy, destructive
or high-security decisions; otherwise proceed reversibly.
Commit/push/rebase owned features without another permission prompt.
Owned PRs/drafts: fix CI/feedback, consolidate owned commits before rebase, resolve conflicts,
verify and lease-push automatically.
Push CI fix or rebase now (`--force-with-lease`).
Never merge, use plain `--force`, or rewrite default/shared/foreign/concurrent branches
without explicit permission.
Delivery follow-ups replace local stops; no restart/reconfiguration requests.
Keep follow-ups in the current PR: `pr/SKILL.md#existing-pr` at start/resume and handoff.
Push/PR/ship: verify origin HEAD/scope; follow `shared/review-enforcement.md`.
Report blockers; uncommitted/unpushed owned work is incomplete.
`shared/remote-completion.md`: recover verified scope; preserve local stops, unrelated work and active owners.
PR upkeep: one authorized transport; honor no-monitoring stops.
Agents/council require host-valid consent. Standing owner consent is reusable only
within its explicit scope; no nested delegation. Persistent setup needs authorization.
Isolate browser automation; never take over human-owned browsers/desktop apps.

End actions with one status line:
`🟢 done — <evidence>`, `🟡 awaiting decision — <decision>`, or
`🔴 blocked — <external blocker and needed input>`.
Immediately before each: `Intent: <outcome> | Impact: <value>`.
Keep user's goal; known/expected user/business value or `not established`; invent no claims/metrics.
For any PR, include its full PR URL on the final status line.

## Work

Smallest working diff; reuse code/tests.
Apply [proportionate verification](shared/verifiability.md#proportionate-verification).
Temporary evidence, inline results; retain requested/required/reusable files.
Project/user requirements win.

One outcome contract: **Objective** (end state), **Guardrails** (bounds),
**Verification** (proof), **Stop** (endpoint/blockers).

inspect -> act -> verify -> repeat. Use scripts for repeatable work, judgment for uncertainty.
Improve feedback loops before opt-in concurrency. Continue reversible decisions;
pair status with the next action, not recaps/offers/non-blocking options.
No extra gates/ceremonies. Add failing public-contract tests only for uncovered risks;
reuse local notes for long-run checkpoints, not routine evidence/checklist files.

Quality-first: `config/model-routing.json`, `/efficient-frontier`; xhigh only.
Opus daily/UI, Fable hardest, Sol reviews. Fable/handoffs: `shared/model-prompting.md`.
Unrequested promotions: `agent-evals/context-ablation/`.

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
- Owned PR requests include automatic CI/feedback/base maintenance through
  `shared/delivery-workflow.md`; preserve hosted merge policy and explicit narrower stops.
  Use host-authorized wakes rather than polling; unavailable monitoring is a visible gap,
  not green readiness. `/plow-ahead` is not delegation consent. Standing owner consent covers only its explicit review scope; preserve model routes
  and disclose unavailable providers.
- `ccusage` token/cost reports are not Codex subscription-quota evidence. Use a host meter or user-reported value; otherwise usage is unknown and report `Codex usage unavailable to the harness`. Never infer quota from session tokens. Do not guess reset time. Keep the owner-selected Opus/Fable/Sol `xhigh` routes; unknown usage never invents a 50% effort gate. Authorized unknown-usage agent waves checkpoint after one explicitly requested wave.
