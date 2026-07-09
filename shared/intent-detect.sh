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

# ── PR/review: once-per-session review request marker ────────────

if echo "$prompt" | grep -qiE 'create.*pr|open.*pr|pull request|push.*branch|submit.*review'; then
  review_marker="/tmp/hook-session-${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}/review-requested"
  if [ -f "$review_marker" ]; then
    directives="$directives\n[PR] quality:gate + type:check first. (Review already requested this session.)"
  else
    directives="$directives\n[PR] quality:gate + type:check first. After: @claude review."
    touch "$review_marker" 2>/dev/null || true
  fi
fi

# ── Browser task detected (URL / navigate / click / visual bug) ──
# Environment fact the model cannot know: which browser CLIs exist here.

if echo "$prompt" | grep -qiE 'https?://|localhost:|click on|click the|navigate to|go to.*http|open.*http|screenshot|hover over|fill.*form|visual.*bug|rendering issue|ui bug|page load|reload.*page'; then
  directives="$directives\n[BROWSER] CLI browser tools installed: \`agent-browser\` and \`bunx playwright\` (codegen/test/screenshot). Never say \"no browser tools\". Order: bunx playwright > agent-browser > claude-in-chrome MCP (last)."
fi

# ── CI fix workflow ──────────────────────────────────────────────

if echo "$prompt" | grep -qiE 'fix ci|green ci|ci failing|ci broken|check failures|fix pipeline|fix checks|fix pr checks|ci red|checks? fail'; then
  directives="$directives\n[CI-FIX] Front-load ALL failures: list EVERY failure by category BEFORE fixing. Order: proto->types->lint->unit->e2e. Push ONCE after all local pass. Terminal only, no browser."
fi

# ── PR-number auto-context ───────────────────────────────────────
# When prompt references a PR number near action keywords, inject branch context.

_pr_number=$(echo "$prompt" | grep -oE '(pr|pull request|fix|ci|check|review).*#([0-9]+)' | grep -oE '#[0-9]+' | head -1 | tr -d '#' || true)
if [ -z "$_pr_number" ]; then
  _pr_number=$(echo "$prompt" | grep -oE '#([0-9]{4,})' | head -1 | tr -d '#' || true)
fi

if [ -n "$_pr_number" ]; then
  directives="$directives\n[PR-CONTEXT] Detected PR #$_pr_number. Before changes: gh pr checkout $_pr_number to get on correct branch. All changes on that branch. Do not create new branches."
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
      directives="$directives\n[SCOPE-LOCK] On feature branch '$_current_branch'. Prefer committing here. Ask before creating new branches or PRs unless explicitly instructed."
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

if echo "$prompt" | grep -qiE 'create.*pr|open.*pr|pull request|push|deploy|migration|drop|delete.*branch|force'; then
  risk="high"
fi

# Only emit risk tier for medium/high — low is default, no need to announce
if [ -n "$risk" ]; then
  directives="$directives\n[RISK:$risk]"
fi

# ── Output ───────────────────────────────────────────────────────

if [ -n "$directives" ]; then
  escaped=$(printf '%s' "$directives" | jq -Rs . 2>/dev/null) || exit 0
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"UserPromptSubmit\",\"additionalContext\":$escaped}}" >&2
fi

exit 0
