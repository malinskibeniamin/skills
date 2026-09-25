# mm rules

Mined from about 1,600 pull requests (authored, reviewed, and commented), 150 tickets, and
the RFCs and product proposals behind them, 2024-09 through 2026-09. Recent agentic
platform work (AI gateway, agent API, agent UI, model serving, SQL engine as the agent data
plane) weighs most: 2026 H2 x3, 2026 H1 x2, 2025 x1, 2024 x0.5. Storage-engine work from
2024-2025 informs only rules it independently supports.

**Grade**: S = repeated in reviews and in shipped work across eras; A = repeated recently;
B = consistent but thinner. **Support** counts tagged PRs (reviewed + shipped) plus design
documents; counts are approximate keyword tags, not a census.

## V1. Name the user and what they will notice (S)

- **Ask**: Who sees this change (end user, operator, developer, buyer), and what do they
  see differently? What does failure look like to them?
- **Satisfied by**: a user-visible effect stated in the body; errors, denials, and blocks
  that carry the reason the user needs; docs claims verified.
- **Finding**: `V1: no user or visible effect stated` (P2); P1 when a failure path renders
  as success or an opaque error ("API call failed", generic "unknown error").
- **Evidence**: a guardrail block shipped twice until it read as a refusal with its reason in
  the agent transcript, not a normal reply or a transport error; low-cardinality error codes
  replaced Go type names in spans; "Why do we need this very generic error? It tells the
  caller nothing"; "do we fully support JDBC?" before the docs claim it.
- **Support**: 30 PRs + 3 RFCs.

## V2. Why now: what is blocked or getting worse (S)

- **Ask**: What breaks, costs, or stalls if this waits a quarter? Who is blocked?
- **Satisfied by**: a linked ticket or incident, a blocked consumer, a cost of delay, or a
  deadline with an owner.
- **Finding**: `V2: no reason this is needed now` (P2); `q: Is this PR still relevant?` for
  stale branches.
- **Evidence**: "stop the bleeding first: every day of delay makes the backfills lossier";
  a storage primitive landed before months of view work because a dependent team could not
  build without it; "is this PR fixing any tracked issue?"; "no current epic delivers it".
- **Support**: 22 PRs + 4 tickets.

## V3. Build what we sell; honor product decisions (S)

- **Ask**: Does this strengthen the product we actually sell, in the direction already
  decided? Does it chase a race a competitor already won?
- **Satisfied by**: alignment with a recorded product decision or stakeholder ask;
  differentiation from the intersection of assets we already run well; existing customers
  get an expansion, not a migration.
- **Finding**: `V3: optimizes a path we do not sell` or `V3: contradicts recorded decision
  <link>` (P2, P1 when it ships public surface).
- **Evidence**: "Phase 1 should target the open table format; we are not selling the native
  format yet"; "native is faster doesn't matter, it was a product decision and we stick to
  it"; a proposal rejected its own earlier draft for bending an engine against its grain
  and chasing a moat a competitor already shipped; renamed a feature because the stakeholder
  asked.
- **Support**: 6 PRs + 4 product proposals.

## V4. Cheapest disproof first (A)

- **Ask**: What is the cheapest experiment that could kill this idea, and has it run?
- **Satisfied by**: validation ordered by cost (buyer conversation, prototype, benchmark,
  then build); a named fallback if the key gate fails; experiments labeled "not a merge
  candidate".
- **Finding**: `V4: large build with no validation gate` (P2) for new capability above a
  week of work without a gate.
- **Evidence**: "Experiment 1 is a buyer conversation, not a build; if wrong we spent a few
  conversations, not a few quarters"; every proposal carries "what to validate first" with
  a make-or-break test and a narrower product that survives its failure; prior art surveyed
  ("every piece exists, nobody connects them") before designing.
- **Support**: 5 proposals and RFCs + 4 experiment PRs.

## V5. Measure every claim (S)

- **Ask**: Is each performance, cost, or reliability claim measured on the path that
  matters, with method stated?
- **Satisfied by**: before/after numbers, the command, dataset and scale, warm or cold,
  runs; honest "not measured, not claimed".
- **Finding**: `V5: unmeasured <perf|cost> claim` (P2); `q: What is the benefit?` for costly
  mechanisms with no number.
- **Evidence**: "Can we add a microbenchmark showing the improvement?"; "This isn't cheap, do
  we know the benefit? Do we run TPC-H in CI? If not, add it"; a customer's own query set
  became a reproducible suite so results compare to the customer's report; benchmarks must
  run at realistic scale, off the node under test, without polling waits.
- **Support**: 12 reviewed + 94 shipped PRs.

## V6. Worth the complexity? Compare with the simplest option (S)

- **Ask**: What does the off-the-shelf, existing, or simpler version cost? Is the gain worth
  the extra concepts?
- **Satisfied by**: the simpler alternative named and rejected with a measured or structural
  reason; reuse of a library, upstream fix, existing helper, or deterministic tool.
- **Finding**: `V6: custom mechanism where <existing> works` (P2).
- **Evidence**: "is the gain worth the complexity? what is the end-to-end number with a stock
  hash map?"; "use something simple first and switch if we see problems"; "overcomplicated,
  use the standard way"; "a lint rule does this faster and cheaper than a model"; "has this
  been fixed upstream?"; one tooling language instead of two.
- **Support**: 34 reviewed + 68 shipped PRs.

## V7. Every surface needs a user today (S)

- **Ask**: Who calls this API, flag, config knob, state, or dependency now?
- **Satisfied by**: a current caller in the diff or on main; otherwise hardcode and ship a
  new version when the need is real.
- **Finding**: `V7: speculative <knob|API|state>` (P2); `q: Why do we need this?`.
- **Evidence**: "a fixed window: three correctness surfaces bought for a knob nobody asked
  to turn"; a teammate asked "we set this, not a customer? how does one tweak it?" and the
  answer was "happy to drop it, we can release a new version"; "introduce this together with
  the code that uses it"; "drop that state for now, easy to add when needed"; "why introduce
  a property that locks us in?"; delete unused code, but grep dependent repositories first.
- **Support**: 58 reviewed PRs.

## V8. One outcome per PR (A)

- **Ask**: Can a reviewer state the PR's outcome in one sentence? Do unrelated changes ride along?
- **Satisfied by**: one outcome; refactors, infra, and fixes in their own commits or PRs;
  a cover letter with a reading order for large diffs.
- **Finding**: `V8: unrelated <change> bundled` (P2).
- **Evidence**: "why does adding benchmarks modify the code?"; "submit the infra part as a
  separate PR"; "a lot of refactoring mixed with logic changes, please separate"; "add a
  cover letter, it is massive"; large PRs ship a reading guide naming the one critical line.
- **Support**: 42 reviewed + 113 shipped PRs.

## V9. Acceptance criteria are observable and executable (S)

- **Ask**: What exact test, command, metric, or live check proves this works, and did it
  fail before?
- **Satisfied by**: criteria naming the command and expected value; a test that fails
  without the change; tests that exercise the feature, not just its error path; a live
  measurement against a stated bar; "what to watch after rollout".
- **Finding**: `V9: no acceptance evidence` (P1 for new capability, P2 otherwise);
  `V9: test does not exercise the feature`.
- **Evidence**: "This code has absolutely no tests"; "How is this testing the feature? what
  is this assertion giving us?"; "confirmed the test fails before the change"; a push path
  measured at 100 ms probe granularity passed its sub-second bar with 10x margin; tickets
  list criteria like "unchanged by update; new value on delete and recreate (integration test)".
- **Support**: 19 reviewed + 28 shipped PRs + 3 tickets.

## V10. Correctness beats convenience (S)

- **Ask**: Can this return wrong results silently, drop data, or turn detection off
  without a signal?
- **Satisfied by**: fail-closed where wrong answers cost more than downtime, with the
  choice stated; a metric or log that makes the degraded mode visible.
- **Finding**: `V10: silent wrong result` or `V10: silent disable` (P1).
- **Evidence**: "we are simply allowing the system to return incorrect results"; a
  customer-reported stale-row bug fixed at the planner; a detector's empty-partition hole
  ("detection silently off") fixed with evidence the transport never supplied; "logging an
  error at warn is equal to ignoring it".
- **Support**: 19 reviewed + 115 shipped PRs.

## V11. Ship dark, graduate on evidence (S)

- **Ask**: How does this reach users, and how does it come back if wrong?
- **Satisfied by**: a default-off flag or shadow mode; integration before production;
  mixed-version behavior stated; an escape hatch; compatibility for stored data, URLs, and
  wire formats; irreversible steps named.
- **Finding**: `V11: irreversible rollout without gate` (P1); `V11: breaks existing
  <links|data|clients>` (P1).
- **Evidence**: shadow, then warn, then enforce, with new policies defaulting to shadow and
  only humans able to release; "enabling this adds two boot dependencies"; "it can't be moved
  back down once clusters have run a newer engine"; a renamed URL parameter got a redirect so
  old bookmarks keep their filter; "with this change we no longer support older clusters".
- **Support**: 15 reviewed + 119 shipped PRs.

## V12. Price the cost (A)

- **Ask**: What does this cost to run: requests, CI minutes, GPU versus CPU hours, storage,
  tokens, on-call?
- **Satisfied by**: a cost line in the body, a cheaper equivalent considered, reuse of
  existing jobs and fleets.
- **Finding**: `V12: new recurring cost with no benefit stated` (P1 when material).
- **Evidence**: a PR section titled "What this costs", including that main would go red when
  the shared cluster is unhealthy; single-row inserts cut from 17 to 13 object-store
  requests; a 20-minute CI leg cut after finding 99% cache hits behind it; "is it better to
  run CI on smaller, cheaper GPUs?"; a classifier ported to CPU so it serves without a GPU;
  always-loaded agent context cut from 49k to 28k characters.
- **Support**: 10 reviewed + 78 shipped PRs.

## V13. Operable in the real deployment (A)

- **Ask**: Will this work, and be debuggable, where customers run it?
- **Satisfied by**: configuration that fits the deployment model, metrics that distinguish
  outage from rollout, alerts for environments nobody watched, a setup script, self-healing
  over permanent failure states.
- **Finding**: `V13: <works locally only|undebuggable failure mode>` (P2).
- **Evidence**: "files are very hard to manage in Kubernetes, accept certificate content";
  "a long-running process should self-heal, not fail permanently"; "can you add a script to
  set up the cluster?"; an alert set added because every existing alert was production-only.
- **Support**: 20 reviewed + 109 shipped PRs.

## V14. Mechanism first, policy later; defer, don't reject (A)

- **Ask**: Is the smallest shippable milestone isolated, and are the deferred parts tracked?
- **Satisfied by**: milestones that each ship alone; known gaps filed as tickets, never
  smuggled in or silently dropped; "out of scope" sections.
- **Finding**: `V14: known gap neither fixed nor tracked` (P2).
- **Evidence**: an RFC scoped to the mechanism only ("trigger policy is out of scope by
  design"); milestones named by outcome ("sense and see", "warn", "enforce", "tune"); "ordered
  last because nothing depends on it, pulled forward on demand"; "deliberately not smuggled
  into this PR, tracked separately"; "add scoping back only if an incident shows binary is
  too blunt".
- **Support**: 4 reviewed + 50 shipped PRs + 3 RFCs.

## V15. Ship over paperwork once direction is clear (B)

- **Ask**: Is process delaying a clear, reversible change?
- **Satisfied by**: docs proportional to risk; harmless cleanups deferred to a follow-up;
  drafts kept as drafts until ready.
- **Finding**: none against the author; flag to reviewers when a plan or RFC blocks a
  reversible change.
- **Evidence**: "dropping the plan doc PR, the work is proceeding directly"; "I will clean up
  includes in the next PR, would love to merge this one"; "not prepared for review yet,
  should stay in draft".
- **Support**: 12 shipped PRs.

## V16. Judge automated findings on merit (B)

- **Ask**: Did bot or model review findings get addressed on evidence, and does model-written
  code carry a human owner?
- **Satisfied by**: valid bot findings applied, invalid ones answered with evidence; the
  author states they reviewed generated code.
- **Finding**: `V16: valid automated finding ignored` (P2).
- **Evidence**: "I think the bot is correct here"; "this is all generated, I need to review it
  manually"; skepticism toward reflexive atomics until justified by measured cost.
- **Support**: 12 reviewed PRs.
