#!/bin/bash
set -euo pipefail
trap 'exit 0' ERR

input=$(cat)
[ "$(echo "$input" | jq -r '.hook_event_name // empty')" = "UserPromptSubmit" ] || exit 0

prompt=$(echo "$input" | jq -r '.prompt // empty' | tr '[:upper:]' '[:lower:]')
[ -n "$prompt" ] || exit 0
echo "$prompt" | grep -qiE '(^|[^a-z])/prime|run prime|prime this' && exit 0

echo "$prompt" | grep -qiE 'go ahead|do it|start|proceed|implement|build|add |create |fix |debug|investigate|refactor|open.*pr|pull request|ci|review' || exit 0

root=$(git rev-parse --show-toplevel 2>/dev/null || true)
[ -n "$root" ] || exit 0
cd "$root" 2>/dev/null || exit 0

sha(){ if command -v shasum >/dev/null 2>&1; then shasum | awk '{print $1}'; elif command -v md5 >/dev/null 2>&1; then md5 -q; else cksum | awk '{print $1}'; fi; }
cache_dir(){
  b="${XDG_CACHE_HOME:-${HOME:-/tmp}/.cache}/codex/prime"
  id=$(printf '%s' "$root" | sha)
  printf '%s/%s\n' "$b" "$id"
}
fingerprint(){
  br=$(git branch --show-current 2>/dev/null || echo detached)
  head=$(git rev-parse HEAD 2>/dev/null || echo none)
  dirty=$(git status --porcelain 2>/dev/null | sha)
  printf 'root=%s\nbranch=%s\nhead=%s\ndirty=%s\n' "$root" "$br" "$head" "$dirty"
}

dir=$(cache_dir)
marker="$dir/prime-current"
if [ -f "$marker" ] && [ "$(cat "$marker" 2>/dev/null)" = "$(fingerprint)" ]; then
  exit 0
fi

sid="${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}"
once="${TMPDIR:-/tmp}/hook-session-$sid/prime-nudged"
mkdir -p "$(dirname "$once")" 2>/dev/null || true
[ -f "$once" ] && exit 0
touch "$once" 2>/dev/null || true

msg="[PRIME] No current prime-current marker for this repo+branch+HEAD. Run /prime before code/PR/CI work; scout first, no full instruction-file paste."
escaped=$(printf '%s' "$msg" | jq -Rs . 2>/dev/null) || exit 0
echo "{\"hookSpecificOutput\":{\"hookEventName\":\"UserPromptSubmit\",\"additionalContext\":$escaped}}" >&2
