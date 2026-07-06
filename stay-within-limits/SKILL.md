---
name: stay-within-limits
description: Use when long-running, high-cost, or parallel agent work must respect usage limits. Check budget before waves and between subagent batches, pause near cap, and resume only when clear.
---

# Stay Within Limits

Repo/code changes: run `/deslop` before commit, push, PR, or merge.
Read `references/builder-upstream.md` for the full pause/resume procedure.
Local override: translate upstream `npx` examples to `bunx`.

Keep long-running agent work inside current usage windows.

## Core loop

1. Run a bounded wave of work. Default to at most 3 parallel subagents unless the user or host gives a throttle.
2. Let in-flight agents finish; do not interrupt them only to save budget.
3. Check current 5-hour and weekly usage with the host's usage/budget tool.
4. If either window is at or above 95%, stop launching work and schedule or prepare a self-contained resume.
5. On resume, re-check the real window before continuing.

## Usage signals

Prefer first-party host usage tools. In Claude Code, use:

```sh
bunx -y ccusage@latest blocks --active --json
```

If the tool reports cost instead of percentage, convert through the current account limit when known. The default stop rule remains 95% of the active 5-hour or weekly limit.

## Reporting

When pausing, report the observed window, threshold, next safe check, remaining plan, and exact command/tool to rerun. When continuing, state the refreshed usage evidence.
