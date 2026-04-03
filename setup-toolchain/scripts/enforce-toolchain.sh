#!/bin/bash
set -euo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

if [ -z "$command" ]; then
  exit 0
fi

# Strip quoted strings and heredoc content to avoid matching banned words
# inside commit messages, echo statements, etc.
_cmd_stripped=$(echo "$command" | sed 's/"[^"]*"//g' | sed "s/'[^']*'//g")
if echo "$command" | grep -qE 'cat <<'; then
  _cmd_stripped=$(echo "$_cmd_stripped" | sed '/<<.*EOF/,/^[[:space:]]*EOF/d')
fi

# Block npm commands
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)npm\s'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"npm is banned. Use bun instead.\nbun install | bun run | bun test | bun install --frozen-lockfile"}' >&2
  exit 2
fi

# Block npx commands
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)npx\s'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"npx is banned. Use bunx instead.\nOr preferably use the package.json script: bun run <script>."}' >&2
  exit 2
fi

# Block tsc commands
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)tsc(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"tsc is banned. Use tsgo instead.\ntsgo --noEmit for type checking. Update package.json scripts accordingly."}' >&2
  exit 2
fi

# Block global installs
if echo "$_cmd_stripped" | grep -qE 'bun\s+(add|install)\s+.*-g(\s|$)' || echo "$_cmd_stripped" | grep -qE 'bun\s+(add|install)\s+.*--global(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"Global package installs are banned.\nInstall as a devDependency instead: bun add -D <package>."}' >&2
  exit 2
fi

# Block installing eslint or prettier
if echo "$_cmd_stripped" | grep -qE 'bun\s+(add|install)\s.*\b(eslint|prettier)\b'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"Do not install eslint or prettier.\nThis project uses Biome + Ultracite. Run bun run lint or bun run lint:fix."}' >&2
  exit 2
fi

# Block eslint as a direct command
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)eslint(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"eslint is banned. This project uses Biome.\nbun run lint (check) | bun run lint:fix (auto-fix)."}' >&2
  exit 2
fi

# Block prettier as a direct command
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)prettier(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"prettier is banned. This project uses Biome.\nRun bun run lint:fix for formatting."}' >&2
  exit 2
fi

# Block direct bunx for tools that have package.json scripts
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)bunx\s+(ultracite|biome|@biomejs/biome|react-doctor|tsr|@tanstack/router-cli|eslint|prettier)'; then
  tool=$(echo "$command" | grep -oE 'bunx\s+\S+' | head -1 | awk '{print $2}')
  echo "{\"hookSpecificOutput\":{\"permissionDecision\":\"deny\"},\"systemMessage\":\"Do not run ${tool} directly via bunx.\nUse the package.json script (bun run <script>) for CI/local parity.\"}" >&2
  exit 2
fi

# --yarn flag enforcement removed — yarn.lock no longer required

# Block destructive rm -rf / rm -r / rm --recursive (allow safe targets)
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)rm\s+(-[a-zA-Z]*r[a-zA-Z]*|--recursive)(\s|$)'; then
  safe_targets="node_modules .next dist build .cache .turbo coverage __pycache__"
  rm_part=$(echo "$command" | grep -oE 'rm\s+.*' | head -1)
  targets=""
  for word in $rm_part; do
    case "$word" in
      rm|-*) continue ;;
      *) targets="$targets $word" ;;
    esac
  done
  targets=$(echo "$targets" | xargs)

  all_safe=true
  for t in $targets; do
    base=$(basename "$t")
    is_safe=false
    for s in $safe_targets; do
      if [ "$base" = "$s" ] || echo "$t" | grep -qF "$s/"; then
        is_safe=true
        break
      fi
    done
    if [ "$is_safe" = false ]; then
      all_safe=false
      break
    fi
  done

  if [ "$all_safe" = false ]; then
    echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"Recursive rm is blocked for this target.\nAllowed targets: node_modules, .next, dist, build, .cache, .turbo, coverage, __pycache__."}' >&2
    exit 2
  fi
fi

# Block git push --force / -f (but allow --force-with-lease)
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)git\s+push\s' && echo "$_cmd_stripped" | grep -qE '\s(--force|-f)(\s|$)' && ! echo "$_cmd_stripped" | grep -qF -- '--force-with-lease'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"git push --force is blocked.\nUse --force-with-lease instead for safer force pushes."}' >&2
  exit 2
fi

# Block git reset --hard
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)git\s+reset\s+--hard'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"git reset --hard is blocked (discards all uncommitted changes).\nUse git stash or git reset --soft instead."}' >&2
  exit 2
fi

# Block git hook bypass flag
_cmd_no_quotes=$(echo "$command" | sed 's/"[^"]*"//g; s/'"'"'[^'"'"']*'"'"'//g')
if echo "$_cmd_no_quotes" | grep -qE '(^|\s|&&|\|\||;)git\s+(commit|push|merge|rebase)\s' && echo "$_cmd_no_quotes" | grep -qE '\s--no-verify(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"Git hook bypass flag is blocked.\nPre-commit hooks exist for a reason. Fix the issue that the hook is catching instead of skipping it."}' >&2
  exit 2
fi

# Block git checkout . / git restore . (discards all uncommitted changes)
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)git\s+(checkout|restore)\s+\.\s*($|;|&&|\|\|)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"git checkout/restore . is blocked (discards all uncommitted changes).\nRestore specific files: git checkout -- <file> or git restore <file>."}' >&2
  exit 2
fi

exit 0
