# Review gates

Use for an explicitly requested gate review, a consumer with `.review-gates.json`, or
an existing gate plan being refreshed for delivery. Ordinary reviews can remain inline.
Source stays read-only during review; local evidence goes under ignored `.context/`.
Ensure the consumer ignores that scratch directory through its normal repository setup;
do not hide unrelated uncommitted work or change ignore policy during a read-only review.

One owner follows **plan -> review -> record -> check -> publish within the endpoint**.
The CLI prepares prompts and verifies receipts. It does not call models, dispatch agents,
run tests, grant approval, change repository protection, or merge.

## Plan the current candidate

From the consuming checkout, resolve the harness root from the loaded skill path and
the actual PR base with `scripts/resolve-pr-base.sh`. Use the installed scripts directly:

```sh
bun --no-install <harness-root>/scripts/review-gates.ts plan --base <actual-base-ref>
```

The returned plan names its gates, lenses, routing reasons and prompt files. It stages the full
diff once, including working changes, untracked files, lockfiles, generated output,
binary changes and deletions. Hashes bind results to checkout, branch, head, base,
working contents, gate definitions, referenced guidance and staged review inputs.
The JSON response contains metadata, not another copy of the diff.

Every shared and consumer gate prompt lists the [two-kind review contract](../shared/review-contract.md)
alongside its own guidance. Its contents participate in the rubric hash: a changed contract
invalidates existing receipts. Keep scope/direction advice separate from defect findings;
the contract changes neither the gate's assigned lens nor the consumer's approval policy.

For semantic applicability, inspect **every** discovered gate's lens against the complete
diff. Save an array of `{ "gate": "<id>", "relevant": false, "reason": "<concrete reason>" }`
records to an ignored file, then pass `--classifications <file>` when planning. Positive
verdicts use `true`. A gate runs when required, when a path matches, when semantically
relevant, or when a prior finding/error still needs confirmation. Skip only when both
signals exclude it with a reason. Missing verdicts conservatively require review.
The owner can classify inline; planning never silently invokes a cheaper model.

## Review and record

Use existing skills through each staged prompt, scoped to that gate's lens. Name the
inspected sources and verification. A clean result needs a `sufficiency` explanation of
why the evidence covers this change; related artifacts alone do not establish coverage.
The default result's `reviewer` is the gate id; use the shared
[findings contract](../agents/references/findings-schema.md).

```sh
bun --no-install <harness-root>/scripts/review-gates.ts record \
  --gate correctness --executor owner --mode inline --model <actual-model-id> \
  --input <result.json>
```

Existing native reviewer agents keep their dispatched identity. To bind their validated
output to a gate, also supply `--reviewer code-reviewer` (or the actual dispatched type).
The gate responsibility and reviewer identity are separate; never rewrite the worker's
identity to pretend it was another agent.

An explicitly authorized multi-agent review can assign one read-only specialist per
applicable gate through the current host's native controls. Record `--mode agent` and
its actual executor/model, not `inline` work relabeled independent. Keep synthesis with
the owner. Preserve the selected model policy, tools, requested endpoint and foreground
execution; these instructions never authorize delegation or nested model calls.
Unknown model provenance is displayed as `not recorded`, not guessed.

Use version 1 of the existing reviewer contract, including scenario, evidence and
verification for findings. P0/P1 findings, critical checks and unresolved testing gaps
require `NEEDS_CHANGES`; contradictory approval labels are rejected. Non-blocking findings remain visible. Collection validates the full
contract; it does not verify that a model's claims are true. An applicable gate cannot
be satisfied by `SKIPPED`, a missing result, `UNAVAILABLE`, `FAILED`, an error, or an approval label alone.

## Challenge findings without losing the claim

When independent review was authorized and actually performed, batch one gate's disputed
findings into a verification result:

```json
{
  "verdicts": [
    {
      "finding_id": "<existing-finding-id>",
      "refuted": true,
      "reason": "<why the claim is incorrect>",
      "evidence": "<source location or reproduction that disproves it>"
    }
  ]
}
```

```sh
bun --no-install <harness-root>/scripts/review-gates.ts verify \
  --gate correctness --executor <distinct-reviewer> --mode agent \
  --model <actual-model-id> --input <verification.json>
```

A missing verdict retains its finding. A non-boolean verdict, unknown/duplicate id,
missing reason/evidence, or self-refutation fails visibly. Original findings and the
verification exchange remain stored. Distinct executor labels do not prove different
model families: disclose same-model/family fallback, and do not claim unavailable
independent coverage. A fixed issue needs a new review of the changed candidate; it is
not a false positive to erase with `verify`.

## Resume and check

[Immediate-only context](../docs/architecture/review-delta-before.png) ->
[findings retained through intermediate plans](../docs/architecture/review-delta-after.png).
Editable scenes: [before](../docs/architecture/review-delta-before.excalidraw),
[after](../docs/architecture/review-delta-after.excalidraw).
The comparison describes input selection, not measured reviewer accuracy or speed.

```sh
bun --no-install <harness-root>/scripts/review-gates.ts check
```

Exit codes: `0` passed, `1` incomplete, `2` blocked/error, `3` stale. Every configured gate
has a row, including explicit skips and not-run gates. Results are per-gate, atomically
written under a candidate-specific run directory. Concurrent writers to the same gate
fail rather than steal the lock. A failed recording remains an error until repaired.

Replanning unchanged inputs reuses completed results. Changed input creates a new run;
old findings and verification exchanges supply context, never current approval.
Every applicable gate needs a fresh result; an unchanged path does not prove an
unaffected domain. Different round counts alone are not evidence of stale review.

New runs include their predecessor identity, so returning to earlier file contents
does not overwrite historical prompts or silently reuse an older approval.
Unreviewed intermediate plans retain earlier findings; without completed coverage
on the immediate predecessor, that gate receives full review rather than a shorter delta.

After a completed review, routine gates with `rereview: "delta"` focus on `repair.diff`
and prior findings. The captured delta includes staged, unstaged, untracked, binary and
deleted files since that review, even before either candidate was committed. The full
`change.diff` remains available for callers, contracts and root-cause investigation.
Both inputs are integrity-checked; planning leaves the caller's files and index alone.
Report the class and affected instances, preserve finding ids, and expand context when
a claim needs it instead of rediscovering unrelated old defects.

Security/recovery, protobuf, contracts/architecture, dependencies/licenses and operations gates
keep full review. New consumer gates default to full; `rereview: "delta"` is an explicit
local review-scope choice, not a human approval tier. Unreviewed, failed or unavailable
gates stay full. Changed base, branch, rubric, or non-descendant HEAD also resets to full.
Reconstructing an unavailable/corrupt candidate fails visibly rather than inventing a delta.
The CLI does not run reviewers; automatic-repair round limits remain owned by
[feedback resolution](../resolve-pr-feedback/SKILL.md#iteration-policy).

[Review-scope routing](../docs/architecture/review-repair.png)
([editable source](../docs/architecture/review-repair.excalidraw)) compares the previous
full-diff path with captured repair input. Source: `createPlan` in
`scripts/review-gates.ts`; public CLI coverage: `scripts/review-gates.test.ts`.

Apply the [convergence rules](OPERATING-MODEL.md#make-review-converge); the CLI
neither runs review rounds nor certifies reviewer accuracy.

Corrupt artifacts fail closed. Keep them for diagnosis; restore the latest pointer from
the immutable run's `plan.json` if needed. Never remove findings or a configured gate to
make a check pass. A local receipt is sampled evidence, not a tamper-proof security gate.

## PR reporting and readiness

```sh
bun --no-install <harness-root>/scripts/review-gates.ts render
bun --no-install <harness-root>/scripts/review-gates.ts update \
  --body <current-pr-body.md> --out <updated-pr-body.md>
```

`render` produces the same state used by `check`, even when pending or stale; its exit
status is not readiness. `update` replaces only the `harness-review` marker block,
preserves human content and refuses ambiguous markers. Both commands are local-only.
During authorized PR publication/update, fetch the current body, update its file, publish
with `gh pr edit --body-file`, and read back the block and candidate. Re-fetch before
retrying an uncertain write. Do not overwrite concurrent human edits with an old body.
Refresh the block after changes; a table does not substitute for `check`.

`full-send-check.ts` automatically checks an existing default plan or a consumer opted in
with `.review-gates.json`; `--review-plan <file>` selects an explicit plan. Missing,
blocked, stale or mismatched review evidence cannot pass readiness. Without opt-in or a
plan it reports `not-configured`, not semantic review. Native checks, approvals and
protections remain separate requirements. PR-only still stops after its one CI snapshot.

## Consumer-specific gates

An explicit consumer opt-in with only shared defaults is:

```json
{ "version": 1, "gates": [] }
```

Add local gates to that array. Each has `id`, `title`, `always`, `globs`, `skills` and
`lens`, following [the shared catalogue](../config/review-gates.json). Local `skills`
paths point to existing guidance relative to the consuming Git root. Use repository-root
globs, including component prefixes in monorepos. Unique ids make additions additive;
collisions fail rather than silently replace a shared gate. Put domain knowledge in its
existing skill/reference, not another duplicated rubric tree.

Shared security path signals include auth/billing directories, installers/updaters,
CI workflows and release paths. They prevent a negative semantic verdict from skipping
that gate; they neither find every sensitive flow nor impose human-approval tiers.
