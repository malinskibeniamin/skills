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
  "assist": {
    "actions": {
      "source": {
        "organizeImports": "on"
      }
    }
  },
  "linter": {
    "rules": {
      "suspicious": {
        "noConsole": "error",
        "noReactForwardRef": "off"
      },
      "complexity": {
        "noExcessiveCognitiveComplexity": {
          "level": "error",
          "options": { "maxAllowedComplexity": 15 }
        }
      },
      "style": {
        "useFilenamingConvention": {
          "level": "error",
          "options": {
            "strictCase": true,
            "filenameCases": ["kebab-case"]
          }
        },
        "noRestrictedImports": {
          "level": "error",
          "options": {
            "paths": {
              "moment": "Use date-fns instead of moment.",
              "lodash": "Use native JS methods or specific lodash subpackages (e.g., lodash/get).",
              "classnames": "Use clsx or the cn utility instead.",
              "mobx": "Use zustand for state management instead of MobX.",
              "mobx-react": "Use zustand for state management instead of MobX.",
              "mobx-react-lite": "Use zustand for state management instead of MobX.",
              "yup": "Use zod for schema validation instead of yup."
            }
          }
        }
      },
      "nursery": {
        "useExhaustiveSwitchCases": "error"
      },
      "project": {
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

Stop hook that auto-fixes lint/format on all changed JS/TS files before Claude finishes.

```bash
#!/bin/bash
set -euo pipefail

# Stop hook: run biome lint:fix on all changed JS/TS files before Claude finishes.
# Only runs if JS/TS files were actually changed.

# Check if any JS/TS files were changed.
# git diff returns paths relative to repo root; strip the prefix so they're
# relative to cwd (where bun run lint:fix:file executes).
# In monorepos, files outside the current package appear in diff but don't exist
# relative to cwd — filter them out to avoid "file not found" errors.
repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
cwd=$(pwd)
prefix="${cwd#"$repo_root"/}/"
# Skip component library directories
# Auto-detect: check common conventions, override with UI_LIB_DIRS env var (pipe-separated)
if [ -z "${UI_LIB_DIRS:-}" ]; then
  _ui_dirs="components/ui"
  [ -d "$repo_root/redpanda-ui" ] && _ui_dirs="$_ui_dirs|redpanda-ui"
  [ -d "$repo_root/src/ui" ] && _ui_dirs="$_ui_dirs|src/ui"
  [ -d "$repo_root/packages/ui" ] && _ui_dirs="$_ui_dirs|packages/ui"
else
  _ui_dirs="$UI_LIB_DIRS"
fi
all_changed=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(js|jsx|ts|tsx|mjs|mts|cjs|cts)$' | grep -vE "/($_ui_dirs)/" | sed "s|^${prefix}||" || true)

# Filter to files that actually exist (excludes monorepo siblings)
changed_files=""
for f in $all_changed; do
  if [ -f "$f" ]; then
    changed_files="$changed_files $f"
  fi
done
changed_files=$(echo "$changed_files" | xargs)

if [ -z "$changed_files" ]; then
  exit 0
fi

# Run lint:fix on changed files only. Uses lint:fix:file / lint:file which
# do NOT hardcode "." — so biome only scans the listed files, not everything.
# Skip noUnusedImports to avoid deleting imports used elsewhere in the file.
fix_output=""
fix_exit=0
fix_output=$(bun run lint:fix:file -- --skip=lint/correctness/noUnusedImports $changed_files 2>&1) || fix_exit=$?

if [ $fix_exit -ne 0 ]; then
  # Check remaining errors — filter out biome's summary lines to detect real errors
  remaining=""
  remaining=$(bun run lint:file -- --skip=lint/correctness/noUnusedImports $changed_files 2>&1) || true

  # Only block if error file paths reference non-library files
  error_files=$(echo "$remaining" | grep -E '^\S+\.(tsx?|jsx?):\d+:\d+' | grep -vE "/($_ui_dirs)/" | grep -v 'internalError/io' || true)
  if [ -n "$error_files" ]; then
    truncated=$(echo "$remaining" | grep -vE "/($_ui_dirs)/" | head -30)
    escaped=$(echo "$truncated" | jq -Rs .)
    echo "{\"decision\":\"block\",\"reason\":\"Biome found unfixable lint errors. Fix these before finishing:\\n\"$escaped\"\"}" >&2
    exit 2
  fi
fi

exit 0
```

## Ultracite Overrides Explained

Ultracite provides a strict baseline. We override these specific behaviors:

| Rule | Group | Ultracite default | Our override | Why |
|------|-------|-------------------|-------------|-----|
| `noConsole` | suspicious | off | error | Ban console.log in production code |
| `noReactForwardRef` | suspicious | on | off | Keep off for React 18 — forwardRef is still required |
| `noExcessiveCognitiveComplexity` | complexity | threshold 20 | threshold 15 | Stricter complexity limit |
| `noExplicitAny` in tests | suspicious | off | error | No `any` escape hatch, even in tests |
| `noDeprecatedImports` | project | off | error | Catch deprecated API usage (requires Biome Scanner) |
| `useFilenamingConvention` | style | off | kebab-case, strict | Enforce kebab-case filenames (`my-component.tsx`, not `MyComponent.tsx`) |
| `noRestrictedImports` | style | enabled, empty | configured | Ban moment, lodash, classnames, mobx, yup |
| `useExhaustiveSwitchCases` | nursery | off | error | Require exhaustive switch/case for type safety |
| `organizeImports` | assist | — | on | Auto-sort imports via `assist.actions.source` |

**Note:** `noClassComponent` was removed from Biome 2.x. Class components are discouraged by convention instead. The React Compiler skill enforces functional patterns via the memoization check.

## Import Deletion Loop Prevention

The PostToolUse hook skips `noUnusedImports` using `--skip=lint/correctness/noUnusedImports`. This prevents:

1. Claude adds `import { Button } from '@/components/ui/button'`
2. Biome deletes it (unused — Claude hasn't written JSX yet)
3. Claude re-adds it
4. Infinite loop

Unused imports are caught at the Stop hook / `quality:gate` when Claude is done editing.
