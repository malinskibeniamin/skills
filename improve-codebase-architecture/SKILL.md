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

Call the Skill tool with "codebase-design" for vocabulary. Other hosts: [dependency loading](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

- **Deletion test:** removing a deep module spreads hidden complexity into callers.
- **Interface is the test surface:** verify design through its stable interface.
- **Two adapters justify a seam:** one adapter is hypothetical.
- **Single source of truth:** behavior follows one owned representation, not parallel lists, flags, registries, validators, or lifecycles.
- **Structural invariant:** construction/transitions make invalid states impossible or unrepresentable.

Read `GLOSSARY.md` and relevant ADRs for names and settled decisions.

## 1. Frame

**Scope before scanning -- YAGNI.** Use the named module/error/pain point; otherwise `git log --name-only --format=` for hot spots. Widen only when history is scattered.

Explore inline; delegation must be explicit. Prefer repo graph tools. Map interfaces, dependency/call graph, data ownership, writers, state transitions, failure paths, and interface tests.

## 2. Find opportunities

Read [REFERENCE.md](REFERENCE.md). Prefer one source of truth over parallel bookkeeping, validated construction over repeated checks, explicit states over illegal flag combinations, and one deep interface over caller choreography.

State each candidate's **error class**, permissive representation, invariant, and why callers cannot recreate it. Regression tests verify design, not architecture.

## 3. Present

Write/open an **HTML report** at `$TMPDIR/architecture-review-<timestamp>.html` (fallback `/tmp` or `%TEMP%`); return its path. Follow [HTML-REPORT.md](HTML-REPORT.md). Call the Skill tool with "excalidraw-diagram" only for useful editable before/after evidence.

Candidates: files/evidence, error class, current/proposed invariant, ownership and module/interface/seam change, before/after, locality/leverage/testing gain, migration slice, rollback, compatibility risk, `Strong|Worth exploring|Speculative` confidence.

End with **Top recommendation**; do not finalize interfaces. Ask which candidate to explore.

## 4. Grill

Call the Skill tool with "grilling": ownership, invariant, module shape, seam/adapters, dependencies, states, migration, rollback, observable tests.

- New term -> Call the Skill tool with "domain-modeling" for `GLOSSARY.md`; durable rejection -> offer ADR.
- Competing interfaces -> design twice with the loaded codebase-design guidance.
- Visual proposal/competing proposals -> Call the Skill tool separately with "visual-plan"/"plan-arbiter".
- Implementation -> reversible sequence for `/development-lifecycle`.

Done when the invariant prevents recurrence through every unchanged call path and public-contract tests pass.
