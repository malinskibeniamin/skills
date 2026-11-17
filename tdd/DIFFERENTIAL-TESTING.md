# Differential testing

Use when a rewrite, migration or optimization must preserve observable behavior and a
trusted old implementation is runnable. Compare through the same public seam; use the
[authoring gate](../test-audit/SKILL.md#authoring-gate) before adding coverage.

## Fix the oracle and domain

1. Pin old/new revisions, runtime/configuration, fixtures and dependency versions. The old
   system is a compatibility oracle, not proof that its behavior is desirable or secure.
2. Define inputs from a bounded seeded generator or authorized, redacted production-shaped
   samples. Include malformed, boundary and state-sequence cases where the contract allows.
   Keep [property-test replay](PROPERTY-BASED-TESTING.md#preserve-reproducibility) metadata.
3. Reset both implementations to equivalent isolated state for every case. Stub only
   existing external-effect boundaries; never replay production writes or payments twice.
4. Compare outputs, errors, exit/status codes and durable effects, not only success values.
   Control time, randomness and ordering at existing seams when they are irrelevant.

## Classify differences

Normalize only contract-irrelevant variation, such as explicitly insignificant whitespace
or generated IDs. Do not sort away meaningful ordering, ignore missing fields, or discard
errors to get agreement. Keep raw observations alongside normalized comparisons.

Record each intended difference narrowly with input scope, expected old/new behavior,
reason and the owner's accepted contract. Changes to that list need separate scrutiny;
the candidate cannot silently redefine equivalence. An unexplained mismatch fails.
An old bug intentionally fixed needs an independent expected-result regression, not
an instruction to copy the bug or a broad exception.

## Prove and retain

- Show the comparator detects a deliberate behavior mismatch and accepts a valid control.
  Test any normalization or approved-difference filter against a nearby real mismatch.
- Save seed/input/action sequence, revisions and both observations; minimize and replay
  mismatches before diagnosing the implementation or comparator.
- Keep the smallest deterministic regression for each confirmed defect. Bound generated
  PR runs; longer exploration needs its own authorized lane, not automatic scheduling.
- State unsupported paths and sampled domains. Agreement on sampled inputs is not a proof
  of full equivalence. Retire the old oracle/harness only when the migration's compatibility
  obligation ends; preserve meaningful regressions under their existing test owner.
