---
name: setup-conventional-commits
description: Enforce conventional commit format via a PreToolUse hook on Bash that intercepts git commit commands. Replaces commitlint + husky entirely. Use when setting up conventional commits, commit message validation, or enforcing commit format standards.
---

# Setup Conventional Commits

## What This Sets Up

- **PreToolUse hook** (Bash matcher) that intercepts `git commit -m "..."` commands
- Validates commit message format: `type(scope): description`
- Replaces commitlint + husky with a zero-dependency Claude Code hook

## Commit Format

```
type(scope): description

[optional body]
```

- **type** (required): `feat`, `fix`, `refactor`, `style`, `test`, `docs`, `chore`, `perf`, `ci`, `build`, `revert`
- **scope** (required): lowercase identifier in parentheses, e.g. `feat(webui):`, `fix(backend):`
- **description** (required): lowercase first letter, no trailing period, 5-72 characters
- **body** (optional): encouraged for `feat` and `fix` commits

### Examples

```
feat(webui): add user profile avatar upload
fix(api): handle null response from auth endpoint
refactor(backend): extract validation into shared utility
chore(deps): bump tanstack-query to latest
```

## Steps

### 1. Create hook script

Copy [`scripts/conventional-commits-check.sh`](scripts/conventional-commits-check.sh) and [`scripts/_hook-lib.sh`](scripts/_hook-lib.sh) into `.claude/hooks/`. Make executable:

```bash
chmod +x .claude/hooks/conventional-commits-check.sh
```

### 2. Configure hook

Add to `.claude/settings.json` hooks config: **PreToolUse** (matcher: `Bash`): `.claude/hooks/conventional-commits-check.sh`

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [".claude/hooks/conventional-commits-check.sh"]
      }
    ]
  }
}
```

### 3. Codex compatibility (optional)

If the project also uses OpenAI Codex, run `codex-compat` to generate `.codex/hooks.json` from the Claude Code config.

### 4. Verify & Commit

- [ ] Hook blocks: `git commit -m "bad message"`
- [ ] Hook blocks: `git commit -m "feat: missing scope"`
- [ ] Hook blocks: `git commit -m "feat(ui): A"`  (uppercase first letter)
- [ ] Hook allows: `git commit -m "feat(ui): add button component"`
- [ ] Hook ignores non-commit Bash commands

Stage and commit: `Add conventional commits enforcement hook`
