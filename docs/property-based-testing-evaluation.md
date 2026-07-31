# Property-Based Testing Evaluation

**Date:** 2026-07-31

**Status:** Adopt the method through measured pilots; do not adopt a vendor

## Verdict

Property-based testing can find customer-impacting contract violations that a fixed
happy-path suite misses. One prototype found a form submitting an invalid create request
with a blank required URL while its visible mode did not match the serialized union.
Generated actions reached the failure, but the independent request oracle made it
meaningful.

That result supports a narrow methodology change, not a required runner or hosted
platform. The failure was also reachable by one deterministic untouched-form test, the
first property model produced two false positives, and the prototype neither fixed the
product nor ran in CI. One finding does not establish broad return on investment.

Adopt the portable parts: high-leverage invariants, independent oracles, known-bad
controls, structured generators, replay and minimization, deterministic regression
promotion, and measured rollout. Keep the runner replaceable.

## What the experiment demonstrates

- A generated browser workload explored mode switches, inputs, scrolling, and submit
  actions beyond the existing valid create journey.
- A request-boundary oracle rejected blank or non-HTTP URLs, absent or multiple union
  branches, and incomplete branch-specific fields.
- Repeated short runs found the invalid-submit class; one 4.66-second trace replayed it.
- The existing fixed journey filled a valid URL and never compared visible auth state
  with the wire request, so its assertions could not detect this class.
- The earlier 15-second exploration generated 86 actions and reached all five modes
  without a product violation. Two apparent failures were property-model bugs.
- The prototype was Chromium-only, scoped to one form, intentionally excluded from CI,
  and added no production fix or deterministic regression.

The strongest evidence is therefore not that random clicking is generally effective.
It is that generated actions plus an independent boundary oracle exposed a missing
negative contract. The oracle and the generated workload must be evaluated separately.

## Tool versus method

| Option | Useful capability | Adoption decision |
|---|---|---|
| Property-based testing | Express a broad invariant and search values or state sequences for a counterexample | Adopt selectively as a method |
| Local generated UI runner | Browser exploration, properties, action generators, trace inspection, and replay | Do not require; compare only in an explicit pilot |
| Hosted deterministic simulator | Guided state-space exploration, fault injection, deterministic replay, and full-system debugging | Do not couple the frontend harness to a platform |
| Existing Vitest and Playwright harness | Public seams, deterministic regressions, browser matrix, accessibility, and CI ownership | Keep as the default execution surface |

A hosted deterministic simulator can control nondeterminism and explore faults across
system histories. That is materially stronger than a local browser random walk, but its
highest leverage is concurrency, coordination, timing, and distributed-system failure.
A single form validation defect does not justify making a hosted platform part of the
frontend test contract.

## Broader evidence and limits

The original [QuickCheck paper](https://doi.org/10.1145/351240.351266) established the
generated-input and property model. A 2025
[empirical Python study](https://cseweb.ucsd.edu/~mcoblenz/assets/pdf/OOPSLA_2025_PBT.pdf)
found that individual property-based tests killed far more mutants than individual unit
tests in its corpus and that 76% of detected mutations were found within 20 inputs.
However, the study was observational, covered 40 runnable Python projects, used mutants
rather than customer defects, and did not measure authoring or maintenance cost. It
supports testing a small generated budget, not copying its effect size into our forecast.

Property-based testing is most credible when:

- one public invariant spans many values or reachable state transitions;
- a simpler model, schema, protocol, or explicit product rule supplies the oracle;
- generators produce valid structured behavior instead of mostly filtered noise;
- the detector rejects a known regression or deliberate mutation;
- failures replay and reduce to a counterexample a developer can understand.

It is weak when the oracle repeats production logic, the defect has one obvious example,
state reset is unreliable, or generated browser actions are used as a substitute for
cross-browser, accessibility, visual, and user-journey evidence.

## UX impact

The method can prevent UX failures at user-to-system boundaries:

- invalid submit reaches the API instead of showing all validation errors locally;
- visible union or oneof selection disagrees with the serialized request;
- switching modes leaves stale hidden values in the payload;
- duplicate actions cause multiple mutations;
- navigation or timing sequences expose a dead end or lost state.

Tests do not resolve those failures by themselves. A finding improves the product only
after it replays, becomes a deterministic RED regression at the smallest public seam,
and receives a fix. Exact copy, visual hierarchy, focus behavior, accessibility, and
documented journeys still need their existing review and test methods.

## Pilot decision gate

Run pilots without changing the default dependency surface:

1. Pick one high-cardinality pure or integration invariant and one genuinely stateful
   browser invariant. Do not start in the browser when a cheaper seam proves the rule.
2. Record the oracle, input distribution, reset contract, and a known-bad control before
   generating cases.
3. Use the existing framework, a small local generator, or an isolated disposable tool.
   Runner choice must not define the product contract or deterministic regression corpus.
4. Keep pull-request runs deterministic and bounded. Put changing-seed or longer runs in
   a scheduled lane until repeated clean runs establish runtime and false-failure rates.
5. Track unique reproducible defects, known-regression or mutation detection, replay
   rate, false failures, runtime, and maintenance time. Coverage is diagnostic only.
6. Promote every real finding to a deterministic regression and rerun the original
   counterexample. Delete properties that add no class-level protection.

Adopt a dedicated dependency only if multiple pilots improve unique reproducible defect
detection enough to repay flake, runtime, API churn, and maintenance. Otherwise retain
the methodology and the deterministic regressions, and discard the runner.

## Harness decision

Implemented:

1. `tdd/SKILL.md` routes high-cardinality invariants and reachable state sequences to a
   runner-neutral property-based testing guide.
2. `tdd/PROPERTY-BASED-TESTING.md` defines seams, oracles, controls, reproducibility,
   CI rollout, measurement, and regression promotion.
3. `e2e-testing/SKILL.md` exposes generated browser exploration only when a cheaper seam
   cannot prove a credible customer contract.
4. TDD and E2E evals lock the portable safeguards.

Deliberately not implemented:

- **No dependency or package:** no generated-test runner, hosted platform, or property
  library is required.
- **No hook:** a static edit event cannot infer a meaningful invariant, oracle, or input
  distribution without producing rote tests and false confidence.
- **No CI lane:** application owners must first supply a measured property and budget.
- **No new skill:** this is a test-shape branch of TDD and E2E, not a separate workflow.
