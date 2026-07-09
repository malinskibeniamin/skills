# Evals for bash-verbose-guard.sh + CLAUDE.md Bash Discipline section.

HOOK="$REPO_ROOT/.claude/hooks/bash-verbose-guard.sh"

run_file_eval "$HOOK" "bash-verbose-guard.sh exists"
run_executable_eval "$HOOK" "bash-verbose-guard.sh executable"
run_content_eval "$REPO_ROOT/skill-manifest.json" "bash-verbose-guard.sh" \
  "manifest registers bash-verbose-guard"

# Nudge paths
_run_bash() {
  local cmd="$1"
  local err; err=$(mktemp); local ec=0
  echo "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"$cmd\"}}" \
    | bash "$HOOK" 2>"$err" >/dev/null || ec=$?
  _last_stderr=$(cat "$err"); _last_exit=$ec
  rm -f "$err"
}

# NOTE: nudge-find, nudge-git-log, nudge-grep-root were removed in 19b8577
# (cost-tune effort, trim duplicate nudges) since CLAUDE.md Bash Discipline
# already documents the patterns and the nudges duplicated guidance every
# turn for low marginal value.

# Clean command: no nudge
_run_bash "ls"
if [ -z "$_last_stderr" ]; then
  echo "  PASS  ls clean (no nudge)"; PASS=$((PASS + 1))
else
  echo "  FAIL  ls unexpectedly nudged: $_last_stderr"; FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: ls false pos"
fi

# Bash discipline is machine-enforced, not documented in CLAUDE.md (lean contract).
run_file_eval "$REPO_ROOT/.claude/hooks/bash-verbose-guard.sh" \
  "bash-verbose-guard hook exists (owns bash discipline)"
run_file_eval "$REPO_ROOT/.claude/hooks/llm-truncate.sh" \
  "llm-truncate hook exists (owns output caps)"
