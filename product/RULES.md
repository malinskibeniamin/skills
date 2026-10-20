# Product rule catalog

Single source of truth for `/product` findings. Each rule merges what several independent,
recency-weighted evidence sets agree on, so current practice outranks older habits.

`src` counts the evidence sets that converge on a rule; `pts` sums each set's own grade for
it (S 3, A 2, B 1, C 0). Grades: **S** pts >= 10 enforced core, **A** >= 7 adopted, **B**
>= 4 apply when the diff plainly matches, **C** below, mention only when asked. Severity
comes from SKILL.md, not from grade. Cite the rule id in findings.

## Lane signals

- **Keep the lights on** saves money or prevents loss: repairs a reproduced provisioning,
  upgrade, deletion, authentication, or release failure; removes idle capacity, leaked
  resources, redundant builds, or dead surface; ships verified security fixes; makes
  recovery and rotation safer; keeps billable usage and upgrade paths accurate.
- **Quality of life** buys speed and reputation: cuts measured CI, setup, preview, or review
  wait without weakening checks; improves real latency and density; turns misleading
  health, empty states, or opaque errors into actionable feedback; makes docs and
  onboarding work; removes flakes and support dead ends.
- **Feature** makes money: unblocks a named customer, deal, acceptance failure, or dated
  demo; makes a capability sellable through plans, billing, or sales workflows; enables
  adoption through governance, audit, identity, or spend control; adds provider, region, or
  deployment support real users need; completes a first-value journey.
- **Taste** keeps the next change cheap: removes duplicate authorities that already drift;
  generates plumbing and adds structural checks; reuses a proven path; deletes obsolete
  flags, forks, and services with a carrying cost; makes a failure class impossible; keeps
  extension cheap without building ahead of a caller.

## Approve without ceremony

- Focused repairs with a reproduced failure, familiar implementation, bounded impact, and
  relevant checks.
- Incremental foundations or customer unblocks whose open items are explicitly nonblocking.
- Paved-path reuse, deletion of proven-obsolete machinery, and generated or typed plumbing
  with compatibility evidence.
- Measured friction cuts, CI stabilization, and practical polish that keep real checks.
- Default-off additions whose off path is inert and free, with no one-way door open.
- Routine version bumps, promotions, and narrow fixes.

## Justification (every change)

| Grade | Rule | Statement | Check | src | pts |
| :---: | --- | --- | --- | ---: | ---: |
| S | `name-the-beneficiary` | Name who benefits (persona, segment, operator, on-call, developers), the problem they hit today, and what changes for them. Lead with the user problem, then the mechanism. | Body describes only the implementation, or says "users" or "cleanup" without a role. | 5 | 14 |
| A | `why-now` | State the trigger: incident, customer ask, launch or demo date, deal, cost spike, measured regression, or blocked consumer. Say what breaks or costs more if it waits a quarter. | No trigger; hardening for a scale the product has not reached with no ceiling estimate; a stale branch nobody asked about. | 3 | 8 |
| A | `reachable-by-user` | Value counts once the beneficiary can reach it: a UI path, API, CLI, docs page, working defaults and setup, and a flag that is on somewhere. Merged engines, gated-off features, tools no prompt names, and examples that do not run as pasted earn nothing yet. | Trace from the change to a surface someone uses today; a new user needs a guessed URL, support, or missing config. | 3 | 8 |
| A | `one-outcome-per-change` | A change serves one lane and one outcome a reviewer can state in a sentence. Refactors, drive-by fixes, infra, and follow-up hardening go to their own PRs; non-goals and what was not fixed here are stated. | Feature mixed with unrelated cleanup, review-driven scope growth, or "while I'm here" changes. | 4 | 9 |
| B | `cheapest-disproof-first` | Run the cheapest experiment that could kill the idea (buyer conversation, prototype, benchmark) before the build. An experiment ends with a written verdict and its data; a disproved hypothesis closes the PR instead of merging a neutral change. | New capability over a week of work with no validation gate, or an experiment left open with no verdict. | 3 | 6 |
| B | `body-answers-the-reviewer` | The body answers review questions before they are asked: the problem in plain words, alternatives rejected in one line, verification, rollout and rollback, the riskiest hunk, and what was not fixed here. | A reviewer cannot tell from the body why this approach and what can break. | 3 | 5 |

## Scope: the smallest thing that proves value (every change)

| Grade | Rule | Statement | Check | src | pts |
| :---: | --- | --- | --- | ---: | ---: |
| S | `smallest-useful-slice` | Ship the cheapest slice that independently unblocks a user, a test, or another team: end to end first, optimize later. Large work is a numbered series where each step lands alone with its tests and rollback, named by what a user can now do. | A slice useful only once later PRs land, or one PR carrying several stories. | 5 | 13 |
| S | `demand-before-surface` | Every new option, field, endpoint, mode, permission, and abstraction needs a caller today. Defer hypothetical generality with a revisit trigger; ask for the use case first, and point at the existing feature when one already solves it. | A knob, variant, or abstraction with a single or hypothetical caller. | 4 | 11 |
| S | `smallest-sufficient-mechanism` | Compare with the simplest option: off-the-shelf, existing, or a small stated cost (seconds of runtime, a bounded error). Add retries, locks, caches, frameworks, or modes only when a measurement or napkin estimate shows the simpler choice fails. Match rigor to lifetime: demos optimize for done, production paths do not. | Machinery with no named failure it prevents, or no simpler alternative considered. | 5 | 11 |
| A | `track-every-deferral` | A workaround, TODO, or deferred item names its exit: the proper fix, owner, ticket, and the event that removes it. Follow-ups land within days; fallout from a fail-closed or security change is fixed in every environment the same day. | "Follow-up" with no ticket, a hack with no exit, or a known broken environment left for later. | 4 | 7 |
| B | `park-what-cannot-land` | Close or park work whose value cannot land yet (missing dependency, no consumer, no maintainer, stale); keep the branch and write the reopen condition. Do not polish or extend code scheduled for replacement unless a real user hits the problem. | Open for weeks with no consumer, or effort spent on a path being retired. | 3 | 6 |
| B | `block-only-on-material-risk` | Block on introduced defects, broken contracts, security, money, or release safety; not taste, cosmetic consistency, or inherited debt. Mark optional feedback nonblocking and let clear, reversible changes ship over paperwork. | A finding that blocks on preference, or a plan document holding up a reversible change. | 3 | 6 |

## Evidence: what proves it is done (every change)

| Grade | Rule | Statement | Check | src | pts |
| :---: | --- | --- | --- | ---: | ---: |
| S | `measure-every-claim` | Performance, cost, reliability, and speed claims ship with before and after numbers at representative scale: command, dataset, warm or cold, runs, and the bar. Unmeasured numbers are labeled as estimates. | A claim without a number, one sample, or local timing for a CI or production claim. | 4 | 11 |
| S | `verify-at-the-real-entrypoint` | Exercise the shipped entrypoint, the real storage or protocol boundary, and the deployment variants that matter. A write is done when the stored state is read back; a merge is done when it is observed working where the consumer runs it. Name what was not verified. | Integration claims backed only by happy-path fakes, success inferred from a 2xx, or "verified locally" on customer-facing work. | 4 | 11 |
| S | `acceptance-is-observable` | Acceptance reads as a demo script of observable outcomes (numbers, states, persisted results, the artifact the consumer receives), lists invariants that must not change, and includes the rollback step when risk exists. The requirement is the problem, not a prescribed implementation. | Missing acceptance, criteria that restate the change, or none that run on a real environment. | 4 | 10 |
| A | `tests-discriminate` | Each defect carries a reproduction that fails today and becomes the test; each new test exercises the changed public behavior and fails when the fix is reverted, with realistic fixtures and deterministic readiness. | A test that passes on the base branch, asserts on mocks, or never exercises the feature. | 3 | 9 |
| A | `triage-findings-on-evidence` | Tie every claim to the current revision and label inference and unrun checks. Every review finding, human or bot, ends fixed (with commit), deferred (with ticket), or accepted with a reason; model-written code has a human owner who read it. | Findings silently dropped, approval claims from an older revision, or generated code nobody read. | 4 | 8 |
| C | `tests-earn-their-cost` | Use the lowest test tier that proves each failure mode; make paid or vendor-flaky suites opt-in, scale timeouts to real work, and delete redundant or brittle checks instead of adding seams for volume. | A heavy suite duplicating a cheaper one, or a production seam that exists only for tests. | 2 | 3 |

## Keep the lights on: saves money

| Grade | Rule | Statement | Check | src | pts |
| :---: | --- | --- | --- | ---: | ---: |
| S | `price-the-run-cost` | State the running cost a change adds or saves (dollars per month, requests, tokens, cache hits, CI minutes, storage, on-call) and bound worst-case amplification. Prefer opt-in, scale-to-zero cost that lands only when a customer enables the feature; remove repeated work before adding capacity; stay under vendor limits. | New node pool, replica, cache, retention, cardinality, fan-out, or build farm without a figure or bound. | 5 | 12 |
| A | `delete-what-doesnt-pay` | Deleting unused code, flags, fields, dependencies, infrastructure, process steps, and always-loaded context is first-class value; misleading surface is worse than missing surface. Check real dependents first; remove a flag once it has run clean. | Dead path kept "just in case", a flag older than its rollout, or a never-enforced field left in place. | 3 | 8 |
| B | `automate-recurring-toil` | Replace repeated, error-prone manual work with wrappers, dry-run modes, reconcilers, and runbooks corrected right after the incident that exposed them. Start rare workflows manual and documented; automate once volume or toil is proven. | A repeated manual step in the PR's own test plan or incident notes with no tooling follow-up. | 3 | 5 |
| B | `guard-destructive-actions` | Deletion, suspension, recreation, and cleanup automation needs explicit intent and mechanical guards: grace periods, scoping to suspended or unreferenced resources, dry runs, and a proven restore path. | Automation that can delete or overwrite the wrong resource on a bug or retry. | 2 | 4 |

## Quality of life: speed and reputation

| Grade | Rule | Statement | Check | src | pts |
| :---: | --- | --- | --- | ---: | ---: |
| S | `errors-users-can-act-on` | A fixable failure is rejected at write time with a specific message, field name, and next step, not found weeks later as an opaque internal error. Translate vendor errors, keep codes machine-readable, and never leak internals. | A path that maps to a generic 500 or "unknown error", or input validated only deep in the runtime. | 4 | 10 |
| B | `fast-feedback-keeps-signal` | Fix friction that taxes everyone (red main, flaky gates, broken onboarding, slow local loops) before polishing edges. CI and dev-loop work states who is unblocked and the time saved, keeps the relevant checks, and treats flakes with data. | Speedup without before and after, a skipped or weakened check, or a retried job hiding a flaky test. | 3 | 6 |
| B | `calm-consistent-surfaces` | Organize surfaces around the user's next action with stable layout, useful density, and immediate feedback: one pattern per concern, cues that survive zoom and greyscale, no one-off layouts that look unfinished in a demo. | A second pattern for an existing concern, or work lost on a background failure. | 3 | 4 |

## Feature: makes money

| Grade | Rule | Statement | Check | src | pts |
| :---: | --- | --- | --- | ---: | ---: |
| A | `fit-the-real-caller` | Shape the feature around the caller's actual task, persona, and deployment: fewer setup steps, no hidden prerequisites, success without internal help, verified on the setups customers run. Agent tools expose the task, not generic enumeration. | A change that adds a manual step, a support-ticket path, or a provider restriction exported to the customer. | 5 | 9 |
| A | `build-what-we-sell` | Feature work names the customer, prospect, segment, launch, or demo it serves and follows recorded product decisions. Parity work cites the convention it matches; capability that decides a deal outranks polish. | A feature with no named buyer or launch, a path we do not sell, or a contradiction of a recorded decision. | 3 | 8 |

## Taste: keeps the next change cheap

| Grade | Rule | Statement | Check | src | pts |
| :---: | --- | --- | --- | ---: | ---: |
| S | `reuse-before-adding` | Use the existing library, platform service, registry component, or repository pattern before adding another mechanism; fix upstream instead of forking. Count every new dependency, service, or fork as recurring cost, and check licenses. | A bespoke client, handler, or controller where a maintained one exists, or a second way of doing the same thing. | 4 | 10 |
| A | `one-source-of-truth` | Each concern has one owner and one authoritative representation for defaults, state, policy, and config; derive other views and import shared constants instead of copying. Each mutable resource has one writer. | A second copy that can drift, or two paths updating the same resource. | 4 | 9 |
| A | `guard-the-mistake-class` | After a mistake happens once, add the cheapest guard that stops the class: a drift check on generated output, a sync test between registries, a boot guard, a lint, or a type or constraint that makes the invalid state unrepresentable. Generate the third hand-written copy. | A bug fix with no check that would have caught the class. | 3 | 8 |
| B | `api-as-product` | Treat every API as a future public product: hard to misuse, consistent with sibling resources, shaped by the domain rather than one client or a vendor, with absent, zero, and cleared values kept distinct. Domain logic lives with its owner behind a small interface. | A one-off resource shape, a vendor-shaped field, or business logic in a generic layer. | 3 | 5 |
| B | `words-customers-use` | Names say exactly what the value is, match sibling resources, and use the words customers and open standards use; no internal jargon, colliding product names, or names that age ("new", "v2"). | A name that needs a comment to decode, or a term only the team uses. | 2 | 4 |

## Delivery: ship fast, fail fast, reversibly (rollout, contract, or migration)

| Grade | Rule | Statement | Check | src | pts |
| :---: | --- | --- | --- | ---: | ---: |
| S | `observable-in-production` | New paths ship with signals that answer a specific question: adoption and failure metrics, actionable alerts (ratios, idle versus wedged, caller errors excluded), bounded labels, and caller-identifying logs without payloads. Page only on what on-call can fix. | A launch-bound feature with no usage or failure signal, or a new alert or error log for an expected condition. | 5 | 13 |
| S | `ship-dark-then-widen` | New behavior lands default off (flag, opt-in, shadow or log-only mode) with the off path proven inert; enable internal, then integration, then production, as a step separate from merge, with a demonstrated rollback. Remove the gate when its purpose ends. | A merge that changes behavior for every tenant at once with no off switch. | 4 | 12 |
| S | `protect-live-consumers` | Check compatibility against deployed clients, stored data, URLs, and wire formats: additive or expand-contract changes, producer before consumer, mixed-version behavior stated, existing data repaired. A hard cutover says why it is safe now; risky merges wait until an in-flight launch or demo has passed. | A rename, removal, or default flip on a live path with no staged rollout or safety argument. | 4 | 11 |
| A | `owner-decides-one-way-doors` | Novel architecture, trust or privacy changes, billing policy, irreversible schema or data steps, production mutations, and customer commitments need their owner's explicit decision. Name the adverse scenario and the exact decision; a PR cannot authorize itself. | A one-way door with no named owner approval, or scope extended to a deliberately excluded cohort. | 4 | 9 |
| B | `safe-defaults` | Choose defaults by how they fail: production-safe by default, security and policy paths fail closed, development bypasses never default, and seeded states that cannot work stay disabled until configured. | A default that is unsafe in production, or a first-run state that cannot work. | 3 | 6 |

## Trust: what customers see (customer-visible output, docs, or data)

| Grade | Rule | Statement | Check | src | pts |
| :---: | --- | --- | --- | ---: | ---: |
| S | `no-false-success` | Nothing reports success, health, or capability that is not real. A field, mode, or argument that is accepted but does nothing is worse than absent: implement it, reject it, or delete it. Unknown, partial, or skipped work is reported as such, never as success, emptiness, or a default. | Config that validates but has no runtime effect, success over a skipped write, or a warn log standing in for an error. | 5 | 15 |
| S | `claim-only-what-ships` | Docs, UI copy, release notes, and examples state only shipped, verified behavior, run as pasted, and fit every segment they claim (self-hosted, enterprise, managed cloud); limits are disclosed and docs ship with the feature. | A published example nobody ran, a claim for an unreleased capability, or a note that fits one deployment while claiming all. | 4 | 11 |
| B | `hide-unready-and-internal` | Unready features stay behind a flag, internal infrastructure gets no public API or UI, and public models expose product concepts, not storage or vendor fields. Narrow and strict can widen later; the reverse is a break. | A public field or endpoint for internal bookkeeping, or a surface exported before a caller needs it. | 3 | 6 |
| B | `protect-data-and-identity` | Derive identity from authenticated evidence and keep tenant and resource ownership through storage, caches, and execution; enforce policy outside the model. Keep payload content out of errors and logs, make recording opt-in, and request the least privilege a customer's IT team will approve. | A path that can act for the wrong tenant, borrows a stronger identity, or logs customer content. | 2 | 6 |
| B | `numbers-tell-the-truth` | Cost, usage, status, and health figures are correct, complete, and unclamped; totals match breakdowns; observed state is kept apart from desired state, and missing telemetry never reads as healthy or zero. | A clamped percentage, a total that can drift from its parts, or a green status over a failed source. | 2 | 5 |
| B | `degrade-visibly` | Prefer partial answers with visible gaps over total failure; an optional dependency, probe, or license check never locks users out. Retries and cleanup are bounded and converge after partial failure, and permanent failure is visible. | A secondary failure that breaks the core operation, or an unbounded retry or poll. | 2 | 5 |
| C | `no-silent-substitution` | Never replace what the caller asked for (model, region, identity, value) with a fallback, or hide a third-party defect behind an invented contract; support it, pass it through, or fail with an actionable error. | A fallback that silently changes the requested resource or semantics. | 2 | 3 |

## Money: revenue integrity (billing, metering, pricing, or entitlement)

| Grade | Rule | Statement | Check | src | pts |
| :---: | --- | --- | --- | ---: | ---: |
| A | `money-path-correctness` | Missing, zero, or unparseable usage stalls, errors, or dead-letters with an alert; it is never skipped or recorded as zero. Prove no double and no lost charge against the real billing environment, use exact decimals with units in names, map invoices to resources the customer owns, and never bill for idle, internal, or platform overhead. | A money-path diff without a charge-path test, pricing sign-off, or a real-environment invoice comparison. | 4 | 7 |
| C | `sell-it-from-day-one` | A sellable capability ships with metering, the dimensions pricing will segment by, and its entitlement path; gating and trial nudges are accurate, quiet when unsure, and show what is actually gated. | A paid capability with no metering, or a nudge that blocks free users on a wrong signal. | 2 | 3 |
