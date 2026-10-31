---
description: "Compatibility preset for author delivery through an authorized merge; full stop or --no-merge retains the merge decision."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["full send"]}
sidebar: {"label":"/full-send"}
title: "/full-send"
type: "skill"
---
![Diagram of the /full-send skill](/diagrams/skills/full-send.svg)

[Open the editable Excalidraw source](/diagrams/skills/full-send.excalidraw)


An explicit `full send <task or PR>` selects the [author delivery workflow](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/delivery-workflow.md)
and authorizes fixes, commit, push, PR, CI/review follow-through and merge of that one
unambiguous deliverable. Discussing this skill is not an invocation.

Earlier stops win: local, no push, draft only, PR-ready, full stop or `--no-merge` narrow the
endpoint. Babysitting alone never grants merge permission. Resolve target/owned worktree,
reuse its PR and keep its branch checked out in Conductor. Ask only if the target is ambiguous
or an owner-reserved decision blocks it.

Read and run the shared workflow, not a second full-send implementation. For unfinished code,
load [development-lifecycle](https://github.com/malinskibeniamin/skills/blob/v4.42.0/development-lifecycle/SKILL.md); existing PRs start from their
current evidence. Use [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/full-send/REFERENCE.md) only for its requested checkpoint,
notification, resume or explicitly delegated review branch. No automatic model switch or agents.

Read [tstack composition](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/TSTACK.md#full-send) and its upstream proof guidance
without changing this owner, adding implicit reviewers or broadening permissions.

The shared workflow selects [native context](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/T3CODE-NATIVE.md#resolve-context)
for authorized monitoring; keep one delivery loop, not a separate T3 workflow.

Inspiration and research limits: [SOURCES.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/full-send/SOURCES.md). Local delivery composes a
licensed tstack snapshot; it is not an upstream endorsement.
