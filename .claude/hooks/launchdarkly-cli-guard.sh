#!/bin/bash
set -euo pipefail

# PreToolUse Bash: redirect direct HTTP clients for LaunchDarkly management
# APIs to ldcli. This is a routing guard, not a shell security sandbox.
source "$(dirname "$0")/source-hook-lib.sh"
hook_parse_bash

# Keep the original command (which may contain secrets) out of process argv.
if printf '%s' "$command" | python3 -c "$(cat <<'PY'
import re
import shlex
import sys

api = re.compile(r"^https?://(?:app(?:\.eu)?\.launchdarkly\.com|app\.launchdarkly\.us)(?::\d+)?/api/", re.I)
assignment = re.compile(r"^[A-Za-z_]\w*=")

def uses_direct_http(command):
    # Ignore heredoc data (docs, fixtures, patch payloads), not shell commands.
    lines = []
    delimiter = None
    for line in command.replace("\\\n", "").splitlines():
        if delimiter is not None:
            if line.strip() == delimiter:
                delimiter = None
            continue
        lines.append(line)
        match = re.search(r"<<-?\s*(['\"]?)([A-Za-z_]\w*)\1", line)
        if match:
            delimiter = match[2]

    lexer = shlex.shlex("\n".join(lines), posix=True, punctuation_chars=";|&()\n")
    lexer.whitespace = " \t\r"
    lexer.whitespace_split = True
    try:
        tokens = list(lexer)
    except ValueError:
        return False  # Incomplete shell syntax is not an executable request.

    segment = []
    for token in tokens + [";"]:
        if token and all(char in ";|&()\n" for char in token):
            while segment and (assignment.match(segment[0]) or segment[0] in {"env", "sudo", "command", "exec"}):
                segment.pop(0)
            if segment:
                executable = segment[0].rsplit("/", 1)[-1]
                if executable in {"curl", "wget", "http", "https"}:
                    if any(api.match(arg.split("=", 1)[1] if arg.startswith("--url=") else arg) for arg in segment[1:]):
                        return True
                if executable in {"bash", "sh", "zsh", "dash"}:
                    for index, arg in enumerate(segment[1:], 1):
                        if arg.startswith("-") and "c" in arg and index + 1 < len(segment):
                            if uses_direct_http(segment[index + 1]):
                                return True
                            break
            segment = []
        else:
            segment.append(token)
    return False

sys.exit(0 if uses_direct_http(sys.stdin.read()) else 1)
PY
)"
then
  hook_deny "LaunchDarkly direct HTTP blocked. Use ldcli flags get/list/update with verified project, environment, and flag keys. Read shared/ldcli.md; missing installation or authentication is not permission to bypass ldcli." "launchdarkly-cli-guard"
fi

exit 0
