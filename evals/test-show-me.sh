# Evals for the vendored humanlayer/show-me skill and install surfaces.

SKILL="$REPO_ROOT/show-me/SKILL.md"

run_file_eval "$SKILL" "show-me skill exists"
run_content_eval "$SKILL" "^name: show-me$" "show-me frontmatter name matches its directory"
run_content_eval "$SKILL" "smallest view that makes the key point clear" \
  "show-me keeps visuals focused"
run_content_eval "$SKILL" "pseudocode|call tree" \
  "show-me supports compact code-shape diagrams"
run_content_eval "$SKILL" "Mermaid" "show-me supports Mermaid diagrams"
run_content_eval "$SKILL" 'Use `diff`' "show-me supports visual diffs"
run_content_eval "$SKILL" "one focused HTML file" \
  "show-me supports focused HTML artifacts"
run_content_eval "$SKILL" "support desktop and mobile" \
  "show-me HTML artifacts cover responsive layouts"

run_file_eval "$REPO_ROOT/show-me/LICENSE" "show-me preserves its upstream MIT notice"
run_content_eval "$REPO_ROOT/show-me/LICENSE" "Copyright \(c\) 2026 HumanLayer" \
  "show-me credits HumanLayer"

run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"\./show-me/"' \
  "Claude plugin registers show-me"
run_content_eval "$REPO_ROOT/scripts/generate-skill-catalog.sh" '"show-me":' \
  "Codex metadata defines show-me"
run_file_eval "$REPO_ROOT/codex-skills/show-me/SKILL.md" \
  "Codex packages show-me"
run_file_eval "$REPO_ROOT/codex-skills/show-me/agents/openai.yaml" \
  "Codex packages show-me interface metadata"

run_content_eval "$REPO_ROOT/docs-site/generate-skill-diagrams.ts" '"show-me":' \
  "docs diagram generator defines show-me"
run_file_eval "$REPO_ROOT/docs-site/public/diagrams/skills/show-me.excalidraw" \
  "show-me keeps an editable docs diagram"
run_file_eval "$REPO_ROOT/docs-site/public/diagrams/skills/show-me.svg" \
  "show-me keeps an exported docs diagram"
