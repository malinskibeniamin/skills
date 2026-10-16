---
name: create-verification-skill
description: Create a project-local skill that launches, drives, observes, and cleans up the real app. Use when a repository lacks a repeatable way to prove UI, CLI, API, or service behavior.
---

# Create a verification skill

Write one cold-start verifier in the repository's canonical skill root, otherwise `.agents/skills/verify-<app>/`. Never mirror it into host-specific roots.

## Interview the repository

Discover before asking:

- **Surface:** primary and secondary UI, CLI, API, mobile, desktop, or library entrypoints.
- **Launch:** repository-native command, readiness signal, ports, environment, seed data, and authentication.
- **Drive:** existing Playwright, PTY, HTTP, debug, or app harness before generic tools.
- **Observe:** screenshots, accessibility snapshots, transcripts, responses, logs, exit codes, and durable side effects.
- **Isolate:** per-run ports, profiles, data, fixtures. Never drive a shared human instance.

If the checkout cannot run, report its failing prerequisite, not invented launch instructions.

For agent-DX or worktree setup requests, use [the capability-gap and cold-start checks](references/agent-dx.md).

## Generate

Write matching `name: verify-<app>` frontmatter and concrete **Launch**, **Doctor**, **Drive**, **Evidence**, **Cleanup** sections:

- **Launch:** exact start and teardown commands that reach a usable app from empty data, including migrations and seed data. A listening port or healthy database alone is not readiness.
- **Doctor:** one read-only check for app identity, build, process or port ownership, data isolation, and auth.
- **Drive:** literal commands and stable handles from this repository. Prefer roles, accessible names, routes, prompt strings, and public APIs over coordinates or internals.
- **Evidence:** capture action and result. Verify side effects through a second public view; mock only existing production boundaries.
- **Cleanup:** stop only processes and scratch state this run created. Never kill by process name. Evidence survives cleanup.

Make helpers executable; document use. For stateful bugs or recurring repro gaps, prove [capture/replay](../shared/verification-replay.md) via native fixture/debug APIs.

## Seed the feature map

Create `features/README.md` and files for the top 3-5 user-facing features. Ground [the feature-map example](references/feature-map-example/README.md) in repository evidence. Each file owns:

1. `Sub-features`
2. `How to get to it (user POV)`
3. `Driving it with <harness>`
4. `Gotchas`

Map every entrypoint. Missing seed-data prerequisites fail the journey: record them in `Gotchas`, never weaken the journey.

## Prove the generated skill

Execute generated skill: launch, doctor, one mapped real user journey, evidence and cleanup. Confirm evidence survives and no created process/state remains. Clean failed attempts, fix instructions and replay. Unexecuted verifiers are drafts.

List stand-in setup gaps; leave them unverified until replayed on the target.

Route drift audits to `/maintain-verification-skill` and feature work to `/dogfood`.
