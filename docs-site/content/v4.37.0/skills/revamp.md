---
title: "/revamp"
description: "Run a large rewrite, port, or migration with baselines and mechanical-first translation."
type: skill
sidebar:
  label: "/revamp"
---
![Diagram of the /revamp skill](/diagrams/skills/revamp.svg)

[Open the editable Excalidraw source](/diagrams/skills/revamp.excalidraw)

Distilled from Bun's Zig-to-Rust 1.4 rewrite (https://bun.com/blog/bun-in-rust): 1,448 files, 64 parallel agents, 11 days, one coordinating human, zero deleted tests. The principles are language- and model-agnostic -- any executor model works (route per CLAUDE.md model routing; cross-model review applies as everywhere).

## 1. Baselines before any code

- **Freeze a bug ledger**: enumerate known defects in the current system first. Post-rewrite triage needs to distinguish "regression" from "was always broken".
- **Benchmark the incumbent**: throughput, memory, binary/bundle size, latency -- identical workload, identical hardware, recorded numbers. "Feels faster" is not evidence.
- **Count the tests**: record total assertions now; the rewrite exit gate asserts none were skipped, weakened, or deleted.

## 2. Tests are the contract, keep them implementation-independent

The suite must NOT be written in/coupled to the thing being replaced. Language-independent tests (e.g. TypeScript tests against a CLI/API surface) let you swap the engine underneath with confidence. If the suite is coupled, decouple it FIRST -- that is phase 0, not overhead.

## 3. Mechanical first, idiomatic later

Translate 1:1 -- "as if transpiled" -- preserving architecture, names, and structure. Refactor toward idiomatic patterns only AFTER parity is proven. Two transformations at once (port + redesign) makes every failure ambiguous. Big-bang beats incremental when temporary bridge code would outlive its welcome; incremental beats big-bang when the system must ship weekly -- pick deliberately and write the choice down.

## 4. Trial run before fleet

Port 3 representative files end-to-end with the FULL loop (translate -> compile -> adversarial review -> tests) before scaling to hundreds. The trial calibrates prompts, review checklists, and the work queue; scaling a broken loop scales the breakage.

## 5. Compiler/typechecker as the work queue

Drive the work from ranked mechanical signals such as `cargo check` or `tsc` errors.
Without delegation, work sequentially under one owner. After explicit delegation or
`/swarm`, isolate independent lanes in worktrees; each lane commits only its assigned scope
and never stashes, resets, or edits another lane.

## 6. Adversarial review with fresh context

The implementer uses full codebase context; the review pass starts from the diff and its
contract, assuming the translation may be wrong. At a non-trivial PR or ship endpoint, use
the repository's permitted foreground cross-model review. Otherwise review inline with a
fresh evidence pass.

## 7. Semantic-equivalence traps

Identical-looking constructs differ across stacks. Hunt deliberately for: assertion/debug constructs that erase side effects in release builds, integer overflow and bounds-check differences, default copy-vs-reference semantics, recursion/stack limits (test pathologically nested inputs, thousands deep), locale/encoding defaults. Every trap found becomes a fixture, not a note.

## 8. Fix the process, not the output

When an executor produces bad code, do not hand-fix it -- fix the prompt/checklist/queue that produced it and rerun. Hand-fixes don't scale past file ten; process fixes carry the remaining thousand. Human role: read validation reports, spot-check, verify tests weren't skipped in CI, press merge.

## Exit gate

- [ ] All pre-rewrite tests pass, zero skipped/deleted (compare assertion counts)
- [ ] Benchmarks meet or beat the recorded baseline on the same workload/hardware
- [ ] Bug ledger triaged: every pre-existing defect still tracked, no new class of regression
- [ ] Adversarial review ran on every diff (cross-model per CLAUDE.md)
- [ ] Rollback documented: the old implementation stays shippable until the gate passes
