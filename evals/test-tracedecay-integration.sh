CODEX_APPENDIX="$REPO_ROOT/.agents/codex-appendix.md"
README="$REPO_ROOT/README.md"
MCP_POLICY="$REPO_ROOT/.claude/hooks/mcp-ban.sh"
SETUP_SCRIPT="$REPO_ROOT/scripts/setup-tracedecay.sh"

run_executable_eval "$SETUP_SCRIPT" \
  "TraceDecay optional setup is executable"

if [ -x "$SETUP_SCRIPT" ]; then
  _td_tmp="$(mktemp -d "${TMPDIR:-/tmp}/frontend-skills-tracedecay-setup.XXXXXX")"
  _td_bin="$_td_tmp/bin"
  _td_project="$_td_tmp/project"
  _td_log="$_td_tmp/commands.log"
  mkdir -p "$_td_bin" "$_td_project"
  _td_project="$(cd "$_td_project" && pwd -P)"

  cat >"$_td_bin/brew" <<'SH'
#!/bin/sh
printf 'brew %s\n' "$*" >>"$TRACEDECAY_SETUP_LOG"
cat >"$TRACEDECAY_FAKE_BIN/tracedecay" <<'INNER'
#!/bin/sh
printf 'tracedecay %s\n' "$*" >>"$TRACEDECAY_SETUP_LOG"
if [ "$1" = "status" ] && [ "${TRACEDECAY_STATUS_OK:-0}" != "1" ]; then
  exit 1
fi
INNER
chmod +x "$TRACEDECAY_FAKE_BIN/tracedecay"
SH

  cat >"$_td_bin/codex" <<'SH'
#!/bin/sh
printf 'codex %s\n' "$*" >>"$TRACEDECAY_SETUP_LOG"
if [ "$*" = "plugin list --json" ]; then
  if [ "${TRACEDECAY_PLUGIN_INSTALLED:-0}" = "1" ]; then
    printf '%s\n' '{"installed":[{"pluginId":"tracedecay@personal"}]}'
  else
    printf '%s\n' '{"installed":[]}'
  fi
fi
SH
  chmod +x "$_td_bin/brew" "$_td_bin/codex"

  _td_run() {
    TRACEDECAY_SETUP_LOG="$_td_log" \
      TRACEDECAY_FAKE_BIN="$_td_bin" \
      PATH="$_td_bin:/usr/bin:/bin" \
      bash "$SETUP_SCRIPT" "$@"
  }

  _td_assert() {
    _td_description="$1"
    _td_pattern="$2"
    if grep -qF -- "$_td_pattern" "$_td_log"; then
      echo "  PASS  $_td_description"
      PASS=$((PASS + 1))
    else
      echo "  FAIL  $_td_description"
      FAIL=$((FAIL + 1))
      ERRORS="$ERRORS\n  FAIL: $_td_description"
    fi
  }

  : >"$_td_log"
  _td_run --yes --agent codex --project "$_td_project" >/dev/null
  _td_assert "setup installs a missing TraceDecay binary" \
    "brew install ScriptedAlchemy/tap/tracedecay"
  _td_assert "setup configures the selected agent" \
    "tracedecay install --agent codex"
  _td_assert "setup installs the generated Codex plugin" \
    "codex plugin add tracedecay@personal"
  _td_assert "setup enrolls the current project" \
    "tracedecay init $_td_project"
  _td_assert "setup verifies the finished integration" \
    "tracedecay doctor --agent codex"

  : >"$_td_log"
  TRACEDECAY_STATUS_OK=1 TRACEDECAY_PLUGIN_INSTALLED=1 \
    _td_run --yes --agent codex --project "$_td_project" >/dev/null
  if grep -qE '^(brew |codex plugin add|tracedecay init )' "$_td_log"; then
    echo "  FAIL  setup reuses an existing binary, plugin, and project index"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: setup idempotency"
  else
    echo "  PASS  setup reuses an existing binary, plugin, and project index"
    PASS=$((PASS + 1))
  fi

  _td_dry_output="$(
    TRACEDECAY_STATUS_OK=1 TRACEDECAY_PLUGIN_INSTALLED=1 \
      _td_run --dry-run --agent codex --project "$_td_project"
  )"
  if printf '%s\n' "$_td_dry_output" |
    grep -qE 'plugin add tracedecay@personal|tracedecay init '; then
    echo "  FAIL  dry-run omits setup already present on the machine"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: setup dry-run idempotency"
  else
    echo "  PASS  dry-run omits setup already present on the machine"
    PASS=$((PASS + 1))
  fi

  : >"$_td_log"
  printf 'n\n' | _td_run --agent codex --project "$_td_project" >/dev/null
  if [ -s "$_td_log" ]; then
    echo "  FAIL  setup makes no changes when declined"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: setup decline path"
  else
    echo "  PASS  setup makes no changes when declined"
    PASS=$((PASS + 1))
  fi

  rm -rf -- "$_td_tmp"
fi

run_content_eval "$CODEX_APPENDIX" "TraceDecay graph" \
  "Codex guidance names TraceDecay as the code-exploration graph"
run_content_eval "$CODEX_APPENDIX" "before broad shell search" \
  "Codex guidance prefers semantic exploration before broad shell search"
run_content_eval "$CODEX_APPENDIX" "tracedecay tool" \
  "Codex guidance documents the CLI fallback"
run_content_eval "$CODEX_APPENDIX" "scoped.*rg" \
  "Codex guidance retains a scoped native-search fallback"

for command in \
  "brew install ScriptedAlchemy/tap/tracedecay" \
  "tracedecay install --agent codex" \
  "codex plugin add tracedecay@personal" \
  "tracedecay daemon install-service" \
  "tracedecay init" \
  "tracedecay doctor --agent codex"; do
  run_content_eval "$README" "$command" "README documents: $command"
done

run_content_eval "$README" "Token-first hook profile.*UserPromptSubmit" \
  "README documents the measured token-first hook profile"
run_content_eval "$README" "setup-tracedecay.sh.*--agent codex" \
  "README exposes the opt-in TraceDecay setup helper"
run_content_eval "$MCP_POLICY" "TraceDecay" \
  "MCP policy explicitly preserves TraceDecay"
