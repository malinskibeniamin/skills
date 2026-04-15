---
allowed-tools: Bash(git *), Bash(gh *)
description: Analyze changes, create categorized conventional commits, and push
---

## Context

- Current git status: !`git status -sb`
- Current diff (staged and unstaged): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Default branch: !`gh repo view --json defaultBranchRef -q '.defaultBranchRef.name'`
- Recent commits for style reference: !`git log --oneline -5`

## Prerequisites

1. Verify you are inside a git repository
2. Verify a git remote exists: `git remote -v` — if none, stop and explain

## Your task

Based on the above changes, execute the full commit-and-push workflow below in a single response. Use only the tools listed in `allowed-tools`.

### Phase 1: Scope confirmation

1. Inspect the status and diff above
2. If the worktree contains changes that look unrelated to each other, **ask the user** which files belong in this publish flow — do NOT default to `git add -A`
3. Present the file list grouped by detected category for user confirmation before proceeding

### Phase 2: Branch strategy

1. If on the default branch (detected above) → create a new branch named `type/description` (for example `feat/add-commit-push-command`) and switch to it
2. Otherwise stay on the current branch
3. Check for existing PR on this branch: `gh pr list --head $(git branch --show-current) --json number,url --jq '.[0]'` — if PR exists, inform user (push will update it)

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

### Phase 4: Pre-push review

1. Show what will be pushed: `git log --oneline origin/<branch>..HEAD 2>/dev/null || git log --oneline -5`
2. Confirm commit count and branch target with user before pushing

### Phase 5: Push

1. Push with tracking: `git push -u origin $(git branch --show-current)`
2. Never force push — `--force-with-lease` acceptable when needed (after rebase)

### Phase 6: Verify and summarize

1. Run `git status` and `git diff` to confirm the working tree is clean
2. If anything remains uncommitted, warn the user
3. Summarize: branch name, list of commits created, remote URL, and anything the user still needs to do

### Safety

- Never stage unrelated changes silently
- Never push without confirming scope when the worktree contains mixed changes
- Never force push — `--force-with-lease` acceptable when needed (after rebase)
- If no accessible git remote exists, stop and explain the blocker
