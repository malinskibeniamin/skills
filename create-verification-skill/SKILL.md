---
name: create-verification-skill
description: Create a project-local skill that launches, drives, observes, and cleans up the real app. Use when a repository lacks a repeatable way to prove UI, CLI, API, or service behavior.
---

Read [Poteto](../shared/POTETO-NATIVE.md#verification).

Reuse an existing verifier. T3 Code: load
[web/desktop](../t3code-skills/test-t3-app/SKILL.md) or
[mobile](../t3code-skills/test-t3-mobile/SKILL.md) per affected surface;
the adapters own native rules.

Uncovered flows: canonical skill root, else
`.agents/skills/verify-<app>/`. Never mirror host roots or duplicate covered flows.

## Interview the repository

- **Surface:** primary and secondary UI, CLI, API, mobile, desktop, or library entrypoints.
- **Launch:** repo command, readiness, ports, env, seed data and auth.
- **Drive:** existing Playwright, PTY, HTTP, debug, or app harness before generic tools.
- **Observe:** screenshots, a11y snapshots, transcripts, responses, logs, exits and durable effects.
- **Isolate:** per-run ports/profiles/data/fixtures. Never drive a human instance.

Report setup gaps.

For agent-DX/worktree setup: [capability-gap and cold-start checks](references/agent-dx.md).

## Generate

Use `name: verify-<app>`: **Launch**, **Doctor**, **Drive**, **Evidence**, **Cleanup**.

- **Launch:** start/teardown commands reaching a usable app from empty data, including migrations and seed data. A listening port or healthy database alone is not readiness.
- **Doctor:** one read-only check for app identity, build, process or port ownership, data isolation, and auth.
- **Drive:** repo commands and stable handles. Prefer roles, accessible names, routes, prompt strings, and public APIs over coordinates or internals.
- **Evidence:** assert the expected outcome; capture action and result. Verify side effects through a second public view; mock only existing production boundaries.
- **Cleanup:** stop only processes and scratch state this run created. Never kill by process name. Evidence survives cleanup.

Make and document executable helpers. For stateful bugs/recurring repro gaps, prove [capture/replay](../shared/verification-replay.md) via native fixture/debug APIs.

## Seed the feature map

Create `features/README.md` and 3-5 feature files. Ground [the example](references/feature-map-example/README.md) in repo evidence. Each owns:

1. `Sub-features`
2. `How to get to it (user POV)`
3. `Driving it with <harness>`
4. `Gotchas`

Pair actions with expected results; code owners refine the rubric against defects and valid controls.

Map every entrypoint. Missing seed-data prerequisites fail the journey: record in `Gotchas`, never weaken it.

## Prove the generated skill

Execute generated skill: launch, doctor, one mapped real journey, evidence and cleanup. Keep evidence; clean up failed attempts, fix and replay. Unexecuted verifiers are drafts.

Time cold starts/journeys; keep diagnostics. Repeat clean-state runs; fix slow/flaky steps before adding concurrency.

List stand-in gaps as unverified until target replay.

### Prove the check can fail

[Replay the decisive assertion against a known failure](references/proof-loop.md).

Drift: `/maintain-verification-skill`. Feature work: `/dogfood`.
