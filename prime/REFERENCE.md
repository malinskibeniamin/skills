# Prime reference

## Output contract

```md
# Prime brief

## State
- Repo:
- Worktree:
- Branch:
- PR/CI:

## Working rules
- <Task-relevant rules only>

## Codebase map
- Stack:
- Dirs:
- Domain docs:

## Current change
- Changed files:
- Recent commits:
- Review feedback:

## Next actions
1. <first>
2. <second>
3. <verify>

## Read next
- <path>: <why>
```

## Context hygiene

- No PRIME.md. Derive from live repo, git, PR, docs. Avoid stale repo-local summaries.
- Do not paste full CLAUDE.md or AGENTS.md. They may already be loaded; large files duplicate context.
- Read relevant sections only: quick ref, lifecycle, toolchain, tests, repo warnings.
- Compress rules into task implications.
- Read source only if changed, task-referenced, or scout-picked.

## Integration

- Manual `/prime`: safest. Agent scouts, chooses reads, emits brief.
- UserPromptSubmit self-invoked: hook says "run `/prime` before work if no `prime-current` marker". Model chooses reads.
- SessionStart: OK for deterministic facts; poor for AI reading. Keep as nudge/scout, never source dump.

## Scout scope

`prime-context.sh` gathers facts only:

- Git state, branch, dirty/changed files, commits.
- Rule docs: `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`.
- Domain docs: `CONTEXT.md`, `CONTEXT-MAP.md`, ADR titles.
- Stack/commands from package/config files.
- Current PR via `gh pr view` if available.
- Candidate next reads.

Network fail-open. Never print secrets/env values.

Marker lives in `$XDG_CACHE_HOME/codex/prime` or `~/.cache/codex/prime`, outside repo.
