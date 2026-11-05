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

Assess reachable impact, sensitive boundaries, reversibility and recovery evidence, not
diff size alone. For costly or hard-to-reverse failures, recommend targeted human line review
of the risky paths and name remaining uncertainty. For bounded reversible changes, retain
the scope/direction skim alongside objective evidence. Unknown impact needs investigation,
not a low-risk label. Record the consequence and recommended scrutiny in the receipt.

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
