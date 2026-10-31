---
description: "Stress-test UI data/layout: long text, Unicode, zoom, narrow containers, empty states, and large collections. Use during diagnosis, dogfood, visual review, or explicit break-it requests."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["break ui"]}
sidebar: {"label":"/break-ui"}
title: "/break-ui"
type: "skill"
---
![Diagram of the /break-ui skill](/diagrams/skills/break-ui.svg)

[Open the editable Excalidraw source](/diagrams/skills/break-ui.excalidraw)


Test the real component against unkind but valid data. Adapted from Emil Kowalski;
[provenance](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/EMIL-SKILLS-CREDITS.md). This is a targeted data/layout audit,
not a replacement for lifecycle dogfood or general visual critique.

## Endpoint

An audit returns evidence and proposed fixes, without editing production components.
Use existing stories/fixtures/mocks first. Create a dev-only toggle or isolated harness
only when the request includes building one; keep scratch artifacts in `.context/`.
An explicit fix request authorizes repairing confirmed defects through TDD and delivery;
do not force another approval step for routine in-scope fixes.

## Loop

For component-specific scenario selection, read the pinned
[scenario axes](https://github.com/malinskibeniamin/skills/blob/v4.42.0/vendor/jakubkrehel/skills/break/scenarios.md) alongside this catalogue.
Use [interface compatibility](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/INTERFACES.md#break); the separate user-only
`break` page is recommended only when requested, never created by an audit alone.

1. Map rendered fields, their source/type, schema limit, optionality, and collection bounds.
   A missing bound means unknown, not permission to invent one or change the API.
2. Read [CATALOG.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/break-ui/CATALOG.md). Choose realistic values within the actual contract;
   introduce invalid/null values only at a boundary expected to validate them.
   Keep shape, component code, tokens, and rendering path unchanged.
3. Feed fixtures through the real props/mock/API boundary. Mix long/short/Unicode data,
   missing optional fields, all valid statuses, and counts 0/1/many. Compare normal data,
   worst case, empty, one item, and the supported cardinality limit.
4. Render in the real container plus the narrowest/widest supported layout, at 200% zoom,
   and in supported themes/directions. Exercise overflowed actions with keyboard/touch.
   Capture screenshots/state; when browser access is missing, label CSS inference.
5. Report the value, visible failure, location, impact, proposed fix, and what held up.
   Identify genuine product choices (wrap/truncate, pagination/virtualization); preserve
   existing conventions rather than turning every edge into a redesign.
6. For requested fixes, start with a failing public-contract regression, repair, then
   replay every affected fixture and normal data. Keep regression fixtures test/dev-only.

## Failure handles

Check fixed-size flex siblings, `min-width: 0`/`minmax(0, 1fr)`, unbreakable strings,
multiline glyph clipping, grapheme-safe initials, locale/plurals, image fallback,
and full-value access after truncation. Never hide numbers the user must compare.

Fixtures use reserved example domains and synthetic data. Never call real customers,
render fixture HTML as executable markup, or mutate production records to make a test.
Report-only requests stop at the report; no gratuitous persistent process or demo switch.
