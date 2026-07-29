---
name: wayfinder
description: Map multi-session work through issue-tracker decision tickets.
disable-model-invocation: true
---

# Wayfinder
Use when a goal is too large for one context window and the way to the **destination** is still foggy. Wayfinder finds the route through **decision tickets** -- questions whose resolution is a decision, not slices of a build to execute. The destination might be a spec, a decision, or a change whose path is unclear.

## Plan, don't do
Wayfinder is planning by default. Each ticket resolves a decision, and the map is done when nothing is left to decide before someone goes and does the thing. The pull to execute is usually the signal that the edge of the map has been reached. An effort can override this in Notes, but absent that, produce decisions, not deliverables.

## Invariants
- Refer to maps and tickets by **name** (their title), not a bare id or slug. Link the name when needed.
- The map is an **index**, not a store: decisions live in their ticket; the map keeps only a one-line gist and pointer.
- Read `CLAUDE.md` first when it exists; otherwise read `AGENTS.md`. Follow that file's **Issue tracker** pointer, then read **Wayfinding operations**. Never assume a document path. If neither file or pointer exists, use the local-markdown fallback.
- Claim a ticket before work by assigning it to the driving dev; this must be the session's first write. Open + unassigned means unclaimed.
- Use the tracker's native blocking/dependency feature when available; fallback to an explicit `Blocked by:` line only when native blocking is unavailable.
- Resolve at most one ticket per session in the primary context. Explicit delegation or
  `/swarm` may authorize parallel ready research tickets; wayfinder invocation alone does not.
- For an authorized parallel map, apply `/efficient-frontier` between ticket waves
  and keep synthesis with the coordinator.
- Use `/agent-watchdog` when auditing another session's resolved ticket, claim, branch, or frontier summary before trusting the map.

## Map shape
The map is one issue or file labelled/marked `wayfinder:map`.

```markdown
## Destination
<what reaching the end of this map looks like -- the spec, decision, or change this effort is finding its way to>
## Notes
<domain; skills every session should consult; standing preferences for this effort>
## Decisions so far
- [<closed ticket title>](link) -- <one-line gist of the answer>
## Not yet specified
<in-scope future questions or risks not sharp enough to ticket yet>
## Out of scope
<work ruled beyond this destination>
```

Open tickets are not listed in the map body; query the issue tracker for open children/frontier tickets.

## Tickets
Each decision ticket is a child issue/file with a focused question sized to one 100K-token agent session:

```markdown
## Question

<the decision or investigation this ticket resolves>
```

Each ticket is either **HITL** -- human in the loop, worked with a human who speaks for themselves -- or **AFK**, driven by the agent alone. A HITL ticket only resolves through that live exchange; the agent must not answer its own grilling questions.

Ticket types:

- **Research** (AFK): read docs, APIs, specs, source, or other primary sources through
  `/research` in the primary context. Link the cited Markdown summary. Use a research lane
  only after explicit delegation or `/swarm`.
- **Prototype** (HITL): make a cheap artifact to react to, including `/prototype` UI or logic code. Link the artifact.
- **Grilling** (HITL): conversation with `/grilling` and `/domain-modeling`. Default when the question is mostly judgment.
- **Task** (HITL or AFK): manual work needed before a decision can continue. Automate where safe; otherwise hand the human a checklist. It earns its place by unblocking a decision, not by delivering the destination.

The answer is not part of the body. Record it on resolution. Assets are linked, not pasted.

## Fog of war
Do not chart what you cannot yet see. **Not yet specified** is for suspected in-scope questions or risks that are not precise enough to assign. A ticket is for a sharp question, even if blocked. Not yet specified excludes what is already decided, what is already a ticket, and what is out of scope.

## Out of scope

Fog only gathers toward the destination. Work beyond the destination is **Out of scope**: it is not fog and it never graduates into tickets unless the destination is redrawn. If a ticket turns out to sit beyond the destination, close it, add one Out of scope line with the reason, and do not record it as a route decision.

## Chart the map

1. Name the Destination. Run `/grilling` and `/domain-modeling` to pin down what this map is finding its way to.
2. Map the frontier. Grill breadth-first across the whole space, surfacing open decisions and first steps. **If this surfaces no fog**, you don't need a map; stop and ask the user how to proceed.
3. Create the map with Destination, Notes, empty Decisions so far, Not yet specified, and Out of scope.
4. Create only the tickets you can specify now. Wire blocking relationships in a second pass after tickets have ids.
5. Resolve one ready AFK Research ticket inline in the primary context. If the user explicitly
   authorized delegation or invoked `/swarm`, launch distinct ready research lanes; each lane
   claims its ticket first, follows `/research`'s artifact location, and does not invent a root
   file or branch.
6. Stop after that one ready research ticket; do not resolve another ticket in this session.

## Work through a map

1. Load the map low-res; do not load every ticket body.
2. Pick the ticket: use the named ticket, or choose the first open, unblocked, unclaimed frontier ticket. Claim it first.
3. Resolve it, zooming into related/closed tickets only as needed. Invoke skills named in Notes; when unsure, use `/grilling` and `/domain-modeling`.
4. Record the answer as a resolution comment or answer section, close/resolve the ticket, then append a context pointer to Decisions so far.
5. Add newly surfaced tickets and blocking edges; clear graduated Not yet specified entries so each fact lives in one place. If a ticket sits beyond the Destination, rule it Out of scope rather than resolving it on the route.

Expect other sessions to edit the tracker concurrently; read current tracker state before writing.

## Handoff

When the map is clear, hand it to `/to-spec` to collapse the linked decisions into one buildable plan, then `/to-tickets`. Skip that collapse only when the effort proved genuinely small.

Recheck your claims first. Before showing the frontier, reread the resolution answer, Decisions-so-far gist, linked assets, and tracker state. Fix any stale or unsupported claim before asking the human to act on the next tickets.

End with copy-pasteable next steps: one command for the next recommended ticket, plus one pinned command per open, unblocked, unclaimed frontier ticket when parallel sessions are safe.
