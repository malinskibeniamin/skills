# LLM Optimization Reference

## llm-env.sh (SessionStart)

> Script: [`scripts/llm-env.sh`](scripts/llm-env.sh)

## llm-test-flags.sh (PreToolUse on Bash)

> Script: [`scripts/llm-test-flags.sh`](scripts/llm-test-flags.sh)

## llm-truncate.sh (PostToolUse on Bash)

> Script: [`scripts/llm-truncate.sh`](scripts/llm-truncate.sh)

## Token Savings Breakdown

| Optimization | Mechanism | Estimated savings |
|-------------|-----------|------------------|
| AI_AGENT=1 | Vitest agent reporter: only shows failures | ~60-80% on test output |
| CLAUDECODE=1 | Bun test: hides passing tests | ~60-80% on test output |
| Block --verbose | Prevents accidentally reverting to verbose mode | variable |
| Truncate >200 lines | Caps output from `bun install`, stack traces, etc. | ~80% on large outputs |

## Environment Variable Reference

| Var | Effect on Vitest | Effect on Bun | Effect on Rstest |
|-----|-----------------|---------------|-----------------|
| `AI_AGENT=1` | Enables agent reporter (failures only) | No effect | Defaults to md reporter |
| `CLAUDECODE=1` | No effect | Shows only failures + summary | No effect |
