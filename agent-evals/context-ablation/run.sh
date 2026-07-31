#!/bin/bash
set -euo pipefail

# Paid, opt-in behavioral evaluation. Deterministic CI never calls this script.
# Usage:
#   agent-evals/context-ablation/run.sh [--dry|--smoke|--force]

root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$root"

command -v bun >/dev/null 2>&1 || {
  echo "bun is required" >&2
  exit 1
}

mode="${1:---dry}"
case "$mode" in
  --dry | --smoke | --force) ;;
  *)
    echo "usage: $0 [--dry|--smoke|--force]" >&2
    exit 1
    ;;
esac

export HOOK_METRICS_DISABLED=1

run_cell() {
  local agent="$1"
  local variant="$2"
  local effort="$3"
  local model="$4"
  echo "== $agent / $model / $variant / $effort =="
  ABLATION_AGENT="$agent" ABLATION_EFFORT="$effort" ABLATION_CLAUDE_MODEL="$model" \
    bunx @vercel/agent-eval@1.4.0 "$mode" \
    "agent-evals/context-ablation/${variant}.ts"
}

while IFS= read -r variant; do
  run_cell codex "$variant" xhigh gpt-5.6-sol
  run_cell codex "$variant" max gpt-5.6-sol
  run_cell claude-code "$variant" high fable
  run_cell claude-code "$variant" xhigh opus
done < <(jq -r '.variants[]' agent-evals/context-ablation/manifest.json)

if [ "$mode" = "--force" ]; then
  echo "Record the decision with agent-evals/context-ablation/scorecard-template.md"
fi
