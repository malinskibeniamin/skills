---
description: "Apply stack-independent frontend invariants. Use when writing or reviewing React, TypeScript, or UI code across routing, state, data, and design systems."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["frontend invariants"]}
sidebar: {"label":"/frontend-invariants"}
title: "/frontend-invariants"
type: "skill"
---
![Diagram of the /frontend-invariants skill](/diagrams/skills/frontend-invariants.svg)

[Open the editable Excalidraw source](/diagrams/skills/frontend-invariants.excalidraw)


When changing interfaces, types or shared state, read the [Poteto adaptation](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-NATIVE.md#design).

Override conflicting `/stack-registry` mechanics. Fix at source; suppress only with a same-line reason: escapes train later sessions.

For TypeScript assertions or widened contracts, use [anti-slop checks](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/anti-slop.md)
to preserve type evidence; a safety comment alone does not justify a cast.

## Rendering

1. Never lie: no fake defaults, lossy display of undecodable data, or truthiness hiding numeric zero. Degraded states name possible causes, preserve the reported reason, and offer retry.
2. Put machine truth beside human labels where operators need it; derive labels, never present keys as labels.
3. Hide unready features; reserve loading layout to prevent CLS.
4. Handle loading, empty, error, no-permission, disabled, and stuck states. Hide empty chrome only from authoritative loaded state: zero diff totals or a disabled action do not prove no work; preserve errors, untracked work, progress, and recovery paths.

## State

5. URL holds shareable tabs/filters/sort/page; local/session storage holds preferences; server cache holds server data; component state dies with its component.
6. Section entry pushes history; intra-section navigation replaces it.
7. Async state must be scoped by full environment/org/user identity. Await teardown before navigation; abort or use last-write-wins; never read defaults before providers resolve.

## Design system

8. Use color/spacing/type tokens; round one-offs to scale, never hardcode existing tokens.
9. Fix shared components at source; no forks, inline restyles, or deep selectors. Keep feature-specific rows beside their feature, not as single-consumer primitive variants. Verify computed styles across cascade layers and combined flag/theme/interaction variants; low specificity alone does not guarantee utility precedence. A temporary fork needs a named defect and upstream ticket.
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
20. Review security: no secrets in history; redact logs/replays/dumps; authz fails closed; reads never mutate; audit URL persistence leaks.
