# Evals for Snyk project creation guard.
# Blocks commands that can accidentally create Snyk projects/apps/targets.

HOOK="$REPO_ROOT/.claude/hooks/snyk-project-create-guard.sh"
MANIFEST="$REPO_ROOT/skill-manifest.json"
CLAUDE_SETTINGS="$REPO_ROOT/.claude/settings.json"
CODEX_HOOKS="$REPO_ROOT/.codex/hooks.json"
PERMISSION_GUARD="$REPO_ROOT/.claude/hooks/codex-permission-request-guard.sh"

run_file_eval "$HOOK" "snyk project create guard exists"
run_executable_eval "$HOOK" "snyk project create guard is executable"
run_content_eval "$MANIFEST" "snyk-project-create-guard\\.sh" "manifest wires Snyk guard"
run_content_eval "$CLAUDE_SETTINGS" "snyk-project-create-guard\\.sh" "Claude settings include Snyk guard"
run_content_eval "$CODEX_HOOKS" "snyk-project-create-guard\\.sh" "Codex hooks include Snyk guard"
run_content_eval "$PERMISSION_GUARD" "snyk-project-create-guard\\.sh" "PermissionRequest guard reuses Snyk guard"

_snyk_guard_case() {
  local cmd="$1"
  local expected="$2"
  local desc="$3"
  local input
  local output
  local actual=0
  input=$(jq -nc --arg cmd "$cmd" '{tool_name:"Bash",tool_input:{command:$cmd}}')
  output=$(printf '%s' "$input" | "$HOOK" 2>&1 >/dev/null) || actual=$?

  if [ "$actual" -eq "$expected" ]; then
    echo "  PASS  $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $desc (expected exit $expected, got $actual)"
    echo "        output: $output"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $desc"
  fi
}

_snyk_guard_case 'snyk test --all-projects --json' 0 \
  "guard allows read-only snyk test"

_snyk_guard_case 'snyk monitor --all-projects' 2 \
  "guard blocks snyk monitor --all-projects"

_snyk_guard_case 'bunx snyk monitor --file=package.json' 2 \
  "guard blocks bunx snyk monitor"

_snyk_guard_case 'snyk monitor --file=go.mod --target-reference="$branch" --project-name="${repo}-${branch}"' 2 \
  "guard blocks branch-derived Snyk monitor identity"

_snyk_guard_case 'SNYK_ALLOW_EXISTING_PROJECT_MONITOR=1 SNYK_EXISTING_PROJECT_ID=123e4567-e89b-12d3-a456-426614174000 snyk monitor --file=go.mod --org=my-org --project-name=existing-api' 0 \
  "guard allows explicit existing-project monitor"

_snyk_guard_case 'SNYK_ALLOW_EXISTING_PROJECT_MONITOR=1 SNYK_EXISTING_PROJECT_ID=123e4567-e89b-12d3-a456-426614174000 snyk monitor --file=go.mod --org=my-org --project-name=chore-snyk-sweep-2026-06-02' 2 \
  "guard blocks date-derived project names even with allow marker"

_snyk_guard_case 'curl -fsS -H "Authorization: Token x" "https://api.snyk.io/rest/orgs/abc/projects?version=2025-11-05&names_start_with=repo"' 0 \
  "guard allows read-only Snyk Projects API lookup"

_snyk_guard_case 'curl -fsS -X POST -H "Authorization: Token x" -d "{}" "https://api.snyk.io/rest/orgs/abc/projects?version=2025-11-05"' 2 \
  "guard blocks Snyk Projects API create"

_snyk_guard_case 'curl -fsS --request POST -H "Authorization: Token x" -d "{}" "https://api.snyk.io/rest/orgs/abc/apps?version=2025-11-05"' 2 \
  "guard blocks Snyk Apps API create"

_snyk_guard_case 'snyk projects create --name accidental-project' 2 \
  "guard blocks Snyk CLI project create"

_snyk_guard_case 'snyk api /orgs/abc/projects --method=POST --data "{}"' 2 \
  "guard blocks Snyk CLI API project create"
