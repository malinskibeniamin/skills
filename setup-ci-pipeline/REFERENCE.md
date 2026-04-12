# CI Pipeline Reference

## Quality Gate Workflow

```yaml
name: Quality Gate

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  quality:
    runs-on: blacksmith-2vcpu-ubuntu-2404  # or ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: oven-sh/setup-bun@v2

      - name: Install dependencies
        run: bun install --frozen-lockfile --yarn

      - name: Lint + format integrity
        run: |
          bun run lint:fix
          git diff --exit-code || {
            echo "::error::Code not formatted. Run 'bun run lint:fix' locally."
            exit 1
          }

      - name: Type check
        run: bun run type:check

      - name: Unit + integration tests
        run: vitest run --coverage --coverage.thresholds.lines=80

      - name: Coverage report
        if: github.event_name == 'pull_request'
        uses: davelosert/vitest-coverage-report-action@v2
```

## Blacksmith Worker Optimization

Use [Blacksmith MCP](https://github.com/grahamnotgrant/blacksmith-mcp) to analyze CI stats:

```bash
# Fetch CI run history to find bottlenecks
gh api repos/{owner}/{repo}/actions/runs --jq '.workflow_runs[:10] | .[] | "\(.name): \(.run_started_at) duration: \(.updated_at)"'
```

Optimization checklist:
- **Caching**: `bun install` often faster than cache restore. Measure: `time bun install --frozen-lockfile`.
- **Parallelization**: Split lint, type-check, tests into parallel jobs.
- **Artifact retention**: Set `retention-days: 7` (coverage), `30` (screenshots). Default 90 days excessive.
- **Cache artifact size**: `actions/cache` only if install >30s consistently.

## Test Sharding

Split large suites across parallel runners.

**When to shard**: Suite >60s. Don't shard <30s — overhead exceeds savings.

```yaml
jobs:
  test:
    strategy:
      matrix:
        shard: [1/3, 2/3, 3/3]
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install --frozen-lockfile --yarn
      - run: vitest run --shard=${{ matrix.shard }} --reporter=blob
      - uses: actions/upload-artifact@v4
        with:
          name: blob-report-${{ strategy.job-index }}
          path: .vitest-reports/

  merge-reports:
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - uses: actions/download-artifact@v4
        with:
          pattern: blob-report-*
          merge-multiple: true
          path: .vitest-reports
      - run: bunx vitest --merge-reports --coverage
```

`--reporter=blob` writes shard-aware chunks. `--merge-reports` aggregates into unified coverage+results. Thresholds apply to merged report.

## Coverage Gates

80% lines / 80% functions / 70% branches floor. Don't chase 100%.

## Bundle Size Budget

Main chunk <300KB gzip, total <1MB gzip. Rsdoctor (`@rsdoctor/rspack-plugin`) for analysis.
