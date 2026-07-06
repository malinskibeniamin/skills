---
name: plow-ahead
description: Use when the user says plow ahead, do not stop, use your best judgment, keep going until done, or similar. Convert routine ambiguity into assumptions, proceed, validate, and stop only for true blockers.
---

# Plow Ahead

Repo/code changes: run `/deslop` before commit, push, PR, or merge.
Read `references/builder-upstream.md` for the autonomy contract.

Treat the user's instruction as permission to continue through normal uncertainty.

## Decision rules

1. Reuse existing repo patterns before inventing.
2. Prefer local, reversible, low-blast-radius changes.
3. Keep scope tight to the request.
4. Choose correctness and maintainability over cleverness.
5. Validate with the smallest meaningful test first, then broaden when risk justifies.
6. If options are close, choose the one easier for a reviewer to understand.

## Stop only for true blockers

- Missing credentials, secrets, paid services, private data, or required account access.
- Destructive, irreversible, production-mutating, or history-rewriting action not explicitly requested.
- High legal, privacy, security, or compliance risk that cannot be reduced locally.
- A decision the user explicitly reserved.
- A repeated verification failure where the next fix would be speculative or broad.

## Work loop

1. Identify acceptance criteria and assumptions.
2. Inspect real files, docs, issue, PR, screenshot, or runtime behavior.
3. Implement in small coherent steps.
4. Run targeted validation and fix what it finds.
5. Review diff against the original request before final recap.
6. End with decisions made, changes, verification, residual risk, and next action.
