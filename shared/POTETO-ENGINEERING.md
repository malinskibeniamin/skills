# Curated Poteto engineering rules

This is the harness's canonical adaptation of the Poteto/pstack principles that change existing design and review decisions. Source reviewed at Cursor plugins commit [`efa2a531985e0a8084d36ff3cf87233be8a9f34b`](https://github.com/cursor/plugins/tree/efa2a531985e0a8084d36ff3cf87233be8a9f34b/pstack).

Do not register one skill per principle. Apply these rules through the existing owners named below.

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
