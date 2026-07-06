---
name: visual-recap
description: Turn a PR, branch, commit, or diff into an interactive Agent-Native visual recap with diagrams, file maps, API/schema summaries, annotated diffs, UI wireframes, and review notes.
---

# Visual Recap

Repo/code changes: run `/deslop` before commit, push, PR, or merge.
Local override: translate upstream `npx @agent-native/core` examples to `bunx @agent-native/core`.

## Required references

Before creating a recap, read `references/agent-native-recap.md`. It owns the full create-visual-recap contract, never-inline rule, Plan MCP URL rules, diff-to-block mapping, redaction, security visibility, local-files privacy mode, and review feedback loop.

Read these only when relevant:

- `references/connection.md` -- connector discovery, reconnect steps, never-inline fallback.
- `references/local-files.md` -- no-hosted-DB/local-only recap mode.
- `references/wireframe.md` -- UI wireframe rules for visible diffs.

## Local harness overlay

- `/commit-push-pr` should create or link a visual recap before opening or updating a PR when the diff is review-worthy.
- `/go` should treat recap as part of the PR handoff for non-trivial work.
- Keep recaps grounded in the real diff. Redact secrets and do not infer facts absent from changed lines.
- Skip recap for tiny, single-file, obvious diffs; state the skip reason.
