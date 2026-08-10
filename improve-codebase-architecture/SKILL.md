---
name: improve-codebase-architecture
description: Redesign module boundaries, ownership, and state to make recurring error classes impossible.
disable-model-invocation: true
license: MIT
metadata:
  author: Matt Pocock
  vendored_from: https://github.com/mattpocock/skills/tree/main/skills/engineering/improve-codebase-architecture
---

# Improve Codebase Architecture

Find architectural changes that make a class of errors impossible. Deepen the design; do not
merely add another check or regression test.

This skill is architecture-only. Generic audit, backlog, correctness, security, performance,
dependency, or documentation work belongs to `/improve`. Implementation belongs to
`/development-lifecycle`; this workflow stays read-only.

## Vocabulary and bar

Run `/codebase-design`. Use **module**, **interface**, **implementation**, **depth**, **deep**,
**shallow**, **seam**, **adapter**, **leverage**, and **locality** exactly.

- **Deletion test:** deleting a deep module spreads its hidden complexity into callers.
- **Interface is the test surface:** tests verify the design through its stable interface.
- **Two adapters justify a seam:** one adapter is a hypothetical abstraction.
- **Single source of truth:** derived behavior follows the owned representation, not a parallel
  list, flag, registry, validator, or lifecycle.
- **Structural invariant:** construction and transitions make invalid states impossible or
  unrepresentable downstream.

Read `CONTEXT.md` and relevant ADRs when present. Domain language names good modules and seams;
ADRs prevent re-litigating durable choices without new evidence.

## 1. Frame and explore

**Scope before scanning -- YAGNI.** If the user names a module, error pattern, or pain point, take
that scope. Otherwise use `git log --name-only --format=` to find changing hot spots; widen only
when history is scattered.

Explore inline by default. Delegation requires explicit user consent. Prefer repository-native
graph tools. Map module interfaces, dependency graph or call graph, data ownership, competing
writers, state transitions, failure paths, and tests at the current interface.

## 2. Find structural opportunities

Read [REFERENCE.md](REFERENCE.md) for the architecture lenses and candidate rejection rules.
Prioritize designs that replace parallel bookkeeping with one source of truth, repeated validation
with validated construction, illegal flag combinations with explicit states, and caller-owned
choreography with one deep module interface.

For each suspect, name the **error class**, current permissive representation, proposed invariant,
and why another caller cannot recreate the mistake. A regression test is not architecture by
itself; tests verify the design after the target invariant exists.

## 3. Present candidates

Write a self-contained HTML report to the OS temp directory:
`$TMPDIR/architecture-review-<timestamp>.html`, falling back to `/tmp` or `%TEMP%`. Open it and
return the absolute path. Read [HTML-REPORT.md](HTML-REPORT.md); use `/excalidraw-diagram` when an
editable before/after view carries the argument.

Every candidate needs files and evidence, error class, current and proposed invariant, ownership
change, module/interface/seam change, before/after visual, locality/leverage/testing benefit,
migration slice, rollback, compatibility risk, and `Strong|Worth exploring|Speculative` confidence.

End with **Top recommendation**. Do not propose final interfaces yet. Ask which candidate to explore.

## 4. Grill the selected design

Run `/grilling`. Resolve ownership, invariant, module shape, seam, adapters, dependency direction,
transition states, migration, rollback, and observable tests.

- New or sharpened domain term -> `/domain-modeling` updates `CONTEXT.md`.
- Durable rejection -> offer an ADR.
- Competing interfaces -> `/codebase-design` design-it-twice.
- Reviewable visual proposal -> `/visual-plan`; competing proposals -> `/plan-arbiter`.
- Implementation request -> reversible migration sequence handed to `/development-lifecycle`.

Done means the selected invariant explains why the error class cannot reappear through an
unmodified call path, with tests verifying that public contract.
