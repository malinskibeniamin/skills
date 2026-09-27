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

# Harness weaving: show-me is the in-chat rendering vocabulary for intent maps and
# the lightweight neighbor of the HTML explainer and plan skills.
run_content_eval "$SKILL" "^description: .*Use when" "show-me description states when to invoke it"
run_content_eval "$SKILL" "never add one-shot" "show-me keeps HTML artifacts out of the repo"
run_content_eval "$SKILL" "Bash\(open /absolute/" "show-me opens an absolute HTML path"
run_content_eval "$SKILL" "/eli5.*/visual-plan" "show-me routes heavier visuals to its neighbors"
run_content_eval "$REPO_ROOT/shared/intent-map.md" "/show-me" \
  "intent maps render Implementation nodes with show-me views"
run_content_eval "$REPO_ROOT/eli5/SKILL.md" "/show-me" "eli5 routes expert in-chat visuals to show-me"
run_content_eval "$REPO_ROOT/visual-plan/SKILL.md" "/show-me" \
  "visual-plan routes quick in-chat views to show-me"
