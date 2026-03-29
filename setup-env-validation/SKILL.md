---
name: setup-env-validation
description: Enforce type-safe environment variable access using t3-env with zod validation. Bans raw process.env.X outside dedicated env files. Use when setting up env validation, t3-env, type-safe environment variables, or banning raw process.env access.
---

# Setup Env Validation

## What This Sets Up

- **t3-env** with zod for type-safe, validated environment variables
- A single `src/env.ts` file as the source of truth for all env vars
- **PostToolUse hook** (Edit|Write) that blocks `process.env.` access in TS/TSX/JS/JSX files
- Skips dedicated env files (`env.ts`, `env.mts`, `env.mjs`, `env.js`) and test files

## Steps

### 1. Install dependencies

```bash
bun add @t3-oss/env-core zod
```

> For Next.js projects use `@t3-oss/env-nextjs` instead of `@t3-oss/env-core`. We don't use Next.js.

### 2. Create `src/env.ts`

```ts
import { createEnv } from "@t3-oss/env-core";
import { z } from "zod";

export const env = createEnv({
  server: {
    DATABASE_URL: z.string().url(),
    API_SECRET: z.string().min(1),
  },
  clientPrefix: "PUBLIC_",
  client: {
    PUBLIC_API_URL: z.string().url(),
  },
  runtimeEnv: process.env,
});
```

Adjust the schema to match your project's env vars. Import `env` everywhere instead of using `process.env` directly:

```ts
import { env } from "@/env";

const url = env.PUBLIC_API_URL; // type-safe, validated at startup
```

### 3. Create hook script

Write `env-validation-check.sh` from [REFERENCE.md](REFERENCE.md) into `.claude/hooks/`. Make executable.

### 4. Configure hook in `.claude/settings.json`

Add to hooks config: **PostToolUse** (matcher: `Edit|Write`): `.claude/hooks/env-validation-check.sh`

### 5. Codex compatibility (optional)

If the project also uses OpenAI Codex, run `codex-compat` to generate `.codex/hooks.json` from the Claude Code config.

### 6. Verify & Commit

- [ ] `src/env.ts` exists with zod schema
- [ ] `import { env } from "@/env"` works in application code
- [ ] Hook blocks `process.env.X` in regular TS/TSX files
- [ ] Hook allows `process.env` in `env.ts` / `env.mts` / `env.mjs` / `env.js`
- [ ] Hook skips test files (`*.test.*`, `*.spec.*`)
- [ ] `.claude/hooks/env-validation-check.sh` is executable
- [ ] Hook configured in `.claude/settings.json`

Stage all files and commit: `Add t3-env validation with process.env enforcement hook`
