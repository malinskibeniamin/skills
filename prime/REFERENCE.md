# Prime reference

## Output contract

A Prime brief should fit in one screen when possible:

```md
# Prime brief

## State
- Repo:
- Worktree:
- Branch:
- PR/CI:

## Working rules
- <Only rules that affect this task>

## Codebase map
- Stack:
- Important dirs:
- Domain docs:

## Current change
- Changed files:
- Recent commits:
- Review feedback:

## Next actions
1. <Best first action>
2. <Second action>
3. <Verification path>

## Read next
- <path>: <why>
```

## Context hygiene

- Do not paste full CLAUDE.md or AGENTS.md. They may already be in system/project context and can be large.
- Read headings and the relevant sections only: quick reference, lifecycle, toolchain, tests, repo-specific warnings.
- Treat instruction files as authority, but compress them into task-specific implications.
- Read source files only when they are changed, directly referenced by the task, or selected by the scout as high-signal.

## Integration options

**Manual `/prime`**: safest first implementation. The agent runs the scout, chooses what to read, and emits the Prime brief.

**UserPromptSubmit self-invoked**: hook injects "run `/prime` before substantive work if no Prime marker exists". This lets the model choose the important reads.

**SessionStart**: useful for deterministic local facts, but less ideal for AI-driven reading because shell hooks cannot reason over the codebase. If used, keep it a nudge or bounded scout output, not a full source dump.

## Scout boundaries

`scripts/prime-context.sh` should gather facts, not replace the agent:

- Git state, branch, upstream, dirty files, changed files, recent commits.
- Candidate instruction docs: `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`.
- Domain docs: `CONTEXT.md`, `CONTEXT-MAP.md`, ADR titles.
- Stack and commands from `package.json`, lockfiles, config files.
- Current PR via `gh pr view` when available.
- Candidate next reads from changed files and high-signal docs.

Network calls must fail open. Secrets and environment values must never be printed.
