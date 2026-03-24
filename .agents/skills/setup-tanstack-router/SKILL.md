---
name: setup-tanstack-router
description: Configure TanStack Router route tree auto-generation via Claude Code PostToolUse hook. Regenerates routeTree when route files change. Use when setting up TanStack Router, file-based routing, or route generation hooks.
---

# Setup TanStack Router

## What This Sets Up

- `generate:routes` package.json script
- **PostToolUse hook** on Write/Edit that regenerates route tree when files in the routes directory change

## Steps

### 1. Add package.json script

```json
{
  "scripts": {
    "generate:routes": "tsr generate"
  }
}
```

### 2. Create hook script

Write `tanstack-router-gen.sh` from [REFERENCE.md](REFERENCE.md) into `.claude/hooks/`. Make executable.

During setup, ask the user for their routes directory path (default: `src/routes/`).

### 3. Configure hook in `.claude/settings.json`

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/tanstack-router-gen.sh" }
        ]
      }
    ]
  }
}
```

### 4. Verify & Commit

- [ ] `bun run generate:routes` works
- [ ] Hook is executable
- [ ] Creating a new route file triggers regeneration

Commit: `Add TanStack Router auto-generation hook`
