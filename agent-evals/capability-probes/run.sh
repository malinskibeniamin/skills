#!/bin/bash
set -euo pipefail

# Paid, opt-in upper-bound probes. Deterministic CI only stubs this runner.
# Usage: agent-evals/capability-probes/run.sh [--dry|--smoke|--force]

root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$root"

for required_command in bun jq claude; do
  command -v "$required_command" >/dev/null 2>&1 || {
    echo "$required_command is required" >&2
    exit 1
  }
done

mode="${1:---dry}"
case "$mode" in
  --dry | --smoke | --force) ;;
  *)
    echo "usage: $0 [--dry|--smoke|--force]" >&2
    exit 1
    ;;
esac

export HOOK_METRICS_DISABLED=1

version_at_least() {
  local current="$1"
  local required="$2"
  local current_major current_minor current_patch
  local required_major required_minor required_patch

  [[ "$current" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || return 1
  [[ "$required" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || return 1
  IFS=. read -r current_major current_minor current_patch <<< "$current"
  IFS=. read -r required_major required_minor required_patch <<< "$required"

  [ "$current_major" -gt "$required_major" ] ||
    { [ "$current_major" -eq "$required_major" ] && [ "$current_minor" -gt "$required_minor" ]; } ||
    { [ "$current_major" -eq "$required_major" ] && [ "$current_minor" -eq "$required_minor" ] && [ "$current_patch" -ge "$required_patch" ]; }
}

minimum_claude_version=$(jq -er '.minimum_claude_version' \
  agent-evals/capability-probes/manifest.json)
claude_version=$(claude --version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
if ! version_at_least "$claude_version" "$minimum_claude_version"; then
  echo "Claude Code $minimum_claude_version or newer is required; found ${claude_version:-unknown}. Run: claude update" >&2
  exit 1
fi

while IFS=$'\t' read -r agent model effort; do
  echo "== $agent / $model / $effort =="
  CAPABILITY_AGENT="$agent" CAPABILITY_MODEL="$model" CAPABILITY_EFFORT="$effort" \
    bunx @vercel/agent-eval@1.4.0 "$mode" \
    agent-evals/capability-probes/create-experiment.ts
done < <(
  jq -r '.models[] | [.agent, .id, .effort] | @tsv' \
    agent-evals/capability-probes/manifest.json
)

if [ "$mode" = "--force" ]; then
  echo "Record results with agent-evals/capability-probes/scorecard-template.md"
fi
