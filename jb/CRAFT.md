# Craft catalog

How a change is shipped, verified, written, and reviewed. RULES.md judges whether a change
earns its time; this file judges whether it is built and landed the way fast,
high-leverage work lands. Cite the rule id. Numbers are targets, not gates.

## Ship -- small, stacked, same day

| Rule | Check |
| --- | --- |
| `merge-within-hours` | A PR is sized to merge the day it opens (median about 3 hours open to merge, three quarters within a day). A PR that needs days of review is a split request. |
| `stack-slices-explicitly` | Large work lands as a chain; each body says `stacked on #N` or `follow-up to #N`, and each slice is useful alone. |
| `fixed-pr-body` | The body has **What / Why / Implementation details / References**, in that order. Why names the caller or failure; References link the ticket, RFC, and prior PRs. |
| `draft-to-learn` | RFCs, proofs of concept, and CI experiments open as draft PRs and close without regret when they lose. A healthy closed-unmerged rate is about 15%, not zero. |
| `reverts-trend-down` | Speed comes with verification: more tests per PR, fewer reverts. A revert is followed by a reland that names the root cause. |
| `bots-first-humans-for-architecture` | Before asking a human: CI green, bot review addressed, a cumulative `Round N summary` posted, outdated threads cleaned up. Humans spend review time on new architecture, not on what a bot or CI can catch. |
| `write-the-lesson-down` | An operational surprise becomes a skill, runbook, or CLAUDE.md edit in the same PR or the next one. |

## Verify -- prove it where the consumer runs it

| Rule | Check |
| --- | --- |
| `revert-test` | Each new test fails when the fix is reverted. A test that still passes guards nothing. |
| `controls-both-ways` | Positive findings carry a negative control and negative findings a positive one; inconclusive is a fail. |
| `real-dependencies` | Storage, broker, and protocol behavior is tested against the real thing (testcontainers, an ephemeral database, a local cluster), not a mock of it. |
| `one-conformance-suite` | Many implementations of one interface (providers, adapters, backends) share one conformance suite that each implementation plugs into. |
| `read-back-after-write` | A write to an external system is read back with the caller's credential, and the PR reports per field what landed. |
| `released-artifact-not-green-ci` | Release claims check the deployed digest against the pinned artifact and application health separately from pod readiness. |
| `measure-claimed-wins` | Performance or cost claims ship with a reproducible benchmark at realistic scale (row counts, query plans, token cost over repeated runs). |

## Code -- what reviewers push on most

Ordered by how often each one decides a review.

| Rule | Check |
| --- | --- |
| `name-says-what-it-is` | Names state the value's role; no `Result.Result`, no vendor-shaped or stale names. Rename in the same PR when a name misleads. |
| `proto-owns-the-contract` | Field behavior, validation, and presence live in proto annotations; update paths use the field mask (`fieldmaskpb.Intersect`, never hand-listed paths); resource names follow the repository's AIP conventions. |
| `layered-config` | Defaults, then config file, then environment overrides (secrets). Local development works with zero setup; production behavior is config on the same binary. |
| `delete-the-extra-step` | Remove an intermediate copy, cache, tag, hash, or wrapper that the next step does not need; read the source of truth directly. |
| `generate-the-third-copy` | The third hand-written copy of a proto-derived layer (SQL, CLI, MCP tools, clients) becomes a generator plus a drift check. |
| `generic-layer-stays-generic` | Provider- or vendor-specific branches live in the provider package, never in shared handlers. |
| `no-silent-substitution` | Never replace what the caller asked for (model, region, identity, value) with a fallback; support it or fail with a structured, actionable error. |
| `question-the-expensive-default` | Serializable isolation, locks, retries, or extra round trips need a named anomaly they prevent here; otherwise use the cheaper option. |
| `lifecycle-you-can-reason-about` | Long-running components expose a blocking `Run(ctx)` that returns on fatal error; no fire-and-forget goroutines, unread unbuffered channels, or `select` with `default` that drops errors; long workflows plan continue-as-new up front. |
| `keep-the-panic-test` | Keep one test for each nil or empty input (nil mask, empty list) that once panicked or could. |

## Review voice

| Rule | Check |
| --- | --- |
| `ask-before-telling` | About half of review comments are questions ("do we need this intermediary step?"). Ask when intent is unclear; state when the defect is certain. |
| `short-and-plain` | Comments are one or two sentences (median about 115 characters), conversational, with the proposed alternative inline. |
| `label-the-nit` | Optional feedback starts with `nit:` and never blocks. |
| `revise-in-public` | When a past decision turns out wrong, say so and point to the better approach. |
