#!/usr/bin/env bash
set -euo pipefail
trap 'exit 0' ERR

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$root" 2>/dev/null || true

section() {
  printf '\n## %s\n\n' "$1"
}

one_line() {
  tr '\n' ' ' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//'
}

file_summary() {
  f="$1"
  [ -f "$f" ] || return 0
  lines=$(wc -l < "$f" | tr -d ' ')
  headings=$(grep -E '^(#|##) ' "$f" 2>/dev/null | head -8 | sed 's/^#* //' | one_line)
  if [ -n "$headings" ]; then
    printf -- '- `%s` (%s lines): %s\n' "$f" "$lines" "$headings"
  else
    printf -- '- `%s` (%s lines)\n' "$f" "$lines"
  fi
}

unique_candidates() {
  awk 'NF && !seen[$0]++ {print}' | head -10
}

default_branch() {
  ref="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
  if [ -n "$ref" ]; then
    printf '%s\n' "${ref#origin/}"
  elif git rev-parse --verify --quiet origin/main >/dev/null; then
    printf 'main\n'
  elif git rev-parse --verify --quiet origin/master >/dev/null; then
    printf 'master\n'
  else
    printf '\n'
  fi
}

printf '# Prime Scout\n\n'
printf -- '- Root: `%s`\n' "$root"
printf -- '- Generated: `%s`\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date)"

section "Work state"
branch="$(git branch --show-current 2>/dev/null || echo detached)"
printf -- '- Branch: `%s`\n' "${branch:-detached}"
upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)"
[ -n "$upstream" ] && printf -- '- Upstream: `%s`\n' "$upstream"
ahead_behind="$(git rev-list --left-right --count HEAD..."$upstream" 2>/dev/null | awk '{print "ahead "$1", behind "$2}' || true)"
[ -n "$ahead_behind" ] && printf -- '- Upstream delta: %s\n' "$ahead_behind"
printf -- '- Last commit: `%s`\n' "$(git log --oneline -1 2>/dev/null || echo 'no commits')"
status_lines="$(git status --short 2>/dev/null | head -20 || true)"
if [ -n "$status_lines" ]; then
  printf -- '- Dirty files:\n'
  printf '%s\n' "$status_lines" | sed 's/^/  - `/' | sed 's/$/`/'
else
  printf -- '- Dirty files: none\n'
fi

section "Instruction sources"
for f in AGENTS.md CLAUDE.md .github/copilot-instructions.md README.md; do
  file_summary "$f"
done

section "Domain and decisions"
for f in CONTEXT-MAP.md CONTEXT.md docs/agents/domain.md; do
  file_summary "$f"
done
if [ -d docs/adr ]; then
  count="$(find docs/adr -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
  printf -- '- ADRs: %s files\n' "$count"
  find docs/adr -maxdepth 1 -type f -name '*.md' 2>/dev/null | sort | head -8 | sed 's/^/- `/; s/$/`/'
else
  printf -- '- ADRs: none found at `docs/adr/`\n'
fi

section "Stack and commands"
if [ -f package.json ]; then
  package_manager="$(jq -r '.packageManager // empty' package.json 2>/dev/null || true)"
  [ -n "$package_manager" ] && printf -- '- Package manager: `%s`\n' "$package_manager"
  scripts="$(jq -r '.scripts // {} | keys[]' package.json 2>/dev/null | head -30 | paste -sd ', ' - || true)"
  [ -n "$scripts" ] && printf -- '- Scripts: %s\n' "$scripts"
  deps="$(jq -r '(.dependencies // {}) + (.devDependencies // {}) | keys[]' package.json 2>/dev/null | grep -E '^(react|@tanstack|@connectrpc|@bufbuild|zustand|vite|next|vitest|playwright|typescript|biome|eslint|tailwindcss)$' | paste -sd ', ' - || true)"
  [ -n "$deps" ] && printf -- '- Detected deps: %s\n' "$deps"
fi
configs="$(find . -maxdepth 2 -type f \( -name 'tsconfig*.json' -o -name 'vite.config.*' -o -name 'vitest.config.*' -o -name 'biome.json*' -o -name 'playwright.config.*' -o -name 'go.mod' -o -name 'Cargo.toml' \) 2>/dev/null | sort | head -20)"
if [ -n "$configs" ]; then
  printf -- '- Config files:\n'
  printf '%s\n' "$configs" | sed 's#^\./##' | sed 's/^/  - `/; s/$/`/'
fi

section "Repo map"
find . -maxdepth 2 -type d \
  \( -name .git -o -name node_modules -o -name dist -o -name build -o -name .next -o -name coverage -o -name .turbo -o -name .cache \) -prune -o \
  -type d -print 2>/dev/null | sed 's#^\./##' | grep -v '^\.$' | sort | head -50 | sed 's/^/- `/; s/$/`/'

section "Recent commits"
git log --oneline --decorate -8 2>/dev/null | sed 's/^/- `/' | sed 's/$/`/' || printf -- '- none\n'

section "Changed files"
base="$(default_branch)"
if [ -n "$base" ] && git rev-parse --verify --quiet "origin/$base" >/dev/null; then
  changed="$(git diff --name-only "origin/$base"...HEAD 2>/dev/null | head -30 || true)"
else
  changed="$(git diff --name-only HEAD~8...HEAD 2>/dev/null | head -30 || true)"
fi
dirty_names="$(git diff --name-only HEAD 2>/dev/null | head -30 || true)"
untracked_names="$(git ls-files --others --exclude-standard 2>/dev/null | head -30 || true)"
if [ -n "$changed$dirty_names$untracked_names" ]; then
  { printf '%s\n' "$changed"; printf '%s\n' "$dirty_names"; printf '%s\n' "$untracked_names"; } | unique_candidates | sed 's/^/- `/; s/$/`/'
else
  printf -- '- none vs detected base\n'
fi

section "Pull request and CI"
if command -v gh >/dev/null 2>&1 && git remote -v 2>/dev/null | grep -q 'github.com'; then
  pr_line="$(gh pr view --json number,title,url,state,isDraft,reviewDecision,baseRefName,headRefName --jq '"#\(.number) \(.title) [\(.state)] draft=\(.isDraft) review=\(.reviewDecision // "unknown") base=\(.baseRefName) head=\(.headRefName) \(.url)"' 2>/dev/null || true)"
  if [ -n "$pr_line" ]; then
    printf -- '- PR: %s\n' "$pr_line"
    checks="$(gh pr checks --json name,state,workflow --jq '.[] | "- `" + .name + "`: " + .state + " (" + (.workflow // "workflow") + ")"' 2>/dev/null | head -12 || true)"
    [ -n "$checks" ] && printf '%s\n' "$checks"
    if [ -x scripts/pr-unresolved-count.sh ]; then
      unresolved="$(scripts/pr-unresolved-count.sh 2>/dev/null | tail -1 || true)"
      [ -n "$unresolved" ] && printf -- '- Unresolved review threads: %s\n' "$unresolved"
    fi
  else
    printf -- '- No current branch PR detected by `gh pr view`.\n'
  fi
else
  printf -- '- GitHub CLI unavailable, unauthenticated, or non-GitHub remote.\n'
fi

section "Candidate next reads"
{
  [ -f AGENTS.md ] && echo AGENTS.md
  [ -f CLAUDE.md ] && echo CLAUDE.md
  [ -f CONTEXT-MAP.md ] && echo CONTEXT-MAP.md
  [ -f CONTEXT.md ] && echo CONTEXT.md
  [ -f README.md ] && echo README.md
  [ -f package.json ] && echo package.json
  printf '%s\n' "$dirty_names"
  printf '%s\n' "$untracked_names"
  printf '%s\n' "$changed"
} | unique_candidates | sed 's/^/- `/; s/$/`/'

section "Agent handoff"
cat <<'EOF'
- Use this scout to decide what to read; do not paste full instruction files.
- Produce a Prime brief with state, working rules, codebase map, current change, risks, next actions, and read-next paths.
- If user already gave a concrete task, bias reads toward changed files and the task area.
EOF
