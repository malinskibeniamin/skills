# Evals for the explicit customer-facing /demo artifact workflow.

SKILL="$REPO_ROOT/demo/SKILL.md"
REFERENCE="$REPO_ROOT/demo/REFERENCE.md"
PLUGIN="$REPO_ROOT/.claude-plugin/plugin.json"

run_file_eval "$SKILL" "demo SKILL.md exists"
run_file_eval "$REFERENCE" "demo reference exists"
run_content_eval "$SKILL" "^name: demo$" "demo name matches its directory"
run_content_eval "$SKILL" "^disable-model-invocation: true$" \
  "demo is explicit-only"
run_content_eval "$SKILL" "customer" "demo optimizes for a customer audience"
run_content_eval "$SKILL" "demos/<slug>" "demo stores committed artifacts predictably"
run_content_eval "$SKILL" "Remotion" "demo prefers Remotion"
run_content_eval "$SKILL" "architecture diagram" \
  "demo has an architecture-diagram fallback"
run_content_eval "$SKILL" "README" "demo protects README from automatic edits"
run_content_eval "$SKILL" "draft PR|--draft" "demo publishes through a draft PR"
run_content_eval "$SKILL" "open -R|Finder" "demo reveals the recording in Finder"
run_content_eval "$SKILL" "absolute.*path|pwd.*cd" \
  "demo reports a terminal-navigable output path"

run_content_eval "$REFERENCE" "merge-base|whole.*diff" \
  "demo grounds its story in the whole change"
run_content_eval "$REFERENCE" "problem.*action.*payoff" \
  "demo uses a customer story arc"
run_content_eval "$REFERENCE" "remotion-best-practices|remotion-create" \
  "demo routes Remotion work through official skills"
run_content_eval "$REFERENCE" "demo\.mp4" "demo renders a stable recording filename"
run_content_eval "$REFERENCE" "early.*middle.*late|sample frames" \
  "demo visually verifies representative frames"
run_content_eval "$REFERENCE" "secret|PII|private" \
  "demo redacts sensitive source material"
run_content_eval "$REFERENCE" "one documented.*blocker|only.*block" \
  "demo falls back only after a concrete Remotion blocker"
run_content_eval "$REFERENCE" "\/commit-push-pr|gh pr create" \
  "demo reuses the repository PR workflow"
run_content_eval "$REFERENCE" "--draft" "demo always requests draft PR mode"
run_content_eval "$REFERENCE" "Do not edit.*README|Never edit.*README" \
  "demo never edits README automatically"

run_content_eval "$PLUGIN" '"\./demo/"' "Claude plugin registers demo"
run_content_eval "$REPO_ROOT/scripts/generate-skill-catalog.sh" '"demo":' \
  "Codex metadata defines demo"
run_file_eval "$REPO_ROOT/codex-skills/demo/SKILL.md" \
  "generated Codex demo proxy exists"
run_file_eval "$REPO_ROOT/codex-skills/demo/agents/openai.yaml" \
  "generated Codex demo metadata exists"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "/demo" \
  "generated catalog lists demo"
