---
name: setup-biome
description: Install Biome linter with Ultracite preset, create biome.jsonc config, and configure Claude Code PostToolUse hook for auto-fix on every edit. Use when setting up linting, formatting, Biome, Ultracite, or code quality enforcement.
---

# Setup Biome + Ultracite

## What This Sets Up

- **Biome** linter/formatter with **Ultracite** opinionated preset
- `biome.jsonc` extending `ultracite/biome/core` + `ultracite/biome/react`
- **PostToolUse hook** that auto-fixes lint/format on every Edit/Write (file-scoped, suppressed)
- Strict overrides: `noConsole`, cognitive complexity 15, `noFocusedTests`, `noDeprecatedImports`, restricted imports

## Steps

### 1. Install dependencies

```bash
bun add -D @biomejs/biome ultracite --yarn
```

### 2. Create `biome.jsonc`

Use the config from [REFERENCE.md](REFERENCE.md). Key points:
- Extends `ultracite/biome/core` and `ultracite/biome/react`
- VCS enabled with git, `useIgnoreFile: true`
- Overrides: `noConsole: error`, cognitive complexity max 15, `noDeprecatedImports: error`
- Restricted imports: `moment`, `lodash`, `classnames`, `enzyme`
- Test files still enforce `noExplicitAny` (ultracite disables it in tests — we re-enable)

### 3. Add package.json scripts

```json
{
  "scripts": {
    "lint": "biome check .",
    "lint:fix": "biome check --write ."
  }
}
```

### 4. Create hook script

Write `biome-autofix.sh` from [REFERENCE.md](REFERENCE.md) into `.claude/hooks/`. Make executable.

This hook:
- Runs on PostToolUse for Edit/Write
- Runs `biome check --write --skip=lint/correctness/noUnusedImports` on the changed file only
- Uses `suppressOutput: true` — Claude never sees auto-fix output
- Only returns a `systemMessage` if unfixable errors remain

### 5. Configure hook in `.claude/settings.json`

Merge into existing settings:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/biome-autofix.sh"
          }
        ]
      }
    ]
  }
}
```

### 6. Verify

- [ ] `biome.jsonc` exists with correct extends
- [ ] `bun run lint` works
- [ ] `bun run lint:fix` works
- [ ] `.claude/hooks/biome-autofix.sh` is executable
- [ ] Hook configured in `.claude/settings.json`

### 7. Commit

Stage all files and commit: `Add Biome + Ultracite with auto-fix hook`
