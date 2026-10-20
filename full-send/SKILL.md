---
name: full-send
description: Compatibility preset for author delivery through an authorized merge; full stop or --no-merge retains the merge decision.
---

An explicit `full send <task or PR>` selects the [author delivery workflow](../shared/delivery-workflow.md)
and authorizes fixes, commit, push, PR, CI/review follow-through and merge of that one
unambiguous deliverable. Discussing this skill is not an invocation.

Earlier stops win: local, no push, draft only, PR-ready, full stop or `--no-merge` narrow the
endpoint. Babysitting alone never grants merge permission. Resolve target/owned worktree,
reuse its PR and keep its branch checked out in Conductor. Ask only if the target is ambiguous
or an owner-reserved decision blocks it.

Read and run the shared workflow, not a second full-send implementation. For unfinished code,
load [development-lifecycle](../development-lifecycle/SKILL.md); existing PRs start from their
current evidence. Use [REFERENCE.md](REFERENCE.md) only for its requested checkpoint,
notification, resume or explicitly delegated review branch. No automatic model switch or agents.

Inspiration and research limits: [SOURCES.md](SOURCES.md). This local workflow is not a
copied or endorsed Theo skill.
