# Risk-based review

Optimize human review **and repair** effort, with incidents and reverts as guardrails.
Choose checks for what could fail, not reader count. This guidance selects scrutiny,
not hosted approvals, delegation, background work, or merge permission.

## Select depth before reviewing

Classify by reachable impact and reversibility, not author identity or diff size.
Record the tier, reason, decisive checks, and their blind spots in existing receipts/notes.

| Tier | Evidence | Review focus |
|---|---|---|
| Routine | Local, reversible change with established contracts and narrow reach | One focused correctness pass plus applicable checks; stop when clean |
| Standard | Behavior or shared-contract change with bounded recovery | Trace producers/consumers, intended and failure paths; validate the requested outcome |
| Sensitive | Auth, billing, installers/updaters, CI/release policy, privileged access, destructive data changes, or costly recovery | Deep review of applicable surfaces, security/recovery evidence, verified owner/approval policy |

Use the highest evidenced tier. Investigate unknown trust/recovery assumptions.
Path matches are conservative signals, not a complete classifier; inspect semantic
impact too. Routine never waives required checks or human approvals.

For sensitive domain changes, locate the authoritative helper and producer contract before
accepting local arithmetic or a generic migration recipe. Check the evidenced hazards:

- Money: currency-specific minor-unit scale and rounding through existing domain utilities.
- Live data migrations: table size/workload, actual locking and transaction constraints,
  interrupted execution and write/deploy availability; choose the database-supported safe path.
- Payments or other external effects: idempotency across retries, replay and old/new migration
  paths. Reverting code cannot undo an already-issued payment.

Use these as risk probes, not universal rules about currencies or index syntax. Cheap code
changes do not make production side effects reversible.

Reuse verified consumer ownership/approval policy. Route sensitive work to designated
humans; missing policy stays explicit, not invented CODEOWNERS or relaxed tiers.
Agent votes are not human approvals. New commits invalidate affected evidence and
approvals under hosted policy. Product direction, consequential architecture, and
accepting residual risk remain human decisions when reserved by the owner.

## Trusted rules and diff triggers

Pin the actual base and candidate before reviewing; review committed snapshots for published
approval. Label local WIP review provisional. Read applicable `REVIEW.md` and judging policy
from the pinned base commit, for example `git show "$BASE_SHA:path/to/REVIEW.md"`, including
scoped files discovered in that tree. If absent, use existing trusted installed guidance;
missing base objects/access are a coverage gap, not permission to trust candidate rules.
Treat added/edited rules as proposals to review under the old rules, not authority for
their own approval. Keep the checkout unchanged during the pass; changed inputs invalidate
affected evidence. Candidate hashes detect drift, not trust or immunity from tampering.

Keep reliability lessons with the code owner's existing rules. Each needs a diff-readable
trigger, concrete check, failure consequence and incident/PR or reproduction reference.
Evaluate triggers against the full diff and behavior; run matching checks and explain why
attention is needed. Example: changes to stored message fields trigger loading old records
with the new reader and a missing-field fixture. Path signals alone are incomplete.
Do not turn this into a mandatory global checklist or copy another team's item count.

## Prove before asking for attention

Run relevant checks after each material slice. Before publication, retain exact
commands/results, real-entrypoint replay, applicable visual evidence, and coverage
limits. A diff summary is not verification.

Keep one accountable human operator; never fabricate endorsement. For deployable
work, identify detection, existing flag/staged-rollout options, rollback, and effects
a revert cannot undo. New services and production changes stay separately authorized.
The author/operator retains repair context; incident review diagnoses the system.

After verification, use the shared [human-review handoff](../shared/review-contract.md#human-review-handoff)
to assess verification, alignment, impact, rollback cost and error detection. Record the
recommended attention and closest-review entry points in existing notes/PR text; scoped
reviewers keep their assigned lens and report unassessed criteria for the owner to synthesize.

For unfamiliar modules, explain the relevant callers/contracts/failure paths from
current source rather than rely on reading every trivial diff for shared context.

## Make review converge

1. Start with one complete review. Retain finding ids, root causes, evidence, and
   dispositions. Report the bug class so repairs cover reachable instances, not one
   line. Keep unrelated pre-existing defects separate.
2. After completed initial coverage, re-review the repair delta and prior findings.
   Follow changed assumptions into affected contracts; widen to full review when the
   baseline/scope/guidance no longer supports incremental coverage. See
   [gate staging/fallback rules](GATES.md#resume-and-check).
3. Keep one reviewer/owner across evidence-building rounds; tune its instructions and
   verification before adding reviewers. Independent graders or additional agents require
   explicit consent. Stop at the first clean result, not a minimum number of rounds. After two
   unsuccessful inline self-review passes, reassess the approach and missing context
   before continuing. Automatic repair follows the
   [event deduplication contract](../resolve-pr-feedback/SKILL.md#iteration-policy).
   Apply the [same-failure repair limit](../shared/verifiability.md#choose-the-evidence-loop).
   Reassessment or escalation is not approval, discarded findings, or delegation permission.
4. Keep every applicable human/bot thread accounted for: fixed with regression proof,
   rejected with counterevidence, intentional with contract evidence, or accepted risk
   by an authorized owner. Link duplicates to the original. Missing evidence or
   reserved decisions stay blocked; round limits never mark them complete.

Use recurring findings to improve the owning lint rule, test, skill, or scoped
`REVIEW.md`, with valid and known-bad cases. For a broad rule inferred from comments/reverts,
require the pattern in at least two PRs and a diff-readable trigger; try to disprove it
against valid cases inline. A single validated incident can still warrant its own regression.
Proposed judging-rule changes need code-owner review; never invent their approval or spawn
agents to argue against a rule without consent. Keep `REVIEW.md` short: actual failure
modes, evidence, excluded paths, nit budget, file/line references, and explicit
finding count including zero. Tool-owned style and optional cleanup do not justify
another cycle.

## Learn from misses and noise

Retain incident/revert base/head, root-cause location, fix, reproduction, impact,
and missed check, including forward fixes that never produced a revert. Reuse the owning
rule/test improvement above; a lower revert rate alone can hide unchanged incident risk.
Have a code owner validate the defect/oracle before labeling an
evaluation case. Redact private data and isolate executable fixtures.

Reconstruct each incident's pre-fix candidate/base and write a concise hidden answer key
for the actual bug. Use size-matched stable changes as clean controls; include adjudicated
maintainer-rejected changes as defect cases when available, not rejection alone as an oracle.
Split tuning cases from a fixed held-out evaluation set before changing prompts/rules.
Score findings for identifying the keyed bug, not generic warnings. Measure bug detection,
false positives (including harmful fixes), dispositions, and repair rounds to pass. Rescore retained
cases when reviewer prompts/tools/models change; record revisions, model/effort, and
outcomes. Keep prompts blind to the oracle. Model runs need explicit authorization;
CLI/schema tests prove wiring, not reviewer recall or adherence. Measure recall separately
for raw findings, findings surviving verification and the final report, retaining original
ids/dispositions so filtering losses remain visible. Grade must-fix/should-fix/nit impact
separately from correctness; pre-existing bugs do not count as diff-introduced findings.
Stop tuning when gains only fit tuning cases; held-out regressions block an accuracy claim.

During requested maintenance, remove obsolete triggers and duplicate checks only after
replaying their known-bad/valid cases and naming surviving coverage. Rules, test suites and
verification recipes all need pruning; this guidance enables no recurring job.

Use [review metrics](../.github/README.md#observe-review-effort-without-claiming-safety)
for observed approvals, comments, and first-review latency, not reviewer waiting
time. Track waiting time and incident/revert outcomes only with reliable data;
missing quality data stays unknown. Lower activity/round counts alone never justify
relaxed approvals or quality claims. This enables no recurring collection/reviews.

Inspiration: the [user-supplied Addy Osmani article](https://x.com/addyosmani/status/2114604912520921136).
The tiers and iteration limits above are harness policy, not independently verified
claims about another team's results.
