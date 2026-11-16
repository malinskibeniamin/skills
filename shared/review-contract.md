# Two kinds of review

Use at review entrypoints, including self-review and scoped gates. Keep the assigned lens,
output schema, pinned candidate and authorization. This contract adds no agents, services,
approval requirements or merge permission.

## Objective: does it work?

Start with the working hypothesis **this change is wrong**. Try to falsify its claims,
not confirm the author's story. This chooses investigative effort, not the verdict:
accept counterevidence, report only supported defects, and stop at a justified clean pass.

Apply [verifiability over readability](verifiability.md): inspect independently
rerunnable contract evidence, domain-language alignment and human spot-check access.
Size, nesting and cyclomatic complexity alone are not defects; measured performance
can justify less readable internals without weakening correctness proof.

Inspect the complete assigned diff and affected contracts. Find bugs, security failures,
credible edge cases and unmet explicit requirements. Report a defect only with a concrete
execution path or reproduction, consequence and smallest correction. Uncertain suspicions
belong in residual evidence limits, not speculative findings. A clean pass is valid.

Run the repository's deterministic lint, formatting and type checks separately; summarize
their results without generating duplicate inline findings or restating their rule catalogs.
Review the correctness of changed checks and what green checks cannot establish.

### Required falsification evidence

Every completed review, including self-review and every applicable gate, records
`challenges` in the [versioned receipt](../agents/references/findings-schema.md).
Select concrete counterexamples from changed assumptions and reachable failure paths;
cover materially distinct risks in the assigned lens rather than filling a quota.
For each, record the scenario, expected behavior, exact check, actual observation and:

- `confirmed`: the defect hypothesis held; link its finding ids and retain reproduction.
- `refuted`: observed counterevidence defeated the hypothesis; a clean review is valid.
- `unresolved`: proof is missing; keep `NEEDS_CHANGES`, not an invented bug or approval.

Execute safe, runnable checks at the real interface. Source traces name decisive locations
and why execution was unavailable or inapplicable; planned commands and reviewer agreement
are not observations. Preserve execution/sandbox limits and the pinned candidate.
Review-only stays read-only. In an authorized fix endpoint, reproduce confirmed defects,
add a failing regression, repair the root cause, and replay the counterexample; a changed
candidate needs fresh review, not deletion or refutation of its earlier true finding.

The hook and gate collector reject completed reports without this evidence. Inline
owners without a matching hook validate the same receipt using the installed
`scripts/review-results.ts` CLI before reporting completion; use `self-reviewer` for
ungated inline review. See [receipt validation](../review/REFERENCE.md#receipt-validation).
Shape validation cannot prove that a check ran or an observation is true. Carry actual
command output/source proof, disclose limits, and retain the existing retry budget.

## Subjective: is it the right change?

Start with the requested outcome, file list and approach:

- **Scope:** did the change touch only what the outcome needs? Account for generated,
  lockfile and verification changes; challenge unrequested behavior or adjacent projects.
- **Direction:** does this fit the system and earn its complexity? Compare existing platform,
  shared helpers and packages with a local implementation; neither reuse nor hand-rolling
  wins automatically. Name the trade-off, not a preferred rewrite.

Keep this assessment brief and separate from defect findings. A violated explicit requirement
or applicable written rule needs its source and evidence; an unwritten preference is advice,
not a defect or automatic repair. The agent can advise; the human owner decides whether the
change should exist. Never present an automated judgment as human endorsement. The skim
does not replace objective inspection; a scoped gate does not take over sibling lenses.

## Consequences choose scrutiny

After self-review and verification, prepare the human-review handoff below against the
complete current diff and requested outcome. Assess consequences, not diff size or agent
confidence. Reuse existing receipts/PR text; this adds no report file or receipt-schema fields.

### Human-review handoff

Assess all five criteria. Cite decisive evidence or state the gap; mark a criterion
inapplicable only with a reason. A green test suite does not settle the other four.

| Criterion | Evidence the human needs |
|---|---|
| **Verification** | Changed contracts covered by tests, exact commands/results, and remaining gaps. For runnable user flows, link applicable real end-to-end computer-use artifacts (captures, recordings or replay receipts) with scenario/revision; follow [proportionate verification](verifiability.md#proportionate-verification). Distinguish automated tests from observed use; unavailable execution/media is a limit, not proof. |
| **Alignment** | Compare the full diff with the issue, PR description and explicit requirements. Explain material deviations and account for generated/mechanical changes; remove unrelated drive-by fixes from author work or flag them in read-only review. A matching PR description alone does not prove alignment with the original request. |
| **Impact** | Name affected users, callers, shared contracts and reachable failure paths, especially auth, permissions, billing and data integrity. Give the risky file/symbol entry points. Resolve sensitive-path code owners using existing repository policy and [review routing](../commit-push-pr/references/metadata.md#codeowners-review-routing); authorized PR delivery requests the verified reviewers, while read-only review only recommends them. Expose missing owners/access and draft-deferred requests. |
| **Rollback cost** | Classify a **two-way door** (cheaply reversible) or **one-way door** (destructive or costly to reverse). Give the actual rollback/forward-recovery procedure, prerequisites and irreversible effects; distinguish inspected plans from tested recovery. A code revert cannot restore deleted data or undo external charges. |
| **Error detection** | Trace a credible production failure from the changed path to its signal: swallowed, surfaced to the caller, logged, or reported to error monitoring. Name the existing alert/dashboard/query and responder or authorized agent route when present, and what is unverified. Prefer actionable monitored reporting over logs alone; swallowed errors or unobserved alerts are visibility gaps. For non-deployable changes, explain the applicable consumer/CI feedback instead. |

Conclude with the recommended human attention and **where to start**: bounded reversible
work can use a scope/direction spot-check; sensitive boundaries, weak verification, costly
recovery or poor detection warrant targeted line review by the appropriate owner. Name
the paths, unresolved questions and evidence that would change that recommendation.
Do not average away a serious risk with stronger criteria or label unknown impact low risk.

Keep test status, material risks, rollback and detection gaps visible in the compact PR
body; link/collapse detailed evidence. Five assessments do not require five headings, a
numeric score or extra reviewer rounds. Reassess affected criteria after scope/head/base
changes. This rubric recommends scrutiny, not approval or production readiness.

Use existing observability and incident routes. Adding Sentry, alert webhooks, credentials,
production probes or agent-triggered remediation needs separate authorization; an alert
relay is investigation input, not permission to change production or expose private data.

Preserve the consumer's human-approval policy, including explicit owner opt-outs. Never
invent reviewer counts, weaken protections, fabricate human sign-off, or turn a recommendation
into a new delivery gate. Review is non-deterministic: agreement or extra rounds cannot prove
correctness. Reuse evidence and finding dispositions; follow the owning workflow's retry
budget rather than restarting reviews to seek certainty.

## Write repeated taste down

When the same taste decision recurs, propose the smallest reusable rule and its exception.
Prefer an existing deterministic lint rule when enforceable; otherwise use the owning
`AGENTS.md` or skill. Rule changes need authoring intent, rationale, and known-bad/valid
verification; a read-only review proposes them without editing. Once adopted, cite the rule
when reporting a violation. Do not copy personal preferences into universal policy.
