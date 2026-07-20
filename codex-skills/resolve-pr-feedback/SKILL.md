---
name: resolve-pr-feedback
description: "Resolve PR review feedback by fetching unresolved threads, triaging, fixing in parallel, and replying. Use when addressing PR review comments, resolving threads, or picking up after human review."
hooks:
  Stop:
    - hooks:
        - type: agent
          model: claude-sonnet-5
          timeout: 90
          statusMessage: "Verifying every review thread was addressed"
          prompt: |
            A session running the resolve-pr-feedback skill is stopping. Hook
            input: $ARGUMENTS. Read the transcript file at transcript_path and
            check the tail of the session: did the assistant enumerate PR
            review threads earlier and then address EVERY one (a fix, a reply,
            or an explicit skip with a reason)? Threads the transcript shows
            as enumerated but never revisited are unaddressed. Respond
            ok=false with the unaddressed thread list in reason ONLY when the
            transcript clearly shows enumerated-but-dropped threads; if the
            transcript is unavailable, ambiguous, or shows no thread work,
            respond ok=true. The deterministic pr-feedback-completeness-stop
            hook already enforces thread resolution state via the GitHub API --
            you are the semantic layer catching resolved-without-substance.
---

Read and follow the complete [canonical skill instructions](../../resolve-pr-feedback/SKILL.md) before acting.
