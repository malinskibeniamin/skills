# Requesting Code Review Reference

## Spec Compliance Review Prompt

When dispatching a spec compliance review subagent:

```
Review this implementation against the requirements. For each requirement:
1. Is it implemented? (yes/no/partial)
2. If partial — what's missing?
3. Are there features NOT in the spec? (scope creep)

Do NOT trust the implementer's self-report. Read the actual code.
Report: APPROVED or CONCERNS with file:line references.
```

## Code Quality Review Prompt

When dispatching a code quality review (or `/codex:adversarial-review`):

```
Review this code for production readiness:
- Separation of concerns: does each file have one clear responsibility?
- Error handling: are failure modes covered? Are errors typed?
- Type safety: any escape hatches (as any, @ts-ignore)?
- DRY: duplicated logic that should be extracted?
- Tests: do they test behavior or implementation details?
- Accessibility: keyboard navigable? ARIA attributes?
- Performance: unnecessary re-renders? Heavy imports?
- Security: user input validated? No eval/innerHTML?

Report: APPROVED, CONCERNS, or NEEDS_CHANGES with severity per issue.
```

## Cross-Model Review

For critical changes, use `/codex:adversarial-review` which challenges design decisions from a different model's perspective:

```
1. Finish implementation → our hooks catch pattern violations
2. Stage 1: Spec compliance review (same session or subagent)
3. Stage 2: /codex:adversarial-review (cross-model challenge)
4. Fix findings from both stages
5. gh pr create → @claude review for remote review
6. Merge
```

## Status Codes

| Code | Meaning | Action |
|---|---|---|
| APPROVED | All checks pass | Proceed to next stage or merge |
| CONCERNS | Minor issues found | Address concerns, re-review optional |
| NEEDS_CHANGES | Significant issues | Must fix and re-review |
