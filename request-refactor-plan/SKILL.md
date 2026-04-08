---
name: request-refactor-plan
description: Create a detailed refactor plan with tiny commits via user interview, then file it as a GitHub issue. Use when user wants to plan a refactor, create a refactoring RFC, or break a refactor into safe incremental steps.
---

# Request Refactor Plan

## Process

### 1. Understand the problem

Ask the user for a detailed problem description and their solution ideas. What's wrong with the current code? What would "better" look like?

### 2. Verify assertions

Use Agent tool with subagent_type=Explore to verify the user's claims about the codebase. Check the actual state — don't take assumptions at face value.

### 3. Explore alternatives

Ask the user about alternative approaches. Are there other ways to solve this? What are the trade-offs?

### 4. Interview in extreme detail

Drill into implementation specifics:
- Exact scope: what changes, what doesn't
- Interface contracts: what callers expect before and after
- Data migrations: any schema or state changes needed
- Backwards compatibility: can this be done incrementally?

### 5. Check test coverage

Assess existing test coverage for the affected code. If insufficient, ask the user about their testing plan before proceeding.

### 6. Break into tiny commits

Follow Martin Fowler's principle: **make each refactoring step as small as possible.** Each commit should:
- Be independently deployable
- Leave tests green
- Change one thing

### 7. Create GitHub issue

Use `gh issue create` with:

    ## Problem Statement
    What's wrong and why it matters.

    ## Solution
    The chosen approach and why.

    ## Commits
    Ordered list of tiny, independently-deployable steps:
    1. [commit description] — what changes, tests stay green
    2. [commit description] — what changes, tests stay green

    ## Decision Document
    Key decisions made during the interview and their rationale.

    ## Testing Decisions
    What new tests are needed, what existing tests change.

    ## Out of Scope
    What explicitly will NOT be touched in this refactor.
