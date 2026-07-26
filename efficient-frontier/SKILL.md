---
name: efficient-frontier
description: Use when a frontier model (Fable, Opus, GPT-5.6) should delegate bounded research, coding, testing, or log reduction to cheaper models while keeping planning, synthesis, risk, and final review central. Owns usage-limit budgeting for agent waves.
---

# Efficient Frontier
Read `references/builder-upstream.md` for the full workflow.

Use the expensive frontier model where marginal judgment matters. Push repeatable, bounded, or token-heavy work to cheaper/faster subagents.

**Host gate:** Claude-hosted workflows may apply the delegation rules below automatically.
In native Codex, this skill does not authorize subagents by itself: work inline unless the user
explicitly requests agents or invokes `/swarm`. Do not recursively invoke `codex exec` from Codex.

## Model rankings

Rankings 1-10, higher better. Cost = what we actually pay, not list price. Intelligence = how
hard a problem you can hand over. Taste = UI/UX, code quality, API design, design, copy.

| Model | Cost | Intelligence | Taste |
|---|---|---|---|
| Fable-5 | 1 | 10 | 9 |
| Opus-5 | 5 | 8 | 9 |
| Sonnet-5 | 6 | 5 | 5 |
| GPT-5.6 Sol (codex) | 8 | 9 | 6 |
| GPT-5.6 Terra (codex) | 9 | 6 | 5 |
| GPT-5.6 Luna (codex) | 10 | 3 | 2 |

Model character and best fit:

- **GPT-5.6 Sol -- ultimate robot**: does what it is told, behaves like a tool and AI assistant, uses tools efficiently, and turns every stone. Choose it for exhaustive, explicit execution.
- **Fable-5 -- code people look at**: strongest taste, gorgeous code, excellent frontend work, extremely complex reasoning, and broad big-model knowledge. Use it for hard problems and initial sketches, wireframes, or prototypes, then offload clear mechanical execution to a cheaper model.
- **Opus-5 -- capable without a harness**: use when you want one model without orchestration overhead. It has much of Fable's taste, is less smart, and is cheaper.

GPT-5.5 is retired. Variant floors are hard: Sol runs actual implementation at xhigh,
Opus-work adversarial review at high, and plan or Sol-only review at xhigh; Terra medium|high
handles PR comments and test-runner chores but never product code or review; Luna high only
handles cheap tool loops far from development.

How to apply -- defaults, not limits. Standing permission to override: if a cheaper model's
output does not meet the bar, rerun or redo on a smarter model WITHOUT asking. Judge the
output, not the price tag; escalating costs less than shipping mediocre output.

- Anything that ships: intelligence > taste > cost. Cost is a tiebreaker only.
- Actual implementation: when Claude is enabled, pair Opus 5 xhigh with Sol xhigh in isolated or non-overlapping lanes; without Claude, use Sol xhigh only.
- User-facing (UI, copy, API design): taste >= 7 (Opus-5, Fable-5). Sol drafts, Claude finishes.
- Taste work: run `/stay-within-limits`. 0-20% Fable high | 21-35% Fable medium | 36-50% Fable low | 51-75% Opus xhigh | 76-90% Opus medium | 91-95% Opus low | no Claude above 95% or unknown.
- Cross-model review, automatic on every change: the author model never solely reviews its
  own work, and the reviewer comes from a DIFFERENT family whenever possible (family
  diversity catches shared blind spots). Fresh Sol high adversarial review checks Opus work;
  Opus 5 xhigh feedback checks Sol implementation. Without Claude, clean-context Sol xhigh
  covers every axis. Record unavailable cross-family coverage. Findings P0-P3 -> fixes
  delegated per routing, re-checked by the reviewer.
- Computer use and other token furnaces (browser verification, codebase analysis): shell to
  codex Sol and report back -- see `/codex` for variant routing (Sol/Terra/Luna + effort
  floors), exec/review mechanics, timeouts, worktree isolation, and wrapper labels.
- Fable-5 effort: `high` or lower only -- `xhigh` is token-hungry, `max` a furnace with worse output.
- **Never use Haiku.**

The frontier model is the brains: ambiguous decomposition, architecture/product/safety
tradeoffs, integrating partial implementations, resolving conflicting subagent reports, final
review. Do not delegate tiny tasks, tightly coupled blockers, or judgments that need the
frontier model's full reasoning.

## Workflow

1. Identify frontier-only decisions: architecture, prioritization, ambiguity resolution, risk, synthesis, final review.
2. Identify delegable work: repo inventory, docs extraction, source comparison, browser/testing passes, log clustering, narrow edits.
3. When delegation is authorized, spawn independent subagents with clear ownership, verification gates, and stop conditions; otherwise execute the same lanes inline.
4. Require compact evidence: findings, changed files, commands, residual risk, blockers.
5. Integrate centrally. Reopen high-risk cited files and inspect key diffs before claiming completion.

## Guardrails

- Do not delegate the immediate blocker if the next local step depends on it.
- Do not ask multiple agents to edit the same files concurrently.
- Do not trust subagent conclusions blindly when risk is high.
- Do not claim universal savings; this works best when work parallelizes cleanly.

## Usage limits (long or parallel waves)

1. Run bounded waves: at most 3 parallel subagents unless the user or host gives a throttle.
2. Let in-flight agents finish; do not interrupt them only to save budget.
3. Before and between waves, run `/stay-within-limits` against the Claude statusline quota snapshot.
4. Above 95% of either window: stop launching Claude, prepare a self-contained resume
   (observed window, threshold, next safe check, remaining plan, exact rerun command).
5. On resume, re-check the real window before continuing.

For native Codex, use a real host meter or a user-reported dashboard value. If neither is
available, usage is unknown: do not infer a percentage or reset time from session tokens.
Run at most one explicitly requested wave, checkpoint, then ask before another wave.
