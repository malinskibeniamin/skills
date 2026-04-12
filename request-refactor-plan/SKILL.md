---
name: request-refactor-plan
description: Create a detailed refactor plan with tiny commits via user interview, then file it as a GitHub issue. Use when user wants to plan a refactor, create a refactoring RFC, or break a refactor into safe incremental steps.
---

# Request Refactor Plan

## Process

### 1. Understand
Ask problem description + solution ideas. What wrong? What "better" look like?

### 2. Verify
Agent(subagent_type=Explore) verify claims about codebase. Check actual state.

### 3. Alternatives
Ask other approaches + trade-offs.

### 4. Drill Into Details
Exact scope, interface contracts (before/after), data migrations, backwards compat, incremental path.

### 5. Test Coverage
Assess existing coverage. Insufficient → ask testing plan before proceeding.

### 6. Tiny Commits
Each step: independently deployable, tests green, changes one thing.

### 7. GitHub Issue

`gh issue create`:

    ## Problem Statement
    What wrong and why.

    ## Solution
    Chosen approach and rationale.

    ## Commits
    1. [description] — what changes, tests green
    2. [description] — what changes, tests green

    ## Decisions
    Key decisions + rationale from interview.

    ## Testing
    New tests needed, existing tests changed.

    ## Out of Scope
    What NOT touched.