---
name: efficient-frontier
description: Use when a frontier model (Fable, Opus, GPT-5.6) should delegate bounded research, coding, testing, or log reduction to cheaper models while keeping planning, synthesis, risk, and final review central. Owns usage-limit budgeting for agent waves.
---

# Efficient Frontier
Read `references/builder-upstream.md` for the full workflow.

Use the expensive frontier model where marginal judgment matters. Push repeatable, bounded, or token-heavy work to cheaper/faster subagents.

## Model rankings

Rankings 1-10, higher better. Cost = what we actually pay, not list price. Intelligence = how
hard a problem you can hand over. Taste = UI/UX, code quality, API design, design, copy.

| Model | Cost | Intelligence | Taste |
|---|---|---|---|
| Fable-5 | 1 | 10 | 9 |
| Opus-4.8 | 4 | 7 | 8 |
| Sonnet-5 | 6 | 5 | 7 |
| GPT-5.6 (codex) | 8 | 9 | 6 |
| GPT-5.5 (codex) | 9 | 5 | 5 |

How to apply -- defaults, not limits. Standing permission to override: if a cheaper model's
output does not meet the bar, rerun or redo on a smarter model WITHOUT asking. Judge the
output, not the price tag; escalating costs less than shipping mediocre output.

- Anything that ships: intelligence > taste > cost. Cost is a tiebreaker only.
- Bulk mechanical (clear-spec implementation, data analysis, migrations): GPT-5.5 -- effectively free.
- User-facing (UI, copy, API design): taste >= 7 (Sonnet-5, Opus-4.8, Fable-5). GPT-5.5 drafts, Claude finishes.
- Reviews and plans: Fable-5 or Opus-4.8; optionally GPT-5.5 as an extra independent perspective.
- Computer use and other token furnaces (browser verification, codebase analysis): shell to
  codex GPT-5.5/5.6 and report back -- see `/codex` for mechanics (exec/review, timeouts,
  worktree isolation, the sonnet+low wrapper pattern for workflows with `GPT-5.5:` labels).
- Fable-5 effort: `high` or lower only -- `xhigh` is token-hungry, `max` a furnace with worse output.
- **Never use Haiku.**

The frontier model is the brains: ambiguous decomposition, architecture/product/safety
tradeoffs, integrating partial implementations, resolving conflicting subagent reports, final
review. Do not delegate tiny tasks, tightly coupled blockers, or judgments that need the
frontier model's full reasoning.

## Workflow

1. Identify frontier-only decisions: architecture, prioritization, ambiguity resolution, risk, synthesis, final review.
2. Identify delegable work: repo inventory, docs extraction, source comparison, browser/testing passes, log clustering, narrow edits.
3. Spawn independent subagents with clear ownership, verification gates, and stop conditions.
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
3. Between waves, check 5-hour and weekly usage with the host's usage tool
   (Claude Code: `bunx -y ccusage@latest blocks --active --json`).
4. At or above 95% of either window: stop launching, prepare a self-contained resume
   (observed window, threshold, next safe check, remaining plan, exact rerun command).
5. On resume, re-check the real window before continuing.
