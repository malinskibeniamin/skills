#!/bin/bash
set -euo pipefail
trap 'exit 0' ERR

# UserPromptSubmit hook: inject DYNAMIC context derived from prompt +
# environment state. Runs alongside user-prompt-context.sh.
# Target: <30ms (keyword grep cascade).
#
# Policy (2026-07 audit): only dynamic endpoint, branch, and PR state belongs here.
# Static rule restatements stay in ambient repository instructions.

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
    rm -f "$_session_dir/task-endpoint" "$_session_dir/task-completed" \
      "$_session_dir/last-injected-endpoint" 2>/dev/null || true
  fi
fi

_endpoint=""
_negated_pr=false
_negated_push=false
_negated_commit=false
_negated_action=false
_artifact_only=false
_delivery_override=false
_action_verbs='build|implement|fix|debug|refactor|update|change|add|remove|delete|write|wire|integrate|upgrade|migrate|rebase|correct|resolve|address'
echo "$prompt" | grep -qiE '(^|[.!?;][[:space:]]*|please[[:space:]]+)unblock yourself|((do not|don.t|dont|never|stop)[^.;]{0,60}(ask|request)[^.;]{0,60}(permission|approval|prompt)[^.;]{0,100}(commit|push|rebase))' && _delivery_override=true
echo "$prompt" | grep -qiE "(do not|don.t|dont|never|without)[^.;]{0,80}((make|create|open)[[:space:]]+(a[[:space:]]+)?)?(pr|pull request)" && _negated_pr=true
echo "$prompt" | grep -qiE "(do not|don.t|dont|never|without)[^.;]{0,80}push" && _negated_push=true
echo "$prompt" | grep -qiE "(do not|don.t|dont|never|without)[^.;]{0,80}commit" && _negated_commit=true
echo "$prompt" | grep -qiE "(do not|don.t|dont|never|without)[^.;]{0,80}($_action_verbs)" && _negated_action=true
echo "$prompt" | grep -qiE 'unblock yourself[^.;]{0,100}(((do not|don.t|dont|never)[^.;]{0,40}push)|keep[^.;]{0,30}local)' && _delivery_override=false
echo "$prompt" | grep -qiE "^[[:space:]]*(please[[:space:]]+)?((can|could|would)[[:space:]]+you[[:space:]]+)?(answer|explain|plan|review|analy[sz]e|summarize|inspect|audit|evaluate)([[:space:][:punct:]]|$)" && _artifact_only=true
echo "$prompt" | grep -qiE "([,;][[:space:]]*(then[[:space:]]+)?|[[:space:]]+(and|then)[[:space:]]+)(please[[:space:]]+)?($_action_verbs)([^[:alnum:]_]|$)" && _artifact_only=false

if echo "$prompt" | grep -qiE '^[[:space:]]*(stop|cancel|never mind|nevermind)([[:space:][:punct:]]|$)'; then
  [ -n "$_session_dir" ] && rm -f "$_session_dir/task-endpoint" 2>/dev/null || true
elif [ "$_delivery_override" = true ] && [ "$_artifact_only" = false ]; then
  _endpoint="push"
elif echo "$prompt" | grep -qiE '(^|[[:space:]])(/go|ship( it)?|plow ahead|babysit|do not stop|keep going until done|use your best judgment)([[:space:][:punct:]]|$)' \
  && [ "$_negated_pr" = false ] && [ "$_negated_push" = false ] && [ "$_negated_commit" = false ]; then
  _endpoint="ship"
elif echo "$prompt" | grep -qiE '(make|create|open)[[:space:]]+((a|the)[[:space:]]+)?(new[[:space:]]+|draft[[:space:]]+)?(pr|pull request)([^[:alnum:]_]|$)|/commit-push-pr([^[:alnum:]]|$)' \
  && ! echo "$prompt" | grep -qi -- '--no-pr' \
  && [ "$_negated_pr" = false ] && [ "$_negated_push" = false ] && [ "$_negated_commit" = false ]; then
  _endpoint="pr"
elif { echo "$prompt" | grep -qiE '(^|[,.;!?][[:space:]]*|[[:space:]]+(and|then)[[:space:]]+)(please[[:space:]]+|can you[[:space:]]+|could you[[:space:]]+|would you[[:space:]]+)?push([[:space:][:punct:]]|$)' \
    || echo "$prompt" | grep -qiE 'commit[[:space:]]*/[[:space:]]*push|force-with-lease[[:space:]]+push' \
    || echo "$prompt" | grep -qi -- '--no-pr'; } \
  && [ "$_negated_push" = false ] && [ "$_negated_commit" = false ] && [ "$_artifact_only" = false ]; then
  _endpoint="push"
elif echo "$prompt" | grep -qiE '(^|[,.;!?][[:space:]]*|[[:space:]]+(and|then)[[:space:]]+)(please[[:space:]]+|can you[[:space:]]+|could you[[:space:]]+|would you[[:space:]]+)?commit([[:space:][:punct:]]|$)' \
  && [ "$_negated_commit" = false ]; then
  _endpoint="commit"
elif echo "$prompt" | grep -qiE "(^|[^[:alnum:]_])($_action_verbs)([^[:alnum:]_]|$)" \
  && [ "$_negated_action" = false ] && [ "$_artifact_only" = false ]; then
  if [ "$_negated_push" = true ] || [ "$_negated_commit" = true ]; then
    _endpoint="local"
  else
    _endpoint="push"
  fi
fi

if [ -n "$_endpoint" ] && [ -n "$_session_dir" ]; then
  printf '%s\n' "$_endpoint" > "$_session_dir/task-endpoint" 2>/dev/null || true
  rm -f "$_session_dir/task-completed" 2>/dev/null || true

  # Per-turn dogfood baseline. Session-wide touch/head state would make a
  # later docs-only task inherit an earlier runnable edit and get blocked.
  _dogfood_touched="$_session_dir/session-touched-files"
  _dogfood_touched_count=0
  [ -f "$_dogfood_touched" ] \
    && _dogfood_touched_count=$(wc -l < "$_dogfood_touched" | tr -d '[:space:]')
  printf '%s\n' "${_dogfood_touched_count:-0}" \
    > "$_session_dir/dogfood-task-start-touched-count" 2>/dev/null || true
  git rev-parse HEAD \
    > "$_session_dir/dogfood-task-start-head" 2>/dev/null || true
  {
    git diff --name-only HEAD 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | sort -u \
    > "$_session_dir/dogfood-task-dirty-baseline" 2>/dev/null || true

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
if echo "$prompt" | grep -qiE 'fix|debug|broken|refactor|extract|move|split|consolidate|clean.?up|write.*test|add|create|build|implement|wire|integrate|set.*up|open.*pr|pull request|push|rebase|deploy|delete|migration|ci'; then
  _scope_lock_prompt=true
fi
case "$_current_branch" in
  main|master|develop|"") ;;
  *)
    if [ "$_scope_lock_prompt" = true ]; then
      directives="$directives\n[SCOPE-LOCK] Stay in feature branch '$_current_branch'. Do not create another branch or PR unless explicitly instructed."
    fi
    ;;
esac

# ── Output ───────────────────────────────────────────────────────

if [ -n "$directives" ]; then
  escaped=$(printf '%s' "$directives" | jq -Rs . 2>/dev/null) || exit 0
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"UserPromptSubmit\",\"additionalContext\":$escaped}}"
fi

exit 0
