---
name: untangle-codebase
description: Untangle leaky abstractions, duplication, temporary workarounds and useless wrappers.
disable-model-invocation: true
argument-hint: "[optional area or concern; comments/tests opt-in; endpoint]"
---

Adapted from [caldoai/skills](../vendor/caldoai/skills/untangle-codebase/SKILL.md);
[provenance and refresh](CREDITS.md). This workflow replaces upstream's automatic
subagents, open-ended completion loop and incidental bug-fix permission.

## Scope and baseline

Establish the outcome contract: target area (whole first-party codebase if omitted),
behavior-preserving guardrails, verification and requested endpoint. Preserve unrelated
work and public contracts. Plan/review-only requests stay read-only; implementation
follows the repository's [delivery contract](../shared/delivery-workflow.md), including
explicit local/no-push stops. Importing or discussing this skill is not an invocation.

Offer these optional additions once, honoring choices already in the request:

| Addition | What it does |
| --- | --- |
| Comments | Remove comments that only restate the code. |
| Tests | Remove tests that wouldn't catch a real bug, and fix the ones that fail without one. |

Ask which to include if unspecified; continue structural work with neither until selected.
Necessary test updates that preserve coverage during a refactor are not optional pruning.

Use [repo navigation](../shared/repo-navigation.md) to identify entrypoints, consumers,
domain rules and existing checks. Record a baseline through the public interface and
a credible failure/recovery case. Keep generated and vendored outputs with their owners.

## Diagnose before editing

Ask **should these pieces change together?** Inventory evidenced problems within scope:

- **Hidden links:** duplicated knowledge, implicit shared state, call-order conventions
  and feature logic scattered by technical layer.
- **Needless links:** callers reaching into internals, stable domains depending on volatile
  implementations, caller-specific parameters and shallow abstractions leaking changes.
- **Surplus:** pass-through wrappers, speculative extension points/configuration and apparently unused code.
- **Special cases:** one-value branches, caller exceptions, swallowed errors, sleeps,
  retries, disabled tests and temporary workarounds. Trace the requirement or external
  constraint each protects; their presence alone is not a defect.

For each finding, retain location, affected callers, concrete change/failure scenario and
the verification that would catch a wrong fix. Use Git co-change history and dependency
evidence where useful; missing graph edges are not proof of dead code. Apply
[dead-code and duplication diagnosis](../shared/verifiability.md#dead-code-and-duplication)
before deletion or sharing. Keep the decision log in existing task notes or temporary
scratch, not a new repository report by default.

## Redesign around requirements

Group related findings under the smallest root-cause fix. Put knowledge that changes
together with its owner; separate independent reasons to change. Prefer stable domain
interfaces over volatile implementation details. Use [codebase design](../codebase-design/SKILL.md) for module boundaries.

Compare the proposal with leaving the code alone: name the coordination cost or failure
it removes and the contracts it must retain. A wrapper may own validation, authorization,
observability or compatibility; similar code may represent different domain rules.
Keep those responsibilities unless evidence supports moving them. More helpers, fewer
lines or fewer special cases alone do not prove a better design.

For example, a dialog's arbitrary focus delay and a global skip-refocus flag may share
one missing focus-restoration owner. Verify nested-dialog and keyboard flows before
replacing both, rather than deleting each workaround independently.

## Implement and verify slices

1. Establish the relevant behavior check before each structural change; use existing
   tests first and [TDD](../tdd/SKILL.md) for an uncovered risk.
2. Migrate affected callers, then remove superseded internals and workarounds whose
   requirements the redesign now satisfies. Preserve externally required compatibility.
3. Replay intended and failure paths after each slice, following
   [proportionate verification](../shared/verifiability.md#proportionate-verification).
   Report newly discovered bugs separately; incidental behavior changes need explicit
   scope rather than being smuggled into a behavior-preserving refactor.
4. If Comments was selected, remove implementation restatements, retain external
   constraints and useful invariants, and remove workaround explanations only with
   their obsolete workaround.
5. If Tests was selected, load [test audit](../test-audit/SKILL.md) and prune last.
   Retain regression coverage until replacement behavior checks pass. Show why each
   removed test cannot catch a distinct regression; rewrite brittle internal assertions
   at the public seam rather than deleting necessary coverage.

## Review and finish

Review hidden links, needless links, surplus and special cases inline. Use subagents
only with explicit delegation consent under the host's model and isolation rules;
loading this skill grants none. Inspect runnable behavior with
[dogfood](../dogfood/SKILL.md), then apply [review](../review/SKILL.md) to the full diff.

Repair confirmed in-scope findings and stop at the first clean scoped review with
baseline behavior preserved and required checks passing. Retain justified exceptions;
report unknowns, coverage gaps and out-of-scope opportunities without expanding the task.
Summarize the root-cause fixes, preserved constraints, verification and remaining limits,
then complete only the requested delivery endpoint. Claim no speed, token or defect reduction without measurement.
