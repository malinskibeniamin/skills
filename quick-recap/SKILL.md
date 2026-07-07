---
name: quick-recap
description: Use when adding or following the red/yellow/green final status block convention for agent responses, especially in managed AGENTS.md or CLAUDE.md instructions and ship/PR flows that need an unmistakable completion state.
---

# Quick Recap

Repo/code changes: run `/deslop` before commit, push, PR, or merge.
Read `references/builder-upstream.md` for examples.

Make completion state obvious at the end of work.

## Status block

End each completed unit of work with one concise status line:

```md
🟢 Actual concise status sentence
```

Rules:

- Use `🟢` when requested work is finished.
- Use `🟡` when non-routine follow-up remains; name the pending item.
- Use `🔴` only when blocked on user input.
- Keep it under 100 characters.
- Put it at the very end.
- Do not add separators or content after it.

For this repo, use `/quick-recap` in final PR/ship flows as a convention reminder, not as a substitute for evidence.
