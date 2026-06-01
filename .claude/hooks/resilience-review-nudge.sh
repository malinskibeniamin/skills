#!/bin/bash
set -euo pipefail
_lib="$(dirname "$0")/_hook-lib.sh"; if [ -f "$_lib" ]; then source "$_lib"; else _m="${TMPDIR:-/tmp}/frontend-skills-broken.${CLAUDE_SESSION_ID:-fs}"; [ -f "$_m" ] || { echo "[frontend-skills] _hook-lib.sh unavailable - run: /plugin install frontend-skills --force" >&2; touch "$_m" 2>/dev/null; }; exit 0; fi

hook_parse_edit_write
hook_skip_generated
hook_skip_tests
hook_get_added_lines
hook_has_escape "resilience-review" && exit 0

case "$file_path" in *.md|*.mdx|*.css|*.scss|*.png|*.jpg|*.jpeg|*.gif|*.svg|*.lock|*lockfile*) exit 0 ;; esac

scan=$(printf '%s\n%s' "$file_path" "$added_lines" | tr '[:upper:]' '[:lower:]')
score=0; reasons=""
add() { score=$((score + 1)); case ",$reasons," in *,"$1",*) ;; *) reasons="${reasons}${reasons:+, }$1" ;; esac; }

printf '%s' "$scan" | grep -qE '<form|handlesubmit|onsubmit|validation|validator|schema|zod|yup|onchange|seterror|errors\.' && add "form/validation"
printf '%s' "$scan" | grep -qE 'fetch\(|usequery|usemutation|mutation|querykey|invalidate|cache|retry|timeout|abortcontroller' && add "async/data flow"
printf '%s' "$scan" | grep -qE 'create|update|delete|submit|save|requestsubmit|reset|rollback|optimistic' && add "state-changing action"
printf '%s' "$scan" | grep -qE 'loading|empty|error|success|disabled|fallback|toast|alert|boundary' && add "ui state/polish"
printf '%s' "$scan" | grep -qE 'mode|state|switch|oneof|union|type|branch|partial|stale|dirty' && add "state transition"
printf '%s' "$scan" | grep -qE 'projectid|resourceid|environment|config|secret|credential|webhook|endpoint|url' && add "config/resource choice"
printf '%s' "$scan" | grep -qE 'catch[[:space:]]*\{|return[[:space:]]+null|return[[:space:]]+\[\]|throw new error|console\.error' && add "error path"

[ "$score" -lt 2 ] && exit 0
_marker="$_hook_session_dir/resilience-review.$(printf '%s' "$file_path" | cksum | awk '{print $1}')"
[ -f "$_marker" ] && exit 0
touch "$_marker" 2>/dev/null || true
hook_nudge "Resilience Review surface detected ($reasons) in ${file_path##*/}. Run /resilience-review before shipping or record skip reason. Escape: // allow: resilience-review [reason]" "resilience-review"
