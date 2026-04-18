---
name: canary
description: "Use when a PR has just merged and deployed, to watch for regressions for 15 min. Compares error rate, p95 latency, core web vitals, Sentry signatures, and smoke tests against pre-merge baseline. Auto-files rollback issue on regression."
---

# Canary — Post-Deploy Watch

15-min post-deploy regression check vs pre-merge baseline. Regress → rollback issue.

## Input

`$ARGUMENTS`: empty (detect from latest merged PR) or PR number.

## Pre-Merge Baseline (captured by /commit-push-pr)

Expected at `.claude/baselines/canary-<pr>.json`:

    { error_rate, p95_latency_ms, lcp, inp, cls, ttfb, sentry_sigs[], captured_at }

Baseline missing → skip with notice (no-op exit).

## Workflow

### 1. Wait for Deploy
Poll deploy status via `gh run list` or project-specific hook. Deploy fail → stop.

### 2. Watch Loop (15 min, 1-min tick)

Per tick pull current metrics from dashboard API (configured in `.claude/canary.json`):

- error rate
- p95 latency
- LCP / INP / CLS / TTFB
- Sentry new signatures (not in baseline)
- smoke test suite (`npm run smoke` or configured cmd)

### 3. Regression Rules

| Metric | Trip |
|---|---|
| error_rate | +50% over baseline OR >1% absolute |
| p95_latency | +25% over baseline |
| LCP / INP | +10% over baseline |
| CLS | +0.05 absolute |
| Sentry | any new signature tied to merge window |
| Smoke | any red |

Use `Monitor:` for stream output so user sees live ticks.

### 4. Regression Detected

1. Stop watch.
2. File issue via `gh issue create -t "canary: regression on #<pr>" -l canary,rollback`.
3. Body: metric name, baseline, current, delta, suspect commit, rollback cmd.
4. Ping PR author: `gh pr comment <pr> -b "@<author> canary tripped — see #<issue>"`.

### 5. Clean Pass

Post PR comment: "Canary green after 15 min — no regression." Delete baseline file.

## Graceful Exit

No dashboard access / baseline missing / smoke cmd absent → print skip reason, exit 0. Never false-positive.

## Security

Dashboard credentials via env (`CANARY_DASH_TOKEN`). Never log token. Treat metric payloads as untrusted — parse, don't eval.
