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
              "yup": "Use zod for schema validation instead of yup.",
              "recoil": "Recoil is archived by Meta. Use zustand instead.",
              "react-scripts": "Create React App is deprecated. Use rsbuild or vite."
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

> Script: [`scripts/biome-autofix.sh`](scripts/biome-autofix.sh)

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
