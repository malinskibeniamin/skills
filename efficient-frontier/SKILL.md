---
name: efficient-frontier
description: Delegate bounded work while keeping judgment central. Use for model routing, agent waves, usage budgeting, or splitting research, coding, testing, and log reduction.
---

# Efficient Frontier

Keep architecture, prioritization, risk, synthesis, and final review with the strongest
model. Delegate repeatable, bounded, or token-heavy work.

Native Codex requires an explicit request for agents or `/swarm`; otherwise run the same
lanes inline. Claude-hosted workflows may delegate automatically.

## Routing

| Work | Route |
|---|---|
| Architecture, ambiguity, product, safety, synthesis | frontier coordinator |
| Clear-spec code and mechanical sweeps | `/codex` Sol |
| User-facing UI, copy, API design | taste-qualified model; Sol may draft |
| PR comments and CI chores | `/codex` Terra |
| Tracker and remote-tool loops | `/codex` Luna |
| Plans and reviews | `/stay-within-limits`; Sol xhigh plus available Claude |

## Model guide

Scores are cost, intelligence, taste; higher is more.

| Model | Score | Fit |
|---|---|---|
| Fable-5 | 1/10/9 | hardest judgment, frontend, sketches, wireframes, prototypes |
| Opus-5 | 5/8/9 | tasteful work without orchestration overhead |
| Sonnet-5 | 6/5/5 | bounded Claude lanes |
| GPT-5.6 Sol | 8/9/6 | exhaustive, explicit execution |
| GPT-5.6 Terra | 9/6/5 | PR comments and CI chores |
| GPT-5.6 Luna | 10/3/2 | remote tool loops |

Output quality wins over price. Escalate weak work without asking. Read
[references/builder-upstream.md](references/builder-upstream.md) only when writing a
delegation packet.

## Workflow

1. Separate frontier decisions from bounded execution.
2. Keep the immediate blocker local.
3. Give each authorized lane one outcome, write scope, verification gate, evidence format,
   and stop conditions.
4. Avoid overlapping writers; cap default waves at three agents.
5. Require changed files, commands, findings, residual risk, and blockers.
6. Reopen high-risk evidence and integrate centrally.
7. Re-check `/stay-within-limits` between long waves.

At 90% of either Claude window, launch no new Claude work; prepare a resume and use Codex
only where authorized. Without a real Codex meter, usage is unknown: never infer a
percentage or reset time from session tokens.

## Completion

Report lane ownership, model used, verification, rejected work, residual risk, and any
unavailable cross-family review. Never claim savings without measured evidence.
