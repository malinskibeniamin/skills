# TanStack Router Setup

## Steps

### 1. Add package.json script

```json
{
  "scripts": {
    "generate:routes": "tsr generate"
  }
}
```

### 2. Create hook scripts

Copy [`scripts/tanstack-router-gen.sh`](scripts/tanstack-router-gen.sh), [`scripts/tanstack-router-check.sh`](scripts/tanstack-router-check.sh), and [`scripts/_hook-lib.sh`](scripts/_hook-lib.sh) into `.claude/hooks/`. Make all executable.

During setup, ask the user for their routes directory path (default: `src/routes/`).

### 3. Configure hooks in `.claude/settings.json`

Add to hooks config: **PostToolUse** (matcher: `Edit|Write`):
- `.claude/hooks/tanstack-router-gen.sh`
- `.claude/hooks/tanstack-router-check.sh`

### 4. Verify

- [ ] `bun run generate:routes` works
- [ ] Creating a new route file triggers regeneration
- [ ] Hook blocks `react-router-dom` imports
- [ ] Hook blocks `window.location.href = ...`
- [ ] Hook warns on `window.location.reload()`
- [ ] Hook blocks `strict: false`
- [ ] Hook blocks `useParams()` without `{ from }`
- [ ] Hook allows `Route.useParams()`
- [ ] Hook blocks `new URLSearchParams`
- [ ] Hook warns on exported components from route files
- [ ] Hook blocks `useSearch` without `validateSearch` in route files

### 5. TanStack Intent (required)

Complete the shared [TanStack Intent setup](../tanstack-intent/SETUP.md). Before Router
work, follow `/tanstack-intent`: discover the installed package catalog and load the
task-specific `use` ids returned by Intent.

### 6. Commit

Stage and commit: `Add TanStack Router auto-generation and anti-pattern hooks`
