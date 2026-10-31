---
description: "Design deep modules with small interfaces. Use when choosing seams, reducing file-hop friction, deepening modules, testing APIs, or applying shared design vocabulary."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["codebase design"]}
sidebar: {"label":"/codebase-design"}
title: "/codebase-design"
type: "skill"
---
![Diagram of the /codebase-design skill](/diagrams/skills/codebase-design.svg)

[Open the editable Excalidraw source](/diagrams/skills/codebase-design.excalidraw)


On interface/type/shared-state changes, read [Poteto](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-NATIVE.md#design).

Design **deep modules**: substantial behavior behind a small interface at a clean seam, testable through that interface. Optimize caller leverage, maintainer locality, and testability.
Use `GLOSSARY.md` terms, via `GLOSSARY-MAP.md` when present; respect ADRs.

A module should reduce caller knowledge and coordination while preserving required behavior.

## Glossary

Use exactly:

**Module** -- interface plus implementation: function, class, package, slice.

**Interface** -- everything callers know: types, invariants, ordering, errors, config, performance; broader than signature.

**Implementation** -- module internals.

**Depth** -- interface leverage. **Deep** means small interface/large behavior; **shallow** means similar interface and implementation complexity.

**Seam** -- where behavior can vary without editing the caller; its interface lives here. Avoid: boundary, except DDD bounded context.

**Adapter** -- concrete implementation at a seam, named by role.

**Leverage** -- capability per interface learned.

**Locality** -- change, bugs, knowledge, verification concentrate together.

Ask whether methods/parameters can shrink and more complexity can hide.

## Principles

- Depth is an interface property, not line ratio; private seams need not leak.
- **Deletion test:** if removal makes complexity vanish, the module was pass-through; if complexity spreads into callers/tests, it earned its keep.
- **The interface is the test surface:** callers and tests cross the same seam. Testing past it signals a weak shape.
- **One adapter is a hypothetical seam; Two adapters means a real one.**
- Direct local code beats an abstraction that only moves code.

## Caller-first sketch

For new/changed interfaces, sketch caller success and failure before types. Name state
owner, invariant and failure result. Derive signatures; apply
[probe](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-ENGINEERING.md#probe-the-shortest-wrong-edit).

## Testability

1. Accept dependencies; do not create them internally.
2. Return results; minimize ambient side effects.
3. Keep methods/parameters few and invariants clear.

When two designs survive deletion, Call the Skill tool with "plan-arbiter": depth, locality, test surface, rollback. Other hosts: [dependency loading](https://github.com/malinskibeniamin/skills/blob/v4.42.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

Relationships: Module has one Interface; Depth is measured against it; Seam hosts it; Adapter satisfies it; Depth creates Leverage and Locality.

Reject depth-by-line-count, interface-as-TypeScript-keyword, and vague boundary wording.

Read [DEEPENING.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/codebase-design/DEEPENING.md) for dependency/seam/testing discipline and [DESIGN-IT-TWICE.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/codebase-design/DESIGN-IT-TWICE.md) for parallel designs.
