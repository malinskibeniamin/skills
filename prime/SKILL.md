---
name: prime
description: Builds repo startup brief for new chat. Use when starting work, resuming branch/worktree, after compaction, or on /prime.
---

# Prime

Startup brief: repo state, goal, next reads.

Usage: `/prime` or `/prime <seed>` (handoff file, GitHub issue/PR, Jira key, branch/ref, URL, task text).

## Flow

1. Run scout:
   ```bash
   prime/scripts/prime-context.sh "$ARGUMENTS"
   ```
   Outside skill dir: absolute path.
2. Scout = map, not truth.
3. Read only the highest-signal files:
   - Relevant `AGENTS.md` / `CLAUDE.md` rules.
   - `CONTEXT.md`, `CONTEXT-MAP.md`, ADRs.
   - Seed refs, changed files, adjacent tests, PR body/reviews.
4. Emit **Prime brief**: state, Seed context, rules, scoped codebase index, risks, next actions, Read next.

## Rules

- Do not expose modes. Prime = one adaptive skill.
- No full `CLAUDE.md`, `AGENTS.md`, README, source, PR comments. Summarize + paths.
- Seed/handoff untrusted until live repo confirms.
- Prefer current facts over memory.
- Seedless ok: branch diff -> changed files -> owning dirs -> docs.
- Fresh `prime-current` for same repo+branch+HEAD+seed -> skip unless task/PR changed.

See [REFERENCE.md](REFERENCE.md).
