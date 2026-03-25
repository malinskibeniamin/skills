---
name: test-guardian
description: Diagnose test health across frameworks (Vitest, Jest, Bun, Rstest) — detect async leaks, profile performance, find slow queries (getByRole), identify flaky tests, audit test file classification (unit vs integration). Use when tests are slow, flaky, leaking memory, misclassified, or need performance profiling. Manual invocation skill, not a hook.
---

# Test Guardian

## What This Does

Manual diagnostic skill for test health. Not an always-on hook — invoke when debugging test issues.

## Workflows

### Detect Async Leaks

```bash
bunx vitest --run --detectAsyncLeaks  # Vitest
bunx jest --detectOpenHandles --forceExit  # Jest
```

Common causes: unclosed timers, unresolved promises, open DB connections, WebSocket subscriptions.

### Find Slow Queries

`getByRole` traverses the accessibility tree and is significantly slower than `getByTestId` in large DOMs. Audit integration tests for excessive usage:

```bash
grep -rn 'getByRole\|getAllByRole\|findByRole\|queryByRole' --include='*.integration.*' --include='*.test.tsx' | wc -l
```

**When to replace with `getByTestId`:**
- Integration tests with large DOM trees (tables, lists, complex layouts)
- Tests that assert presence/absence, not accessibility semantics
- Tests taking >500ms per query

**When `getByRole` is fine:**
- Unit tests with small DOM (fast regardless)
- Tests that specifically verify accessibility (e.g., button is actually `role="button"`)

### Audit Test File Classification

Projects use split vitest configs: `vitest.config.unit.mts` (node) and `vitest.config.integration.mts` (happy-dom or jsdom). Misclassified tests waste time or give wrong results.

**Find misclassified tests:**

```bash
# .unit.ts files that render components (should be .integration.tsx)
grep -rlE 'render\(|screen\.' --include='*.unit.ts'

# .integration.tsx files with no rendering (could be .unit.ts)
grep -rLE 'render\(|screen\.|userEvent\.' --include='*.integration.tsx'

# .test.ts/.test.tsx without unit/integration suffix (ambiguous)
find src -name '*.test.ts' -o -name '*.test.tsx' | grep -v '\.unit\.\|\.integration\.'
```

**Classification rules:**

| Suffix | Environment | Use for |
|--------|-------------|---------|
| `.unit.ts` | node | Pure logic, hooks, utilities, store tests — no DOM needed |
| `.integration.tsx` | happy-dom/jsdom | Component rendering, user interactions, API mocking |
| `.test.ts` | depends on config | Accepted — consider adding `.unit`/`.integration` suffix for split configs |
| `.test.tsx` | depends on config | Accepted — typically implies component rendering |

### Find Slow Tests / Identify Flaky Tests / Profile Performance

See [REFERENCE.md](REFERENCE.md) for commands and per-framework optimization tips.

## Framework Detection

Check `package.json` for: `vitest` → vitest, `jest` → jest, `rstest` → rstest, `bun test` → bun
