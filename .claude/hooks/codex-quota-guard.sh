#!/bin/bash
set -euo pipefail
exec "$(dirname "$0")/quota-guard.sh" codex
