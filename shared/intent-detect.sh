#!/bin/bash
set -euo pipefail
trap 'exit 0' ERR

# UserPromptSubmit hook: inject DYNAMIC context derived from prompt +
# environment state. Runs alongside user-prompt-context.sh.
# Target: <30ms (keyword grep cascade).
#
# Policy (2026-07 audit): only directives that carry information the model
# does NOT already have belong here — branch state, PR numbers, installed
# tools, once-per-session markers. Static rule restatements ([TDD],
# [LIFECYCLE], [MINIMAL], [CLI-FIRST], ...) were removed: they duplicated
# CLAUDE.md verbatim and cost ~2-4k redundant tokens per session.

input=$(cat)
hook_event=$(echo "$input" | jq -r '.hook_event_name // empty')

if [ "$hook_event" != "UserPromptSubmit" ]; then
  exit 0
fi

prompt=$(echo "$input" | jq -r '.prompt // empty' | tr '[:upper:]' '[:lower:]')

if [ -z "$prompt" ]; then
  exit 0
fi

directives=""

# ── Requested endpoint + turn completion state ──────────────────

_hook_sid="${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}"
[ -z "$_hook_sid" ] && _hook_sid=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null || true)
_session_dir=""
if [ -n "$_hook_sid" ]; then
  _session_dir="/tmp/hook-session-${_hook_sid}"
  mkdir -p "$_session_dir" 2>/dev/null || true
  if [ -f "$_session_dir/task-completed" ]; then
    rm -f "$_session_dir/task-endpoint" "$_session_dir/task-completed" 2>/dev/null || true
  fi
fi

_endpoint=""
_negated_pr=false
_negated_push=false
_negated_commit=false
_negated_action=false
_artifact_only=false
_action_verbs='build|implement|fix|debug|refactor|update|change|add|remove|delete|write|wire|integrate|upgrade|migrate|correct|resolve|address'
echo "$prompt" | grep -qiE "(do not|don.t|dont|never|without)[^.;]{0,80}((make|create|open)[[:space:]]+(a[[:space:]]+)?)?(pr|pull request)" && _negated_pr=true
echo "$prompt" | grep -qiE "(do not|don.t|dont|never|without)[^.;]{0,80}push" && _negated_push=true
echo "$prompt" | grep -qiE "(do not|don.t|dont|never|without)[^.;]{0,80}commit" && _negated_commit=true
echo "$prompt" | grep -qiE "(do not|don.t|dont|never|without)[^.;]{0,80}($_action_verbs)" && _negated_action=true
echo "$prompt" | grep -qiE "^[[:space:]]*(please[[:space:]]+)?((can|could|would)[[:space:]]+you[[:space:]]+)?(answer|explain|plan|review|analy[sz]e|summarize|inspect|audit|evaluate)([[:space:][:punct:]]|$)" && _artifact_only=true
echo "$prompt" | grep -qiE "([,;][[:space:]]*(then[[:space:]]+)?|[[:space:]]+(and|then)[[:space:]]+)(please[[:space:]]+)?($_action_verbs)([^[:alnum:]_]|$)" && _artifact_only=false

if echo "$prompt" | grep -qiE '^[[:space:]]*(stop|cancel|never mind|nevermind)([[:space:][:punct:]]|$)'; then
  [ -n "$_session_dir" ] && rm -f "$_session_dir/task-endpoint" 2>/dev/null || true
elif echo "$prompt" | grep -qiE '(^|[[:space:]])(/go|ship( it)?|plow ahead|babysit|do not stop|keep going until done|use your best judgment)([[:space:][:punct:]]|$)' \
  && [ "$_negated_pr" = false ] && [ "$_negated_push" = false ] && [ "$_negated_commit" = false ]; then
  _endpoint="ship"
  directives="$directives\n[ENDPOINT:ship] Run the requested full delivery loop. No background activity may survive final status."
elif echo "$prompt" | grep -qiE '(make|create|open)[[:space:]]+((a|the)[[:space:]]+)?(new[[:space:]]+|draft[[:space:]]+)?(pr|pull request)([^[:alnum:]_]|$)|/commit-push-pr([^[:alnum:]]|$)' \
  && ! echo "$prompt" | grep -qi -- '--no-pr' \
  && [ "$_negated_pr" = false ] && [ "$_negated_push" = false ] && [ "$_negated_commit" = false ]; then
  _endpoint="pr"
  directives="$directives\n[ENDPOINT:pr] Making a PR includes verify + commit + push + PR creation + one CI snapshot. Push is an implied prerequisite; merge and force-push are not authorized."
elif { echo "$prompt" | grep -qiE '(^|[,.;!?][[:space:]]*|[[:space:]]+(and|then)[[:space:]]+)(please[[:space:]]+|can you[[:space:]]+|could you[[:space:]]+|would you[[:space:]]+)?push([[:space:][:punct:]]|$)' || echo "$prompt" | grep -qi -- '--no-pr'; } \
  && [ "$_negated_push" = false ] && [ "$_negated_commit" = false ]; then
  _endpoint="push"
  directives="$directives\n[ENDPOINT:push] Commit if needed, push the current branch, then stop. Do not open a PR."
elif echo "$prompt" | grep -qiE '(^|[,.;!?][[:space:]]*|[[:space:]]+(and|then)[[:space:]]+)(please[[:space:]]+|can you[[:space:]]+|could you[[:space:]]+|would you[[:space:]]+)?commit([[:space:][:punct:]]|$)' \
  && [ "$_negated_commit" = false ]; then
  _endpoint="commit"
  directives="$directives\n[ENDPOINT:commit] Commit the requested scope, then stop. Do not push."
elif echo "$prompt" | grep -qiE "(^|[^[:alnum:]_])($_action_verbs)([^[:alnum:]_]|$)" \
  && [ "$_negated_action" = false ] && [ "$_artifact_only" = false ]; then
  _endpoint="local"
  directives="$directives\n[ENDPOINT:local] State a concise plan, continue immediately, verify local changes, then stop without commit or push."
fi

if [ -n "$_endpoint" ] && [ -n "$_session_dir" ]; then
  printf '%s\n' "$_endpoint" > "$_session_dir/task-endpoint" 2>/dev/null || true
  rm -f "$_session_dir/task-completed" 2>/dev/null || true
fi

# ── PR delivery context ──────────────────────────────────────────

if echo "$prompt" | grep -qiE '(make|create|open)[[:space:]]+((a|the)[[:space:]]+)?(new[[:space:]]+|draft[[:space:]]+)?(pr|pull request)([^[:alnum:]_]|$)'; then
  directives="$directives\n[PR] quality:gate + type:check first. Take one CI snapshot; do not request or post a review unless asked."
fi

# ── Browser task detected (URL / navigate / click / visual bug) ──
# Environment fact the model cannot know: which browser CLIs exist here.

if echo "$prompt" | grep -qiE 'https?://|localhost:|click on|click the|navigate to|go to.*http|open.*http|screenshot|hover over|fill.*form|visual.*bug|rendering issue|ui bug|page load|reload.*page'; then
  directives="$directives\n[BROWSER] Use an isolated \`agent-browser\` or \`bunx playwright\` session. Never close, restart, resize, or take over a human-owned browser or desktop app. If isolation is unavailable, report blocked verification."
fi

# ── CI fix workflow ──────────────────────────────────────────────

if echo "$prompt" | grep -qiE 'fix ci|green ci|ci failing|ci broken|check failures|fix pipeline|fix checks|fix pr checks|ci red|checks? fail'; then
  directives="$directives\n[CI-FIX] Front-load ALL failures: list EVERY failure by category BEFORE fixing. Order: proto->types->lint->unit->e2e. Push ONCE after all local pass. Terminal only, no browser."
fi

# ── PR-number auto-context ───────────────────────────────────────
# When prompt references a PR number near action keywords, inject branch context.

_pr_number=$(echo "$prompt" | grep -oiE '(pr|pull request)[^#]*#([0-9]+)' | grep -oE '#[0-9]+' | head -1 | tr -d '#' || true)

if [ -n "$_pr_number" ]; then
  if [ -z "$_endpoint" ] && echo "$prompt" | grep -qiE 'review|analy[sz]e|summarize|inspect|explain'; then
    directives="$directives\n[PR-CONTEXT] Review PR #$_pr_number read-only with: gh pr view $_pr_number and gh pr diff $_pr_number. Do not checkout, edit, push, or comment unless asked."
  else
    directives="$directives\n[PR-CONTEXT] Explicit PR #$_pr_number. First verify it with gh pr view $_pr_number. For requested write work, checkout only after that succeeds; otherwise keep the current branch and report the artifact mismatch."
  fi
fi

# ── Scope-lock: prefer committing to current feature branch ─────
# Auto-detected from branch state, not prompt keywords.

_current_branch=$(git branch --show-current 2>/dev/null || true)
_scope_lock_prompt=false
if echo "$prompt" | grep -qiE 'fix|debug|broken|refactor|extract|move|split|consolidate|clean.?up|write.*test|add|create|build|implement|wire|integrate|set.*up|open.*pr|pull request|push|deploy|delete|migration|ci'; then
  _scope_lock_prompt=true
fi
case "$_current_branch" in
  main|master|develop|"") ;;
  *)
    if [ "$_scope_lock_prompt" = true ]; then
      directives="$directives\n[SCOPE-LOCK] Stay in feature branch '$_current_branch'. Do not create another branch or PR unless explicitly instructed; the endpoint directive controls commit and push."
    fi
    ;;
esac

# ── Risk tier (informs auto mode confidence) ────────────────────
# low: tests, components, refactoring — fully guarded by hooks
# medium: bug fixes, debugging — may need exploratory actions
# high: PRs, deploys, infra — touches shared/external systems

risk=""

if echo "$prompt" | grep -qiE 'fix.*bug|debug|broken|not working|crash|triage|investigate|regression'; then
  risk="medium"
fi

if echo "$prompt" | grep -qiE '(make|create|open)[[:space:]]+((a|the)[[:space:]]+)?(new[[:space:]]+|draft[[:space:]]+)?(pr|pull request)|push|deploy|migration|drop|delete.*branch|force'; then
  risk="high"
fi

# Only emit risk tier for medium/high — low is default, no need to announce
if [ -n "$risk" ]; then
  directives="$directives\n[RISK:$risk]"
fi

# ── Output ───────────────────────────────────────────────────────

if [ -n "$directives" ]; then
  escaped=$(printf '%s' "$directives" | jq -Rs . 2>/dev/null) || exit 0
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"UserPromptSubmit\",\"additionalContext\":$escaped}}"
fi

exit 0
