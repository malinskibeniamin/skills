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


On interface/type/shared-state changes, read [Poteto](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/POTETO-NATIVE.md#design).

Design **deep modules**: substantial behavior behind a small, independently testable interface. Apply [verifiability](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/verifiability.md): caller leverage and locality, not implementation size.
Use `GLOSSARY.md` terms, via `GLOSSARY-MAP.md` when present; respect ADRs.

Reduce caller knowledge/coordination; preserve required behavior.

Imports: [checks](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/check-loop.md).

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
[probe](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/POTETO-ENGINEERING.md#probe-the-shortest-wrong-edit).

## Testability

1. Exercise the public interface with a focused command and repeatable fixture.
2. Control dependencies at existing seams; return observable results and isolate state.
3. Expose invariants and failure diagnostics; prove wrong behavior fails through the public interface.

When two designs survive deletion, Call the Skill tool with "plan-arbiter": depth, locality, test surface, rollback. Other hosts: [dependency loading](https://github.com/malinskibeniamin/skills/blob/v4.45.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

Reject depth-by-line-count, interface-as-TypeScript-keyword, and vague boundary wording.

Read [DEEPENING.md](https://github.com/malinskibeniamin/skills/blob/v4.45.0/codebase-design/DEEPENING.md#change-locality) for cleanup/dependencies/tests; [DESIGN-IT-TWICE.md](https://github.com/malinskibeniamin/skills/blob/v4.45.0/codebase-design/DESIGN-IT-TWICE.md) for alternatives.
