#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "ts|tsx|js|jsx"

# Skip files where process.env is correct (build config, env definitions, scripts)
case "$(basename "$file_path")" in
  env.ts|env.mts|env.mjs|env.js) exit 0 ;;                         # env definition
  rsbuild.config.*|vite.config.*|webpack.config.*) exit 0 ;;        # bundler config
  next.config.*|nuxt.config.*|astro.config.*) exit 0 ;;             # framework config
  vitest.config.*|jest.config.*|playwright.config.*) exit 0 ;;      # test runner config
  tailwind.config.*|postcss.config.*|biome.jsonc) exit 0 ;;         # tooling config
  tsconfig.*|.eslintrc.*|.prettierrc.*) exit 0 ;;                   # ts/lint config
  Dockerfile|docker-compose.*) exit 0 ;;                            # container config
esac

# Skip config directories
if echo "$file_path" | grep -qE '(config/|scripts/|\.config\.)'; then
  exit 0
fi

hook_skip_tests
hook_get_added_lines

# Check for raw process.env access
if echo "$added_lines" | grep -qE 'process\.env\.'; then
  hook_block "Do not use raw process.env access.\nImport the validated env object: import { env } from \\\"@/env\\\".\n\nAll variables must be declared in src/env.ts with t3-env zod validation."
fi

exit 0
