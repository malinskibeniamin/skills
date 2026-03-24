# Project Rules

This project optimizes for AI agent token usage:
- NEVER use `--verbose` flag on test runners (vitest, jest, bun test). It wastes tokens.
- `AI_AGENT=1` and `CLAUDECODE=1` are already set for LLM-friendly output.
- Use `bun test` without verbose flags.

# Task

Run the project's test suite and show the results. Do NOT use --verbose flag.
