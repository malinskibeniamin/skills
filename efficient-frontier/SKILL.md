---
name: efficient-frontier
description: Apply eval-backed model routing and budget explicitly authorized agent waves without moving judgment away from the owner.
---

`config/model-routing.json` is source of truth; never copy subjective scores into prompts.

1. Choose the best qualified primary owner/runtime.
2. Owner: Opus 5.5 `high` (UI, code, plans, review).
3. Second lane: Sol `medium` via `/codex` (clear-spec execution, independent review, computer use, investigation); unavailable -> Astra `high`, named; never a cheaper GPT.
4. UI, copy, API design: taste >= 8 and a Claude owner, else a named Astra fallback.
5. Chores: Luna `high` (tiny edits, clean rebases, mechanical CI fixes, read-only listing); conflicts, diagnosis, judgment -> Sol.
6. Fable 5.1 (`high` max) only on explicit ask for extraordinary work. `xhigh`/`max` need context-ablation evidence or user selection.
7. The user explicitly authorizes a different-family pass.
8. `ultra` is multi-agent and needs explicit delegation or `/swarm`. Pro mode, persisted reasoning, programmatic tools, explicit cache are API-only unless exposed.

One owner implements. Without delegation, run useful lanes inline. Authorized lanes each get one bounded objective, inputs, exclusions, evidence, stop. Coordinator retains architecture, priority, risk, synthesis, acceptance.

## Capacity

Use explicit `/stay-within-limits` host meter for Claude capacity; otherwise say unknown. Never infer capacity from tokens/cost. Capacity removes routes, never lowers quality.

## Promotion

Before changing defaults run `agent-evals/context-ablation/`: vary one context group, hold tasks/scoring constant, and prefer lower cost only among quality-equivalent results. Record winner in routing config.

Read [references/builder-upstream.md](references/builder-upstream.md) only for an authorized delegation packet.
