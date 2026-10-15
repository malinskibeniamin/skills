# Progress without moving the target

## Continuation

On handoff/resume, preserve the original objective, requested endpoint, explicit narrower
stops and reserved decisions with their source request. A new explicit delivery instruction
may replace an earlier local stop; summaries, tool errors and intermediate work do not.
Record repository/worktree/branch, local and published HEAD/base, dirty scope, checks and
review/replay receipts, next action and missing prerequisites. Link existing artifacts;
redact state using [verification replay](verification-replay.md).

Re-read git and hosted state before trusting inherited receipts. Match their revision,
fixture and environment; invalidate affected receipts after edits, pushes, rebases or base
movement. Distinguish locally fixed, committed, pushed, reviewed, merged and deployed.
An unchanged HEAD cannot freeze CI/reviews; a dispatched worker is not delivery.

Retain identity and permission boundaries. Missing credentials, owner decisions or
production authority need a self-contained host question or conspicuous blocked receipt,
not another identity, guessed approval or a success claim. Continue safe independent work.

## Repeated attempts

When work plateaus or tool failures repeat, keep a compact untracked attempt ledger:

```md
Objective / accepted behavior / requested endpoint:
Fixed primary metric + feature-fidelity guardrails:
Base / current candidate / environment / fixture:
Best independently verified result + command/artifact:
Failed hypothesis + observed result:
Next falsifiable experiment + discriminating observation:
Receipts invalidated by edit/push/rebase/base or fixture change:
Reserved decision / external prerequisite / notification:
```

If the fixed metric stops improving while code grows, inspect the failed hypothesis and
choose a discriminating experiment through `/diagnosing-bugs`; do not repeat equivalent
patches, enlarge the spec or weaken tests. A new metric requires a new thesis and baseline,
not a relabeled success. Follow `/quantify-impact` for proportional measurement.

Repeated tool failures first need a minimal reproduction and supported-tool/version check.
Repair the owned tooling or use a verified supported path, then resume the original task.
Do not substitute hand-waving for missing output or keep layering speculative workarounds.
Use actual command/tool history to identify friction before building analytics machinery;
counts alone do not prove quality, attribution or causal improvement.

Pause only at a genuine boundary with no safe discriminating action. Persist the checkpoint
and notify the exact decision/prerequisite. Remaining token budget is not a reason to retry
forever; a quiet worker, dispatched session or success paragraph is not delivered work.
