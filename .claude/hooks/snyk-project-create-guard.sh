#!/bin/bash
set -euo pipefail

# PreToolUse Bash: deny Snyk commands that can accidentally create new
# projects/apps/targets. Read-only audits remain allowed.

_shim="$(dirname "$0")/source-hook-lib.sh"; if [ -f "$_shim" ]; then . "$_shim" 2>/dev/null || true; fi
hook_parse_bash

_cmd_for_check=$(printf '%s\n' "$command" | awk '
  BEGIN { in_hd = 0 }
  in_hd && /^[[:space:]]*(EOF|JSON|SCRIPT|SH)[[:space:]]*$/ { in_hd = 0; next }
  in_hd { next }
  { print }
  /<<-?[[:space:]]*['"'"'"]?[A-Za-z_][A-Za-z0-9_]*['"'"'"]?/ { in_hd = 1 }
')

_has() {
  printf '%s' "$_cmd_for_check" | grep -Eq -- "$1"
}

_snyk_bin='(^|[[:space:];&|()])((bunx|npx)[[:space:]]+)?([^[:space:];&|()]*/)?snyk'
_monitor_re="${_snyk_bin}[[:space:]]+monitor([[:space:]]|$)"

_deny() {
  hook_deny "$1" "snyk-project-create-guard"
}

if _has "$_monitor_re"; then
  if _has '(^|[[:space:]])--all-projects([[:space:]]|$)'; then
    _deny "snyk monitor --all-projects blocked. It can create Snyk projects. Use snyk test for audits."
  fi

  if _has '--(target-reference|project-name)(=|[[:space:]]+)[^[:space:];&|]*([0-9]{4}-[0-9]{2}-[0-9]{2}|snyk-sweep|chore[-/]snyk|audit|sweep|\$[\{]?(branch|audit_branch|ref|repo_slug)|\$\()'; then
    _deny "Branch/date-derived Snyk monitor identity blocked. Reuse a verified existing Snyk project identity only."
  fi

  _has_allow=false
  if _has '(^|[[:space:]])SNYK_ALLOW_EXISTING_PROJECT_MONITOR=1([[:space:]]|$)' \
    && _has '(^|[[:space:]])SNYK_EXISTING_PROJECT_ID=[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}([[:space:]]|$)' \
    && _has '(^|[[:space:]])--file(=|[[:space:]]+)[^[:space:];&|]+' \
    && _has '(^|[[:space:]])--org(=|[[:space:]]+)[^[:space:];&|]+' \
    && _has '(^|[[:space:]])--project-name(=|[[:space:]]+)[^[:space:];&|]+'; then
    _has_allow=true
  fi

  if [ "$_has_allow" != "true" ]; then
    _deny "snyk monitor blocked unless it includes SNYK_ALLOW_EXISTING_PROJECT_MONITOR=1, SNYK_EXISTING_PROJECT_ID, --file, --org, and --project-name from an existing project preflight."
  fi
fi

if _has "${_snyk_bin}[[:space:]]+(project|projects|app|apps|target|targets)[[:space:]]+(create|import|add)([[:space:]]|$)"; then
  _deny "Snyk project/app/target creation command blocked. Reuse existing Snyk resources."
fi

_snyk_write='((^|[[:space:]])(-X|--request|--method)(=|[[:space:]]*)?(POST|PUT|PATCH)([[:space:]]|$)|(^|[[:space:]])-X(POST|PUT|PATCH)([[:space:]]|$)|(^|[[:space:]])(--data|-d|--data-raw|--data-binary)(=|[[:space:]]|$))'
_snyk_resource='/(projects|targets|apps|integrations)([/?]|[[:space:]]|"|'"'"'\'"'"''"'"'|$)'

if _has 'api\.snyk\.io' && _has "$_snyk_resource" && _has "$_snyk_write"; then
  _deny "Snyk API write to projects/apps/targets blocked. Read/list existing resources only."
fi

if _has "${_snyk_bin}[[:space:]]+api([[:space:]]|$)" && _has "$_snyk_resource" && _has "$_snyk_write"; then
  _deny "Snyk API write to projects/apps/targets blocked. Read/list existing resources only."
fi

exit 0
