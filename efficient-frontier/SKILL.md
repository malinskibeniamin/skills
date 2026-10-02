---
name: efficient-frontier
description: Apply eval-backed model routing and budget explicitly authorized agent waves without moving judgment away from the owner.
---

Read [tool choice](../shared/communication.md#protect-attention-while-working) before routing.

`config/model-routing.json` owns routing; never copy subjective scores into prompts.

1. Owner: Opus 5.5 `xhigh` for daily work, plans, code, and UI.
2. Sol `xhigh` reviews PRs via `/codex`; if unavailable, use a labeled clean-context Opus `xhigh` pass and disclose missing different-family coverage.
3. UI, copy, API design: Opus owns the work, with taste >= 8. If unavailable, report the UI lane blocked instead of switching silently.
4. Keep chores inline on the Opus daily driver. Use Sol `xhigh` for execution, computer use, or investigation when the user chooses Codex.
5. Other models require an explicit user request; never `max`. Historical scores do not override the owner's preferred pair.
6. The user explicitly authorizes a different-family pass; model preference alone does not authorize spawning agents.
7. `ultra` needs explicit delegation or `/swarm`. Pro mode, persisted reasoning, programmatic tools, explicit cache: API-only unless exposed.

One owner implements; lanes inline without delegation. Authorized lanes get a bounded objective, inputs, exclusions, evidence, stop. Owner keeps architecture, priority, risk, synthesis, acceptance.

## Capacity

The `/stay-within-limits` host meter owns capacity; else unknown. Never infer from tokens/cost. Capacity removes routes, never lowers quality.

## Promotion

The current `xhigh` defaults are explicit owner choices, not benchmark promotions.
Before unrequested default changes run `agent-evals/context-ablation/`: vary one context group, hold tasks/scoring constant, and prefer lower cost only among quality-equivalent results. Record winner in routing config.

Read [references/builder-upstream.md](references/builder-upstream.md) only for an authorized delegation packet.
