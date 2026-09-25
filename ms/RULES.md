# Rule catalog

Single source of truth for `/ms`. Every entry is backed by at least three independent
authored PRs, review threads, tickets, or design notes from a product owner's four years of
platform, SDK, gateway, and console work. Evidence is recency-weighted (older years count
less; the current agentic platform work counts most), so grades track what matters now:
S/A is the enforced core; B is adopted; C wording is provisional.

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
