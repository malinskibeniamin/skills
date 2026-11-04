# Project rules

## Toolchain

`bun` | TS 7 `tsc`/tsrs | Biome | Vitest | React Doctor

Local policy wins.
Navigation: [repo navigation](shared/repo-navigation.md).

- UI: `@/components/ui/` first; buttons: `<Button>`, variants/tokens.
  Functional React; React Compiler owns memoization.
- State: zustand=client, TanStack Query=server, connect-query=ConnectRPC; app env from `@/env`.
- Proto: enum names, not magic numbers. Validate formats, not only presence.
- Tests: `.test.ts` unit, `.test.tsx` integration, `.browser.test.tsx` visual,
  `e2e/*.spec.ts` Playwright; co-locate with source.
- Services: repo CLI. LaunchDarkly flags: `ldcli` only; read `shared/ldcli.md`.

Follow local idioms. Preserve zoom, worktree isolation,
secrets, types, generated files; use `exemplars/`.

Code quality: [verifiability](shared/verifiability.md).

## Human-facing text

`shared/communication.md`: decision/value/ask first; own claims, intent,
uncertainty. Above 200 words: <=120-word brief, then detail.
Tool-count word limits; never invent human endorsement.

Substantial outputs: `shared/intent-map.md` maps
objective/assumptions/references/risks/implementation/verification/superseded choices.
Trivial/single-path output stays linear.

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
Owned PRs/drafts: fix feedback/CI, consolidate owned commits before rebase, resolve
conflicts, verify and lease-push automatically.
Push CI fix or rebase now (`--force-with-lease`).
Never merge, use plain `--force`, or rewrite default/shared/foreign/concurrent branches
without explicit permission.
Delivery follow-ups replace local stops; never request a session restart/reconfiguration.
Keep follow-ups in the current PR: `pr/SKILL.md#existing-pr` at start/resume and handoff.
Push/PR/ship: verify origin HEAD/scope; follow `shared/review-enforcement.md`.
Report blockers; uncommitted/unpushed owned work is incomplete.
Recover verified scope via `shared/remote-completion.md`; preserve explicit local stops,
unrelated work, and active owners.
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

One outcome contract:

- **Objective** -- end state.
- **Guardrails** -- non-inferable constraints/reserved decisions.
- **Verification** -- observable proof.
- **Stop** -- requested endpoint/genuine blockers.

Repeatable work: deterministic scripts/CLIs; uncertainty: agent judgment.
Improve feedback loops before concurrency; delegation stays opt-in.
inspect -> act -> verify -> repeat. Evidence chooses plans/tools/guidance. Continue reversible
decisions; pair status with the next action, not recaps/offers/non-blocking options.
Add no approval gates, fixed durations, or skill ceremonies. Meaningful behavior starts with a failing public-contract test. Long work: checklist/evidence/pause triggers in `.context/implementation-notes.md`.

`config/model-routing.json` selects models; `/efficient-frontier` applies it. Quality wins.
Never invent rankings or infer usage from tokens. Promote context, effort,
or models only through `agent-evals/context-ablation/`.

Before done: `bun run lint:fix` + `bun run type:check`. Never hand-edit generated files
(`*.gen.*`, `*_pb.*`, `*_connectquery.*`, or an `@generated`/`DO NOT EDIT` header).
