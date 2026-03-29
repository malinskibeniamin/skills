# Env Validation Reference

## env-validation-check.sh

PostToolUse hook that blocks raw `process.env.` access outside dedicated env files.

> Script: [`scripts/env-validation-check.sh`](scripts/env-validation-check.sh)

## Example `src/env.ts`

```ts
import { createEnv } from "@t3-oss/env-core";
import { z } from "zod";

export const env = createEnv({
  server: {
    DATABASE_URL: z.string().url(),
    API_SECRET: z.string().min(1),
    NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
  },
  clientPrefix: "PUBLIC_",
  client: {
    PUBLIC_API_URL: z.string().url(),
    PUBLIC_APP_NAME: z.string().min(1),
  },
  runtimeEnv: process.env,
});
```

## Usage Pattern

```ts
// BAD — raw access, no validation, no type safety
const url = process.env.PUBLIC_API_URL;
const secret = process.env.API_SECRET;

// GOOD — validated, typed, fails fast on missing vars
import { env } from "@/env";
const url = env.PUBLIC_API_URL;   // string (validated URL)
const secret = env.API_SECRET;     // string (min length 1)
```

## Why t3-env

| Problem | Solution |
|---------|----------|
| `process.env.X` is always `string \| undefined` | t3-env returns typed values via zod |
| Missing env vars crash at runtime in production | t3-env validates at startup — fails fast |
| No single source of truth for required vars | `src/env.ts` declares everything in one place |
| Easy to typo env var names | TypeScript autocomplete from the env object |
