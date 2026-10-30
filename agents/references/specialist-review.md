# Specialist review contract

Apply the [two-kind review contract](../../shared/review-contract.md) within the
assigned lens. Keep optional scope/direction advice in `simplification_opportunities`,
separate from defects; summarize deterministic checks without duplicate diagnostics.

Use only for the coordinator's assigned lens and pinned candidate (base, head and
working snapshot). Missing scope/source is `UNAVAILABLE`, not approval. Inspect
actual producers, consumers and evidence; author claims are leads. Compare defects
with the baseline; dirty filenames alone do not establish pre-existing behavior.

Review source read-only. Consume supplied captures, traces and command output;
when fresh execution is needed, name the exact missing proof for the owner or
verifier. Do not install tools, edit source, publish, operate production, start
watchers or invoke another model. Delegate only through the owner's explicit
permission; activation and risk do not grant it. Host tools and consumer policy
own browser access, secrets and safety. Preserve selected model/effort.

Load referenced model-invoked skills only for the assigned surface, per
[dependency loading](../../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
Guidance supplies a lens, not permission to execute its delivery or sibling flows.
Explicit-only skills remain human-invoked. Report overlapping root causes once;
name the primary owner and supporting evidence instead of duplicating findings.

Return one version 1 JSON block per [findings-schema.md](findings-schema.md).
Use your dispatched agent name as `reviewer`; an inline owner uses the gate id,
never claims independent review. Include `testing_gaps` and
`simplification_opportunities`, even when empty. A clean result needs `sufficiency`
tied to inspected sources and proof for this candidate. Include limits explicitly.

Findings need a concrete scenario, source/evidence, reachable consequence and
verification. Grade by impact, not domain. Unproven concerns are evidence gaps,
not invented defects. Introduced P0/P1 or unresolved testing gaps require
`NEEDS_CHANGES`; use `UNAVAILABLE` for an uncompleted applicable review and
`SKIPPED` with a reason only for non-applicability. No approval from absent tools,
a filename match, an unrun command or another reviewer agreeing.
