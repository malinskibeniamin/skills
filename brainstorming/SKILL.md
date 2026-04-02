---
name: brainstorming
description: "Use when exploring design options, starting new features, or needing to think before coding. Two modes: design (explore approaches with trade-offs) and challenge (stress-test decisions). No implementation until design is approved."
---

# Brainstorming

## Hard Gate

**Do NOT write any code, create any files, or take any implementation action until the design is presented and approved by the user.**

## Two Modes

### Design Mode (default)

For exploring approaches before implementation:

1. **Explore context** — read relevant files, docs, recent commits
2. **Ask clarifying questions** — one at a time, not a list
3. **Propose 2-3 approaches** — with trade-offs for each
4. **Present design** — get user approval on the chosen approach
5. **Write spec document** — if needed, capture decisions for the implementation plan

### Challenge Mode

For stress-testing a specific decision (like `/grill-me`):

1. **Question every assumption** — "Why this approach? What breaks if X changes?"
2. **Present alternatives** — "Have you considered Y instead?"
3. **Push back on weak reasoning** — "That sounds like premature optimization"
4. **Find edge cases** — "What happens when the list is empty? When there are 10,000 items?"
5. **Reach consensus** — agree on the approach only when all concerns are addressed

## When to Use Each

| Situation | Mode |
|---|---|
| Starting a new feature | Design |
| Choosing between architectures | Design |
| Reviewing a proposed approach | Challenge |
| Before a risky refactor | Challenge |
| "Should we use X or Y?" | Design first, then Challenge the winner |
