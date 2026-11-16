# Property-Based Testing

Use property-based testing when one public invariant should hold across a large input
space or many reachable action sequences. It is an amplifier for a strong contract, not
a default replacement for focused examples.

## Choose the assurance, not the engine

- **Regression protection:** reject a known bad behavior with a focused example.
- **Discovery:** search inputs and action histories that were not individually scripted,
  checking general rules as the system changes.
- **Deterministic simulation (DST):** control the relevant time, randomness, I/O and
  scheduling so execution can be reproduced within the stated simulated scope.

Regression protection and discovery are not interchangeable. A fixed example can retain a
found bug without retaining the explorer's ability to find different histories.
A seed alone does not control browser, backend or operating-system scheduling. Name
controlled and uncontrolled sources before claiming deterministic replay; fuzzing is not itself DST.

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

## Stateful verification gate

When correctness depends on state history or asynchronous completion order, or when changing
exploratory tests, identify the following in the existing test/PR explanation before calling
verification complete. Reuse
current evidence and adequate tests; routine/stateless edits do not require new properties,
mutations, dependencies or a separate evidence report.

1. The public seam and plain-language property.
2. An **independent oracle** from a schema, protocol, reference implementation, worked
   example, or explicit product rule. Reusing the production algorithm is tautological.
3. The relevant action histories, preconditions and failure/recovery cases. If generating,
   name valid/invalid input domains and their distribution; filtering random noise hides
   generator defects. Explain whether examples suffice or broader discovery is needed.
4. Controlled response order, time and randomness, plus what remains uncontrolled. Exercise
   meaningful pending/intermediate states, not only outcomes after everything settles.
5. The initial fixture and reset behavior for each case, replay and shrink attempt. Observe
   the actual implementation through its public interface, not only the reference model.
6. Intended RED and a valid control: show the detector rejects the credible wrong behavior
   and accepts the correct/restored implementation. An infrastructure error or an unrelated
   assertion failure is not detection of the claimed contract.

For an editor, a useful history is submit A, edit B while A is pending, then deliver A's
response. When editing is allowed during submission, confirming A must not mark B as saved.
Assert the draft and confirmed values independently; awaiting A before editing B misses
that contract entirely.

Prove the detector before trusting a green run. A reported bug supplies a known
counterexample. Preventive work uses a deliberate mutation or small positive control,
then removes it after observing the intended RED. If the property cannot reject a known
bad implementation, improve the property or generator before production code.

Missing contract evidence is a verification gap, not a passing gate. Review the actual
command results and observations. Harness routing/content checks protect publication of
this guidance; they do not prove agent adherence or provide semantic proof of correctness.

## Preserve reproducibility

The method is runner-neutral and has **no required runner**. Prefer the project's existing
test framework and property library. Compare the needed exploration capability: generation,
observation, temporal checks, reset, replay, minimization and triage.
Do not replace an explorer with one known regression and call them equivalent, or require
rebuilding a full explorer merely to avoid a dependency. A new engine still needs a bounded
pilot and an accepted maintenance cost; it does not authorize paid services or a DST rebuild.

Every failure must retain:

- property name and violated observation;
- initial state/fixture, relevant application/specification versions, and reset procedure;
- concrete generated inputs/actions and fault/completion order; retain seed/path metadata
  when available, but keep the counterexample usable without the original generator;
- original counterexample plus the shrunk or manually minimized counterexample;
- relevant requests, responses, state, logs, and browser evidence with secrets redacted.

Replay the minimized failure before making it a deterministic regression. Report attempted
and successful replays; a failed replay does not erase an observed violation. Preserve the
original trace and diagnose product, oracle, fixture and timing causes instead of retrying
to green. Shrinking must reset the system under test between candidates; shared residue
produces false minimization.

## Run and promote findings

- Keep pull-request runs bounded: replay the regression corpus plus a small generated
  budget within the project's reliability/runtime limits. Report uncontrolled timing rather
  than labeling a fixed-seed browser run deterministic.
- Put longer or changing-seed exploration in a scheduled lane until repeated unchanged
  runs establish its false-positive and flake rate.
- Generated browser actions use isolated stubs or disposable tenants. Never let an
  explorer discover destructive production actions.
- Track unique reproducible defects, mutation or known-regression detection, replay rate,
  false failures, runtime, and maintenance time. Coverage alone does not prove value.
- For added detection or replacement claims, run baseline and candidate against the same
  fixed controls, state, faults and stated budgets. Report overlap and additional detections.
  Seeded controls prove sensitivity, not real-world bug yield or a coverage percentage.

Triage a violation as either a property defect or a product defect. For a real product
defect, create a deterministic RED regression at the smallest public seam, fix it, and
replay both the regression and the generated counterexample. Retain the broad property
only when it protects a meaningful class beyond that example.

Property-based tests do not replace deterministic journeys, cross-browser checks,
accessibility analysis, visual review, or dogfood. Tests find contract violations; the
fix and deterministic regression are what resolve and prevent the customer problem.

Primary references: [DST and its controlled scope](https://antithesis.com/docs/resources/deterministic_simulation_testing/),
[browser-explorer replay limitations](https://antithesishq.github.io/bombadil/browser/4.1-reproducing-violations.html).
