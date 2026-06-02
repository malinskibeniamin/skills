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

## Seed context
- Source:
- Summary:
- Claims to verify:

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

- No PRIME.md. Derive live from repo/git/PR/docs, no stale summaries.
- Do not paste full CLAUDE.md or AGENTS.md. Avoid duplicate context.
- Read relevant sections only: quick ref, lifecycle, toolchain, tests, repo warnings.
- Compress rules -> task implications.
- Read source only if changed, seed/task-referenced, or scout-picked.

## Integration

- `/prime`: repo-led brief.
- `/prime <seed>`: seed = handoff file, GitHub issue/PR, Jira key, branch/ref, URL, task text.
- Manual only by default: user chooses `/prime`; no prompt nudge.
- SessionStart: optional deterministic scout only; poor for AI reads. Never source dump.

## Scout scope

Gather facts:

- Git state, branch, dirty/changed files, commits.
- Rule docs: `AGENTS.md`, `CLAUDE.md`, copilot instructions.
- Domain docs: `CONTEXT.md`, `CONTEXT-MAP.md`, ADRs.
- Stack/commands from configs.
- Seed context via local file, `gh issue view`, `gh pr view`, `acli jira workitem view`, branch diff/log.
- Current PR via `gh pr view` if available.
- Candidate next reads.

Network fail-open. Never print secrets/env.

Marker: `$XDG_CACHE_HOME/codex/prime` or `~/.cache/codex/prime`, outside repo.
