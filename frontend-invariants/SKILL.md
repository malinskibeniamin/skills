---
name: frontend-invariants
description: Apply stack-independent frontend invariants. Use when writing or reviewing React, TypeScript, or UI code across routing, state, data, and design systems.
paths:
  - "**/*.tsx"
  - "**/*.ts"
---

# Frontend Invariants

These principles survived every stack migration (UI kits, routers, data layers, form and state libraries all died; these did not). When an invariant and a stack-specific rule conflict, the invariant wins; stack mechanics live in `/stack-registry`.

## The amplification principle
Every tolerated anti-pattern, escape hatch, or suppression is a training example the next LLM session imitates and spreads. Fix at source; suppress only with a same-line reason; never let "just this once" in.

## Rendering honesty
1. **Never lie in the rendering.** No fake defaults, no lossy pretty-printing of undecodable data, no hiding legitimate zeros (`value == null`, never truthiness, for numeric display). Degraded states name the possible causes, quote the reported reason verbatim, and offer retry.
2. **Machine truth beside human labels** -- show the ID/raw value where operators need it; derive display strings, never display machine keys as labels.
3. **Show nothing before it's ready** -- unready features are hidden, not teased; loading reserves layout (no CLS).
4. **Every surface handles its full state matrix**: loading / empty / error / no-permission / disabled / stuck -- not just the happy path.

## State placement
5. **URL = shareable state** (tabs, filters, sort, page); **local/session storage = personal prefs** (density, collapsed panels); **server cache = server data**; component state only for what dies with the component. Never swap lanes.
6. **Intra-section navigation replaces history; section entry pushes** -- Back escapes the section, it doesn't replay every tab.
7. **The recurring async meta-bug**: state resolved asynchronously, read too early or scoped too broadly -- key caches by their full scope (env/org/user), await teardown before navigation, abort or last-write-wins stale responses, don't read flag/config defaults before the provider resolves.

## Design-system relationship
8. **Tokens over ad-hoc values** -- color, spacing, type all come from the scale; round designer one-offs to the nearest step; never hardcode hex/px where a token exists.
9. **Fix shared components at source** -- never fork, inline-restyle, or deep-select into a shared component; a fork is acceptable only with a named defect and a ticket to fix upstream.
10. **Search the system before building** -- the component you need probably exists; when consumers repeatedly misuse an API, fix the API, not the consumers.

## Interaction
11. **Buttons act, links navigate** -- anything that changes the URL is a real link (cmd-click works); actions are buttons; disabled controls carry a perceivable reason.
12. **Destructive flows fail closed** -- confirm enables only after a fresh successful zero-reference check; every close path (X/ESC/Enter/back) respects in-flight and dirty state.
13. **Restrained motion by default** -- animation only when it clarifies a state change; honor `prefers-reduced-motion`; delete animation that fights usability.

## Process
14. **Mock at the boundary seam, as little as possible**; only mock unhappy paths; test factories construct real types (assign, never deep-merge).
15. **Tests prove side effects a user can cause** -- delete render-only tests; wait for causes, never durations.
16. **A migration ends with a mechanical freeze** on the old pattern; a feature flag's removal is part of its definition of done.
17. **Scope discipline**: single-purpose PRs; migrations migrate; deferrals carry ticket links; dependency bumps and registry syncs ship separately.
18. **Verbose, entity-precise naming** -- no acronyms in routes/files/labels; booleans read as predicates; precision doubles as LLM-hallucination defense.
19. **Domain truth comes from the domain owner** -- inheritance chains, units (GiB vs GB), naming standards, SLAs are sourced and cited, never assumed in the UI.
20. **Frontend review includes a security pass** -- no secrets in git history, redact logs/replays/failure dumps, fail closed on authz, reads never mutate, audit what URL persistence leaks.
