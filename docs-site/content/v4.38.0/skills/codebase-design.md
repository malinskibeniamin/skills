---
title: "/codebase-design"
description: "Design deep modules with small interfaces. Use when choosing seams, reducing file-hop friction, deepening modules, testing APIs, or applying shared design vocabulary."
type: skill
sidebar:
  label: "/codebase-design"
---
![Diagram of the /codebase-design skill](/diagrams/skills/codebase-design.svg)

[Open the editable Excalidraw source](/diagrams/skills/codebase-design.excalidraw)

Design **deep modules**: much behavior behind a small interface at a clean seam, testable through that interface. Aim: leverage for callers, locality for maintainers, testability for agents and people.

Depth must increase semantic density now. Do not create a module, seam, adapter,
or interface for hypothetical reuse. The design wins only when it removes more
knowledge and coordination from callers than it introduces.

## Glossary

Use these terms exactly; avoid loose synonyms.

**Module** -- anything with interface + implementation: function, class, package, slice. Avoid: unit, component, service.

**Interface** -- everything a caller must know: type surface, invariants, ordering, errors, config, perf. Avoid: API or signature when you mean the full contract.

**Implementation** -- what is inside a module. Distinct from **Adapter**: an adapter is the concrete thing filling a seam.

**Depth** -- leverage at the interface. **Deep** = small interface, large behavior. **Shallow** = interface nearly as complex as implementation.

**Seam** -- place where behavior can vary without editing that place; where the module interface lives. Avoid: boundary, overloaded with DDD bounded context.

**Adapter** -- concrete implementation satisfying an interface at a seam; names role, not substance.

**Leverage** -- caller gets more capability per interface learned.

**Locality** -- change, bugs, knowledge, and verification concentrate in one place.

## Deep vs shallow

Deep module:

```
Small Interface
----------------
Deep Implementation
```

Shallow module:

```
Large Interface
----------------
Thin Implementation
```

Ask:

- Can methods shrink?
- Can params simplify?
- Can more complexity hide inside?

## Principles

- **Depth is interface property, not implementation size.** Internals may have private seams; callers do not learn them.
- **Deletion test.** If deleting a module makes complexity vanish, it was pass-through. If complexity reappears across callers/tests, it earned its keep.
- **The interface is the test surface.** Callers and tests cross same seam. Testing past it usually means wrong shape.
- **One adapter means a hypothetical seam. Two adapters means a real one.** Do not add seams for imaginary variation.
- **Direct is a design.** A small local expression is better than an abstraction that merely moves code.

## Designing for testability

1. Accept dependencies; do not create them inside.
2. Return results where possible; minimize ambient side effects.
3. Keep surface small: fewer methods, fewer params, clearer invariants.

When two viable module/interface designs survive the deletion test, use `/plan-arbiter` to compare depth, locality, test surface, and rollback before committing to one.

## Relationships

- A Module has one Interface.
- Depth is measured against Interface.
- A Seam is where Interface lives.
- Adapter sits at a Seam and satisfies Interface.
- Depth creates Leverage and Locality.

## Rejected framings

- Depth as implementation-lines/interface-lines: rewards padding.
- Interface as only TypeScript `interface` or public methods: too narrow.
- Boundary: use seam or interface unless you mean DDD bounded context.

## References

- [DEEPENING.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/codebase-design/DEEPENING.md) -- dependency categories, seam discipline, replace-don't-layer testing.
- [DESIGN-IT-TWICE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/codebase-design/DESIGN-IT-TWICE.md) -- parallel interface designs, compare on depth, locality, seam placement.
