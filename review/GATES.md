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

```sh
bun --no-install <harness-root>/scripts/review-gates.ts check
```

Exit codes: `0` passed, `1` incomplete, `2` blocked/error, `3` stale. Every configured gate
has a row, including explicit skips and not-run gates. Results are per-gate, atomically
written under a candidate-specific run directory. Concurrent writers to the same gate
fail rather than steal the lock. A failed recording remains an error until repaired.

Replanning unchanged inputs reuses completed results. Changed input creates a new run;
old findings are supplied as context, never recycled as current approval. Re-review
affected behavior using the full staged diff and confirm prior findings. This first
version deliberately invalidates changed candidates conservatively rather than infer
that an unchanged path proves an unaffected domain. Different round counts are not, by
themselves, evidence of stale review.

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
