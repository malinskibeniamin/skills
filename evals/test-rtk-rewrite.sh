# Evals for universal RTK routing through the PreToolUse(Bash) dispatcher.

HOOK="$REPO_ROOT/.claude/hooks/pre-bash.sh"
REWRITE_HOOK="$REPO_ROOT/.claude/hooks/rtk-rewrite.sh"

run_file_eval "$REWRITE_HOOK" "rtk-rewrite.sh exists"
run_executable_eval "$REWRITE_HOOK" "rtk-rewrite.sh is executable"
run_content_eval "$HOOK" "rtk-rewrite.sh" "pre-bash dispatcher registers RTK rewrite"

_rtk_tmp=$(mktemp -d)
_rtk_capture="$_rtk_tmp/capture"

cat > "$_rtk_tmp/rtk" <<'EOF'
#!/bin/bash
set -euo pipefail

[ "${1:-}" = "hook" ] && [ "${2:-}" = "claude" ] || exit 1
jq -r '.tool_input.command // empty' >> "$RTK_CAPTURE"
EOF
chmod +x "$_rtk_tmp/rtk"

# Every non-empty Bash command reaches RTK. RTK remains the single source of
# truth for deciding whether the command should be rewritten or passed through.
while IFS= read -r _rtk_command; do
  : > "$_rtk_capture"
  _rtk_payload=$(jq -nc --arg command "$_rtk_command" \
    '{tool_name:"Bash",tool_input:{command:$command}}')
  _rtk_exit=0
  printf '%s' "$_rtk_payload" \
    | PATH="$_rtk_tmp:$PATH" RTK_CAPTURE="$_rtk_capture" bash "$HOOK" >/dev/null \
    || _rtk_exit=$?

  if [ "$_rtk_exit" -eq 0 ] && grep -qF -- "$_rtk_command" "$_rtk_capture"; then
    echo "  PASS  RTK receives: $_rtk_command"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  RTK receives: $_rtk_command (exit=$_rtk_exit)"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: RTK did not receive: $_rtk_command"
  fi
done <<'EOF'
ls -la
tree -L 2
cat README.md
rg TODO .
ruff check .
pytest
docker ps
printf ok
EOF

# Missing RTK must not block the original command.
_rtk_missing_exit=0
_rtk_missing_output=$(printf '%s' '{"tool_name":"Bash","tool_input":{"command":"ls"}}' \
  | PATH="/usr/bin:/bin" bash "$REWRITE_HOOK") || _rtk_missing_exit=$?
if [ "$_rtk_missing_exit" -eq 0 ] && [ -z "$_rtk_missing_output" ]; then
  echo "  PASS  missing RTK fails open"
  PASS=$((PASS + 1))
else
  echo "  FAIL  missing RTK fails open (exit=$_rtk_missing_exit output=$_rtk_missing_output)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: missing RTK did not fail open"
fi

rm -rf "$_rtk_tmp"
