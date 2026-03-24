---
name: test-guardian
description: Diagnose test health across frameworks (Vitest, Jest, Bun, Rstest) — detect async leaks, profile performance, find slow tests, identify flaky tests. Use when tests are slow, flaky, leaking memory, or need performance profiling. Manual invocation skill, not a hook.
---

# Test Guardian

## What This Does

Manual diagnostic skill for test health. Not an always-on hook — invoke when debugging test issues.

## Workflows

### Detect Async Leaks

**Vitest:**
```bash
bunx vitest --run --detectAsyncLeaks
```

**Jest:**
```bash
bunx jest --detectOpenHandles --forceExit
```

Common causes: unclosed timers, unresolved promises, open database connections, WebSocket subscriptions.

### Profile Test Performance

**Vitest** — enable import duration analysis:
```ts
// vitest.config.ts (temporary)
export default defineConfig({
  test: {
    experimental: { importDurations: true }
  }
})
```

Then run and check output for slowest imports.

**CPU profiling:**
```bash
node --cpu-prof ./node_modules/vitest/vitest.mjs --run
```

Open `.cpuprofile` in Chrome DevTools or Speedscope.

### Find Slow Tests

Run with timing and sort:
```bash
bunx vitest --run --reporter=verbose 2>&1 | grep -E '✓|×' | sort -t'(' -k2 -rn | head -20
```

### Identify Flaky Tests

Run tests multiple times and look for inconsistencies:
```bash
for i in $(seq 1 5); do
  echo "--- Run $i ---"
  bunx vitest --run 2>&1 | tail -3
done
```

### Optimize Test Configuration

See [REFERENCE.md](REFERENCE.md) for per-framework optimization tips.

## Framework Detection

Check `package.json` for:
- `vitest` → use vitest commands
- `jest` → use jest commands
- `rstest` / `@rstest/core` → use rstest commands
- `bun test` (default) → use bun test commands
