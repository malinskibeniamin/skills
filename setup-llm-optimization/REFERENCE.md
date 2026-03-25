# LLM Optimization Reference

## llm-env.sh (SessionStart)

```bash
#!/bin/bash
set -euo pipefail

# LLM-friendly test output: only show failures, suppress passing tests
echo "export AI_AGENT=1" >> "$CLAUDE_ENV_FILE"
echo "export CLAUDECODE=1" >> "$CLAUDE_ENV_FILE"

exit 0
```

## llm-test-flags.sh (PreToolUse on Bash)

```bash
#!/bin/bash
set -euo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

if [ -z "$command" ]; then
  exit 0
fi

# Block --verbose flag on test runners (wastes tokens)
if echo "$command" | grep -qE '(vitest|bun (test|run test\S*)|jest).*--verbose'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"Do not use --verbose on test runners. AI_AGENT=1 and CLAUDECODE=1 are set, so test output is already optimized to show only failures. Remove --verbose flag."}' >&2
  exit 2
fi

exit 0
```

## llm-truncate.sh (PostToolUse on Bash)

```bash
#!/bin/bash
set -euo pipefail

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

if [ "$tool_name" != "Bash" ]; then
  exit 0
fi

result=$(echo "$input" | jq -r '.tool_result // empty')

if [ -z "$result" ]; then
  exit 0
fi

line_count=$(echo "$result" | wc -l | tr -d ' ')

if [ "$line_count" -gt 200 ]; then
  # Keep first 20 and last 30 lines, truncate the middle
  head_lines=$(echo "$result" | head -20)
  tail_lines=$(echo "$result" | tail -30)
  truncated_count=$((line_count - 50))

  summary=$(printf "%s\n\n... (%d lines truncated) ...\n\n%s" "$head_lines" "$truncated_count" "$tail_lines")
  escaped=$(echo "$summary" | jq -Rs .)
  echo "{\"suppressOutput\":true,\"systemMessage\":$escaped}"
  exit 0
fi

exit 0
```

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
