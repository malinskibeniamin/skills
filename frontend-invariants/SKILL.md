---
name: frontend-invariants
description: Apply stack-independent frontend invariants. Use when writing or reviewing React, TypeScript, or UI code across routing, state, data, and design systems.
paths:
  - "**/*.tsx"
  - "**/*.ts"
---

These survive stack migrations and override conflicting stack mechanics in `/stack-registry`. Every tolerated escape hatch trains later sessions: fix at source; suppress only with a same-line reason.

## Rendering

1. Never lie: no fake defaults, lossy display of undecodable data, or truthiness hiding numeric zero. Degraded states name possible causes, preserve the reported reason, and offer retry.
2. Put machine truth beside human labels where operators need it; derive labels, never present keys as labels.
3. Hide unready features; reserve loading layout to prevent CLS.
4. Handle loading, empty, error, no-permission, disabled, and stuck states.

## State

5. URL holds shareable tabs/filters/sort/page; local/session storage holds preferences; server cache holds server data; component state dies with its component.
6. Section entry pushes history; intra-section navigation replaces it.
7. Async state must be scoped by full environment/org/user identity. Await teardown before navigation; abort or use last-write-wins; never read defaults before providers resolve.

## Design system

8. Use color/spacing/type tokens; round one-offs to the scale, never hardcode when a token exists.
9. Fix shared components at source; no forks, inline restyles, or deep selectors. A temporary fork needs a named defect and upstream ticket.
10. Search before building. Repeated consumer misuse means fix the API.

## Interaction

11. Buttons act; links navigate and support command-click. Disabled controls expose a reason.
12. Destructive flows fail closed: enable confirmation only after a fresh zero-reference check; X/Escape/Enter/back respect dirty and in-flight state.
13. Motion only clarifies state; honor `prefers-reduced-motion`.

## Process

14. Mock minimally at boundary seams and only for unhappy paths; factories build real types by assignment, not deep merge.
15. Tests prove user-caused side effects, not rendering; wait for conditions, never durations.
16. Migrations mechanically freeze old patterns. Feature-flag removal is definition of done.
17. Keep PRs single-purpose; migrations migrate; deferrals link tickets; dependency bumps and registry syncs ship separately.
18. Use precise names: no route/file/label acronyms; booleans are predicates.
19. Source domain inheritance, units, naming, and SLAs from cited owners; never assume UI truth.
20. Review security: no secrets in history; redact logs/replays/dumps; authz fails closed; reads never mutate; audit URL persistence leaks.
