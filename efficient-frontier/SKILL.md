---
name: efficient-frontier
description: Use when a high-cost frontier model should delegate bounded research, coding, testing, browser checks, or log reduction while keeping planning, synthesis, risk, integration, and final review central.
---

# Efficient Frontier

Repo/code changes: run `/deslop` before commit, push, PR, or merge.
Vendored from Builder.io. Read `references/builder-upstream.md` for the full upstream workflow.

Use the expensive frontier model where marginal judgment matters. Push repeatable, bounded, or token-heavy work to cheaper/faster subagents.

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
