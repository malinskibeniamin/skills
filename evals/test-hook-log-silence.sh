# A disappeared telemetry target must not turn a clean hook into noisy output.
_log_fixture=$(mktemp -d "${TMPDIR:-/tmp}/hook-log-silence.XXXXXX")
_log_session="eval-hook-log-silence-$$-$RANDOM"
_log_rc=0
CLAUDE_SESSION_ID="$_log_session" bash -c '
  source "$1/shared/hook-lib.sh"
  _hook_log_file="$2/disappeared/structured.jsonl"
  _hook_log_entry info fixture
  _hook_log_entry info fixture hook 7
' fixture "$REPO_ROOT" "$_log_fixture" \
  > "$_log_fixture/stdout" 2> "$_log_fixture/stderr" || _log_rc=$?
if [ "$_log_rc" -eq 0 ] && [ ! -s "$_log_fixture/stdout" ] && [ ! -s "$_log_fixture/stderr" ]; then
  echo "  PASS  failed telemetry writes stay silent in both timing branches"
  PASS=$((PASS + 1))
else
  echo "  FAIL  failed telemetry writes leak into clean hook output"
  cat "$_log_fixture/stderr"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: telemetry write failure silence"
fi
rm -rf "$_log_fixture" "/tmp/hook-session-$_log_session"
