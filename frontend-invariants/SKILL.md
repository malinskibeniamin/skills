---
name: frontend-invariants
description: Apply stack-independent frontend invariants. Use when writing or reviewing React, TypeScript, or UI code across routing, state, data, and design systems.
paths:
  - "**/*.tsx"
  - "**/*.ts"
---

For interface, type or shared-state changes, read [Poteto](../shared/POTETO-NATIVE.md#design).

Override conflicting `/stack-registry` mechanics. Fix at source; suppress only with a same-line reason: escapes train later sessions.

For TypeScript assertions/widened contracts, use [anti-slop](../shared/anti-slop.md):
preserve type evidence; safety comments do not justify casts.

Imports: [checks](../shared/check-loop.md).

## Rendering

1. Never lie: no fake defaults, lossy display of undecodable data, or truthiness hiding numeric zero. Degraded states name possible causes, preserve the reported reason, and offer retry.
2. Put machine truth beside human labels where operators need it; derive labels, never present keys as labels.
3. Hide unready features; reserve loading layout to prevent CLS.
4. Handle loading, empty, error, no-permission, disabled and stuck states. Hide empty chrome only on authoritative loaded data: zero diff totals or disabled actions do not prove no work. Preserve errors, untracked work, progress and recovery.

## State

5. URL holds shareable tabs/filters/sort/page; local/session storage holds preferences; server cache holds server data; component state dies with its component.
6. Push history on section entry; replace within sections.
7. Scope async state by environment/org/user; await teardown before navigation. Abort stale work or use last-write-wins; read defaults after providers resolve.

Editable server defaults: read [override guidance](WRITABLE-DERIVED-STATE.md).

## Design system

8. Use color/spacing/type tokens; round one-offs to scale, never hardcode existing tokens.
9. Fix shared components at source; no forks, inline restyles, or deep selectors. Keep feature rows local, not as single-consumer primitive variants. Verify computed styles across layers and combined flag/theme/interaction variants; low specificity alone does not guarantee utility precedence. Temporary forks need a named defect and upstream ticket.
10. Search first; fix APIs repeatedly misused by consumers.

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
19. Cite owners for domain inheritance, units, names and SLAs; never assume UI truth.
20. Security: no secrets in history; redact logs/replays/dumps; authz fails closed; reads never mutate; audit URL persistence leaks.
