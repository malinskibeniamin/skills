---
allowed-tools: Bash(git *), Bash(gh *)
description: Analyze changes, create categorized conventional commits, and push
---

## Context

- Current git status: !`git status -sb`
- Current diff (staged and unstaged): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits for style reference: !`git log --oneline -5`

## Prerequisites

1. Verify `gh --version` exists — if missing, stop and ask the user to install it
2. Verify `gh auth status` — if not authenticated, ask the user to run `gh auth login` and stop
3. Verify you are inside a git repository

## Your task

Based on the above changes, execute the full commit-and-push workflow below in a single response. Use only the tools listed in `allowed-tools`.

### Phase 1: Scope confirmation

1. Inspect the status and diff above
2. If the worktree contains changes that look unrelated to each other, **ask the user** which files belong in this publish flow — do NOT default to `git add -A`
3. Present the file list grouped by detected category for user confirmation before proceeding

### Phase 2: Branch strategy

1. If on `main`, `master`, or the repository default branch → create a new branch named `type/description` (for example `feat/add-commit-push-command`) and switch to it
2. Otherwise stay on the current branch

### Phase 3: Categorized commits

Analyze every changed file and group by change purpose into conventional commit types:

| Type | Matches |
|------|---------|
| `docs` | *.md, SKILL.md, REFERENCE.md, comments-only changes |
| `test` | *.test.ts, *.test.tsx, *.spec.ts, EVAL.ts, agent-evals/ |
| `refactor` | code restructuring without behavior change |
| `style` | formatting, whitespace, lint-only fixes |
| `fix` | bug fixes, error corrections |
| `feat` | new features, new components, new endpoints |
| `chore` | config files, dependencies, build scripts, tooling |
| `perf` | performance improvements |
| `ci` | CI/CD pipeline changes |
| `build` | build system changes |

**For each category that has files:**

1. Stage only the relevant files with explicit paths: `git add <file1> <file2> ...` — never use `git add -A` or `git add .`
2. Commit with message format: `type(scope): terse description`
   - Infer scope from the directory or module the files belong to
   - Lowercase first letter, 5-72 characters, no trailing period
   - Include a `Co-Authored-By` trailer
3. Move to the next category

If a file could fit multiple categories, assign it to the most specific one.

### Phase 4: Push

1. Push with tracking: `git push -u origin $(git branch --show-current)`
2. Never force push — `--force-with-lease` is acceptable when needed (for example after a rebase)

### Phase 5: Verify and summarize

1. Run `git status` and `git diff` to confirm the working tree is clean
2. If anything remains uncommitted, warn the user
3. Summarize: branch name, list of commits created, and anything the user still needs to do

### Write safety

- Never stage unrelated changes silently
- Never push without confirming scope when the worktree contains mixed changes
- If no accessible GitHub remote exists, stop and explain the blocker
