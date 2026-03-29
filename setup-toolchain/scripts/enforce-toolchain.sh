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
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"tsc is banned. Use tsgo instead for type checking.\n- tsc → tsgo\n- tsc --noEmit → tsgo --noEmit\n- bun run type:check should use tsgo in package.json"}' >&2
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

# Block destructive rm -rf / rm -r / rm --recursive (allow safe targets)
if echo "$command" | grep -qE '(^|\s|&&|\|\||;)rm\s+(-[a-zA-Z]*r[a-zA-Z]*|--recursive)(\s|$)'; then
  safe_targets="node_modules .next dist build .cache .turbo coverage __pycache__"
  # Extract the rm subcommand, strip "rm" and all flags (words starting with -)
  rm_part=$(echo "$command" | grep -oE 'rm\s+.*' | head -1)
  targets=""
  for word in $rm_part; do
    case "$word" in
      rm) ;; # skip rm itself
      -*) ;; # skip flags
      *)  targets="$targets $word" ;; # path argument
    esac
  done
  all_safe=true
  for t in $targets; do
    t=$(basename "$t")
    found=false
    for s in $safe_targets; do
      if [ "$t" = "$s" ]; then
        found=true
        break
      fi
    done
    if [ "$found" = false ]; then
      all_safe=false
      break
    fi
  done
  if [ "$all_safe" = false ]; then
    echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"Destructive rm -rf is blocked. Only these targets are allowed: node_modules, .next, dist, build, .cache, .turbo, coverage, __pycache__. Remove files individually or use a more targeted command."}' >&2
    exit 2
  fi
fi

# Block git push --force / -f (but allow --force-with-lease)
if echo "$command" | grep -qE '(^|\s|&&|\|\||;)git\s+push\s' && echo "$command" | grep -qE '\s(--force|-f)(\s|$)' && ! echo "$command" | grep -qF -- '--force-with-lease'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"git push --force is blocked. Use --force-with-lease instead for safer force pushes."}' >&2
  exit 2
fi

# Block git reset --hard
if echo "$command" | grep -qE '(^|\s|&&|\|\||;)git\s+reset\s+--hard'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"git reset --hard is blocked. This discards all uncommitted changes. Use git stash or git reset --soft instead."}' >&2
  exit 2
fi

# Block git checkout . / git restore . (discards all uncommitted changes)
if echo "$command" | grep -qE '(^|\s|&&|\|\||;)git\s+(checkout|restore)\s+\.\s*($|;|&&|\|\|)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"git checkout . / git restore . is blocked. This discards all uncommitted changes. Restore specific files instead: git checkout -- <file> or git restore <file>."}' >&2
  exit 2
fi

exit 0
