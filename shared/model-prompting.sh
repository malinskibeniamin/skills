#!/bin/bash

# A conditional pointer, not a copied prompt or permission to switch models.
# Keep the same installed-resource paths across startup, compaction and delegates.
harness_model_prompting_context() {
  local model="${1:-claude-fable-5-2}"
  local root
  root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
  case "$model" in
    gemini-4-*|*neon*|*carbon*|*hydrogen*)
      printf '%s' "[harness-model] For Gemini 4 on Antigravity, read $root/shared/model-prompting.md#gemini-4-on-antigravity. $root/config/antigravity-model-routing.json owns Antigravity host defaults. Preserve the selected Gemini model, effort, permissions and delivery endpoint; batch independent reads/edits in parallel and inspect shell output directly for warnings."
      ;;
    *)
      printf '%s' "[harness-model] For Fable work or model handoffs, read $root/shared/model-prompting.md. $root/config/model-routing.json owns roles and effort. Preserve the selected model, permissions and delivery endpoint; this grants no delegation. Carry decisions, constraints and verification in a short summary, not cross-model thinking."
      ;;
  esac
}
