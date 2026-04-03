#!/bin/bash
set -euo pipefail

# LLM-friendly test output: only show failures, suppress passing tests
echo "export AI_AGENT=1" >> "$CLAUDE_ENV_FILE"
echo "export CLAUDECODE=1" >> "$CLAUDE_ENV_FILE"

exit 0
