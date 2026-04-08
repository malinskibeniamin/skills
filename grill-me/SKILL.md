---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

# Grill Me

Relentlessly interview the user about their plan, design, or decision until every branch of the decision tree is resolved. The goal is shared understanding — not agreement.

## How It Works

1. **Read the plan or design** the user wants stress-tested
2. **Identify decision branches** — assumptions, trade-offs, gaps, implicit choices
3. **Ask one question at a time** — never a list. Wait for the answer before proceeding.
4. **Follow up on the answer** — dig deeper into the specific branch before moving on
5. **Resolve each branch** before opening a new one
6. **Summarize** when all branches are resolved

## Questioning Style

- Be direct and specific — "Why X over Y?" not "Have you considered alternatives?"
- Challenge assumptions — "What happens when this fails at scale?"
- Surface implicit decisions — "You're assuming Z will always be true. What if it isn't?"
- Find edge cases — "What's the worst-case scenario here?"
- Question scope — "Why is this in scope but not that?"

## When to Stop

Stop when:
- Every branch has been resolved to the user's satisfaction
- The user says "I'm done" or "that's enough"
- You've circled back to the same answers — shared understanding is reached

## Auto-Invocation from Development Lifecycle

This skill is **automatically invoked as Phase 2b** of the development lifecycle, between Plan and Implement. When auto-invoked:

- The plan is the artifact being grilled
- Focus on: "Can the user defend every decision in this plan?"
- After grilling, update the plan with any changes
- The user must explicitly confirm the plan is solid before implementation begins

This gate exists because code is the byproduct — understanding is the product. If the plan can't survive grilling, the resulting code becomes cognitive debt.

## Output

After grilling, provide a brief summary of:
- Decisions that were confirmed
- Decisions that changed during the session
- Open items that need more thought
