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

Reuse verified consumer ownership/approval policy. Route sensitive work to designated
humans; missing policy stays explicit, not invented CODEOWNERS or relaxed tiers.
Agent votes are not human approvals. New commits invalidate affected evidence and
approvals under hosted policy. Product direction, consequential architecture, and
accepting residual risk remain human decisions when reserved by the owner.

## Prove before asking for attention

Run relevant checks after each material slice. Before publication, retain exact
commands/results, real-entrypoint replay, applicable visual evidence, and coverage
limits. A diff summary is not verification.

Keep one accountable human operator; never fabricate endorsement. For deployable
work, identify detection, existing flag/staged-rollout options, rollback, and effects
a revert cannot undo. New services and production changes stay separately authorized.
The author/operator retains repair context; incident review diagnoses the system.

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
3. Stop at the first clean result, not a minimum number of rounds. After two
   unsuccessful inline self-review passes, reassess the approach and missing context
   before continuing. Automatic repair retains its
   [three-round pause/retry contract](../resolve-pr-feedback/SKILL.md#iteration-policy).
   Reassessment is not approval, discarded findings, or delegation permission.
4. Keep every applicable human/bot thread accounted for: fixed with regression proof,
   rejected with counterevidence, intentional with contract evidence, or accepted risk
   by an authorized owner. Link duplicates to the original. Missing evidence or
   reserved decisions stay blocked; round limits never mark them complete.

Use recurring findings to improve the owning lint rule, test, skill, or scoped
`REVIEW.md`, with valid and known-bad cases. Keep `REVIEW.md` short: actual failure
modes, evidence, excluded paths, nit budget, file/line references, and explicit
finding count including zero. Tool-owned style and optional cleanup do not justify
another cycle.

## Learn from misses and noise

Retain incident/revert base/head, root-cause location, fix, reproduction, impact,
and missed check. Have a code owner validate the defect/oracle before labeling an
evaluation case. Redact private data and isolate executable fixtures.

Pair validated cases with clean controls. Measure bug detection, false positives
(including harmful fixes), dispositions, and repair rounds to pass. Rescore retained
cases when reviewer prompts/tools/models change; record revisions, model/effort, and
outcomes. Keep prompts blind to the oracle. Model runs need explicit authorization;
CLI/schema tests prove wiring, not reviewer recall or adherence.

Use [review metrics](../.github/README.md#observe-review-effort-without-claiming-safety)
for observed approvals, comments, and first-review latency, not reviewer waiting
time. Track waiting time and incident/revert outcomes only with reliable data;
missing quality data stays unknown. Lower activity/round counts alone never justify
relaxed approvals or quality claims. This enables no recurring collection/reviews.

Inspiration: the [user-supplied Addy Osmani article](https://x.com/addyosmani/status/2114604912520921136).
The tiers and iteration limits above are harness policy, not independently verified
claims about another team's results.
