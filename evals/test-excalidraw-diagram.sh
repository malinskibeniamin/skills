# Contract for the Excalidraw diagram-generation skill.

SKILL="$REPO_ROOT/excalidraw-diagram/SKILL.md"
REFERENCE="$REPO_ROOT/excalidraw-diagram/REFERENCE.md"
VISUAL_REVIEW="$REPO_ROOT/visual-review/SKILL.md"
VISUAL_RECAP="$REPO_ROOT/visual-recap/SKILL.md"
IMPROVE="$REPO_ROOT/improve/SKILL.md"
ARCHITECTURE_REPORT="$REPO_ROOT/improve/references/architecture-report.md"

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
run_content_eval "$SKILL" 'describe.*elements.*before|before.*export.*describe.*elements' \
  "skill refuses empty editable exports after Mermaid conversion"
run_content_eval "$SKILL" '\.excalidraw.*(PNG|SVG)|PNG.*\.excalidraw|SVG.*\.excalidraw' \
  "skill preserves editable source with rendered output"
run_content_eval "$SKILL" 'isolated browser' \
  "skill keeps browser automation isolated"
run_content_eval "$REFERENCE" 'Shadcn-style preset' \
  "reference defines the requested visual preset"
run_content_eval "$REFERENCE" 'roughness' \
  "reference preserves Excalidraw rough rendering"
run_content_eval "$REFERENCE" '5.?10 nodes|five to ten nodes' \
  "reference bounds Mermaid complexity before tool switching"
run_content_eval "$REFERENCE" 'accTitle.*accDescr|accDescr.*accTitle' \
  "reference requires Mermaid-native accessibility metadata"
run_content_eval "$REFERENCE" 'canonical source|source of truth' \
  "reference prevents Mermaid and Excalidraw sources from drifting"
run_content_eval "$REFERENCE" 'target renderer|repository.*build|build.*repository' \
  "reference validates durable Mermaid in its destination renderer"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"\./excalidraw-diagram/"' \
  "Claude plugin registers the Excalidraw skill"
run_file_eval "$REPO_ROOT/codex-skills/excalidraw-diagram/SKILL.md" \
  "Codex plugin exposes the Excalidraw skill"
run_file_eval "$REPO_ROOT/codex-skills/excalidraw-diagram/agents/openai.yaml" \
  "Codex plugin exposes Excalidraw UI metadata"
run_content_eval "$VISUAL_REVIEW" '/excalidraw-diagram' \
  "visual review can add an editable flow map when screenshots are insufficient"
run_content_eval "$VISUAL_REVIEW" 'screenshots.*primary|primary.*screenshots' \
  "visual review keeps screenshots as primary evidence"
run_content_eval "$VISUAL_REVIEW" 'Mermaid.*fallback|fallback.*Mermaid' \
  "visual review degrades gracefully when the Excalidraw canvas is unavailable"
run_content_eval "$VISUAL_RECAP" '/excalidraw-diagram' \
  "visual recap can map architecture and data-flow changes with Excalidraw"
run_content_eval "$VISUAL_RECAP" 'Agent-Native.*primary|primary.*Agent-Native' \
  "visual recap keeps the Agent-Native recap as the primary review surface"
run_content_eval "$VISUAL_RECAP" '\.excalidraw.*(PNG|SVG)|PNG.*\.excalidraw|SVG.*\.excalidraw' \
  "visual recap preserves editable source beside its rendered diagram"
run_content_eval "$IMPROVE" '/excalidraw-diagram' \
  "architecture improvement can create editable before-and-after diagrams"
run_content_eval "$IMPROVE" 'artifact.*requested|requested.*artifact' \
  "architecture improvement keeps diagram files behind the requested artifact boundary"
run_content_eval "$ARCHITECTURE_REPORT" '/excalidraw-diagram' \
  "architecture report documents its Excalidraw rendering path"
run_content_eval "$ARCHITECTURE_REPORT" 'Mermaid.*simple|simple.*Mermaid' \
  "architecture report keeps Mermaid for simple graph-shaped evidence"
run_content_eval "$ARCHITECTURE_REPORT" 'mermaid@11\.16\.1' \
  "architecture report pins the Mermaid renderer exactly"
run_content_eval "$ARCHITECTURE_REPORT" 'securityLevel: "strict"' \
  "architecture report keeps Mermaid HTML rendering strict"
