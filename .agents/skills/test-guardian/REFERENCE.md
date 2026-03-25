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

## Find Slow Tests

```bash
bunx vitest --run --reporter=verbose 2>&1 | grep -E '✓|×' | sort -t'(' -k2 -rn | head -20
```

## Identify Flaky Tests

```bash
for i in $(seq 1 5); do
  echo "--- Run $i ---"
  bunx vitest --run 2>&1 | tail -3
done
```

## Slow Query Audit (getByRole)

`getByRole` traverses the full accessibility tree. In integration tests with large DOMs (tables, sidebars, complex layouts), a single `getByRole` call can take 50-200ms vs <1ms for `getByTestId`.

**Find hotspots:**
```bash
# Count getByRole usage per file
grep -rcn 'getByRole\|getAllByRole\|findByRole\|queryByRole' --include='*.integration.*' --include='*.test.tsx' | sort -t: -k2 -rn | head -20

# Find files with 5+ getByRole calls (likely slow)
grep -rcn 'getByRole' --include='*.test.*' | awk -F: '$2 >= 5' | sort -t: -k2 -rn
```

**Replacement strategy:**
```tsx
// SLOW in large DOM — traverses accessibility tree
const button = screen.getByRole('button', { name: 'Submit' })

// FAST — direct attribute lookup
const button = screen.getByTestId('submit-button')

// ALSO GOOD — getByText is fast for unique text
const button = screen.getByText('Submit')
```

**Keep getByRole when:**
- Testing that an element has the correct ARIA role (accessibility verification)
- DOM is small (unit tests with single component render)
- The query is `*ByRole('heading')` or similar structural checks

## Test File Classification

### Vitest Split Config

Projects use two vitest configs for different environments:

| Config | Script | Environment | Speed |
|--------|--------|-------------|-------|
| `vitest.config.unit.mts` | `bun run test:unit` | node | Fast, no DOM overhead |
| `vitest.config.integration.mts` | `bun run test:integration` | happy-dom | Component rendering with fast DOM |

### File Naming Conventions

| Suffix | Environment | Use for |
|--------|-------------|---------|
| `*.unit.ts` | node | Pure logic: utilities, hooks, store tests, transformers |
| `*.unit.tsx` | node | Simple component snapshot tests |
| `*.integration.tsx` | happy-dom | Full component rendering, user interactions, API mocking |
| `*.integration.ts` | happy-dom | Component integration with services, testcontainers |

### Common Misclassifications

**Should be `.unit.ts` (not `.integration.tsx`):**
- Tests that only call functions and assert return values
- Store/zustand tests that don't render components
- Utility/transformer tests
- Pure hook tests with no DOM interaction

**Should be `.integration.tsx` (not `.unit.ts`):**
- Tests that call `render()` from `@testing-library/react`
- Tests that use `screen.getBy*` queries
- Tests that simulate user events (`userEvent.click`, etc.)
- Tests that mock API responses and verify UI updates
- Hook tests using `renderHook` that need DOM environment

**Ambiguous `.test.ts`/`.test.tsx` (needs suffix):**
- Any test file without `.unit.` or `.integration.` runs in the default config
- These should be classified to ensure correct environment and proper config split

### Environment Mismatch Symptoms

| Symptom | Likely cause |
|---------|-------------|
| `document is not defined` | Unit test trying to render components — should be integration |
| `window is not defined` | Unit test accessing browser APIs — should be integration |
| Test passes locally, fails in CI | Environment mismatch between configs |
| Integration test is very slow | Might be pure logic that could be a unit test |
| `happy-dom` rendering errors | Complex component needs jsdom — check happy-dom compatibility |

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
