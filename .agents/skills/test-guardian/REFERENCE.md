# Test Guardian Reference

## LLM-Friendly Reporters

| Framework | Flag / Config | Output |
|-----------|--------------|--------|
| Vitest 4.1+ | `AI_AGENT=1 vitest` or `--reporter=agent` | Failures + summary only |
| Bun test | `CLAUDECODE=1 bun test` | Failures + summary only |
| Rstest | `--reporter=md` | Structured markdown |
| Jest | `--json` | Machine-readable JSON |

## Async Leak Detection

### Vitest
```ts
// vitest.config.ts
export default defineConfig({
  test: {
    detectAsyncLeaks: true, // WARNING: significantly slows tests
  }
})
```

CLI: `bunx vitest --run --detectAsyncLeaks`

### Jest
```bash
bunx jest --detectOpenHandles --forceExit
```

### Common Leak Patterns

| Leak type | Fix |
|-----------|-----|
| `setTimeout` not cleared | Use `clearTimeout` in cleanup/afterEach |
| Open database connection | Close in `afterAll` |
| WebSocket not closed | Close in cleanup function |
| Event listener not removed | Remove in cleanup/useEffect return |
| Unresolved promise | Ensure all promises resolve/reject |

## Performance Optimization

### Vitest
- Use `happy-dom` instead of `jsdom` (2-3x faster)
- Avoid barrel imports (use specific entry points)
- Enable dependency optimizer for heavy packages
- Use `--pool=threads` for CPU-bound tests
- Use `--shard` for parallel CI

### Jest
- Use `--maxWorkers=50%` to avoid overloading
- Enable `--cache` (default)
- Use `moduleNameMapper` to mock heavy dependencies

### Bun
- Already fast by default
- Use `--preload` for shared setup
- Use `--bail` to stop on first failure

## Profiling Commands

```bash
# CPU profile (Vitest)
node --cpu-prof ./node_modules/vitest/vitest.mjs --run

# Heap profile (Vitest)
node --heap-prof ./node_modules/vitest/vitest.mjs --run

# Import durations (Vitest)
# Add experimental.importDurations: true to config, then run normally

# Coverage with debug
DEBUG=vitest:coverage bunx vitest --run --coverage
```
