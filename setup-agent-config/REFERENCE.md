# LLM Optimization Reference

## llm-env.sh (SessionStart)

> Script: [`scripts/llm-env.sh`](scripts/llm-env.sh)

## user-prompt-context.sh (UserPromptSubmit)

> Script: [`../shared/user-prompt-context.sh`](../shared/user-prompt-context.sh)

Injects project state into every prompt as `additionalContext`. Claude knows state without wasting tool calls.

### Context Levels

Set `PROMPT_CONTEXT_LEVEL` in SessionStart hook:

```bash
echo "export PROMPT_CONTEXT_LEVEL=standard" >> "$CLAUDE_ENV_FILE"
```

| Level | What's injected | Latency | Tokens |
|-------|----------------|---------|--------|
| `minimal` | Git branch, dirty state, last commit, ahead/behind | ~80ms | ~50 |
| `standard` (default) | Minimal + scripts + violations + condensed rules + config | ~120ms | ~200 |
| `full` | Standard + tsconfig paths + UI component inventory + route tree + proto version + last stop outcome | ~170ms | ~350 |

### The Rules Line

Most valuable injection. Compresses 300+ lines PostToolUse enforcement into one line Claude applies *before* writing code:

```
Rules: bun biome vitest | no-memo(compiler) no-as-any no-ts-ignore no-style={{}} no-useEffect | UI:@/components/ui/ | no-raw-HTML(<button>→<Button>) | zustand:create<T>()() useShallow | env:@/env(no process.env) | TanStack-Router(no react-router-dom) | connect-query(no raw useQuery)
```

Instead of write→block→fix (3 tool calls, ~1500 tokens), Claude writes correct first try (1 tool call). Estimated savings: **3000-8000 tokens per session**.

### Full Level — What It Adds

```
Paths: @/*=src/* @/ui/*=src/components/ui/*
UI: button,input,select,dialog,table,label,textarea,badge,card,alert
Routes: index.tsx,users/$userId.tsx,settings.tsx
Proto: v2
Last stop: typecheck PASS, tests PASS
```

Prevents 2-3 Glob/Read calls Claude makes discovering import paths, available components, route params.

### Codex Compatibility

Codex lacks `UserPromptSubmit`. Approximate via:
- **SessionStart**: one-time context snapshot (stale but available)
- **AGENTS.md**: static rules and scripts baked at generation time
- **Stop → `.codex/session-state.md`**: violations and git state written per-turn

See `codex-compat` REFERENCE.md for approximation strategy.

## llm-test-flags.sh (PreToolUse on Bash)

> Script: [`scripts/llm-test-flags.sh`](scripts/llm-test-flags.sh)

### Hard enforcement (rewrite via `updatedInput`)

| Action | Runner | Why |
|--------|--------|-----|
| Strip `--verbose` | Vitest, Jest | Wastes tokens — agent reporters already show only failures |

### Soft suggestions (via `additionalContext`)

Suggested not forced. Claude may include:

| Flag | Runner | Why |
|------|--------|-----|
| `--pool=forks` | Vitest | Each test file own process — OS cleans up zombies even if vitest crashes |
| `--bail=1` | Vitest | Fail fast on first failure — no wasted tokens on cascading failures |
| `--teardownTimeout=5000` | Vitest | Kill hanging teardown after 5s — prevents zombie processes from stalled cleanup |
| `--reporter=github` | Vitest (CI only) | GitHub Actions annotations inline in PR diffs |
| `--bail` | Jest | Fail fast |
| `--forceExit` | Jest | Force exit after tests — prevents hanging from open handles |

Suggestions only appear when flag not already present.

## llm-truncate.sh (PostToolUse on Bash)

> Script: [`scripts/llm-truncate.sh`](scripts/llm-truncate.sh)

## NODE_OPTIONS

`NODE_OPTIONS=--max-old-space-size=8192` set in SessionStart hook (`session-env.sh`). Gives Node.js 8GB heap, preventing OOM on:
- Large test suites with many imports
- TypeScript compilation (`tsgo` / `tsc`)
- Bundler builds (rsbuild, webpack, vite)
- Protobuf code generation

## Vitest Config Optimizations

Recommended `vitest.config.ts` settings. Hook handles CLI flags; these handle config-level tuning.

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

`hanging-process` reporter logs which async ops prevent vitest exit. Remove once zombies resolved — adds overhead.

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