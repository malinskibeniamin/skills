---
name: prime
description: Builds a compact startup brief for the current repository, branch, PR, CI, review feedback, stack, docs, and likely next actions. Use when starting a new chat in an existing codebase, resuming a branch or worktree, after compaction, or when the user invokes /prime before doing product or code work.
---

# Prime

Create the "where am I and what matters?" brief for a fresh agent session.

## Workflow

1. Run the scout:
   ```bash
   prime/scripts/prime-context.sh
   ```
   If invoked from outside this skill folder, use the absolute path to `scripts/prime-context.sh`.
2. Read the scout output. It is a map, not the answer.
3. Read only the highest-signal files needed for this repo and task:
   - Current-agent rules: `AGENTS.md` for Codex, `CLAUDE.md` for Claude Code.
   - Domain docs: `CONTEXT.md`, `CONTEXT-MAP.md`, relevant ADRs.
   - Changed files on the current branch.
   - PR body/review threads if the branch has a PR.
4. Produce a concise **Prime brief**:
   - Repo and work state.
   - Rules and commands that change how work should happen.
   - Active PR, CI, review feedback, or issue context.
   - Relevant architecture/domain map.
   - Risks, unknowns, and best next actions.

## Rules

- Do not expose modes. Prime is one adaptive skill; depth follows repo state and user intent.
- Do not paste full `CLAUDE.md`, `AGENTS.md`, README, source files, or PR comments. Summarize and link paths.
- Prefer current facts over remembered assumptions.
- If scout output shows no PR, no dirty files, and no user task, keep the brief short and name likely next reads.
- If this session already has a fresh Prime brief for the same worktree and branch, do not rerun unless branch, PR, or user intent changed.

See [REFERENCE.md](REFERENCE.md) for output contract and hook integration options.
