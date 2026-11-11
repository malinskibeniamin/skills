---
description: "Implement a whole spec and its tickets on one integration branch with parallel implementers."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["implement spec"]}
sidebar: {"label":"/implement-spec"}
title: "/implement-spec"
type: "skill"
---
![Diagram of the /implement-spec skill](/diagrams/skills/implement-spec.svg)

[Open the editable Excalidraw source](/diagrams/skills/implement-spec.excalidraw)


You have been provided a spec. This spec should have tickets associated with it, describing how to implement the spec.

Choose this for an approved spec with real blocker edges and independently verifiable tickets, not an ordinary single-ticket task. Invoking this skill is the user's explicit request for delegation and parallel agents; loading or mentioning it is not consent.
Load skills per [dependency loading](https://github.com/malinskibeniamin/skills/blob/v4.45.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

If `CLAUDE.md` exists, read `CLAUDE.md` first; otherwise read `AGENTS.md`. Follow its Issue tracker pointer. If absent, tell the user to run `/work-automation-kit`.

The goal is the entire spec implemented on a single **integration branch**, with every ticket resolved the way the issue tracker closes work.

The tickets are not a list of steps. They are a **task graph** with blocking relationships between them. This means there is always a **frontier** of tickets which are ready to be grabbed.

Communication to and from subagents should be sparse. Communicate primarily through **context pointers**: to the spec, tickets, research notes, and previous commits. Don't duplicate information already available via pointers.

Start every authorized subagent with a fresh context window and a self-contained brief; do not fork the coordinator's conversation.

Use only host-supported, authorized delegation. Bound concurrent implementers by independent
ownership and the coordinator's ability to integrate and verify their work, not frontier size.
An unavailable delegation capability is a reported limitation, not permission to change providers.

## Steps

1. Read the spec, full tickets and blocking relationships. Apply the
   [build-ticket graph contract](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/ticket-graph.md) before dispatch: missing edges,
   cycles and an empty frontier with unfinished work cannot be treated as completion.

2. (optional) Use an **exploration subagent** to conduct any exploration required by the tickets - relevant codebase files or external documentation. Ensure the exploration subagent can save files - it should save its markdown notes in a directory outside the repo, accessible by all future subagents. This lets **implementer subagents** focus on implementation rather than exploration.

3. Create the integration branch. If the issue tracker closes work through PRs, or the user asks for one, open a draft PR after the first merge in step 5 (a branch with no commits ahead of main can't open one), marked as closing the spec and tickets.

4. Use a fresh **implementer subagent** for each ticket, each in its own worktree on its own branch. Each implementer subagent:
   - confirms its clean, agent-owned worktree is based on the integration branch's pinned tip before starting; correct a wrong base without resetting foreign, dirty or concurrent work;
   - Calls the Skill tool with "tdd" to build the ticket;
   - merges the integration branch tip into its own branch before reporting done, so step 5 is a fast-forward.

5. Once an **implementer subagent** completes, merge its work to the integration branch with a **merger subagent**.

6. Verify the integrated slice against its acceptance criteria, then refresh ticket state
   and recompute the **frontier**. Dispatch newly ready work within the authorized bounds;
   an implementer's completion alone never unblocks dependent work.

7. Once all tickets are complete, Call the Skill tool with "review" on the integration branch. Fix all issues raised by the code review in a single fresh **implementer subagent**.

8. If a draft PR exists, keep it draft when that is the requested endpoint; otherwise mark it ready for review. Without a PR, resolve each ticket the way the issue tracker closes work, and report the integration branch.

9. Clean up only owned implementer worktrees whose results are integrated and whose useful
   artifacts are retained. Preserve dirty, unpushed or foreign work; report anything left.
