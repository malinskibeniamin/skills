# Conventional Commits Reference

## conventional-commits-check.sh

PreToolUse hook (Bash matcher). Intercepts `git commit`. Validates message against conventional commit format.

> Script: [`scripts/conventional-commits-check.sh`](scripts/conventional-commits-check.sh)

## Validation Rules

1. **Type** must match allowed types above
2. **Scope** required. Lowercase alphanumeric, hyphens/underscores
3. **Colon + space** separator between scope and description
4. **Description** starts lowercase
5. **Description** no trailing period
6. **Description** 5-72 chars
7. **Body** optional. Encouraged for `feat` and `fix`