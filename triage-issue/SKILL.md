---
name: triage-issue
description: Triage a bug or issue by exploring the codebase to find root cause, then create a GitHub issue with a TDD-based fix plan. Use when user reports a bug, wants to file an issue, mentions "triage", or wants to investigate and plan a fix for a problem.
---

# Triage Issue

## 1. Capture
One question max: "What's the problem?" If described, skip to explore.

## 2. Explore + Diagnose
Agent(subagent_type=Explore): Where (modules/behaviors), What (symptoms), Why (root cause), Related (interacting code).

## 3. Fix Approach
Minimal change (surgical > rewrite). Affected interfaces/contracts. Behaviors to verify -> tests.

## 4. TDD Fix Plan
Ordered RED-GREEN cycles. Vertical slices (one test -> one fix). Describe behaviors, not impl steps. Durable language (module names, contracts), not file paths.

## 5. Create GitHub Issue

`gh issue create` with:

    ## Problem
    Observable symptoms.

    ## Root Cause Analysis
    Why -- underlying mechanism.

    ## TDD Fix Plan
    1. RED: test [behavior] -> GREEN: fix [root cause]
    2. RED: test [edge case] -> GREEN: handle [condition]

    ## Acceptance Criteria
    - [ ] Testable criterion 1
    - [ ] Testable criterion 2

No file paths or line numbers -- issue must survive refactors.