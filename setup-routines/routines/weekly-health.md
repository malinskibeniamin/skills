# Routine: Weekly Codebase Health

Run weekly. Measure codebase health, catch drift. Only report when something **changed** or **degraded** since last run.

## Important: avoid noise

Do NOT create report if everything green and unchanged. Silence = healthy. Only open issue when:
- Quality check that was passing now failing
- Verification regressed (a contract check fails, becomes flaky or cannot run independently)
- New vulnerability or measured performance regression appeared
- New pattern drift appeared

## Steps

### 1. Run project quality checks

Detect available scripts from package.json, run them. Continue on failure -- collect all results.

```bash
# Read available scripts
cat package.json | jq -r '.scripts | keys[]' 2>/dev/null

# Run standard checks (adapt to what exists)
# Type checking
bun run type:check 2>&1 | tail -50 || true

# Linting
bun run lint 2>&1 | tail -50 || true

# Tests
bun test --run 2>&1 | tail -50 || true
```

### 2. Check dependencies

```bash
# Outdated deps (if bun)
bun outdated 2>&1 | head -30 || npm outdated 2>&1 | head -30 || true

# Security audit
bun audit 2>&1 | head -30 || npm audit 2>&1 | head -30 || true
```

### 3. Run verify-install (if available)

```bash
if [ -f scripts/verify-install.sh ]; then
  bash scripts/verify-install.sh --json 2>&1
fi
```

### 4. Measure code health signals

Apply [verifiability over readability](../../shared/verifiability.md). Start with
modules changed since the previous report and their existing public-contract checks.

- Resolve focused verification commands from the maintained test map, package scripts
  and runner configuration; a missing co-located test file does not prove a gap.
- Run representative contract checks independently of unrelated app layers. Record
  command, fixture, result, setup dependencies and failure diagnostics. Name blocked
  checks as unverified; do not turn missing prerequisites into a pass.
- Compare repeatability, setup coupling, verification time and credible untested
  behavior with the previous run. Report a new gap with the affected contract and
  smallest reproducer or concrete blocked verification path.
- Preserve domain-language discoverability and human access to the relevant check.
  File/function size, nesting, cyclomatic complexity, TODO counts and coverage
  percentages alone are not health regressions or reasons to split code.

### 5. Compare with previous report

Search previous health report issues:

```bash
gh issue list --state all --label "health-report" --limit 1 --json number,body
```

Compare current with previous. Only flag **regressions** -- improvements good but not worth issue.

### 6. Report (only if regressions found)

```bash
gh issue create \
  --title "Codebase health regression -- $(date +%Y-%m-%d)" \
  --label "health-report,automated" \
  --body "## Codebase Health Regression

### What changed
[Only list items that regressed since last report]

| Check | Previous | Current | Delta |
|---|---|---|---|
| [check name] | [old value] | [new value] | [direction] |

### Recommended actions
1. [Highest impact action]
2. [Second action]

---
*Detected by Claude Code routine. Previous report: #[number]*"
```

If everything stable or improved -> do nothing. Close previous open health-report issues now resolved.

## Rules

- Read-only. Never edit code, create branches, or fix issues.
- Compare with previous report -- only surface deltas, not absolute state.
- No previous report exists -> create baseline (first run only).
- Silence = healthy. No "all clear" issues.
- Adapt checks to project stack -- read package.json, Makefile, or build config to detect available tools.
