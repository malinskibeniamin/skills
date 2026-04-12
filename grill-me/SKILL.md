---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

# Grill Me

Relentlessly interview about plan/design/decision until every decision branch resolved. Goal: shared understanding, not agreement.

## Process

1. Read the plan or design to stress-test
2. Identify decision branches — assumptions, trade-offs, gaps, implicit choices
3. **One question at a time** — never a list. Wait for answer before proceeding.
4. Follow up — dig deeper into specific branch before moving on
5. Resolve each branch before opening new one
6. Summarize when all resolved

## Style

- Direct: "Why X over Y?" not "Have you considered alternatives?"
- Challenge assumptions: "What happens when this fails at scale?"
- Surface implicit decisions: "You're assuming Z is always true. What if not?"
- Edge cases: "Worst-case scenario?"
- Scope: "Why in scope but not that?"

## Stop When

- Every branch resolved to user's satisfaction
- User says "done" or "enough"
- Circled back to same answers — shared understanding reached

## Auto-Invocation

Phase 2b of development lifecycle (between Plan and Implement). When auto-invoked:
- Plan is the artifact being grilled
- After grilling, update plan with changes
- User must confirm plan is solid before impl begins

## Output

Brief summary: decisions confirmed, decisions changed, open items.
