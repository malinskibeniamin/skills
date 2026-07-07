---
name: implement
description: Implement a piece of work based on a spec or set of tickets.
disable-model-invocation: true
---
Repo/code changes: run `/deslop` before commit, push, PR, or merge.


Implement the work described by the user in the spec or tickets.

If the spec cites third-party/API behavior, run `/read-the-damn-docs`. If an approved `/visual-plan` exists, treat it as the reviewable plan of record and keep implementation aligned.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /review to review the work.

Commit your work to the current branch.
