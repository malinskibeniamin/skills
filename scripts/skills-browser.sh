#!/bin/bash
set -euo pipefail

# Pass-through to agent-browser for permitted interactive automation, not a
# replacement for Playwright Test. Tool choice and saved-flow safety belong to
# dogfood/SKILL.md#browser-and-data-tasks; user/host browser policy wins.
#
# Use a task-owned session, never a human-owned browser/profile. Examples:
#   scripts/skills-browser.sh --session <task> open https://app.example.com
#   scripts/skills-browser.sh --session <task> snapshot -i
#   scripts/skills-browser.sh --session <task> click @e5
#   scripts/skills-browser.sh --session <task> fill @e12 "value"
#   scripts/skills-browser.sh --session <task> screenshot --annotate /tmp/s.png
#   scripts/skills-browser.sh --session <task> close
#
# Missing CLI exits 127; callers must not count it as passing verification.

if ! command -v agent-browser >/dev/null 2>&1; then
  cat >&2 <<'EOF'
agent-browser not installed. Choose one:

  brew install agent-browser
  cargo install agent-browser
  npm install -g agent-browser

Then: agent-browser install  # Downloads Chrome; choose setup explicitly.

Browser verification BLOCKED until the permitted tool is available; no checks ran.
EOF
  exit 127
fi

exec agent-browser "$@"
