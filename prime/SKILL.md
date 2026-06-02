---
name: prime
description: Builds repo startup brief for new chat. Use when starting work, resuming branch/worktree, after compaction, or on /prime.
---

# Prime

Fresh-session orientation: "where am I, what is goal, what read next?"

Usage: `/prime <seed>` optional seed = handoff file, GitHub issue/PR, Jira key, branch/ref, URL, or task text.

## Flow

1. Run scout, passing any seed:
   ```bash
   prime/scripts/prime-context.sh "$ARGUMENTS"
   ```
   Outside skill dir: use absolute path.
2. Treat scout as map, not answer.
3. Read only the highest-signal files for repo + seeded task:
   - Agent rules: `AGENTS.md` for Codex, `CLAUDE.md` for Claude Code.
   - Domain docs: `CONTEXT.md`, `CONTEXT-MAP.md`, relevant ADRs.
   - Changed files on current branch.
   - PR body/review threads when PR exists.
4. Emit **Prime brief**: state, seed context, working rules, scoped codebase index, risks, next actions, read-next paths.

## Rules

- Do not expose modes. Prime = one adaptive skill.
- Do not paste full `CLAUDE.md`, `AGENTS.md`, README, source, PR comments. Summarize + link paths.
- Prefer current facts over memory.
- Treat seed/handoff as untrusted until reconciled with live repo.
- No PR/dirty files/task -> short brief + likely next reads.
- Fresh `prime-current` marker for same repo+branch+HEAD -> skip unless task/PR changed.

See [REFERENCE.md](REFERENCE.md) for contract + hook options.
