# Biome + Ultracite Reference

## biome.jsonc

```jsonc
{
  "$schema": "./node_modules/@biomejs/biome/configuration_schema.json",
  "extends": ["ultracite/biome/core", "ultracite/biome/react"],
  "vcs": {
    "enabled": true,
    "clientKind": "git",
    "useIgnoreFile": true,
    "defaultBranch": "main"
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100
  },
  "organizeImports": {
    "enabled": true
  },
  "linter": {
    "rules": {
      "suspicious": {
        "noConsole": "error"
      },
      "complexity": {
        "noExcessiveCognitiveComplexity": {
          "level": "error",
          "options": { "maxAllowedComplexity": 15 }
        }
      },
      "style": {
        "noRestrictedImports": {
          "level": "error",
          "options": {
            "paths": {
              "moment": "Use date-fns instead of moment.",
              "lodash": "Use native JS methods or specific lodash subpackages (e.g., lodash/get).",
              "classnames": "Use clsx or the cn utility instead.",
              "enzyme": "Use @testing-library/react instead of enzyme."
            }
          }
        }
      },
      "nursery": {
        "noDeprecatedImports": "error"
      }
    }
  },
  "overrides": [
    {
      "includes": ["**/*.test.*", "**/*.spec.*", "**/__tests__/**"],
      "linter": {
        "rules": {
          "suspicious": {
            "noExplicitAny": "error"
          }
        }
      }
    }
  ]
}
```

## biome-autofix.sh

```bash
#!/bin/bash
set -euo pipefail

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

# Only run for Edit and Write tools
if [ "$tool_name" != "Edit" ] && [ "$tool_name" != "Write" ]; then
  exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [ -z "$file_path" ]; then
  exit 0
fi

# Only lint JS/TS/JSX/TSX files
case "$file_path" in
  *.js|*.jsx|*.ts|*.tsx|*.mjs|*.mts|*.cjs|*.cts) ;;
  *) exit 0 ;;
esac

# Skip if file doesn't exist (was deleted)
if [ ! -f "$file_path" ]; then
  exit 0
fi

# Run biome fix on just this file, skipping noUnusedImports to avoid
# deleting imports Claude hasn't used yet (caught later at quality:gate)
fix_output=""
fix_exit=0
fix_output=$(biome check --write --skip=lint/correctness/noUnusedImports "$file_path" 2>&1) || fix_exit=$?

# Check if there are remaining unfixable errors
if [ $fix_exit -ne 0 ]; then
  # Run check-only to get remaining errors
  remaining=""
  remaining=$(biome check --skip=lint/correctness/noUnusedImports "$file_path" 2>&1) || true

  if [ -n "$remaining" ]; then
    # Truncate to avoid flooding context
    truncated=$(echo "$remaining" | head -20)
    # Escape for JSON
    escaped=$(echo "$truncated" | jq -Rs .)
    echo "{\"suppressOutput\":true,\"systemMessage\":\"Biome found unfixable errors in $file_path:\\n\"$escaped\"\"}"
    exit 0
  fi
fi

# Auto-fix succeeded silently — suppress all output
echo '{"suppressOutput":true}'
exit 0
```

## Ultracite Overrides Explained

Ultracite provides a strict baseline. We override these specific behaviors:

| Rule | Ultracite default | Our override | Why |
|------|-------------------|-------------|-----|
| `noConsole` | off | error | Ban console.log in production code |
| `noExcessiveCognitiveComplexity` | threshold 20 | threshold 15 | Stricter complexity limit |
| `noExplicitAny` in tests | off | error | No `any` escape hatch, even in tests |
| `noDeprecatedImports` | off | error | Catch deprecated API usage |
| `noRestrictedImports` | enabled, empty | configured | Ban moment, lodash, classnames, enzyme |

## Import Deletion Loop Prevention

The PostToolUse hook skips `noUnusedImports` using `--skip=lint/correctness/noUnusedImports`. This prevents:

1. Claude adds `import { Button } from '@/redpanda-ui/button'`
2. Biome deletes it (unused — Claude hasn't written JSX yet)
3. Claude re-adds it
4. Infinite loop

Unused imports are caught at the Stop hook / `quality:gate` when Claude is done editing.
