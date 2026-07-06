---
name: efficient-fable
description: Use when Claude Fable should orchestrate codebase-heavy work while cheaper agents do bounded research, coding, testing, or log reduction. Keep Fable on architecture, synthesis, integration, risk, and final review.
---

# Efficient Fable

Repo/code changes: run `/deslop` before commit, push, PR, or merge.
Vendored from Builder.io. Read `references/builder-upstream.md` for the full orchestration notes.

Use Fable as orchestrator, architect, synthesizer, and final judge. Use cheaper subagents for bounded research, coding, testing, log reduction, and repetitive edits.

## Fable owns

- Ambiguous decomposition and sequencing.
- Architecture, product, safety, and rollback tradeoffs.
- Integrating partial implementations into one coherent path.
- Resolving conflicting subagent reports.
- Final review and user-facing synthesis.

## Delegation loop

1. Name the expensive-token risk: large repo search, long logs, docs scan, or repeated edits.
2. Split independent work into bounded agents before reading everything yourself.
3. Give each agent a self-contained handoff: repo, objective, scope, out-of-scope, evidence format, verify commands, stop conditions.
4. Ask for compact evidence: files, lines, commands, diffs, uncertainty, and blockers.
5. Reopen important cited files and inspect high-impact claims before deciding.
6. Spend Fable tokens on judgment, integration, and final review.

Do not delegate tiny tasks, tightly coupled blockers, or judgments that require Fable's full reasoning.
