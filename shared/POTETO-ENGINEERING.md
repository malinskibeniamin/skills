# Curated Poteto engineering rules

This is the harness's canonical adaptation of the Poteto/pstack principles that change existing design and review decisions. Source reviewed at Cursor plugins commit [`efa2a531985e0a8084d36ff3cf87233be8a9f34b`](https://github.com/cursor/plugins/tree/efa2a531985e0a8084d36ff3cf87233be8a9f34b/pstack).

This curated adaptation remains the structural guidance for the existing owners below.
[Native composition](POTETO-NATIVE.md) connects the complete current stack to the relevant
existing skills without invoking explicit-only workflows. See [compatibility rules](POTETO-COMPATIBILITY.md)
and the [current source inventory](../vendor/pstack.lock.json).

The native [caller-first sketch](../codebase-design/SKILL.md#caller-first-sketch) and
structural probe below also adapt [architect](../vendor/pstack/skills/architect/SKILL.md),
its [design red flags](../vendor/pstack/skills/architect/references/design-red-flags.md),
and the [historical review rubric](https://github.com/cursor/plugins/blob/88d47514b82e7c44f00f2b2a72ff6dd12158038c/pstack/skills/interrogate/references/rubric.md) at
[`88d47514b82e7c44f00f2b2a72ff6dd12158038c`](https://github.com/cursor/plugins/tree/88d47514b82e7c44f00f2b2a72ff6dd12158038c/pstack).
These are authored native adaptations, not instructions to invoke the explicit-only
upstream workflows. Existing endpoint, model, and delegation rules remain authoritative.
The current [interrogate source](../vendor/pstack/skills/interrogate/SKILL.md) replaces
that rubric with executed counterexamples; native review uses the scoped
[review and diagnosis adaptation](POTETO-NATIVE.md#review-and-diagnosis).

## Probe the shortest wrong edit

Name the invariant, then try one locally plausible use or edit that could bypass it:
import an internal representation, write shared state through a second owner, add an
item to only one hand-synced list, or call persistence without validation. Choose the
case relevant to the changed interface, not a checklist for every task.

Trace whether the actual interface, types, build, or runtime guard rejects it. In design,
revise a shape that relies on every caller remembering an internal rule. In review,
use a path the diff already permits; do not manufacture a defect by removing a guard.
Report only a concrete invariant violation with impact and a reproducible counterexample.
A blocked misuse clears that concern; a pattern alone is not a finding. Keep read-only
reviews read-only and run disposable probes outside product files.

Keep small design sketches inline; skip relationship-preserving mechanical moves.
Explore alternatives only for a material fork or explicit request; add no approval pause.

Owners: `/codebase-design` before implementation; `/review` for changed structural
contracts, including ordinary review. Existing severity and proof requirements apply.

## Minimize reader load

Maintainability has two independent costs: layers to trace and hidden state to hold. Collapse one-caller wrappers and pass-through adapters. Adjacent layers must change the abstraction or hide meaningful decisions. Shrink mutable state scope and place an invariant at its owner instead of repeating it in consumers.

Test: can a new reader answer "where does this value come from?" and "what can change it?" without a tour of unrelated files?

Owner: `/codebase-design` for design, `/review --deep` for diff evidence.

## Encode lessons in structure

When the same correction appears twice, prefer the strongest mechanism the repository can support: unrepresentable state, type/schema, lint or CI failure, canonical helper, runtime check, then prose only when judgment is irreducible. Remove the duplicated instruction after the mechanism owns it.

Owner: the affected code/config owner; `/review --deep` reports repeated prose or comments only when a concrete structural enforcement exists.

## Redesign from first principles

Integrate a new requirement as if it were present on day one. Propagate the chosen shape through types, callers, tests, docs, and examples. Migrate callers and delete superseded internal APIs in the same wave when compatibility is not a public requirement.

Owner: `/codebase-design`; delivery stays incremental and verifiable through `/development-lifecycle`.

## Prove the decisive fact

Move claims from source pointer to walked counterexample to executable check to real entrypoint. Do not promote an unexecuted safety claim to certainty. Preserve the smallest rerunnable proof that fails loudly if the claim is false.

Owner: `/blast-radius` for non-local safety, `/dogfood` for user behavior.
