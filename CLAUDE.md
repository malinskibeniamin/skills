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

Follow local idioms. Keep zoom/worktree isolation,
secrets/types/generated files; use `exemplars/`.

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
Browser automation: agent-browser default; never take over human-owned browsers/apps.

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
