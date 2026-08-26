---
name: plan-arbiter
description: Arbitrate competing plans. Use when choosing or merging proposals from agents, transcripts, visual plans, PR descriptions, files, or pasted strategies.
---

Read `references/builder-upstream.md`. Turn competing plans into one executable direction, not blended mush.

## Workflow

1. Collect pasted/local/session/transcript/PR/comment/visual/chat plans.
2. Normalize objective, scope, assumptions, questions, files, sequence, validation, rollback, complexity.
3. Cross-check real code, docs, specs, tests, visuals, systems.
4. Decide `Adopt|Hybrid|Revise first`.
5. Produce one handoff with gates and rejected alternatives.

Planning stays read-only unless implementation is explicitly requested.

Tie-break: request fit/correctness; grounding; lower irreversible risk; smaller verified slice; clearer handoff.

```md
## Plan arbiter
Sources:
Verdict: Adopt <plan> | Hybrid | Revise first
Why:
Execution plan:
Rejected alternatives:
Verification gates:
Open questions: <blockers only>
```
