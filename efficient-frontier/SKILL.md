---
name: efficient-frontier
description: Apply eval-backed model routing and budget explicitly authorized agent waves without moving judgment away from the owner.
---

Read [tool choice](../shared/communication.md#protect-attention-while-working) before routing.

`config/model-routing.json` owns routing; never copy subjective scores into prompts.

1. Owner: Opus 5.5 `high` (UI, code, plans).
2. Lane 2: Sol `medium` via `/codex` (clear-spec execution, computer use, investigation); unavailable -> named Astra `high`, never a cheaper GPT.
3. Astra `high` reviews PRs, Opus 5.5 `high` if needed; `xhigh` if >=50% Codex usage left.
4. UI, copy, API design: taste >= 8 and a Claude owner, else a named Astra fallback.
5. Chores: Luna `high` (tiny edits, clean rebases, mechanical CI fixes, read-only listing); conflicts, diagnosis, judgment -> Sol.
6. Fable 5.1 (`high` max): explicit ask, extraordinary work only. `xhigh`: context-ablation evidence or user pick; never `max`.
7. The user explicitly authorizes a different-family pass.
8. `ultra` needs explicit delegation or `/swarm`. Pro mode, persisted reasoning, programmatic tools, explicit cache: API-only unless exposed.

One owner implements; lanes inline without delegation. Authorized lanes get a bounded objective, inputs, exclusions, evidence, stop. Owner keeps architecture, priority, risk, synthesis, acceptance.

## Capacity

The `/stay-within-limits` host meter owns capacity; else unknown. Never infer from tokens/cost. Capacity removes routes, never lowers quality.

## Promotion

Before changing defaults run `agent-evals/context-ablation/`: vary one context group, hold tasks/scoring constant, and prefer lower cost only among quality-equivalent results. Record winner in routing config.

Read [references/builder-upstream.md](references/builder-upstream.md) only for an authorized delegation packet.
