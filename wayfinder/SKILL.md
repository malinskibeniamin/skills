---
name: wayfinder
description: Plan huge work that cannot fit in one agent session as a shared issue-tracker map, then resolve one investigation ticket per session until the route is clear.
---

# Wayfinder

Repo/code changes: run `/deslop` before commit, push, PR, or merge.

Use when a goal is too large for one context window and the route is still foggy. Wayfinder turns the unknowns into a shared map on the repo's issue tracker, then works exactly one ticket per session.

## Invariants

- Refer to maps and tickets by **name** (their title), not a bare id or slug. Link the name when needed.
- The map is an **index**, not a store: decisions live in their ticket; the map keeps only a one-line gist and pointer.
- Tracker mechanics come from `docs/agents/issue-tracker.md` under **Wayfinding operations**. If missing, use the local-markdown fallback.
- Claim a ticket before work by assigning it to the driving dev; this must be the session's first write. Open + unassigned means unclaimed.
- Use the tracker's native blocking/dependency feature when available; fallback to an explicit `Blocked by:` line only when native blocking is unavailable.
- Never resolve more than one ticket per session.

## Map shape

The map is one issue or file labelled/marked `wayfinder:map`.

```markdown
## Notes

<domain; skills every session should consult; standing preferences for this effort>

## Decisions so far

- [<closed ticket title>](link) -- <one-line gist of the answer>

## Fog

<suspected future questions or risks not sharp enough to ticket yet>
```

Open tickets are not listed in the map body; query the issue tracker for open children/frontier tickets.

## Tickets

Each ticket is a child issue/file with a focused question sized to one 100K-token agent session:

```markdown
## Question

<the decision or investigation this ticket resolves>
```

Ticket types:

- **Research**: read docs, APIs, specs, source, or other primary sources. Link the cited Markdown summary.
- **Prototype**: make a cheap artifact to react to, including `/prototype` UI or logic code. Link the artifact.
- **Grilling**: conversation with `/grilling` and `/domain-modeling`. Default when the question is mostly judgment.
- **Task**: literal manual work needed before decisions can continue. Automate where safe; otherwise hand the human a checklist.

The answer is not part of the body. Record it on resolution. Assets are linked, not pasted.

## Fog of war

Do not chart what you cannot yet see. Fog is for suspected questions or risks that are not precise enough to assign. A ticket is for a sharp question, even if blocked. Fog excludes what is already decided and what is already a ticket. Resolving one ticket clears nearby fog and may graduate part of it into new tickets.

## Chart the map

1. Run `/grilling` and `/domain-modeling` to surface open decisions.
2. Create the map with Notes, empty Decisions so far, and Fog.
3. Create only the tickets you can specify now. Wire blocking relationships in a second pass after tickets have ids.
4. Stop. Charting the map is one session's work. Do not also resolve tickets.

## Work through a map

1. Load the map low-res; do not load every ticket body.
2. Pick the ticket: use the named ticket, or choose the first open, unblocked, unclaimed frontier ticket. Claim it first.
3. Resolve it, zooming into related/closed tickets only as needed. Invoke skills named in Notes; when unsure, use `/grilling` and `/domain-modeling`.
4. Record the answer as a resolution comment or answer section, close/resolve the ticket, then append a context pointer to Decisions so far.
5. Add newly surfaced tickets and blocking edges; clear graduated Fog so each fact lives in one place.

Expect other sessions to edit the tracker concurrently; read current tracker state before writing.

## Handoff

Recheck your claims first. Before showing the frontier, reread the resolution answer, Decisions-so-far gist, linked assets, and tracker state. Fix any stale or unsupported claim before asking the human to act on the next tickets.

End with copy-pasteable next steps: one command for the next recommended ticket, plus one pinned command per open, unblocked, unclaimed frontier ticket when parallel sessions are safe.
