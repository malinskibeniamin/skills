# Env Validation Reference

## Enforcement: Biome, not a hook

Raw `process.env` access is banned by Biome's `noProcessEnv` (nursery, `error`) configured in [`../biome/REFERENCE.md`](../biome/REFERENCE.md), with overrides allowing it in `src/env.ts` and build/test config files. The former `env-validation-check.sh` PostToolUse hook was retired in favor of the lint rule -- one owner per rule.

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
// BAD -- raw access, no validation, no type safety
const url = process.env.PUBLIC_API_URL;
const secret = process.env.API_SECRET;

// GOOD -- validated, typed, fails fast on missing vars
import { env } from "@/env";
const url = env.PUBLIC_API_URL;   // string (validated URL)
const secret = env.API_SECRET;     // string (min length 1)
```