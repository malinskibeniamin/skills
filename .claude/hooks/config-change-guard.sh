#!/bin/bash
set -eo pipefail
trap 'exit 0' ERR

# ConfigChange (matcher: project_settings): .claude/settings.json is
# GENERATED from skill-manifest.json. A mid-session edit that diverges from
# the manifest is either an agent weakening a guardrail or a hand-edit the
# next regenerate silently reverts. Block on drift; regenerated output passes
# the drift check by construction, and user/local/policy scopes never route
# here (matcher-scoped). No-op in consumer repos without the generator.

input=$(cat 2>/dev/null || echo '{}')
source_kind=$(echo "$input" | jq -r '.source // .matcher // empty' 2>/dev/null)
# Belt and braces: if the payload names a non-project scope, stay out of it.
case "$source_kind" in
  user_settings|local_settings|policy_settings) exit 0 ;;
esac

root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
gen="$root/scripts/generate-hook-configs.sh"
[ -x "$gen" ] || exit 0

bash "$gen" --check >/dev/null 2>&1 && exit 0

reason="Blocked: .claude/settings.json is generated and this change diverges from skill-manifest.json. Edit skill-manifest.json instead, then run: bash scripts/generate-hook-configs.sh --apply"
if command -v jq >/dev/null 2>&1; then
  escaped=$(printf '%s' "$reason" | jq -Rs .)
else
  escaped="\"$reason\""
fi
echo "{\"decision\":\"block\",\"reason\":$escaped}" >&2
exit 2
