# Contract for the Excalidraw diagram-generation skill.

SKILL="$REPO_ROOT/excalidraw-diagram/SKILL.md"
REFERENCE="$REPO_ROOT/excalidraw-diagram/REFERENCE.md"
VISUAL_REVIEW="$REPO_ROOT/visual-review/SKILL.md"
VISUAL_RECAP="$REPO_ROOT/visual-recap/SKILL.md"
IMPROVE="$REPO_ROOT/improve-codebase-architecture/SKILL.md"
ARCHITECTURE_REPORT="$REPO_ROOT/improve-codebase-architecture/HTML-REPORT.md"
PR_WORKFLOW="$REPO_ROOT/excalidraw-diagram/PR-WORKFLOW.md"

run_file_eval "$SKILL" "Excalidraw skill exists"
run_file_eval "$REFERENCE" "Excalidraw scene reference exists"
run_content_eval "$SKILL" '^name: excalidraw-diagram$' \
  "skill exposes the Excalidraw diagram trigger"
run_content_eval "$SKILL" 'bunx @excalidraw/cli@0\.2\.0 render' \
  "skill defaults to the pinned official local renderer"
run_content_eval "$SKILL" 'no account|no API key' \
  "local rendering does not require Excalidraw+ authentication"
run_content_eval "$REFERENCE" 'bunx mcp-excalidraw-server@2\.1\.2' \
  "reference retains the pinned optional canvas CLI"
run_content_eval "$REFERENCE" 'SVG.*without.*browser|without.*browser.*SVG' \
  "optional SVG export does not require a person's browser"
run_content_eval "$REFERENCE" 'CONDUCTOR_PORT:-3000' \
  "skill avoids fixed-port collisions in Conductor workspaces"
run_content_eval "$SKILL" 'Mermaid.*direct elements|direct elements.*Mermaid' \
  "skill routes structured and art-directed diagrams separately"
run_content_eval "$SKILL" 'screenshot.*view.*fix|screenshot.*inspect.*fix' \
  "skill requires a visual correction loop"
run_content_eval "$SKILL" 'describe.*elements.*before|before.*export.*describe.*elements' \
  "skill refuses empty editable exports after Mermaid conversion"
run_content_eval "$SKILL" '\.excalidraw.*(PNG|SVG)|PNG.*\.excalidraw|SVG.*\.excalidraw' \
  "skill preserves editable source with rendered output"
run_content_eval "$REFERENCE" 'isolated browser' \
  "skill keeps browser automation isolated"
run_content_eval "$REFERENCE" '"type": "excalidraw"' \
  "reference provides a native editable scene, not only canvas shorthand"
run_file_eval "$PR_WORKFLOW" "backend diagram workflow exists"
run_content_eval "$PR_WORKFLOW" 'architecture, data flow, API contracts, or workflows' \
  "backend diagrams target meaningful structural and contract changes"
run_content_eval "$PR_WORKFLOW" 'mechanical|docs-only' \
  "backend diagrams skip changes without a useful architectural delta"
run_content_eval "$PR_WORKFLOW" 'Git.*authoritative|Git.*source of truth' \
  "maintained diagram authority stays in Git"
run_content_eval "$PR_WORKFLOW" 'same PR' \
  "relevant existing diagrams are refreshed with the code change"
run_content_eval "$PR_WORKFLOW" 'merge-base|base revision' \
  "before diagrams use actual base evidence"
run_content_eval "$PR_WORKFLOW" 'nonblocking|non-blocking' \
  "diagram failures remain nonblocking"
run_content_eval "$PR_WORKFLOW" 'diagram.*not.*(test|proof)|not.*(test|proof).*diagram' \
  "architectural illustrations do not replace execution evidence"
run_content_eval "$REPO_ROOT/pr/SKILL.md" 'backend diagrams' \
  "PR descriptions route eligible backend changes to diagram guidance"
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" 'backend diagrams' \
  "delivery considers backend diagrams before publishing the PR"
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
run_content_eval "$IMPROVE" 'Skill tool with "excalidraw-diagram"' \
  "architecture improvement can create editable before-and-after diagrams"
run_content_eval "$IMPROVE" '\$TMPDIR/architecture-review|OS temp directory' \
  "architecture improvement keeps report artifacts outside the repository"
run_content_eval "$ARCHITECTURE_REPORT" '/excalidraw-diagram' \
  "architecture report documents its Excalidraw rendering path"
run_content_eval "$ARCHITECTURE_REPORT" 'Mermaid.*simple|simple.*Mermaid' \
  "architecture report keeps Mermaid for simple graph-shaped evidence"
run_content_eval "$ARCHITECTURE_REPORT" 'mermaid@11\.16\.1' \
  "architecture report pins the Mermaid renderer exactly"
run_content_eval "$ARCHITECTURE_REPORT" 'securityLevel: "strict"' \
  "architecture report keeps Mermaid HTML rendering strict"
