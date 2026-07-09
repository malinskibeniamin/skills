#!/bin/bash
# Extracted check logic for env-validation-check.sh. Source ../_hook-lib.sh before this file.

run_env_validation_check() {
hook_filter_extensions "ts|tsx" || return 0

# Skip files where process.env is correct (build config, env definitions, scripts)
case "$(basename "$file_path")" in
  env.ts|env.mts|env.mjs|env.js) return 0 ;;
  rsbuild.config.*|vite.config.*|webpack.config.*) return 0 ;;
  next.config.*|nuxt.config.*|astro.config.*) return 0 ;;
  vitest.config.*|jest.config.*|playwright.config.*) return 0 ;;
  tailwind.config.*|postcss.config.*|biome.jsonc) return 0 ;;
  tsconfig.*|.eslintrc.*|.prettierrc.*) return 0 ;;
  Dockerfile|docker-compose.*) return 0 ;;
esac

# Skip config directories
if echo "$file_path" | grep -qE '(config/|scripts/|\.config\.)'; then
  return 0
fi

hook_skip_tests
hook_get_added_lines

# Check for raw process.env access (exclude build-time constants)
if echo "$added_lines" | grep -vE 'process\.env\.(NODE_ENV|DEV|PROD|SSR|TEST)' | grep -qE 'process\.env\.'; then
  hook_block "No raw process.env. Import from @/env. Declare vars in src/env.ts with t3-env+zod. Exception: NODE_ENV."
fi

return 0
}
