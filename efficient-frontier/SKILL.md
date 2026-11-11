---
name: efficient-frontier
description: Select Opus for daily work, Fable for demanding technical work, and Sol for reviews; preserve selected models and explicit delegation.
---

Only for requested delegation, read [Poteto](../shared/POTETO-NATIVE.md#delegation).

Use [tool choice](../shared/communication.md#protect-attention-while-working).

`config/model-routing.json` owns routing; omit subjective prompt scores.

1. Owner: Opus 5.5 `xhigh` for daily work, plans, code, UI.
   Use Fable 5.2 `xhigh` for the hard-task triggers in `quality_first.hard`: major
   migrations/refactors, demanding architecture/research, long-horizon technical work,
   or an observed Opus capability shortfall. Fix missing context/tools/checks first;
   task length or a failed test alone is not an escalation signal.
2. Sol `xhigh` reviews PRs via `/codex`; if unavailable, label a clean-context Opus `xhigh` pass and disclose missing different-family coverage.
3. Opus owns UI, copy, API design (taste >= 8); if unavailable, report the UI lane blocked.
4. Keep chores inline on Opus. Use Sol `xhigh` for user-selected Codex execution, computer use, or investigation.
5. Route only Opus/Fable/Sol; never `max`. Report unavailable Fable hard-task lanes;
   substitute Opus there only by explicit owner choice. Owner preference overrides historical scores.
6. The user explicitly authorizes a different-family pass; model preference is not spawning consent.
7. `ultra` needs explicit delegation or `/swarm`. Pro mode, persisted reasoning, programmatic tools, explicit cache: API-only unless exposed.

Without delegation, keep lanes inline. Authorized briefs bound objective, inputs, exclusions, evidence, stop. One owner keeps architecture, priority, risk, synthesis and acceptance.

Preserve an explicitly selected session model. A hard-task match selects the Fable role
where the host permits selection; it does not authorize a recursive call, new thread,
paid credits, or a silent switch. Discover host availability and exact identifiers;
report a missing route instead of using an alias that resolves to another model.
For Fable work, model handoffs, or Claude prompt changes, read
[model prompting](../shared/model-prompting.md).

## Capacity

Capacity: `/stay-within-limits` host meter, else unknown. Never infer from tokens/cost; remove routes, never lower quality.

## Promotion

`xhigh` is owner-selected, not benchmark-promoted.
Before unrequested default changes run `agent-evals/context-ablation/`: vary one context group, fix tasks/scoring, prefer lower cost only among quality-equivalent results. Record winner in routing config.

[Packet and source](references/builder-upstream.md): authorized delegation only.
