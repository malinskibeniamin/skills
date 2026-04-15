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
              "react-scripts": "Create React App is deprecated. Use rsbuild or vite.",
              "react-beautiful-dnd": "Archived by Atlassian. Use @dnd-kit/core instead.",
              "framer-motion": "Renamed to 'motion'. Use the motion package instead.",
              "@redpanda-data/ui": "Legacy Chakra library. Use redpanda-ui registry components instead.",
              "lucide-react": "Use components/icons barrel for consistent icon usage."
            }
          }
        }
      },
      "correctness": {
        "noRestrictedElements": {
          "level": "error",
          "options": {
            "elements": {
              "button": "Use <Button> from @/components/ui/ instead.",
              "input": "Use <Input> from @/components/ui/ instead.",
              "select": "Use <Select> from @/components/ui/ instead.",
              "textarea": "Use <Textarea> from @/components/ui/ instead."
            }
          }
        }
      },
      "nursery": {
        "useExhaustiveSwitchCases": "error",
        "useConsistentTestIt": {
          "level": "error",
          "options": { "function": "test", "withinDescribe": "test" }
        },
        "noPlaywrightWaitForTimeout": "error"
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

Stop hook: auto-fix lint/format on changed JS/TS files.

> Script: [`scripts/biome-autofix.sh`](scripts/biome-autofix.sh)

## Ultracite Overrides Explained

Ultracite strict baseline. Overrides:

| Rule | Group | Ultracite default | Our override | Why |
|------|-------|-------------------|-------------|-----|
| `noConsole` | suspicious | off | error | Ban console.log in prod |
| `noReactForwardRef` | suspicious | on | off | Keep off for React 18 — forwardRef still required |
| `noExcessiveCognitiveComplexity` | complexity | threshold 20 | threshold 15 | Stricter complexity limit |
| `noExplicitAny` in tests | suspicious | off | error | No `any` escape, even in tests |
| `noDeprecatedImports` | project | off | error | Catch deprecated API usage (needs Biome Scanner) |
| `useFilenamingConvention` | style | off | kebab-case, strict | Enforce kebab-case filenames (`my-component.tsx`, not `MyComponent.tsx`) |
| `noRestrictedImports` | style | enabled, empty | configured | Ban moment, lodash, classnames, mobx, yup, @redpanda-data/ui, lucide-react |
| `noRestrictedElements` | correctness | off | configured | Ban raw `<button>`, `<input>`, `<select>`, `<textarea>` — use registry |
| `useExhaustiveSwitchCases` | nursery | off | error | Require exhaustive switch/case for type safety |
| `useConsistentTestIt` | nursery | off | test only | Enforce `test()` over `it()` |
| `noPlaywrightWaitForTimeout` | nursery | off | error | Ban `page.waitForTimeout()` in Playwright tests |
| `organizeImports` | assist | — | on | Auto-sort imports via `assist.actions.source` |

**Note:** `noClassComponent` removed in Biome 2.x. React Compiler skill enforce functional patterns via memoization check.

## Import Deletion Loop Prevention

PostToolUse hook skip `noUnusedImports` (`--skip=lint/correctness/noUnusedImports`). Prevent:

1. Claude add `import { Button } from '@/components/ui/button'`
2. Biome delete it (unused — Claude hasn't written JSX yet)
3. Claude re-add it
4. Infinite loop

Caught at Stop hook / `quality:gate` when done editing.