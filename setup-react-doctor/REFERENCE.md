# React Doctor Reference

## react-doctor-stop.sh

```bash
#!/bin/bash
set -euo pipefail

# Check if any React files were changed
changed_files=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(tsx|jsx)$' || true)

if [ -z "$changed_files" ]; then
  exit 0
fi

# Run react-doctor in diff mode
output=""
exit_code=0
output=$(bun run doctor -- --diff --score 2>&1) || exit_code=$?

if [ $exit_code -ne 0 ]; then
  truncated=$(echo "$output" | head -30)
  escaped=$(echo "$truncated" | jq -Rs .)
  echo "{\"decision\":\"block\",\"reason\":\"React Doctor found issues in changed files:\\n\"$escaped\"\"}" >&2
  exit 2
fi

# Extract score if available
score=$(echo "$output" | grep -oE '[0-9]+' | tail -1 || echo "")

if [ -n "$score" ] && [ "$score" -lt 50 ]; then
  echo "{\"decision\":\"block\",\"reason\":\"React Doctor health score is $score/100 (critical). Fix issues before finishing.\"}" >&2
  exit 2
fi

exit 0
```

## Rule Categories

| Category | Biome covers? | Keep in react-doctor? |
|----------|--------------|----------------------|
| Hook dependencies | Yes | No (disabled) |
| Nested components | Yes | No (disabled) |
| Performance patterns | No | Yes |
| Bundle size analysis | No | Yes |
| Dead code detection | No | Yes |
| Security (secrets, XSS) | Partial | Yes |
| Accessibility | Partial | Yes |
| Architecture (prop drilling) | No | Yes |

## CLI Flags

| Flag | Purpose |
|------|---------|
| `--diff` | Only scan changed files |
| `--verbose` | Show file-level details |
| `--score` | Output just the numeric score |
| `--no-lint` | Skip linting (keep dead code) |
| `--no-dead-code` | Skip dead code (keep linting) |
| `--fix` | Auto-fix with AI |
