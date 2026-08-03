# Contract for the Excalidraw diagram-generation skill.

SKILL="$REPO_ROOT/excalidraw-diagram/SKILL.md"
REFERENCE="$REPO_ROOT/excalidraw-diagram/REFERENCE.md"

run_file_eval "$SKILL" "Excalidraw skill exists"
run_file_eval "$REFERENCE" "Excalidraw scene reference exists"
run_content_eval "$SKILL" '^name: excalidraw-diagram$' \
  "skill exposes the Excalidraw diagram trigger"
run_content_eval "$SKILL" 'bunx mcp-excalidraw-server@1\.1\.0' \
  "skill pins its CLI dependency and uses Bun"
run_content_eval "$SKILL" 'CONDUCTOR_PORT:-3000' \
  "skill avoids fixed-port collisions in Conductor workspaces"
run_content_eval "$SKILL" 'Mermaid.*direct elements|direct elements.*Mermaid' \
  "skill routes structured and art-directed diagrams separately"
run_content_eval "$SKILL" 'screenshot.*view.*fix|screenshot.*inspect.*fix' \
  "skill requires a visual correction loop"
run_content_eval "$SKILL" '\.excalidraw.*(PNG|SVG)|PNG.*\.excalidraw|SVG.*\.excalidraw' \
  "skill preserves editable source with rendered output"
run_content_eval "$SKILL" 'isolated browser' \
  "skill keeps browser automation isolated"
run_content_eval "$REFERENCE" 'Shadcn-style preset' \
  "reference defines the requested visual preset"
run_content_eval "$REFERENCE" 'roughness' \
  "reference preserves Excalidraw rough rendering"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"\./excalidraw-diagram/"' \
  "Claude plugin registers the Excalidraw skill"
run_file_eval "$REPO_ROOT/codex-skills/excalidraw-diagram/SKILL.md" \
  "Codex plugin exposes the Excalidraw skill"
run_file_eval "$REPO_ROOT/codex-skills/excalidraw-diagram/agents/openai.yaml" \
  "Codex plugin exposes Excalidraw UI metadata"
