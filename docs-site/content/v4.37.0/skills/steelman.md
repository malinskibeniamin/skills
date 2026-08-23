---
title: "/steelman"
description: "Argue the strongest evidence-backed case against a premise. Use when user says steelman, asks for pushback or second opinion, or when a high-stakes decision depends on an uncertain assumption."
type: skill
sidebar:
  label: "/steelman"
---
![Diagram of the /steelman skill](/diagrams/skills/steelman.svg)

[Open the editable Excalidraw source](/diagrams/skills/steelman.excalidraw)

Anti-sycophancy. LLMs agree by default. This skill forces opposite case.
Skip preferences, goals, trivial operations, user-proven claims, and implementation work
unless security, data loss, or irreversibility makes pushback necessary.

## Procedure

### Step 1: Identify claim

Restate user claim in one sentence. Flag type:
- **Factual** (verifiable: grep, docs, run) -> verify first
- **Causal** ("X breaks because Y") -> test the mechanism
- **Architectural** ("pattern Z won't scale") -> explore existing usage
- **Preference/goal/scope** -> decline steelman. Log `noise`. Return.

Preference/goal is user's call. No steelman.

### Step 2: Evidence gather

Fan out checks *before* arguing:
- Grep for named symbols / patterns
- Read referenced files
- Run tests/commands if cheap
- Consult docs/web for version/tooling claims

Do NOT argue from generics ("pattern smells"). Argue from repo evidence.

### Step 3: Steelman opposite

Write strongest counter-argument with specific references:
- What would have to be true for user to be wrong?
- What evidence in the repo supports wrong-case?
- What failure mode does user not consider?
- What precedent contradicts (git blame, prior commits, related files)?

Format: 2-4 bullet points. Each cites file:line or command output.

### Step 4: Verdict

Three outcomes:
- **Confirmed**: evidence supports user. Say so with refs. Proceed with user plan.
- **Contradicted**: evidence against user. Surface with refs. Let user decide (override or revise). Do NOT block.
- **Mixed**: partial confirm. Name which parts hold, which don't.

## Anti-pattern

Don't:
- Ask "are you sure?" -- verify silently, surface evidence only
- Play devil's advocate without refs -- grounded in repo only
- Block user. Surface, don't gate.
- Steelman every turn -- signal decays. Reserve for high-stakes + explicit invite.

[ETHOS: User fallible. Verify before act. Surface evidence, not doubt.]
