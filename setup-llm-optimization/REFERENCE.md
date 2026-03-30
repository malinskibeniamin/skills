# LLM Optimization Reference

## llm-env.sh (SessionStart)

> Script: [`scripts/llm-env.sh`](scripts/llm-env.sh)

## llm-test-flags.sh (PreToolUse on Bash)

> Script: [`scripts/llm-test-flags.sh`](scripts/llm-test-flags.sh)

### Hard enforcement (rewrite via `updatedInput`)

| Action | Runner | Why |
|--------|--------|-----|
| Strip `--verbose` | Vitest, Jest | Wastes tokens — agent reporters already show only failures |

### Soft suggestions (via `additionalContext`)

These are suggested to Claude but not forced. Claude may choose to include them:

| Flag | Runner | Why |
|------|--------|-----|
| `--pool=forks` | Vitest | Each test file gets its own process — OS cleans up zombies even if vitest crashes |
| `--bail=1` | Vitest | Fail fast on first failure — don't waste tokens on cascading failures |
| `--teardownTimeout=5000` | Vitest | Kill hanging teardown after 5s — prevents zombie processes from stalled cleanup |
| `--reporter=github` | Vitest (CI only) | GitHub Actions annotations inline in PR diffs |
| `--bail` | Jest | Fail fast |
| `--forceExit` | Jest | Force exit after tests complete — prevents hanging from open handles |

Suggestions only appear when the flag is not already present in the command.

## llm-truncate.sh (PostToolUse on Bash)

> Script: [`scripts/llm-truncate.sh`](scripts/llm-truncate.sh)

## NODE_OPTIONS

`NODE_OPTIONS=--max-old-space-size=8192` is set in the SessionStart hook (`session-env.sh`). This gives Node.js 8GB heap, preventing OOM on:
- Large test suites with many imports
- TypeScript compilation (`tsgo` / `tsc`)
- Bundler builds (rsbuild, webpack, vite)
- Protobuf code generation

## Vitest Config Optimizations

These are recommended `vitest.config.ts` settings. The hook handles CLI flags; these handle config-level tuning.

### Dependency optimization (faster startup)

```ts
export default defineConfig({
  test: {
    deps: {
      optimizer: {
        web: {
          // Pre-bundle heavy deps so vitest doesn't re-transform them per test file
          include: ['@bufbuild/protobuf', '@connectrpc/connect', 'zod'],
        },
      },
    },
    server: {
      deps: {
        // Inline ESM-only packages that cause resolution issues
        inline: ['@bufbuild/protobuf'],
      },
    },
  },
})
```

### Pool configuration (anti-zombie)

```ts
export default defineConfig({
  test: {
    pool: 'forks',
    poolOptions: {
      forks: {
        // Limit concurrent workers to prevent resource exhaustion
        maxForks: 4,
        minForks: 1,
      },
    },
    // Kill test if it takes longer than 10s
    testTimeout: 10000,
    // Kill teardown if it takes longer than 5s
    teardownTimeout: 5000,
  },
})
```

### Hanging process detection

Add to `vitest.config.ts` for debugging zombie issues:

```ts
export default defineConfig({
  test: {
    reporters: process.env.CI
      ? ['github', 'hanging-process']
      : ['default', 'hanging-process'],
  },
})
```

The `hanging-process` reporter logs which async operations prevent vitest from exiting. Remove once zombies are resolved — it adds overhead.

## Token Savings Breakdown

| Optimization | Mechanism | Estimated savings |
|-------------|-----------|------------------|
| AI_AGENT=1 | Vitest agent reporter: only shows failures | ~60-80% on test output |
| CLAUDECODE=1 | Bun test: hides passing tests | ~60-80% on test output |
| Strip --verbose | Prevents verbose mode (via `updatedInput` rewrite) | variable |
| --bail=1 | Stops after first failure instead of running entire suite | ~1,000-50,000 tokens |
| Truncate >200 lines | Caps output from `bun install`, stack traces, etc. | ~80% on large outputs |
| --pool=forks | Reliability (zombie prevention), not token savings | 0 |

## Environment Variable Reference

| Var | Effect on Vitest | Effect on Bun | Effect on Rstest |
|-----|-----------------|---------------|-----------------|
| `AI_AGENT=1` | Enables agent reporter (failures only) | No effect | Defaults to md reporter |
| `CLAUDECODE=1` | No effect | Shows only failures + summary | No effect |
| `NODE_OPTIONS=--max-old-space-size=8192` | 8GB heap for worker processes | 8GB heap | N/A (Rust) |
