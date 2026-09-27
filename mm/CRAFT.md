# mm craft

How to build a change that passes `/mm` on the first review. Load when planning or
implementing; in review, cite `C<n>` beside the `V<n>` it supports.

## C1. Pick work that compounds

- Prefer work every later change pays for until it is fixed: slow or flaky build and CI
  legs, broken local tooling, silent correctness holes on the data path, and per-request
  cost (object-store calls, GPU time, tokens).
- Fix at the source, even in another repository (SDK error shape, upstream library,
  missing endpoint), and link the pair of PRs.
- Own the platform you ship on: when the toolchain blocks you, fix it in its own PR.

## C2. Ship as a stack of milestones

- One plan step per commit and one outcome per PR; stack PRs and state the merge order
  ("stacked on #N, merge that first").
- Each milestone works alone and is named by outcome: sense, warn, enforce, tune.
- New behavior lands dark: default-off flag or shadow mode, integration before
  production, then a separate small PR flips it on.
- Handle mixed-version rollout in the same PR: say what an old peer answers and how the
  new code degrades.
- Every optimization keeps an escape hatch (session option, fallback implementation, a
  non-positive interval that disables it) so it can be turned off without a rebuild.
- Defer harmless cleanup to the next PR to keep momentum; never defer correctness. File
  known gaps as tickets and list what was not run.

## C3. Test with an oracle, not only with expected values

- Differential first: run the new path against the old implementation, a reference
  library, or a second independent implementation, and assert the new path actually ran
  so a case cannot pass by falling back on both sides.
- Replay real traffic or a production-shaped corpus through old and new; report the diff
  count, not "looks right".
- Pin shared constants with tests (window size equals the SQL bucket; a default mirrored
  in two services; every catalog verb offered exactly once).
- Treat external input as hostile: fuzz parsers, corrupt real fixtures, cap allocations a
  header can request, and ship each defect with its reproducing test.
- Model production-only failures in simulation (clock drift and steps, empty partitions,
  lost messages) instead of waiting for them.
- Prove the test fails before the fix; generate golden data in the test rather than
  committing it; never fix a race by weakening the test.

## C4. Make measurements honest

- State command, dataset, scale, warm or cold, runs, and the bar before measuring.
- Keep the benchmark measuring what it claims: derive literals from the scale so a needle
  query always matches one row, use incompressible padding so the size written is the
  size claimed, and keep load generators off the node under test.
- Live checks report numbers and margin (bar under 1 s, measured about 0.1 s) and, when
  it matters, the odds the result was luck.
- Add the metric that makes the effect observable in production in the same PR.

## C5. Write code that encodes intent

- Types carry meaning: named types for ids, a two-value enum or bool class instead of a
  bare `bool` parameter, a struct instead of adjacent same-typed parameters,
  `std::variant`/tagged unions instead of one config for everything, `optional` instead of
  empty-string or `-1` sentinels. Default an unset proto field to the safe behavior
  (`disable_*` rather than `enabled`).
- Errors are values with structure: result types over exceptions, code plus reason over a
  string, low-cardinality codes on spans and metrics. Validate caller input and return an
  error; assert only true invariants. A warn log is not error handling.
- Reuse before writing: standard library, the existing helper, an upstream fix, then a
  vetted dependency; write custom code only after a measurement shows the gap, and keep
  the old path as a fallback.
- Enforce module boundaries in the build, not by convention; keep private dependencies
  out of public headers.
- Comments state why, invariants, and safety arguments; never restate the code.
- Hot paths get the care; metadata and cold paths get the simplest code.

## C6. Make the PR cheap to review

- Body sections: a two-line plain-language summary; reviewer focus (reading order, the
  hard-to-reverse decisions with the rejected alternative and its measured cost, and the
  single most critical line as a permalink); what was verified with commands; what was not
  run; what to watch after rollout.
- History is part of the product: bisectable commits, refactors before behavior, fixes
  amended into the commit that introduced them, `<area>: <what>` subjects, no fixup or
  merge commits in review. Refer to commits by subject; hashes rot after rebase.
- Adjacent bugs found on the way get their own PRs, linked from this one.
- Close and reopen cleanly when a branch is superseded; keep drafts as drafts.
- Model-written code has a human owner who reviewed it; say so when it matters.

## C7. Review like a principal

- Ask the three-word necessity questions first: "Why do we need this?", "Where is this
  used?", "Is this still relevant?".
- Mark nits as nits and approve with them; block only on correctness, contracts, and
  one-way doors.
- Judge bot findings on merit in one line each; agree when the bot is right.
- Concede reversible disagreements fast ("happy to drop it"); argue only one-way doors.
- Open the full file before claiming something is missing; UI diffs hide files.
