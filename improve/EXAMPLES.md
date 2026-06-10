# Improve examples

`/improve` uses the most capable model for audit and planning, then leaves execution to cheaper models or humans. The output is not a patch; it is a set of plans any fresh-context agent can execute safely later.

## Standard audit

User: `/improve`

Expected result: advisor runs read-only recon and audit, presents a prioritized findings table, asks which findings to turn into plans, then writes selected plans under `plans/`.

## Quick focused audit

User: `/improve quick security`

Expected result: advisor checks security hotspots only, reports high-confidence findings with evidence, and states what was not audited.

## Single known plan

User: `/improve plan extract duplicated config loader`

Expected result: advisor investigates only enough to write one self-contained plan with drift check, exact scope, verification commands, STOP conditions, and done criteria.

## Review existing plan

User: `/improve review-plan plans/003-cache-boundary.md`

Expected result: advisor critiques whether the plan is executable by a fresh-context agent, then edits only the plan files to remove ambiguity.

## Reconcile backlog

User: `/improve reconcile`

Expected result: advisor verifies existing plan statuses, refreshes drifted plans, marks obsolete plans retired, and updates `plans/README.md`.
