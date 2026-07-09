---
name: commit-push
description: Analyze changes, create categorized conventional commits, and push -- no PR.
disable-model-invocation: true
---

# Commit and push

Run `/commit-push-pr` Phases 0-4 only (context -> scope confirmation -> branch strategy ->
categorized conventional commits -> push). Stop before Phase 5: do not open a PR.
See [commit-push-pr/SKILL.md](../commit-push-pr/SKILL.md) for the full procedure and safety rules.
