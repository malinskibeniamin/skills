---
name: grill-me
description: A relentless interview to sharpen a plan or design.
disable-model-invocation: true
---

# Grill Me

Repo/code changes: run `/deslop` before commit, push, PR, or merge.
Phase 2b gate. No implementation until plan survive grilling.

## Step 1: Interview

Run the `/grilling` skill: walk every branch of decision tree. Resolve dependencies one-by-one. Each question, give recommended answer. One at time.

If question answerable by exploring codebase, explore first.

## Step 2: Three-Hat Fan-Out (parallel)

Once user present coherent plan, spawn three reviewers **in parallel** (single message, multiple Agent tool calls):

- **`plan-product-hat`**: persona, pain, success metric, scope, reversibility, TTV
- **`plan-engineering-hat`**: architecture, error paths, perf, security, test strategy, rollback
- **`plan-design-hat`**: flow, a11y, copy, visual consistency, states (empty/loading/error)

Each emit `{reviewer, status, findings[], must_answer[]}` per findings-schema.md.

If multiple agents, transcripts, visual plans, or alternative implementation plans now compete, run `/plan-arbiter` after the hats. Arbiter chooses `Adopt`, `Hybrid`, or `Revise first` before implementation approval.

## Step 3: Merge

Consolidate all `must_answer` questions into single list, deduped. Surface to user. User answer each. Plan updated inline.

Any reviewer return `status: BLOCKED` -> plan no advance until blocking finding addressed or user override.

## Step 4: Approve

All hats return `APPROVED` or user override specific findings -> plan approved -> Phase 3 (Implement).

## Skip Gate

Skip three-hat fan-out only if:
- Trivial bug fix, AND
- <3 tasks in plan, AND
- No architectural / product / UX decisions

Else, fan-out mandatory. [ETHOS: Grill Before Build]
