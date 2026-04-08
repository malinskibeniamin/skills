---
name: triage-issue
description: Triage a bug or issue by exploring the codebase to find root cause, then create a GitHub issue with a TDD-based fix plan. Use when user reports a bug, wants to file an issue, mentions "triage", or wants to investigate and plan a fix for a problem.
---

# Triage Issue

## Process

### 1. Capture the problem

Ask ONE question max: "What's the problem you're seeing?"

If the user already described it, skip straight to exploration.

### 2. Explore and diagnose

Use Agent tool with subagent_type=Explore to investigate:
- **Where**: which modules/behaviors are affected
- **What**: the observable symptoms
- **Why**: root cause analysis
- **Related**: code that interacts with the affected area

### 3. Identify fix approach

Determine:
- Minimal change needed (prefer surgical fixes over rewrites)
- Affected interfaces and contracts
- Behaviors to verify (these become tests)

### 4. Design TDD fix plan

Create an ordered list of RED-GREEN cycles:
- Each cycle is a vertical slice (one test → one fix)
- Describe behaviors, not implementation steps
- Use durable language (module names, contracts) not file paths or line numbers

### 5. Create GitHub issue

Use `gh issue create` with:

    ## Problem
    What's broken and the observable symptoms.

    ## Root Cause Analysis
    Why it's broken — the underlying mechanism.

    ## TDD Fix Plan
    Ordered RED-GREEN cycles:
    1. RED: test that [behavior] → GREEN: fix [root cause]
    2. RED: test that [edge case] → GREEN: handle [condition]

    ## Acceptance Criteria
    - [ ] Testable criterion 1
    - [ ] Testable criterion 2

Do NOT include file paths or line numbers — the issue should remain useful after refactors.
