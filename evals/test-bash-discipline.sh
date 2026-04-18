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

# find without maxdepth
_run_bash "find /Users/foo -name '*.ts'"
if echo "$_last_stderr" | grep -q "find without"; then
  echo "  PASS  warns on find without -maxdepth"; PASS=$((PASS + 1))
else
  echo "  FAIL  no warn for find without -maxdepth"; FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: find nudge"
fi

# find with maxdepth or head: no nudge
_run_bash "find . -maxdepth 2 -name '*.ts'"
if ! echo "$_last_stderr" | grep -q "find without"; then
  echo "  PASS  no warn when find has -maxdepth"; PASS=$((PASS + 1))
else
  echo "  FAIL  false-positive find nudge"; FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: find false pos"
fi

# git log without limit
_run_bash "git log --graph"
if echo "$_last_stderr" | grep -q "git log without"; then
  echo "  PASS  warns on git log without limit"; PASS=$((PASS + 1))
else
  echo "  FAIL  no warn for git log"; FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: git log nudge"
fi

_run_bash "git log -n 30"
if ! echo "$_last_stderr" | grep -q "git log without"; then
  echo "  PASS  no warn for git log -n 30"; PASS=$((PASS + 1))
else
  echo "  FAIL  false-positive git log nudge"; FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: git log false pos"
fi

_run_bash "git log --oneline --since yesterday"
if ! echo "$_last_stderr" | grep -q "git log without"; then
  echo "  PASS  no warn for git log --oneline"; PASS=$((PASS + 1))
else
  echo "  FAIL  false-positive git log --oneline"; FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: git log --oneline false pos"
fi

# grep -r at repo root
_run_bash "grep -r foo ."
if echo "$_last_stderr" | grep -q "grep -r"; then
  echo "  PASS  warns on grep -r ."; PASS=$((PASS + 1))
else
  echo "  FAIL  no warn for grep -r ."; FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: grep -r nudge"
fi

# Clean command: no nudge
_run_bash "ls"
if [ -z "$_last_stderr" ]; then
  echo "  PASS  ls clean (no nudge)"; PASS=$((PASS + 1))
else
  echo "  FAIL  ls unexpectedly nudged: $_last_stderr"; FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: ls false pos"
fi

# CLAUDE.md has Bash Discipline section
run_content_eval "$REPO_ROOT/CLAUDE.md" "Bash Discipline" \
  "CLAUDE.md has Bash Discipline section"
run_content_eval "$REPO_ROOT/CLAUDE.md" "llm-truncate" \
  "Bash Discipline references llm-truncate cap"
run_content_eval "$REPO_ROOT/CLAUDE.md" "bash-verbose-guard" \
  "Bash Discipline references bash-verbose-guard"
