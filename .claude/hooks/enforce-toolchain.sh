#!/bin/bash
set -euo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

if [ -z "$command" ]; then
  exit 0
fi

# Block npm commands
if echo "$command" | grep -qE '(^|\s|&&|\|\||;)npm\s'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"npm is banned. Use bun instead.\n- npm install → bun install --yarn\n- npm run → bun run\n- npm test → bun test\n- npm ci → bun install --frozen-lockfile --yarn"}' >&2
  exit 2
fi

# Block npx commands
if echo "$command" | grep -qE '(^|\s|&&|\|\||;)npx\s'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"npx is banned. Use bunx instead, or preferably use the package.json script equivalent (bun run <script>)."}' >&2
  exit 2
fi

# Block tsc commands
if echo "$command" | grep -qE '(^|\s|&&|\|\||;)tsc(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"tsc is banned. Use tsgo instead for type checking.\n- tsc → tsgo\n- tsc --noEmit → tsgo --noEmit\n- npm run typecheck should use tsgo in package.json"}' >&2
  exit 2
fi

# Block global installs
if echo "$command" | grep -qE 'bun\s+(add|install)\s+.*-g(\s|$)' || echo "$command" | grep -qE 'bun\s+(add|install)\s+.*--global(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"Global package installs are banned. Install as a devDependency instead: bun add -D <package> --yarn"}' >&2
  exit 2
fi

# Block installing eslint or prettier
if echo "$command" | grep -qE 'bun\s+(add|install)\s.*\b(eslint|prettier)\b'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"Do not install eslint or prettier. This project uses Biome + Ultracite for linting and formatting. Run bun run lint or bun run lint:fix."}' >&2
  exit 2
fi

# Block eslint as a direct command
if echo "$command" | grep -qE '(^|\s|&&|\|\||;)eslint(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"eslint is banned. This project uses Biome for linting.\n- eslint → bun run lint\n- eslint --fix → bun run lint:fix"}' >&2
  exit 2
fi

# Block prettier as a direct command
if echo "$command" | grep -qE '(^|\s|&&|\|\||;)prettier(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"prettier is banned. This project uses Biome for formatting.\n- prettier → bun run lint:fix"}' >&2
  exit 2
fi

# Block direct bunx for tools that have package.json scripts
if echo "$command" | grep -qE '(^|\s|&&|\|\||;)bunx\s+(ultracite|biome|@biomejs/biome|react-doctor|tsr|@tanstack/router-cli|eslint|prettier)'; then
  tool=$(echo "$command" | grep -oE 'bunx\s+\S+' | head -1 | awk '{print $2}')
  echo "{\"hookSpecificOutput\":{\"permissionDecision\":\"deny\"},\"systemMessage\":\"Do not run ${tool} directly via bunx. Use the package.json script instead (bun run <script>) to ensure CI and local dev produce identical results.\"}" >&2
  exit 2
fi

# Ensure --yarn flag on bun install/add (for Snyk yarn.lock compatibility)
if echo "$command" | grep -qE '(^|\s|&&|\|\||;)bun\s+(install|add)(\s|$)'; then
  if ! echo "$command" | grep -qF -- '--yarn'; then
    echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"Always use --yarn flag with bun install/add to generate yarn.lock for Snyk security scans.\n- bun install → bun install --yarn\n- bun add <pkg> → bun add <pkg> --yarn"}' >&2
    exit 2
  fi
fi

exit 0
