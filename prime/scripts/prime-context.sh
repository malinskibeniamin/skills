#!/usr/bin/env bash
set -euo pipefail
trap 'exit 0' ERR

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$root" 2>/dev/null || true

sec(){ printf '\n## %s\n\n' "$1"; }
one(){ tr '\n' ' ' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//'; }
fsum(){
  f="$1"; [ -f "$f" ] || return 0
  l=$(wc -l < "$f" | tr -d ' ')
  h=$(grep -E '^(#|##) ' "$f" 2>/dev/null | head -8 | sed 's/^#* //' | one)
  [ -n "$h" ] && printf -- '- `%s` (%s lines): %s\n' "$f" "$l" "$h" || printf -- '- `%s` (%s lines)\n' "$f" "$l"
}
uniq10(){ awk 'NF && !seen[$0]++{print}' | head -10; }
base_branch(){
  r=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)
  [ -n "$r" ] && { printf '%s\n' "${r#origin/}"; return; }
  git rev-parse --verify --quiet origin/main >/dev/null && { echo main; return; }
  git rev-parse --verify --quiet origin/master >/dev/null && { echo master; return; }
  echo ""
}

printf '# Prime Scout\n\n- Root: `%s`\n- Generated: `%s`\n' "$root" "$(date -u '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date)"

sec "Work state"
br=$(git branch --show-current 2>/dev/null || echo detached)
up=$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)
printf -- '- Branch: `%s`\n' "${br:-detached}"
[ -n "$up" ] && printf -- '- Upstream: `%s`\n' "$up"
ab=$(git rev-list --left-right --count HEAD..."$up" 2>/dev/null | awk '{print "ahead "$1", behind "$2}' || true)
[ -n "$ab" ] && printf -- '- Upstream delta: %s\n' "$ab"
printf -- '- Last commit: `%s`\n' "$(git log --oneline -1 2>/dev/null || echo 'no commits')"
st=$(git status --short 2>/dev/null | head -20 || true)
if [ -n "$st" ]; then printf -- '- Dirty files:\n'; printf '%s\n' "$st" | sed 's/^/  - `/; s/$/`/'; else echo '- Dirty files: none'; fi

sec "Instruction sources"
for f in AGENTS.md CLAUDE.md .github/copilot-instructions.md README.md; do fsum "$f"; done

sec "Domain and decisions"
for f in CONTEXT-MAP.md CONTEXT.md docs/agents/domain.md; do fsum "$f"; done
if [ -d docs/adr ]; then
  c=$(find docs/adr -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
  printf -- '- ADRs: %s files\n' "$c"
  find docs/adr -maxdepth 1 -type f -name '*.md' 2>/dev/null | sort | head -8 | sed 's/^/- `/; s/$/`/'
else echo '- ADRs: none found at `docs/adr/`'; fi

sec "Stack and commands"
if [ -f package.json ]; then
  pm=$(jq -r '.packageManager // empty' package.json 2>/dev/null || true); [ -n "$pm" ] && printf -- '- Package manager: `%s`\n' "$pm"
  sc=$(jq -r '.scripts // {} | keys[]' package.json 2>/dev/null | head -30 | paste -sd ', ' - || true); [ -n "$sc" ] && printf -- '- Scripts: %s\n' "$sc"
  dp=$(jq -r '(.dependencies//{})+(.devDependencies//{})|keys[]' package.json 2>/dev/null | grep -E '^(react|@tanstack|@connectrpc|@bufbuild|zustand|vite|next|vitest|playwright|typescript|biome|eslint|tailwindcss)$' | paste -sd ', ' - || true); [ -n "$dp" ] && printf -- '- Detected deps: %s\n' "$dp"
fi
cfg=$(find . -maxdepth 2 -type f \( -name 'tsconfig*.json' -o -name 'vite.config.*' -o -name 'vitest.config.*' -o -name 'biome.json*' -o -name 'playwright.config.*' -o -name go.mod -o -name Cargo.toml \) 2>/dev/null | sort | head -20)
[ -n "$cfg" ] && { echo '- Config files:'; printf '%s\n' "$cfg" | sed 's#^\./##; s/^/  - `/; s/$/`/'; }

sec "Repo map"
find . -maxdepth 2 -type d \( -name .git -o -name node_modules -o -name dist -o -name build -o -name .next -o -name coverage -o -name .turbo -o -name .cache \) -prune -o -type d -print 2>/dev/null | sed 's#^\./##' | grep -v '^\.$' | sort | head -50 | sed 's/^/- `/; s/$/`/'

sec "Recent commits"
git log --oneline --decorate -8 2>/dev/null | sed 's/^/- `/; s/$/`/' || echo '- none'

sec "Changed files"
base=$(base_branch)
[ -n "$base" ] && git rev-parse --verify --quiet "origin/$base" >/dev/null && ch=$(git diff --name-only "origin/$base"...HEAD 2>/dev/null | head -30 || true) || ch=$(git diff --name-only HEAD~8...HEAD 2>/dev/null | head -30 || true)
di=$(git diff --name-only HEAD 2>/dev/null | head -30 || true)
un=$(git ls-files --others --exclude-standard 2>/dev/null | head -30 || true)
if [ -n "$ch$di$un" ]; then { printf '%s\n' "$ch"; printf '%s\n' "$di"; printf '%s\n' "$un"; } | uniq10 | sed 's/^/- `/; s/$/`/'; else echo '- none vs detected base'; fi

sec "Pull request and CI"
if command -v gh >/dev/null 2>&1 && git remote -v 2>/dev/null | grep -q github.com; then
  pr=$(gh pr view --json number,title,url,state,isDraft,reviewDecision,baseRefName,headRefName --jq '"#\(.number) \(.title) [\(.state)] draft=\(.isDraft) review=\(.reviewDecision // "unknown") base=\(.baseRefName) head=\(.headRefName) \(.url)"' 2>/dev/null || true)
  if [ -n "$pr" ]; then
    printf -- '- PR: %s\n' "$pr"
    gh pr checks --json name,state,workflow --jq '.[]|"- `"+.name+"`: "+.state+" ("+(.workflow//"workflow")+")"' 2>/dev/null | head -12 || true
    [ -x scripts/pr-unresolved-count.sh ] && scripts/pr-unresolved-count.sh 2>/dev/null | tail -1 | sed 's/^/- Unresolved review threads: /'
  else echo '- No current branch PR detected by `gh pr view`.'; fi
else echo '- GitHub CLI unavailable, unauthenticated, or non-GitHub remote.'; fi

sec "Candidate next reads"
{ [ -f AGENTS.md ] && echo AGENTS.md; [ -f CLAUDE.md ] && echo CLAUDE.md; [ -f CONTEXT-MAP.md ] && echo CONTEXT-MAP.md; [ -f CONTEXT.md ] && echo CONTEXT.md; [ -f README.md ] && echo README.md; [ -f package.json ] && echo package.json; printf '%s\n' "$di" "$un" "$ch"; } | uniq10 | sed 's/^/- `/; s/$/`/'

sec "Agent handoff"
cat <<'EOF2'
- Use scout to choose reads; never paste full instruction files.
- Emit Prime brief: state, rules, map, change, risks, next actions, read-next paths.
- Concrete user task -> bias reads toward changed files + task area.
EOF2
