#!/bin/bash
set -euo pipefail

# Run tsgo type checking before Claude finishes responding
output=""
exit_code=0
output=$(tsgo --noEmit 2>&1) || exit_code=$?

if [ $exit_code -ne 0 ]; then
  # Truncate to keep context manageable
  truncated=$(echo "$output" | head -30)
  escaped=$(echo "$truncated" | jq -Rs .)
  echo "{\"decision\":\"block\",\"reason\":\"Type errors found. Fix before finishing:\\n\"$escaped\"\"}" >&2
  exit 2
fi

exit 0
