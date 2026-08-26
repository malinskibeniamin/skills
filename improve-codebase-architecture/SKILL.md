---
name: improve-codebase-architecture
description: Redesign module boundaries, ownership, and state to make recurring error classes impossible.
disable-model-invocation: true
license: MIT
metadata:
  author: Matt Pocock
  vendored_from: https://github.com/mattpocock/skills/tree/main/skills/engineering/improve-codebase-architecture
---

Make an error class impossible, not another check/test. Generic audit belongs to `/improve`; implementation to `/development-lifecycle`. Stay read-only.

## Vocabulary

Run `/codebase-design`; use its module, interface, implementation, depth, seam, adapter, leverage, and locality terms.

- **Deletion test:** removing a deep module spreads hidden complexity into callers.
- **Interface is the test surface:** verify design through its stable interface.
- **Two adapters justify a seam:** one adapter is hypothetical.
- **Single source of truth:** behavior follows one owned representation, not parallel lists, flags, registries, validators, or lifecycles.
- **Structural invariant:** construction/transitions make invalid states impossible or unrepresentable.

Read `CONTEXT.md` and relevant ADRs; domain language names modules and prevents needless re-litigation.

## 1. Frame

**Scope before scanning -- YAGNI.** If the user names a module/error/pain point, take that scope. Otherwise use `git log --name-only --format=` for hot spots; widen only when history is scattered.

Explore inline by default; delegation must be explicit. Prefer repo graph tools. Map interfaces, dependency graph or call graph, data ownership, writers, state transitions, failure paths, and interface tests.

## 2. Find opportunities

Read [REFERENCE.md](REFERENCE.md). Prefer one source of truth over parallel bookkeeping, validated construction over repeated checks, explicit states over illegal flag combinations, and one deep interface over caller choreography.

For each candidate state the **error class**, permissive representation, proposed invariant, and why another caller cannot recreate it. Regression tests are not architecture; tests verify design.

## 3. Present

Write and open an **HTML report** at `$TMPDIR/architecture-review-<timestamp>.html` (fallback `/tmp` or `%TEMP%`); return its path. Follow [HTML-REPORT.md](HTML-REPORT.md). Use `/excalidraw-diagram` only when editable before/after evidence helps.

Each candidate needs files/evidence, error class, current/proposed invariant, ownership and module/interface/seam change, before/after view, locality/leverage/testing gain, migration slice, rollback, compatibility risk, and `Strong|Worth exploring|Speculative` confidence.

End with **Top recommendation**; do not finalize interfaces. Ask which candidate to explore.

## 4. Grill

Run `/grilling` on ownership, invariant, module shape, seam/adapters, dependency direction, states, migration, rollback, and observable tests.

- New domain term -> `/domain-modeling` updates `CONTEXT.md`; durable rejection -> offer ADR.
- Competing interfaces -> design twice with `/codebase-design`.
- Visual proposal -> `/visual-plan`; competing proposals -> `/plan-arbiter`.
- Implementation -> reversible sequence for `/development-lifecycle`.

Done when the target invariant prevents recurrence through every unchanged call path and tests verify its public contract.
