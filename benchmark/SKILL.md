---
name: benchmark
description: "Use when running /qa or /canary, or when a PR changes user-facing pages, to capture Core Web Vitals and compare against stored baseline. Blocks merge on >10% regression on any metric. Runs Lighthouse CI or WebPageTest."
---

# Benchmark — Core Web Vitals Gate

Lighthouse/WPT on critical pages. Compare vs baseline. >10% regress → block.

## Input

`$ARGUMENTS`: empty (use `.claude/benchmark.json` page list) or `<url>` single page.

## Config

`.claude/benchmark.json`:

    { "tool": "lhci" | "wpt",
      "pages": ["/", "/dashboard", "/checkout"],
      "base_url_env": "BENCH_BASE_URL",
      "regression_pct": 10 }

Baseline file: `.claude/baselines/perf.json`.

## Workflow

### 1. Tool Check
`lhci --version` or `webpagetest --version`. Missing → print install hint, exit 0 (do not block on tooling absence unless `BENCH_REQUIRED=1`).

### 2. Run
Per page, N=3 runs, use median. Capture:

- LCP (Largest Contentful Paint)
- INP (preferred) or FID
- CLS (Cumulative Layout Shift)
- TTFB (Time to First Byte)

Use `Monitor:` for long runs.

### 3. Baseline Path

No baseline → write current as baseline, print "baseline captured", exit 0.

Baseline exists → compare.

### 4. Compare

Per page × metric:

    delta_pct = (current - baseline) / baseline * 100

Regress if `delta_pct > regression_pct`. CLS uses absolute delta > 0.05.

### 5. Report

    | Page | Metric | Baseline | Current | Δ% | Status |
    |---|---|---|---|---|---|
    | / | LCP | 1800 | 2100 | +16.6 | FAIL |
    | / | INP | 120 | 125 | +4.1 | ok |

### 6. Gate

Any FAIL → exit non-zero → blocks merge (caller `/qa` or `/canary` surfaces).

### 7. Update Baseline

Green run + user opt-in (`--update-baseline`) → overwrite `.claude/baselines/perf.json`. Commit separately.

## Escape Hatch

`// allow: perf-regression [reason + mitigation plan]` in PR body or commit trailer. Reason + plan both mandatory. Logged.

## Scope

Diff-adjacent pages only if `--changed`. Default: full page list from config.
