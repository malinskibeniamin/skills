# Value rule catalog

Single source of truth for `/ss` findings. Support is recency-weighted, so current practice
outranks older habits; n counts independent examples behind each rule.

Grades: **S** (weighted >= 10) enforced core, **A** (>= 7) adopted, **B** (>= 4.5) apply
when the diff plainly matches, **C** (below) mention only when asked. Cite the rule id in findings.

## Justification (every PR)

| Grade | Rule | Statement | Check | n | w |
| :---: | --- | --- | --- | ---: | ---: |
| S | `evidence-over-assertion` | Performance, cost, reliability, and speedup claims ship with measured before and after numbers on representative hardware; a disproved hypothesis closes the PR instead of merging a neutral change. | Claim without number, one sample, or local-only timing on a CI claim. | 15 | 18.7 |
| S | `reachable-by-user` | Value counts once the beneficiary can reach it: a UI path, API, CLI, docs page, and a flag that is on somewhere. Merged engines, gated-off features, tools no prompt names, and docs examples that do not run as pasted earn nothing yet. | Trace from the change to a surface a customer or operator uses today. | 14 | 18.9 |
| S | `no-silent-no-op` | A field, mode, or tool argument that is accepted but does nothing is worse than absent. Implement it, reject it, or delete it; never leave it configured, billed, and unenforced. | New or touched config that validates but has no runtime effect, or a success response that hides a skipped write. | 9 | 13.0 |
| A | `one-primary-bucket` | A PR serves one bucket. Refactors, formatting, drive-by fixes, and follow-up hardening go to their own PRs so each merge has one reason and one rollback. | Diff mixes a feature with unrelated cleanup, or a narrow fix carries broad quality work. | 8 | 9.9 |
| A | `name-the-beneficiary` | Name who benefits (persona, customer, operator, on-call, internal engineers) and what changes for them. Lead the description with the user problem before the mechanism. | Body describes only the implementation, or says "users" without a role. | 8 | 9.2 |
| A | `why-now` | State the trigger: incident, customer ask, launch or demo date, deal, cost spike, measured regression. Record why it was not done earlier and why it cannot wait. | No trigger; hardening for a scale the product has not reached without a ceiling estimate. | 9 | 9.8 |
| A | `acceptance-as-demo` | Acceptance criteria read as a demo script or "done when" list that runs on a real environment, including the rollback step when risk exists. "Verified locally" is not done for customer-facing work. | Missing AC, AC that only restates the change, or no real-environment verification. | 9 | 9.25 |
| B | `explain-for-outsiders` | Lead with a short plain-language summary, the user problem, alternatives considered with one-line rejections, and an explicit risk statement. | Reviewer cannot tell from the body why this approach and what can break. | 7 | 6.9 |

## Feature: makes money

| Grade | Rule | Statement | Check | n | w |
| :---: | --- | --- | --- | ---: | ---: |
| S | `name-the-deal` | Feature work names the customer, prospect, segment, launch, or demo it serves, and what that buyer cannot do today. Capability that decides a deal ("decisive for multilingual prospects") outranks polish. | Feature with no named buyer or launch and no request behind it. | 9 | 10.45 |
| A | `self-service-over-hand-holding` | Prefer changes that let a customer succeed without internal help: remove setup steps, pre-fill configuration, surface the cause of failure. Time-to-first-success is the metric. | Change adds a manual step, a support ticket path, or a hidden prerequisite. | 7 | 8.15 |
| A | `measure-adoption` | New capability ships with a usage or outcome signal (metric, event, dashboard, audit record) so the team can tell whether anyone uses it and reach out when they struggle. | Launch-bound feature with no telemetry of use or failure. | 8 | 8.45 |
| A | `revenue-path-correctness` | Billing, metering, pricing, and entitlement changes prove no double charge and no lost charge, carry units in names (cents, per hour), use decimals for money, and cite product or pricing sign-off. | Revenue-affecting diff without a test of the charge path or without sign-off. | 12 | 7.45 |

## Keep the lights on: saves money

| Grade | Rule | Statement | Check | n | w |
| :---: | --- | --- | --- | ---: | ---: |
| S | `cost-in-dollars` | Changes that add or resize infrastructure state the dollar cost per month and when it is incurred. Prefer opt-in, scale-to-zero, and cost that lands only when a customer enables the feature; count upgrade and surge costs, not just steady state. | New node pool, replica, cache, retention, cardinality, or build farm without a figure. | 10 | 12.75 |
| S | `delete-what-doesnt-pay` | Deleting unused code, dependencies, flags, infrastructure, process steps, and always-loaded context is first-class value. Remove a flag once it has run clean in production. | Dead path kept "just in case"; flag older than its rollout; new process with no owner. | 15 | 14.15 |
| B | `toil-to-automation` | Replace hand-run, error-prone operations with reconcilers, dry-run tooling, runbooks updated from real incidents, and durable rollout records. | Repeated manual step in the PR's own test plan or incident notes. | 7 | 6.25 |
| B | `alert-on-actionable-only` | Page only on what on-call can fix. User configuration errors go back to the user; noisy checks notify, not page, while being improved; normal teardown is not an error log. | New alert or ERROR log for an expected or user-caused condition. | 6 | 5.45 |

## Quality of life: reputation and speed

| Grade | Rule | Statement | Check | n | w |
| :---: | --- | --- | --- | ---: | ---: |
| S | `errors-users-can-act-on` | A user-fixable failure returns a specific, actionable message at write time, not an opaque internal error at run time, and never leaks internals. | Error path that maps to a generic 500, a bare "internal error", or a failure discovered weeks later. | 10 | 10.55 |
| B | `unblock-the-many` | CI and developer-experience work states who is unblocked and how much time it saves, keeps only the measured wins, and removes redundant checks instead of adding new ones. | Speedup claimed without a before and after, or a new gate that duplicates an existing one. | 7 | 5.85 |

## Design bet: taste, incremental, reversible

| Grade | Rule | Statement | Check | n | w |
| :---: | --- | --- | --- | ---: | ---: |
| A | `reuse-or-buy-before-build` | Use the shared library, official SDK, or production-tested tool before hand-rolling; fix upstream instead of forking; check licenses before depending on a model or package. | New bespoke client, protocol handler, or controller where a maintained one exists. | 8 | 9.65 |
| S | `default-off-reversible` | New behavior lands default off (flag, zero replicas, opt-in per tenant) with per-environment enablement and a demonstrated rollback; enablement is a separate step from merge. | Merge that changes behavior for every existing tenant at once with no off switch. | 11 | 11.85 |
| S | `smallest-slice-that-proves-value` | Ship the cheapest slice that proves the claim for the current stage: end to end first, optimize later; UI abstractions before backend models for early access; defer generality until a second real user. | Options, modes, or abstractions with a single caller or a hypothetical future user. | 15 | 13.2 |
| S | `protect-paying-customers` | Classify blast radius on existing customer paths, sequence risky cutovers behind verification, keep wire and schema changes backwards compatible, default to safe settings, and hold risky merges until an in-flight customer demo or launch has passed. | Rename, removal, or default flip on a live path without a staged rollout. | 14 | 11.75 |
| A | `scope-discipline` | Keep the PR to its stated purpose; ticket follow-ups instead of folding them in, especially near a deadline. Merge the value, then iterate. | Review-driven scope growth, or "while I'm here" changes. | 10 | 7.1 |
| B | `time-box-hacks` | A workaround is fine when it names its exit: the proper fix, the owner, and the date or event that removes it. | Hack, TODO, or temporary disable with no exit condition. | 8 | 5.5 |
| B | `proportional-quality` | Match rigor to lifetime and blast radius: one-off scripts and demos optimize for done; production paths and security boundaries do not. | Gold-plating throwaway code, or demo-grade shortcuts on a production path. | 8 | 6.6 |
| C | `quantify-risk-before-machinery` | Before adding retries, rollback engines, locks, or scale work, estimate the failure probability or ceiling with napkin math; add machinery only when the number justifies it. | Complex safeguard for a failure that is rare and cheap to retry, with no estimate. | 5 | 4.25 |

## Engineering practice: how the change is built, tested, and shipped

Bucket-neutral. Apply to any diff; the check names what to look for in the PR itself.

| Grade | Rule | Statement | Check | n | w |
| :---: | --- | --- | --- | ---: | ---: |
| S | `guard-the-mistake-class` | After a mistake happens once, add the cheapest guard that stops the whole class: a drift check on generated output, a sync test between registries, a boot guard that refuses unsafe config, a migration lint. Fix the instance and the class together. | Bug fix with no test, lint, or startup check that would have caught the class. | 9 | 10.1 |
| A | `test-the-real-seam` | Test at the seam that actually breaks: real containers or protocol-faithful fakes instead of mocks, journey-level certification tests (enable, write, read back), and live or contract-pinned tests for third-party APIs. A happy-path fake of an external API is not coverage. | Integration claim backed only by hand-written happy-path fakes, or no test that exercises the user journey end to end. | 9 | 9.85 |
| A | `follow-up-lands-fast` | A deferred item gets a ticket in the PR and usually lands within a day or two; fallout from a fail-closed or security change is fixed in every environment the same day. | "Follow-up" with no ticket, or a known broken environment left for later. | 7 | 9.35 |
| A | `triage-every-finding` | Every review finding, human or bot, ends in one of three states with a line of reasoning: fixed (with commit), deferred (with ticket), or accepted trade-off. Post a round summary on long reviews. | Findings silently dropped, or resolved threads with no disposition. | 6 | 9.0 |
| A | `pay-down-own-friction` | When a manual step hurts, ship the wrapper, `--dry` mode, runbook, or skill that week, and correct runbooks right after the incident that exposed them. | PR test plan or incident notes describing a repeated manual procedure with no tooling follow-up. | 8 | 8.85 |
| A | `close-with-a-verdict` | An experiment ends with a written verdict and its data: keep, or close with "hypothesis disproved". Unmeasured numbers are labeled as such, and permanent limits are labeled permanent. | Speculative PR left open indefinitely, or estimates presented as measurements. | 7 | 8.5 |
| A | `verify-the-stored-write` | A write is done when the stored state is read back and matches, not when the API returns 2xx. Tests record the full outbound request and assert field by field. | Success path that trusts the status code, or a fake that records only part of the request. | 6 | 8.3 |
| A | `numbered-stack` | Large work ships as numbered, independently mergeable PRs (1/n..n/n), each with its own tests and rollback; split by what is verified versus blocked. | One PR mixing several stories, or a stack whose layers cannot merge alone. | 7 | 7.9 |
| A | `validate-at-the-boundary` | Reject bad input at write time with field-level errors: schema validation rules, cross-field constraints, typed values instead of strings, decimals and units for money. Runtime surprises weeks later are the failure mode. | New or changed input accepted without validation, or a constraint enforced only deep in the runtime. | 8 | 7.3 |
| B | `one-owner-per-resource` | Each mutable resource has one writer: serialize updates per resource id through one control loop instead of locks or competing reconcilers, and split state by writer. | Two paths updating the same resource, or a lock added to paper over concurrent reconcilers. | 7 | 4.85 |
| C | `debuggable-over-clever` | Prefer formats, configs, and logs a tired on-call can read: human-readable payloads, printable effective config, one log line at each decision, and conditions that read as intent. | Binary or opaque format chosen for no measured gain, or a decision path with no log. | 6 | 3.85 |
