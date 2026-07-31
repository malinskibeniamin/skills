# Real Claude Code CLI integration test. CI sets
# CLAUDE_PLUGIN_INSTALL_REQUIRED=1 after installing the pinned CLI; local runs
# skip when Claude Code is unavailable.

_claude_install_test="$REPO_ROOT/scripts/test-claude-plugin-install.sh"
_claude_install_bin="${CLAUDE_BIN:-$(command -v claude 2>/dev/null || true)}"

if [ -z "$_claude_install_bin" ]; then
  if [ "${CLAUDE_PLUGIN_INSTALL_REQUIRED:-0}" = "1" ]; then
    echo "  FAIL  Claude Code CLI is required for plugin installation testing"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: Claude Code CLI missing for plugin installation test"
  else
    echo "  SKIP  Claude plugin installation test (Claude Code CLI unavailable)"
    SKIP=$((SKIP + 1))
  fi
elif [ ! -x "$_claude_install_test" ]; then
  echo "  FAIL  Claude plugin installation test is executable"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: missing executable scripts/test-claude-plugin-install.sh"
elif CLAUDE_BIN="$_claude_install_bin" "$_claude_install_test"; then
  echo "  PASS  Claude Code installs the local frontend-skills plugin"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Claude Code installs the local frontend-skills plugin"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Claude plugin installation integration test"
fi
