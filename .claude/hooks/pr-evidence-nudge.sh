#!/bin/bash
set -euo pipefail

# Advisory routing, not a shell parser or proof that visual evidence is complete.
# Successful-hook context must be in stdout JSON, not debug-only stderr.
command=$(jq -r '.tool_input.command // empty' | tr -d "\\\\\"'")
if printf '%s' "$command" | grep -qE '(^|[[:space:];|&/])(gh[[:space:]]+((--repo|-R|--hostname)[=[:space:]]+[^[:space:]]+[[:space:]]+)*(pr[[:space:]]+(create|edit|reopen|ready)|stack[[:space:]]+submit)|git[[:space:]]+push)([[:space:];|&]|$)'; then
  jq -nc --arg context '[pr-evidence] Before publication, follow commit-push-pr/REFERENCE.md and shared/verifiability.md#proportionate-verification: smallest functional diff, existing checks first, new regressions only for credible uncovered risk. Reconcile an existing session PR with its full diff, value, decisive results and material limits; re-read the hosted body after updates. Inspect affected rendering; retain focused screenshots/comparisons only when useful or explicitly required. Backend/API/Protobuf/frontend-backend contract, architecture, data-flow or workflow changes without explanatory screenshots/video require a source-grounded diagram (excalidraw-diagram/PR-WORKFLOW.md); prefer Excalidraw, fall back to inline Mermaid on rendering/upload failure. Mixed changes still need diagrams for unexplained non-UI contracts. The lifecycle Stop gate requires hosted visual evidence or Visual evidence: not applicable — <concrete reason> for changes outside that scope. It checks presence, not accuracy or skip eligibility. Video, annotations, reports and new visual runners remain conditional. Keep logs/captures temporary and summarize inline. Reuse existing consuming-repo safeguards; add files only for a concrete in-scope need. Preserve hosted policy and approval counts; missing required checks/access is not green. Push alone never authorizes PR creation.' \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:$context}}'
fi
