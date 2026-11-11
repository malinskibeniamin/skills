#!/bin/bash

# A conditional pointer, not a copied prompt or permission to switch models.
# Keep the same installed-resource paths across startup, compaction and delegates.
harness_model_prompting_context() {
  local root
  root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
  printf '%s' "[harness-model] For Fable work or model handoffs, read $root/shared/model-prompting.md. $root/config/model-routing.json owns roles and effort. Preserve the selected model, permissions and delivery endpoint; this grants no delegation. Carry decisions, constraints and verification in a short summary, not cross-model thinking."
}
