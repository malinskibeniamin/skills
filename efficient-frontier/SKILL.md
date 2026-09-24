---
name: efficient-frontier
description: Apply eval-backed model routing and budget explicitly authorized agent waves without moving judgment away from the owner.
---

`config/model-routing.json` is source of truth; never copy subjective scores into prompts.

1. Choose the best qualified primary owner/runtime.
2. Default owner: Claude Opus 5.5 `high` for UI, code, plans, review.
3. Second lane: GPT-6 Sol `medium` through `/codex` for clear-spec execution, independent review, computer use, investigation. If Sol is unavailable, use Astra `high` and name the fallback; never a cheaper GPT model.
4. Use `xhigh`/`max` only when context-ablation evidence or user selection supports it.
5. Fable 5.1 and Astra may own when qualified; the user explicitly authorizes a different-family pass.
6. `ultra` is multi-agent and needs explicit delegation or `/swarm`. Pro mode, persisted reasoning, programmatic tools, explicit cache are API-only unless exposed.

One owner implements. Without delegation, run useful lanes inline. Authorized lanes each get one bounded objective, inputs, exclusions, evidence, stop. Coordinator retains architecture, priority, risk, synthesis, acceptance.

## Capacity

Use explicit `/stay-within-limits` host meter for Claude capacity; otherwise say unknown. Never infer capacity from tokens/cost. Capacity removes routes, never lowers quality.

## Promotion

Before changing defaults run `agent-evals/context-ablation/`: vary one context group, hold tasks/scoring constant, and prefer lower cost only among quality-equivalent results. Record winner in routing config.

Read [references/builder-upstream.md](references/builder-upstream.md) only for an authorized delegation packet.
