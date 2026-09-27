# Rule catalog

Single source of truth for `/ms`. Every entry is backed by at least three independent
examples. Grades express aggregate support, weighted toward recent examples: S/A is the
enforced core; B is adopted; C wording is provisional.

Cite the rule id in findings. n = independent evidence count.

## Value: why this change, for whom

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| S | `value-beneficiary` | Open with the person who hits the problem today and what it costs them; a diff without a named beneficiary is not justified yet. | 30 |
| S | `value-run-cost` | Name the running cost the change adds or saves (metric cardinality, per-request fan-out, tokens, cache hits, CI minutes, idle cloud resources) and bound it. | 15 |
| S | `value-segment` | Check every surface for each customer segment it reaches (self-hosted community, enterprise, managed cloud, serverless, third-party compatible deployments); do not ship behavior, docs, or release notes that fit one segment while claiming all. | 14 |
| A | `value-demand-first` | Ask for the use case before building a request. If an existing feature solves it, point there; niche asks go to a fork, a local setting, or a demand signal instead of product surface. | 15 |
| A | `value-money-exact` | On money paths an unknown model, provider, rate, or usage bucket is an alert, never a free or approximate charge; keep billing-grade precision end to end. | 9 |
| A | `value-monetize-fairly` | Paid-tier gating and trial nudges are accurate and quiet when unsure: never block free users on a wrong signal, never nag without certainty, always show what is actually gated. | 11 |
| A | `value-persona` | On agent-building surfaces serve the primary persona first (non-engineer builders), then operators and admins, then security approvers; engineer-only detail stays available but is not the default view. | 8 |

## Scope: ship fast, fail fast

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| S | `scope-yagni` | Delete speculative generality: options nobody sets, validators nothing calls, metadata nobody maintains, bulk or streaming variants without a caller, permissions for operations that do not exist. | 16 |
| S | `scope-boundaries` | State non-goals, deliberate omissions, and not-fixed-here follow-ups; split unrelated changes out instead of riding them along. | 13 |
| S | `scope-reuse-upstream` | Prefer the existing shared package, upstream library, or established repository pattern over a local variant; a second way of doing the same thing is maintenance debt. | 14 |
| S | `scope-increment` | Land the smallest slice that boots in production without regression: new behavior behind a default-off knob or an unmounted service, stacked PRs with an explicit plan of what comes next. | 13 |
| S | `scope-park` | Close or park work whose value cannot land yet (missing dependency, no consumer, no maintainer, stale, unreviewed); keep the branch and write down the reopen condition. | 13 |
| B | `scope-no-sunk-cost` | Do not polish code already scheduled for replacement; temporary duplication is fine when the replacement is named. | 7 |

## Delivery: rollout, reversibility, proof

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| S | `delivery-proof` | Claim only what was exercised: real entrypoint, production-shaped data, before/after numbers; name what was not verified and how the effect will be observed after merge. | 16 |
| S | `delivery-rollout` | A contract change says how it rolls out: additive fields first, producer before consumer, a fallback for independently deployed apps, hard-cut notes, canary-first enablement, and the rollback. | 12 |
| S | `delivery-operate` | New services and features ship with what on-call needs (dashboards as code, bounded metrics, caller-identifying logs at actionable levels) and without noise that drowns real failures. | 15 |
| A | `delivery-irreversible` | Spend review time in proportion to irreversibility: break pre-1.0 APIs now while nothing depends on them, start narrow and strict, force compile-time breaks for semantic changes; published contracts need lists, pagination, and names that can grow. | 10 |
| A | `delivery-defaults` | Choose defaults by how they fail: silent failure modes default on with an explicit opt-out, security and policy paths fail closed, collectors that need extra customer permissions default off. | 8 |

## Trust: what customers see

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| S | `trust-no-false-success` | Nothing reports success, health, cost, or capability that is not real: no success for deferred work, no healthy status over failed sources, no zero price for unknown usage, no affordance that cannot deliver. | 16 |
| S | `trust-docs-match` | Customer-facing docs, setup guides, snippets, and enablement content match shipped behavior, compile or run, and disclose friction and caveats honestly. | 16 |
| S | `trust-degrade` | Prefer partial answers with visible gaps over total failure; never lock users out of working functionality because an optional dependency, permission probe, or license check failed. | 14 |
| S | `trust-privacy` | Keep customer data where customers expect it: no payload content in errors, logs, or feedback stores; content recording is opt-in and honest; request the least privilege a customer's IT team will approve. | 12 |
| A | `trust-words` | Use the words customers and open standards use; avoid internal jargon, colliding product names, and names that age ("new", "modern", "v2"). | 10 |

## Quality of life and reputation

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| S | `qol-flow` | Fix friction that blocks everyone (red main, flaky gates, broken onboarding, local stacks that cannot run) before polishing edges; keep the failure signal visible when absorbing flakes. | 16 |
| S | `qol-measured` | A performance, CI, or developer-experience claim carries a before/after measurement or a reproducible failure, and names who feels it. | 12 |
| A | `qol-consistency` | Consistency is reputation: one pattern per concern, reference implementations for contributors, no one-off layouts that make the product look unfinished in a demo. | 10 |

## Taste

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| S | `taste-one-source` | One source of truth: derive what can be computed, delete hand-maintained copies that drift, import shared constants instead of copying strings. | 10 |
| A | `taste-api-product` | Treat every API as a future public product: hard to misuse, no fan-out per request, consistent with sibling APIs, not shaped only by one frontend's convenience. | 12 |
| A | `taste-self-critique` | Be the first skeptic of your own change: say which part is weak, ask whether a break is worth it, and narrow scope after approval when the evidence changes. | 6 |

## Acceptance criteria

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| S | `accept-done-when` | Define done as observable outcomes (numbers, states, user-visible behavior), list invariants that must not change, and name non-goals; the requirement is the problem, not a prescribed implementation. | 14 |
| S | `accept-repro-first` | Each defect carries a reproduction that fails today and becomes the acceptance test; state mitigating factors and blast radius up front. | 10 |

## Craft: how code is written

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| A | `craft-dependency-ration` | Every dependency is a maintenance commitment: write the small helper instead of importing a library for it, prefer upstream fixes over forks, and pin versions instead of floating tags. | 9 |
| A | `craft-narrow-surface` | Export and expose the minimum: keep symbols, fields, and endpoints private until a caller needs them; narrow and strict can widen later, the reverse is a break. | 9 |
| A | `craft-errors-by-layer` | Design errors: build wire errors once at the service edge, make reasons only as granular as the caller can act on, validate config at load with the field named, and have partial results say which items failed. | 9 |
| A | `craft-readable-conditions` | Code reads without decoding: no double negatives, complex conditions split into named variables, positive booleans, and comments that explain intent without ticket references or change history. | 8 |
| A | `craft-simplest-shape` | Pick the representation reality needs, not the most typed one: strings for provider-owned vocabularies, text over database enums, attribute maps over ever-growing fields, one enum over correlated booleans. | 8 |
| A | `craft-log-actionable` | Log levels follow actionability: warn only when someone must act, identify the caller after authentication, never log payload content, and pre-create metric series so absence is visible. | 9 |

## Testing and QA

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| A | `test-prevent-class` | After fixing a bug, add the check that makes its class impossible: a startup assertion, a lint rule, a drift test pinning two sources together, or a compile-time break via shared constants. | 9 |
| A | `test-flake-data` | Treat flakes with data: measure the rate, rerun per test so the report names the flaky one, fix the root cause or remove the assertion deliberately, and watch the gate after merge. | 7 |
| A | `test-real-wiring` | Tests exercise real wiring and production-shaped data: no test that constructs the state the code under test should build, round-trip serialization for new fields, fixtures copied from real stored shapes. | 7 |
| A | `test-repro-fast` | Make the failure cheap to reproduce before fixing it: shrink the trigger until it runs in milliseconds, and show the check failing on the base branch and passing on the change. | 6 |
| A | `test-cost-aware` | Test cost is design: scale timeouts to real work, make paid or vendor-flaky suites opt-in, pin test images, and create prerequisites with lower-level clients so one failure does not cascade. | 7 |

## PR shape and review

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| A | `pr-small-steady` | Ship a steady stream of small PRs; a large change is a numbered series where each step lands on main with zero behavior change and names what comes next. | 8 |
| A | `pr-body-answers` | The body answers review questions before they are asked: why, what, verification, rollout and rollback, the riskiest hunk to push back on, and what was deliberately not fixed here. | 8 |
| A | `review-ask-first` | Review with questions and suggestion blocks, not prescriptions: ask whether it needs to exist, offer the one-click fix, approve fast, and block only on contract, security, or release-safety breaks. | 7 |
| A | `review-own-ai-output` | AI output is yours: review generated code before opening a PR, ask the model to argue against your change, and question AI-produced conventions before following them. | 6 |
| B | `pr-split-blast-radius` | Split by blast radius: a change that affects every caller ships alone, unrelated fixes move to their own PR, and a fix is never blocked on an adjacent improvement. | 5 |
