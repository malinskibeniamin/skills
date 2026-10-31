---
description: "Create a project-local skill that launches, drives, observes, and cleans up the real app. Use when a repository lacks a repeatable way to prove UI, CLI, API, or service behavior."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["create verification skill"]}
sidebar: {"label":"/create-verification-skill"}
title: "/create-verification-skill"
type: "skill"
---
![Diagram of the /create-verification-skill skill](/diagrams/skills/create-verification-skill.svg)

[Open the editable Excalidraw source](/diagrams/skills/create-verification-skill.excalidraw)


For behavior/verifier checks, read [Poteto](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-NATIVE.md#verification).

Reuse any existing verifier. T3 Code: load
[web/desktop](https://github.com/malinskibeniamin/skills/blob/v4.42.0/t3code-skills/test-t3-app/SKILL.md) or
[mobile](https://github.com/malinskibeniamin/skills/blob/v4.42.0/t3code-skills/test-t3-mobile/SKILL.md) per affected surface;
their adapters own native rules.

For uncovered flows, use the canonical skill root, else
`.agents/skills/verify-<app>/`. Never mirror host roots or duplicate covered flows.

## Interview the repository

Discover before asking:

- **Surface:** primary and secondary UI, CLI, API, mobile, desktop, or library entrypoints.
- **Launch:** repository-native command, readiness signal, ports, environment, seed data, and authentication.
- **Drive:** existing Playwright, PTY, HTTP, debug, or app harness before generic tools.
- **Observe:** screenshots, accessibility snapshots, transcripts, responses, logs, exit codes, and durable side effects.
- **Isolate:** per-run ports, profiles, data, fixtures. Never drive a shared human instance.

Report failed launch prerequisites; never invent instructions.

For agent-DX or worktree setup requests, use [the capability-gap and cold-start checks](https://github.com/malinskibeniamin/skills/blob/v4.42.0/create-verification-skill/references/agent-dx.md).

## Generate

Write matching `name: verify-<app>` frontmatter and concrete **Launch**, **Doctor**, **Drive**, **Evidence**, **Cleanup** sections:

- **Launch:** exact start and teardown commands that reach a usable app from empty data, including migrations and seed data. A listening port or healthy database alone is not readiness.
- **Doctor:** one read-only check for app identity, build, process or port ownership, data isolation, and auth.
- **Drive:** literal commands and stable handles from this repository. Prefer roles, accessible names, routes, prompt strings, and public APIs over coordinates or internals.
- **Evidence:** capture action and result. Verify side effects through a second public view; mock only existing production boundaries.
- **Cleanup:** stop only processes and scratch state this run created. Never kill by process name. Evidence survives cleanup.

Make/document executable helpers. For stateful bugs/recurring repro gaps, prove [capture/replay](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/verification-replay.md) via native fixture/debug APIs.

## Seed the feature map

Create `features/README.md` and top 3-5 feature files. Ground [the example](https://github.com/malinskibeniamin/skills/blob/v4.42.0/create-verification-skill/references/feature-map-example/README.md) in repo evidence. Each owns:

1. `Sub-features`
2. `How to get to it (user POV)`
3. `Driving it with <harness>`
4. `Gotchas`

Map every entrypoint. Missing seed-data prerequisites fail the journey: record in `Gotchas`, never weaken it.

## Prove the generated skill

Execute generated skill: launch, doctor, one mapped real journey, evidence and cleanup. Preserve evidence; leave no created process/state. Clean failed attempts, fix and replay. Unexecuted verifiers are drafts.

List stand-in setup gaps; leave them unverified until replayed on the target.

Route drift audits to `/maintain-verification-skill` and feature work to `/dogfood`.
