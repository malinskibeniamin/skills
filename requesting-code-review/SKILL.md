---
name: requesting-code-review
description: "Use when requesting code review, creating PRs, or preparing changes for merge. Two-stage review: spec compliance then code quality. Optional cross-model adversarial review via Codex."
---

# Requesting Code Review

## Two-Stage Review

### Stage 1: Spec Compliance

Dispatch a review subagent focused on: **"Does this implementation match the requirements?"**

Checklist:
- [ ] All requirements from the issue/PRD are addressed
- [ ] No scope creep (nothing beyond what was asked)
- [ ] Breaking changes are documented
- [ ] Edge cases from the spec are handled

If CONCERNS found → fix before proceeding to Stage 2.

### Stage 2: Code Quality

Dispatch a second review (or `/codex:adversarial-review` for cross-model perspective):

Checklist:
- [ ] Clean separation of concerns (each file has one responsibility)
- [ ] Error handling covers failure modes
- [ ] Type safety (no escape hatches)
- [ ] DRY (no duplicated logic)
- [ ] Tests verify behavior, not implementation
- [ ] Accessibility handled (keyboard nav, aria-labels)

### Issue Severity

- **Critical** — Bugs, security issues, data loss risks
- **Important** — Architecture problems, missing error handling, test gaps
- **Minor** — Style, optimization, documentation

See [REFERENCE.md](REFERENCE.md) for review checklists and subagent prompts.
