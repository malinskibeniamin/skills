# Prime reference

## Output contract

```md
# Prime brief

## State
- Repo:
- Worktree:
- Branch:
- PR/CI:
- Observed HEAD/base and dirty paths:
- Original objective / requested endpoint / narrower stops / reserved decisions:

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

- Use [repo navigation](../shared/repo-navigation.md); Read next keeps verified pointers, not copied recipes.
- No PRIME.md. Derive live from repo/git/PR/docs, no stale summaries.
- On resume, use the [continuation checkpoint](../shared/progress-evidence.md#continuation):
  reconcile explicit follow-ups; summaries do not replace endpoints. Re-observe hosted gates.
- Do not paste full CLAUDE.md or AGENTS.md. Avoid duplicate context.
- Read task-relevant rule sections only.
- Summarize rule implications; read only changed, task-referenced or scout-picked source.

## Integration

- `/prime`: repo-led brief.
- `/prime <seed>`: handoff, GitHub issue/PR, Jira key, ref, URL, task.
- Manual only by default: user chooses `/prime`; no prompt nudge.
- SessionStart: optional deterministic scout only; poor for AI reads. Never source dump.

## Scout scope

Gather facts:

- Git state, branch, dirty/changed files, commits.
- Rule docs: `AGENTS.md`, `CLAUDE.md`, copilot instructions.
- Domain docs: `GLOSSARY.md`, `GLOSSARY-MAP.md`, ADRs.
- Stack/commands from configs.
- Seed: file, `gh issue view`, `gh pr view`, `acli jira workitem view`, diff/log.
- Current PR via `gh pr view` if available.
- Next reads.

Network fail-open. Never print secrets/env.

Marker: `$XDG_CACHE_HOME/codex/prime` or `~/.cache/codex/prime`, outside repo.
