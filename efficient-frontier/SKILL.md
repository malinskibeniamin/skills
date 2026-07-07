---
name: efficient-frontier
description: Use when a frontier model (Fable, Opus, GPT-5.6) should delegate bounded research, coding, testing, or log reduction to cheaper models while keeping planning, synthesis, risk, and final review central. Owns usage-limit budgeting for agent waves.
---

# Efficient Frontier
Read `references/builder-upstream.md` for the full workflow.

Use the expensive frontier model where marginal judgment matters. Push repeatable, bounded, or token-heavy work to cheaper/faster subagents.

## Model routing

The frontier model (Fable, Opus, GPT-5.6) is the brains: it owns ambiguous decomposition,
architecture/product/safety tradeoffs, integrating partial implementations, resolving conflicting
subagent reports, and the final review. Mundane bounded work routes to the cheaper tier
(Sonnet for exploration/atomic coding, Haiku for lookups/boilerplate/log reduction, or the
host's equivalent mini/fast models). Do not delegate tiny tasks, tightly coupled blockers, or
judgments that need the frontier model's full reasoning.

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
