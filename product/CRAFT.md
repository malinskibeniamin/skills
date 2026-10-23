# Craft

How work is chosen, shaped, verified, written, and reviewed so it passes `/product` on the
first read. Load when planning or writing a change; in review, cite a craft id beside the
rule it supports. Numbers are targets, not gates.

## Choose the work

| Craft | Check |
| --- | --- |
| `unblock-before-polish` | Red main, flaky gates, broken onboarding, and slow local loops come before new surface; they tax everyone at once. |
| `pick-compounding-work` | Prefer work every later change pays for: slow CI legs, broken tooling, silent correctness holes, per-request cost. Fix at the source, even in another repository, and link the pair. |
| `three-outcomes` | Every idea gets one: build the smallest slice, park it with a reopen condition, or point at the existing feature that solves it. |
| `time-box-out-loud` | Say where low-value work stops: "beyond this change I will not spend more time; reject it if it is not worth it." |
| `draft-to-learn` | RFCs, proofs of concept, and CI experiments open as drafts and close without regret when they lose. A closed-unmerged rate of zero means nothing risky was tried. |

## Shape the change

| Size (changed lines) | Target time to merge | Typical content |
| ---: | ---: | --- |
| under 50 | about 1 hour | fix, config, copy, dependency bump |
| 50-200 | a few hours | one behavior with its test |
| 200-800 | same day | a feature slice behind a default-off switch |
| over 800 | a planned series | scaffold, generated code, or step n of N |

| Craft | Check |
| --- | --- |
| `merge-within-hours` | Size the PR to merge the day it opens. A PR that needs days of review is a split request. |
| `numbered-series` | Large work is "PR n of N": each step lands on main default off or with zero behavior change, with Deferred and Up next notes. Use `stacked on #N` only when a step cannot land alone, and state the merge order. |
| `phase-shape-then-semantics` | Land large API or data changes in labelled phases: shape first, semantics next, legacy fields kept until no consumer reads them. |
| `split-by-blast-radius` | Anything global (retry policy, shared layout, auth) ships alone; adjacent bugs found on the way get their own PRs, linked from this one. |
| `mixed-version-in-the-same-pr` | Say what an old peer answers and how the new code degrades during rollout. |
| `keep-an-escape-hatch` | Every optimization can be turned off without a rebuild: an option, a fallback implementation, or a disabling value. |
| `defer-cleanup-not-correctness` | Harmless cleanup moves to the next PR to keep momentum; correctness never does. |

## Write the PR body

Answer the reviewer before they ask. When `/commit-push-pr` owns the template, map these
answers into its sections.

```md
## Why
<who hits this today, what it costs them, and the trigger>

## What
<the change in 1-3 bullets; the shape if bullets hide it>

## Verification
<what ran, where (unit, e2e, named integration environment, live), and what was observed>
<command or real-entrypoint replay; failing on base, passing here; numbers when measured>

## Rollout
<per environment; default state; rollback in one line>

## Worth reviewing
- Riskiest hunk: <file or hunk to push back on, and the assumption behind it>

## Not fixed here
- <adjacent problem found and deliberately left, with where it goes next>
```

History is part of the product: bisectable commits, refactors before behavior, fixes
squashed into the commit that introduced them, no fixup commits in review.
Commit and PR titles state the guarantee after the change, not only the activity.

## Test and verify

| Craft | Check |
| --- | --- |
| `tests-grow-with-code` | Behavior changes ship tests in the same PR; roughly one test line per production line is a target, not a gate. Substantive code without tests states why (generated, pure move, config only). |
| `test-refusal-and-no-op-paths` | Test what must not happen: rejection, empty input, idle runs, and errors that keep the last good state. Name tests as behavior sentences, such as "idle tick writes nothing". |
| `reproduce-first` | Shrink the trigger until it runs in milliseconds; show the check failing on the base branch and passing on the change. |
| `revert-test` | Each new test fails when the fix is reverted. A test that still passes guards nothing. |
| `oracle-over-expected-values` | Run the new path against the old implementation, a reference, or a second implementation, and assert the new path actually ran. Replay production-shaped data and report the diff count. |
| `controls-both-ways` | Positive findings carry a negative control and negative findings a positive one; inconclusive is a fail. |
| `real-dependencies` | Test storage, broker, and protocol behavior against the real thing (containers, an ephemeral database, a local cluster). Many implementations of one interface share one conformance suite. |
| `read-back-after-write` | Read a write to an external system back with the caller's credential and report per field what landed. |
| `released-artifact-not-green-ci` | Release claims check the deployed artifact against the pinned one, and application health separately from pod readiness. |
| `honest-measurement` | State command, dataset, scale, warm or cold, runs, and the bar before measuring; keep load generators off the node under test; report the margin. Add the production metric in the same PR. |
| `hostile-input` | Fuzz parsers, corrupt real fixtures, cap allocations a header can request, and model clock drift, empty partitions, and lost messages in simulation. |

Flake protocol: compute the gate's flake rate from recent runs; rerun per test so the
report names the flaky one; fix the root cause or remove the assertion and say why; revert
a fix that does not move the rate; watch the gate for a week after merge.

## Write code that encodes intent

| Craft | Check |
| --- | --- |
| `name-says-what-it-is` | Names state the value's role; no stale or vendor-shaped names. Rename in the same PR when a name misleads. |
| `types-carry-meaning` | Named types for ids, an enum over a bare boolean parameter, a struct over adjacent same-typed parameters, optional over empty-string or `-1` sentinels; an unset field defaults to the safe behavior. |
| `errors-are-values` | Structured code and reason, built once at the service edge and only as granular as the caller can act on; validate input and return an error, assert only true invariants. A warn log is not error handling. |
| `contract-in-the-schema` | Field behavior, validation, and presence live in the schema; update paths use field masks, never hand-listed paths; resource names follow repository conventions. |
| `layered-config` | Defaults, then config file, then environment overrides for secrets. Local development works with zero setup; production behavior is config on the same binary. |
| `generic-layer-stays-generic` | Provider- or vendor-specific branches live in the provider package, never in shared handlers. |
| `delete-the-extra-step` | Remove an intermediate copy, cache, tag, or wrapper the next step does not need; read the source of truth directly. |
| `question-the-expensive-default` | Serializable isolation, locks, retries, or extra round trips name the anomaly they prevent here; otherwise use the cheaper option. |
| `lifecycle-you-can-reason-about` | Long-running components expose a blocking run that returns on fatal error; no fire-and-forget work or dropped errors; retries and waits are bounded. |
| `readable-conditions` | No double negatives; complex conditions split into named variables; comments explain the non-obvious invariant, trade-off, or deliberate omission, with a ticket or RFC for rationale when relevant; delete comments that restate the code. |
| `debuggable-over-clever` | Formats, config, and logs a tired on-call can read: printable effective config and one log line at each decision. Hot paths get the care; cold paths get the simplest code. |

## Review voice

| Craft | Check |
| --- | --- |
| `necessity-first` | Ask the short questions first: "Why do we need this?", "Where is this used?", "Is this still relevant?" |
| `ask-before-telling` | Ask when intent is unclear; state when the defect is certain. Use suggestion blocks so the fix is one click. |
| `short-and-plain` | One or two conversational sentences with the alternative inline. Optional feedback starts with `nit:` and never blocks. |
| `concede-reversible` | Drop reversible disagreements fast; argue only one-way doors. Open the full file before claiming something is missing. |
| `bots-first-humans-for-architecture` | Before asking a human: CI green, bot findings addressed, a round summary posted. Humans spend review time on architecture. |
| `itemize-replies` | Reply to every finding on your own PR: fixed with the commit, or declined with the reason. Say so when a past decision turns out wrong. |

## Work with AI

- Read every generated diff before it becomes a PR; close unreviewed agent PRs.
- Trim generated code and comments until a human can read and own them; explain or remove
  long, unclear comments.
- Ask the model to argue against the change, then act on the answer, including closing it.
- Keep agent context lean: keep a line only if removing it would cause a mistake.
- Question conventions the model invented before following them.
- Turn an operational surprise into a skill, runbook, or agent-instructions edit in the
  same PR or the next one.
