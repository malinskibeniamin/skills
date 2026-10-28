---
description: "Apply eval-backed model routing and budget explicitly authorized agent waves without moving judgment away from the owner."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["efficient frontier"]}
sidebar: {"label":"/efficient-frontier"}
title: "/efficient-frontier"
type: "skill"
---
![Diagram of the /efficient-frontier skill](/diagrams/skills/efficient-frontier.svg)

[Open the editable Excalidraw source](/diagrams/skills/efficient-frontier.excalidraw)


Read [tool choice](https://github.com/malinskibeniamin/skills/blob/v4.41.0/shared/communication.md#protect-attention-while-working) before routing.

`config/model-routing.json` owns routing; never copy subjective scores into prompts.

1. Owner: Opus 5.5 `xhigh` for daily work, plans, code, UI.
2. Sol `xhigh` reviews PRs via `/codex`; if unavailable, label a clean-context Opus `xhigh` pass and disclose missing different-family coverage.
3. Opus owns UI, copy, API design (taste >= 8); if unavailable, report the UI lane blocked.
4. Keep chores inline on Opus. Use Sol `xhigh` for user-selected Codex execution, computer use, or investigation.
5. Route only Opus/Sol; never `max`. If neither is available, report the lane blocked. Owner preference overrides historical scores.
6. The user explicitly authorizes a different-family pass; model preference alone does not authorize spawning agents.
7. `ultra` needs explicit delegation or `/swarm`. Pro mode, persisted reasoning, programmatic tools, explicit cache: API-only unless exposed.

One owner; lanes inline without delegation. Authorized lanes get a bounded objective, inputs, exclusions, evidence, stop. Owner keeps architecture, priority, risk, synthesis, acceptance.

## Capacity

`/stay-within-limits` host meter owns capacity; else unknown. Never infer from tokens/cost; capacity removes routes, never lowers quality.

## Promotion

Current `xhigh` defaults are owner choices, not benchmark promotions.
Before unrequested default changes run `agent-evals/context-ablation/`: vary one context group, fix tasks/scoring, prefer lower cost only among quality-equivalent results. Record winner in routing config.

Read [builder upstream](https://github.com/malinskibeniamin/skills/blob/v4.41.0/efficient-frontier/references/builder-upstream.md) only for authorized delegation.
