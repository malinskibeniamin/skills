# Rule catalog

Single source of truth for `/av`. Rules come from four years of authored pull requests,
review comments, tickets, and design documents by one senior engineer on a cloud
platform's billing, control-plane, and agentic data-plane work. Evidence is recency
weighted (oldest year 0.25 up to the current year 1.25), so recent practice outranks
early habits.

`n` = independent examples; `w` = recency-weighted support. Grades: **S** w ≥ 14,
**A** w ≥ 7, **B** w ≥ 3.5, **C** below. Money-path severity comes from `/av` P1 rules, not
from grade. Cite the rule id in findings.

## Scope -- is this the work to do now?

| Grade | Rule | Statement | n | w |
| :---: | --- | --- | ---: | ---: |
| S | `name-the-beneficiary` | State who benefits (segment, deal, launch, on-call, developers) and the problem they have today; tickets carry who / success criteria / why it matters. | 24 | 24.5 |
| A | `demand-before-generality` | Add fields, options, metrics, and abstractions only for a demonstrated need; if the stack will not support it end to end now, leave it out. A cheap slot is acceptable only when redoing it later is expensive and the request keeps recurring. | 16 | 13.0 |
| A | `slice-milestones-by-user-visible-behavior` | Split large work into independently shippable milestones, each described by what a user can now do; land the data layer first so follow-ups stay narrow; finish every announced phase. | 12 | 12.0 |
| B | `stop-investing-in-retiring-code` | Do not fix or extend code scheduled for retirement unless a real user was observed hitting the problem. | 6 | 6.3 |
| A | `proportionate-fix` | Prefer the smallest change that meets the need; accept a small, stated cost (seconds of runtime, a bounded one-hour error) over new machinery, and say why the machinery is not worth it. | 10 | 9.5 |
| B | `stay-in-scope-on-money-paths` | Keep billing and entitlement changes to their stated scope; do not extend behavior to cohorts that were deliberately excluded without a separate decision. | 5 | 5.3 |
| A | `ground-parity-in-the-market` | For parity features, cite the competitor or industry convention being matched and the gap it closes. | 6 | 7.5 |
| B | `validate-against-real-customer-setups` | Before a pilot or deal depends on it, verify the feature on the frameworks, providers, or integrations prospects actually use and record per-setup verdicts. | 3 | 3.8 |

## Money -- revenue integrity and cost

| Grade | Rule | Statement | n | w |
| :---: | --- | --- | ---: | ---: |
| S | `never-silently-lose-billable-usage` | Missing, zero, or unparseable usage must stall, error, or dead-letter with an alert; never skip it, move past it, or record it as zero. | 18 | 19.8 |
| B | `ambiguity-underbills-never-double-bills` | When meter or vendor semantics are undocumented, stop and understand them; if forced to choose, fail toward underbilling, never double billing. | 7 | 5.8 |
| A | `prove-billing-against-the-real-vendor` | Money-path changes are verified against the real billing vendor or integration environment: rates visible in that environment, a compared invoice, and a re-run of the signup-to-paid flow. Mocks alone do not count. | 14 | 12.3 |
| A | `guard-destructive-automation` | Deletion, suspension, and cleanup automation is gated: only applies to already-suspended accounts, distinguishes manual from automatic actions, keeps grace periods, refuses while referenced resources remain. | 12 | 11.3 |
| B | `trace-price-changes-to-a-business-source` | Price, discount, or plan changes point to the pricing source of truth and the customer-facing commitment (order form, announcement) before they reach production. | 5 | 5.0 |
| B | `invoices-trace-to-customer-resources` | Billing keys and report labels must be understandable to the customer and map to a resource they own; do not reuse another product's key to save work. | 5 | 6.3 |
| A | `protect-billing-channel-integrity` | Transitions between marketplace, card, contract, and flat-fee billing never leave a second active billing path, an unpriced path, or a blocked customer. | 7 | 7.5 |
| B | `meter-new-products-from-day-one` | A new sellable capability ships with its metering and billing path; "billing works" is a GA criterion even if charging starts later. | 5 | 6.3 |
| A | `quantify-cost-and-toil` | Maintenance work states what it saves: leaked resources, CI minutes, vendor quota, storage file counts, manual hours. | 11 | 10.0 |
| B | `emit-the-dimensions-pricing-needs` | Usage records carry the dimensions pricing will segment by (product, tier, region group, architecture) so prices change without code. | 7 | 5.3 |
| B | `respect-vendor-limits-and-contracts` | Know and monitor third-party rate limits and contract caps; design the call pattern (cache, batch, backoff) to stay under them. | 6 | 4.3 |
| B | `customers-never-pay-for-waste` | Customers are not billed for idle clusters, internal or system traffic, desired-but-absent capacity, platform overhead, or credits lost in a plan change. | 6 | 4.8 |

## Trust -- what customers see

| Grade | Rule | Statement | n | w |
| :---: | --- | --- | ---: | ---: |
| S | `numbers-tell-the-truth` | Cost, usage, and health figures are correct, complete, and unclamped (show 142%, not 100%); totals cannot drift from breakdowns; the next action is obvious. | 16 | 20.0 |
| S | `no-silent-success` | Reject or surface configurations and edits that cannot work (saved-but-ignored fields, providers with no credentials, updates that no-op) instead of reporting success. | 13 | 15.5 |
| A | `errors-guide-self-service` | Errors say what broke and how to fix it; translate opaque vendor errors; a generic failure that needs an operator is a self-service blocker. | 11 | 12.3 |
| A | `first-run-has-no-traps` | Defaults and seeded states that cannot work are prevented: disabled until configured, auto-disabled when the last credential goes, verified before save with a soft warning when verification is unavailable. | 6 | 7.5 |
| A | `claim-only-what-is-true` | UI copy, docs, and release notes state only shipped, verified behavior; remove false claims, unimplemented features, and implementation details. | 9 | 10.0 |
| A | `hide-unready-and-internal-surfaces` | Unready features stay behind a flag; internal infrastructure gets no public API or UI; expose a public API as the last step. | 11 | 10.5 |
| B | `ship-docs-with-the-feature` | Every user-facing feature ships with docs reviewed by the docs team and customer-facing release notes. | 6 | 6.8 |
| C | `accessible-by-default` | Charts and status use redundant cues that survive greyscale, color blindness, and zoom. | 2 | 2.5 |

## Delivery -- ship fast, fail fast, safely

| Grade | Rule | Statement | n | w |
| :---: | --- | --- | ---: | ---: |
| S | `ship-dark-then-widen` | Ship behind a flag or disabled by default; enable for internal orgs, then integration, then production, with every other environment explicitly off; decouple release from rollout; use log-only shadow mode for risky automation. | 16 | 17.0 |
| S | `merged-is-not-delivered` | Done means observed working in a real environment: flag enabled, permissions granted, topics and roles present, end-to-end path exercised. Hold the merge when live verification fails. | 12 | 14.5 |
| A | `state-why-the-risk-is-acceptable` | A breaking change, skipped compatibility guard, or hard cutover names why it is safe now (no production consumers, rarely executed, nothing live yet). | 13 | 11.5 |
| S | `observability-is-part-of-done` | New paths ship with metrics and alerts that are actionable (ratios, not raw rates), distinguish idle from wedged, and exclude caller errors from failure counts. | 16 | 14.3 |
| A | `explain-for-the-reviewer` | The PR body explains the problem in plain words, how it was verified, and the review order; add a demo clip or diagram for non-trivial flows; keep one logical change per PR. | 11 | 12.3 |
| C | `freeze-near-launch` | Close to a launch or demo, merge only fixes; anything else waits unless an explicit reason is given. | 4 | 3.0 |
| B | `prefer-reversible-steps` | Decommission by opt-in before deletion; revert fast and reland with the root cause; keep the old path until the new one is proven. | 6 | 5.0 |
| B | `track-deferred-work` | Every deferred test, TODO, or workaround gets a ticket; untracked TODOs surface in production. | 7 | 4.0 |
| C | `manual-first-then-automate` | Start rare operational workflows as a documented manual or semi-manual path; automate once the volume or toil is proven. | 5 | 2.3 |

## Taste -- design that keeps shipping cheap

| Grade | Rule | Statement | n | w |
| :---: | --- | --- | ---: | ---: |
| S | `delete-dead-and-misleading-surface` | Remove unused features, never-enforced fields, dead buttons, stale config, and duplicate implementations; misleading surface is worse than missing surface. | 20 | 22.0 |
| A | `one-owner-one-source-of-truth` | Give each concern one owning service and one source of truth; reuse the existing config or mechanism before adding a new concept. | 12 | 12.0 |
| A | `names-match-values` | Names say exactly what the value is, stay consistent with sibling resources, and are chosen to survive vendor renames. | 11 | 10.8 |
| B | `own-your-public-api` | Design public APIs for this product's needs, not a vendor's shape; include only fields the designs need; settle the shape before anyone depends on it. | 8 | 6.3 |
| B | `production-safe-defaults` | Defaults are the production-safe choice; development-only modes and security bypasses are never the default. | 7 | 4.5 |
| B | `do-not-paper-over-upstream-defects` | When a third party is wrong, fix it upstream or surface it; do not fabricate a contract in our layer that hides their defect. | 3 | 3.8 |
