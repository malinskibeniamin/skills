# Property-Based Testing

Use property-based testing when one public invariant should hold across a large input
space or many reachable action sequences. It is an amplifier for a strong contract, not
a default replacement for focused examples.

## Choose a high-leverage seam

Prefer the cheapest seam that exposes the behavior:

1. Pure function or domain API for values, parsing, normalization, and round trips.
2. Integration boundary for form state, unions, serialization, and request validation.
3. Browser only for behavior that depends on real navigation, DOM events, focus, timing,
   or sequences that a lower seam cannot represent.

Good property shapes include:

- **Round trip:** decoding an encoded supported value returns the same value.
- **Reference agreement:** the implementation agrees with a simpler independent model.
- **Invariant:** every reachable transition preserves a domain rule.
- **Metamorphic relation:** a meaningful input transformation has a predictable effect.
- **Boundary rejection:** invalid state never crosses a request, storage, or mutation boundary.

For customer-facing forms, high-leverage examples are visible oneof selection matching
the serialized branch, switching branches clearing stale values, invalid submit staying
local with every error visible, and duplicate actions producing at most one mutation.
Keep fixed examples for exact regressions, visual hierarchy, copy, and documented journeys.

## Specify before generating

Write down:

1. The public seam and plain-language property.
2. An **independent oracle** from a schema, protocol, reference implementation, worked
   example, or explicit product rule. Reusing the production algorithm is tautological.
3. Valid and invalid input domains, including their intended distribution. Generate
   structured user behavior; filtering random noise hides generator defects.
4. Preconditions that make each stateful action possible in the current state.
5. Reset behavior so every case and every shrink attempt starts from known state.

Prove the detector before trusting a green run. A reported bug supplies a known
counterexample. Preventive work uses a deliberate mutation or small positive control,
then removes it after observing the intended RED. If the property cannot reject a known
bad implementation, improve the property or generator before production code.

## Preserve reproducibility

The method is runner-neutral and has **no required runner**. Prefer the project's existing
test framework and property library. Add a dependency only when a measured pilot shows it
beats a small local generator and the project accepts its maintenance cost.

Every failure must retain:

- property name and violated observation;
- seed, path, trace, or explicit generated inputs/actions;
- original counterexample plus the shrunk or manually minimized counterexample;
- relevant requests, responses, state, logs, and browser evidence with secrets redacted.

Replay the minimized failure before treating it as a product defect. A failure that cannot
replay is diagnosis work, not a retry candidate. Shrinking must reset the system under test
between candidates; shared residue produces false minimization.

## Run and promote findings

- Keep pull-request runs bounded and deterministic: replay the regression corpus plus a
  small generated budget that fits the project's existing reliability and runtime limits.
- Put longer or changing-seed exploration in a scheduled lane until repeated unchanged
  runs establish its false-positive and flake rate.
- Generated browser actions use isolated stubs or disposable tenants. Never let an
  explorer discover destructive production actions.
- Track unique reproducible defects, mutation or known-regression detection, replay rate,
  false failures, runtime, and maintenance time. Coverage alone does not prove value.

Triage a violation as either a property defect or a product defect. For a real product
defect, create a deterministic RED regression at the smallest public seam, fix it, and
replay both the regression and the generated counterexample. Retain the broad property
only when it protects a meaningful class beyond that example.

Property-based tests do not replace deterministic journeys, cross-browser checks,
accessibility analysis, visual review, or dogfood. Tests find contract violations; the
fix and deterministic regression are what resolve and prevent the customer problem.
