#!/bin/bash
set -euo pipefail
exec "$(dirname "$0")/pr-review-auto-hook.sh" codex
