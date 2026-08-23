---
name: resolve-pr-feedback
description: Use to resolve PR comments, requested changes, replies, and thread closure.
hooks:
  Stop:
    - hooks:
        - type: agent
          model: claude-sonnet-5
          timeout: 90
          statusMessage: "Verifying every review thread was addressed"
          prompt: |
            Read transcript_path from $ARGUMENTS. If the session enumerated PR review
            threads, verify each received a fix, reply, or reasoned skip. Return ok=false
            with only the dropped threads when omission is clear. If evidence is absent or
            ambiguous, return ok=true. The deterministic hook owns GitHub state; check
            semantic substance only.
---

Read and follow the complete [canonical skill instructions](../../resolve-pr-feedback/SKILL.md) before acting.
