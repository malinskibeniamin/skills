# Public Bash dispatch contract: manage LaunchDarkly flags through ldcli.
HOOK="$REPO_ROOT/.claude/hooks/pre-bash.sh"

_ldcli_bash_case() {
  local command="$1" expected="$2" label="$3"
  local input
  input=$(jq -nc --arg command "$command" '{tool_name:"Bash",tool_input:{command:$command}}')
  if [ "$expected" = 2 ]; then
    run_hook_eval "$HOOK" "$input" 2 "$label" "ldcli"
  else
    run_hook_eval "$HOOK" "$input" 0 "$label"
  fi
}

_ldcli_bash_case 'curl -fsS "https://app.launchdarkly.com/api/v2/flags/project/flag"' 2 \
  "direct LaunchDarkly reads redirect to ldcli"
_ldcli_bash_case 'env /usr/bin/curl -X PATCH -d "[]" "https://app.eu.launchdarkly.com/api/v2/flags/project/flag"' 2 \
  "wrapped EU flag writes redirect to ldcli"
_ldcli_bash_case 'wget -qO- https://app.launchdarkly.us/api/v2/flags/project' 2 \
  "federal flag reads redirect to ldcli"
_ldcli_bash_case 'http PATCH https://app.launchdarkly.com/api/v2/flags/project/flag' 2 \
  "HTTPie flag writes redirect to ldcli"
_ldcli_bash_case 'c"ur"l https://app.launchdarkly.com/api/v2/flags/project/flag' 2 \
  "quoted executable fragments cannot bypass routing"
_ldcli_bash_case $'printf "ready";\ncurl https://APP.LAUNCHDARKLY.COM/api/v2/flags/project/flag' 2 \
  "compound commands and uppercase hosts preserve routing"
_ldcli_bash_case 'curl --url=https://app.launchdarkly.com/api/v2/flags/project/flag' 2 \
  "curl URL option cannot bypass routing"
_ldcli_bash_case 'bash -c "curl https://app.launchdarkly.com/api/v2/flags/project/flag"' 2 \
  "nested shell requests preserve routing"
_ldcli_bash_case $'curl \\\n  https://app.launchdarkly.com/api/v2/flags/project/flag' 2 \
  "line continuations preserve routing"

_ldcli_bash_case 'ldcli flags get --project project --flag flag --env staging --output json' 0 \
  "ldcli flag reads remain available"
_ldcli_bash_case 'ldcli --base-uri https://app.eu.launchdarkly.com flags update --project project --flag flag --data "[]"' 0 \
  "ldcli writes with a regional base URI remain available"
_ldcli_bash_case 'curl -fsS https://launchdarkly.com/docs/home/getting-started/ldcli' 0 \
  "official documentation remains available"
_ldcli_bash_case 'curl https://example.com/api/v2/flags' 0 \
  "other services remain available"
_ldcli_bash_case 'curl https://app.launchdarkly.com.evil.example/api/v2/flags' 0 \
  "unrelated lookalike domains are not LaunchDarkly"
_ldcli_bash_case 'echo "curl https://app.launchdarkly.com/api/v2/flags"' 0 \
  "quoted documentation is not an HTTP request"
_ldcli_bash_case $'cat <<\'EOF\'\ncurl https://app.launchdarkly.com/api/v2/flags\nEOF' 0 \
  "heredoc fixtures are not HTTP requests"
_ldcli_bash_case 'curl https://example.com; ldcli --base-uri https://app.launchdarkly.com/api/v2 flags get --project project --flag flag' 0 \
  "unrelated HTTP and ldcli in separate segments do not cross-match"

# Codex approval adapter must preserve the same routing denial and useful hint.
input=$(jq -nc '{tool_name:"Bash",tool_input:{command:"curl https://app.launchdarkly.com/api/v2/flags/project"}}')
output=$(printf '%s' "$input" | "$REPO_ROOT/.claude/hooks/codex-permission-request-guard.sh")
if printf '%s' "$output" | jq -e '.hookSpecificOutput.decision | .behavior == "deny" and (.message | contains("ldcli"))' >/dev/null; then
  echo "  PASS  Codex PermissionRequest redirects to ldcli"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Codex PermissionRequest lost the ldcli denial"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Codex PermissionRequest lost the ldcli denial"
fi
