---
name: prototype
description: Build disposable evidence for unresolved logic, interaction, or visual questions. Use when runnable evidence would resolve behavior or UI uncertainty before commitment.
---

# Prototype

A prototype answers one named question. It is evidence, not an early production branch.

Choose the cheapest faithful shape:

- Logic/state uncertainty -> a small executable state model; see [LOGIC.md](LOGIC.md).
- UI/interaction uncertainty -> several meaningfully different variants; see
  [UI.md](UI.md).
- API/tool uncertainty -> a minimal call against a sandbox or fixture.

Put disposable artifacts under `.context/prototypes/<question>/` when possible, or next
to the target only when the real runtime must load them. Mark any in-tree artifact
clearly and delete it before shipping unless the user explicitly wants it preserved.

## Constraints

1. Standard library and existing dependencies first; no scaffolding unrelated to the
   question.
2. One command to run.
3. In-memory or scratch persistence only.
4. Show the relevant state and observations.
5. Before relying on the verdict, run `/dogfood` once through the decisive path and likely
   boundary; do not dogfood every intermediate edit.
6. Record question, evidence, and verdict in the issue, ADR, implementation notes, or
   implementing commit. Delete the artifact by default.

If the prototype contradicts the plan, revisit the affected decision before production
implementation.
