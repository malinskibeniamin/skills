# Setup Env Validation
t3-env + zod for type-safe env vars. `src/env.ts` is the single source of truth. Biome
`noProcessEnv` rejects raw `process.env` outside environment and build/test configuration
files.

## Steps

### 1. Install
```bash
bun add @t3-oss/env-core zod
```

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

Use `import { env } from "@/env"` everywhere instead of `process.env`.

### 3. Enforcement
No hook to copy. Biome `noProcessEnv` owns enforcement; see
`../biome/REFERENCE.md` for `src/env.ts` and configuration-file overrides.

### 4. Verify
- [ ] `import { env } from "@/env"` works
- [ ] `bun run lint` rejects `process.env.X` in application files
- [ ] `bun run lint` allows `process.env` in environment and build/test configuration files
