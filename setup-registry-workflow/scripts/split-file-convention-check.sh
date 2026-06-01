#!/bin/bash
set -euo pipefail
_lib="$(dirname "$0")/_hook-lib.sh"; if [ -f "$_lib" ]; then source "$_lib"; else _m="${TMPDIR:-/tmp}/frontend-skills-broken.${CLAUDE_SESSION_ID:-fs}"; [ -f "$_m" ] || { echo "[frontend-skills] _hook-lib.sh unavailable - run: /plugin install frontend-skills --force" >&2; touch "$_m" 2>/dev/null; }; exit 0; fi

hook_parse_edit_write
hook_filter_extensions "ts|tsx"
hook_skip_generated
hook_skip_tests

case "$file_path" in
  */routes/*) ;;
  *) exit 0 ;;
esac

base=$(basename "$file_path")
file_content=$(cat "$file_path" 2>/dev/null || true)

case "$base" in
  *.page.ts|*.page.tsx|route.ts|route.tsx|index.ts|index.tsx|__root.ts|__root.tsx) exit 0 ;;
esac

if echo "$base" | grep -qE '(-parts|[.]parts|[.]dialogs?|[.]checklists?)\.tsx?$'; then
  hook_block "Split-file convention: route UI files must be either .page.tsx in routes/ or named components under components/. Avoid -parts/.dialogs/.checklist suffix mixes." "split-file-convention"
fi

# Route declaration files can be named by path, but split UI components should
# not live beside them under ad-hoc names.
if ! echo "$file_content" | grep -qE 'create(File|Root)?Route|export[[:space:]]+const[[:space:]]+Route\b'; then
  if echo "$file_content" | grep -qE '(^|[[:space:]])(export[[:space:]]+)?(function|const)[[:space:]]+[A-Z][A-Za-z0-9_]*|export[[:space:]]+default[[:space:]]+function[[:space:]]+[A-Z]'; then
    hook_block "Split-file convention: route page components stay as *.page.tsx in routes/; reusable pieces move to components/." "split-file-convention"
  fi
fi

exit 0
