---
name: efficient-frontier
description: Apply eval-backed model routing and budget explicitly authorized agent waves without moving judgment away from the owner.
---

# Efficient frontier

Read `config/model-routing.json`. It is the routing source of truth; do not reproduce
subjective model scores in prompts or skills.

Quality comes first:

1. Choose the primary owner that best meets the task and available runtime.
2. Default to GPT-5.6 Sol at `xhigh`; Sol is eligible to own UI, implementation, plans,
   review, and computer use.
3. Use `max` for difficult quality-first work only when the context ablation supports the
   lift or the user explicitly selects it.
4. Treat Terra and Luna as eval-gated. Do not route product code or review to them until a
   versioned behavioral eval promotes that use.
5. Fable or Opus may own work when available and quality-qualified. For a non-trivial PR,
   prefer one bounded review from a different model family; otherwise use a labeled,
   clean-context Sol fallback.
6. `ultra` means a multi-agent team and requires explicit delegation or `/swarm`.
   Pro mode, persisted reasoning, programmatic tool calling, and explicit cache controls
   are API-only unless the active harness exposes them.

One owner implements. Without explicit delegation, execute any useful lanes inline.
With delegation, give each lane one bounded objective, inputs, exclusions, evidence
contract, and stop condition. Keep architecture, prioritization, risk, synthesis, and
final acceptance with the coordinator.

## Capacity

Claude subscription capacity may be checked through the explicit
`/stay-within-limits` host-meter procedure. Unknown capacity is reported as unknown.
Never infer it from local tokens or cost. Capacity can remove a route; it cannot lower the
quality gate.

## Promotion

Run `agent-evals/context-ablation/` before changing defaults. Compare one context group at
a time, hold tasks and scoring constant, and prefer lower cost only among
quality-equivalent results. Record the winning policy in `config/model-routing.json`.

Read [references/builder-upstream.md](references/builder-upstream.md) only when composing
an authorized delegation packet.
