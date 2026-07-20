---
name: golang
description: "Evidence-backed Go conventions for workload bounds, error boundaries, proto/API implementation, Temporal, testing, rollout, and controllers. Use when writing or changing Go services, handlers, workflows, controllers, or Go tests."
paths:
  - "**/*.go"
  - "**/go.mod"
hooks:
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "f=\"${CLAUDE_PLUGIN_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null)}/.claude/hooks/go-proto-reserved-check.sh\"; [ -x \"$f\" ] && exec \"$f\"; exit 0"
        - type: command
          command: "f=\"${CLAUDE_PLUGIN_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null)}/.claude/hooks/go-test-image-pin-check.sh\"; [ -x \"$f\" ] && exec \"$f\"; exit 0"
---

Read and follow the complete [canonical skill instructions](../../golang/SKILL.md) before acting.
