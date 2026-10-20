---
name: cli-for-agents
description: Design and review agent-friendly CLIs. Use for commands, flags, help, pipelines, errors, retries, dry runs, and machine-readable output.
---

Read the complete [upstream guidance](../../vendor/cursor/cli-for-agent/skills/cli-for-agents/SKILL.md), then apply these host constraints:

- Use the target repository's runtime, command structure, and existing output contracts. Verify supported flags before invoking them.
- Missing required inputs in non-interactive mode must fail promptly with a nonzero exit and an actionable example. Offer prompts only in an explicit interactive mode.
- Confirmation flags such as `--yes` and `--force` do not grant authorization. Preserve permission checks, safe defaults, and the user's destructive-action constraints.
- Exercise the real entrypoint: help examples, invalid inputs, pipelines, retry safety, and a no-write destructive preview. Report unsupported paths rather than claiming they passed.

[Provenance, selection, and refresh](../../shared/CURSOR-SKILLS-CREDITS.md).
