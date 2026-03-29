# Conventional Commits Reference

## conventional-commits-check.sh

PreToolUse hook (Bash matcher) that intercepts `git commit` commands and validates the commit message against conventional commit format.

> Script: [`scripts/conventional-commits-check.sh`](scripts/conventional-commits-check.sh)

## Allowed Commit Types

| Type | Purpose |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring (no behavior change) |
| `style` | Formatting, whitespace (no logic change) |
| `test` | Adding or updating tests |
| `docs` | Documentation only |
| `chore` | Build, tooling, dependency updates |
| `perf` | Performance improvement |
| `ci` | CI/CD configuration |
| `build` | Build system changes |
| `revert` | Reverting a previous commit |

## Validation Rules

1. **Type** must be one of the allowed types above
2. **Scope** is required, lowercase alphanumeric with hyphens/underscores
3. **Colon + space** separator between scope and description
4. **Description** starts with lowercase letter
5. **Description** does not end with a period
6. **Description** is 5-72 characters
7. **Body** is optional but encouraged for `feat` and `fix`
