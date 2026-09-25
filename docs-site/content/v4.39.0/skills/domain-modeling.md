---
title: "/domain-modeling"
description: "Build and sharpen a project's domain model. Use when discussing codebase terminology, writing or editing a CONTEXT.md, or recording or editing an ADR."
type: skill
sidebar:
  label: "/domain-modeling"
---
![Diagram of the /domain-modeling skill](/diagrams/skills/domain-modeling.svg)

[Open the editable Excalidraw source](/diagrams/skills/domain-modeling.excalidraw)


Actively challenge, resolve, and record domain terms/decisions while designing. Merely reading `CONTEXT.md` is not domain modeling.

## Files

Use root `CONTEXT.md` and `docs/adr/` for one context. If root `CONTEXT-MAP.md` exists, follow it to context-local `CONTEXT.md` and ADRs; system-wide ADRs stay under root docs. Create files only when the first real term/decision exists.

## During the session

### Challenge the glossary

When user language conflicts with `CONTEXT.md`, quote the mismatch and ask which meaning wins.

### Sharpen language

Replace vague/overloaded words with a proposed canonical term, distinguishing nearby concepts explicitly.

### Test scenarios

Probe relationships and boundaries with concrete edge cases until terms are precise.

### Cross-reference code

Check stated behavior against code; surface contradictions for resolution.

### Update CONTEXT.md inline

Record resolved terms immediately using [CONTEXT-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/domain-modeling/CONTEXT-FORMAT.md). Do not batch. `CONTEXT.md` is a glossary only: no implementation detail, spec, scratch notes, or implementation decisions.

### Offer ADRs sparingly

Offer an ADR only when all hold:

1. **Hard to reverse:** later change is costly.
2. **Surprising without context:** a future reader would ask why.
3. **Real trade-off:** genuine alternatives were rejected for reasons.

Otherwise skip. Use [ADR-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/domain-modeling/ADR-FORMAT.md).
