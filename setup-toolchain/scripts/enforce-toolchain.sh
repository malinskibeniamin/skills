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
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"npm banned. Use bun: install|run|test|install --frozen-lockfile"}' >&2
  exit 2
fi

# Block npx commands
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)npx\s'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"npx banned. Use bunx or bun run <script>."}' >&2
  exit 2
fi

# Block tsc commands
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)tsc(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"tsc banned. Use tsgo --noEmit."}' >&2
  exit 2
fi

# Block global installs
if echo "$_cmd_stripped" | grep -qE 'bun\s+(add|install)\s+.*-g(\s|$)' || echo "$_cmd_stripped" | grep -qE 'bun\s+(add|install)\s+.*--global(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"Global installs banned. Use: bun add -D <package>."}' >&2
  exit 2
fi

# Block installing eslint or prettier
if echo "$_cmd_stripped" | grep -qE 'bun\s+(add|install)\s.*\b(eslint|prettier)\b'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"eslint/prettier banned. Project uses Biome: bun run lint|lint:fix."}' >&2
  exit 2
fi

# Block eslint as a direct command
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)eslint(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"eslint banned. Use Biome: bun run lint|lint:fix."}' >&2
  exit 2
fi

# Block prettier as a direct command
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)prettier(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"prettier banned. Use Biome: bun run lint:fix."}' >&2
  exit 2
fi

# Block direct bunx for tools that have package.json scripts
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)bunx\s+(ultracite|biome|@biomejs/biome|react-doctor|tsr|@tanstack/router-cli|eslint|prettier)'; then
  tool=$(echo "$command" | grep -oE 'bunx\s+\S+' | head -1 | awk '{print $2}')
  echo "{\"hookSpecificOutput\":{\"permissionDecision\":\"deny\"},\"systemMessage\":\"${tool} via bunx banned. Use bun run <script> for CI parity.\"}" >&2
  exit 2
fi

# --yarn flag enforcement removed — yarn.lock no longer required

# Block destructive rm -rf / rm -r / rm --recursive (allow safe targets)
# Skip git rm — it's version-controlled and reversible
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)rm\s+(-[a-zA-Z]*r[a-zA-Z]*|--recursive)(\s|$)' \
   && ! echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)git\s+rm\s'; then
  safe_targets="node_modules .next dist build .cache .turbo coverage __pycache__ .claude/skills .claude/hooks skills-lock.json"
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
      if [ "$base" = "$s" ] || echo "$t" | grep -qF "$s/" || [ "$t" = "$s" ] || echo "/$t" | grep -qF "/$s"; then
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
    echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"rm -r blocked. Allowed: node_modules .next dist build .cache .turbo coverage __pycache__."}' >&2
    exit 2
  fi
fi

# Block git push --force / -f (but allow --force-with-lease)
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)git\s+push\s' && echo "$_cmd_stripped" | grep -qE '\s(--force|-f)(\s|$)' && ! echo "$_cmd_stripped" | grep -qF -- '--force-with-lease'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"git push --force blocked. Use --force-with-lease."}' >&2
  exit 2
fi

# Block git reset --hard
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)git\s+reset\s+--hard'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"git reset --hard blocked. Use git stash or reset --soft."}' >&2
  exit 2
fi

# Block git hook bypass flag
_cmd_no_quotes=$(echo "$command" | sed 's/"[^"]*"//g; s/'"'"'[^'"'"']*'"'"'//g')
if echo "$_cmd_no_quotes" | grep -qE '(^|\s|&&|\|\||;)git\s+(commit|push|merge|rebase)\s' && echo "$_cmd_no_quotes" | grep -qE '\s--no-verify(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"--no-verify blocked. Fix hook issue, not bypass."}' >&2
  exit 2
fi

# Block git checkout . / git restore . (discards all uncommitted changes)
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)git\s+(checkout|restore)\s+\.\s*($|;|&&|\|\|)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"git checkout/restore . blocked. Use specific files: git restore <file>."}' >&2
  exit 2
fi

exit 0
