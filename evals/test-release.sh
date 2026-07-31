# Evals for the explicit frontend-skills release workflow.

RELEASE_SKILL="$REPO_ROOT/release/SKILL.md"

run_file_eval "$RELEASE_SKILL" "release skill exists"
run_content_eval "$RELEASE_SKILL" '^name: release$' "release skill has correct name"
run_content_eval "$RELEASE_SKILL" '^disable-model-invocation: true$' "release is explicit-use only"
run_content_eval "$RELEASE_SKILL" 'origin/main|latest main' "release starts from latest main"
run_content_eval "$RELEASE_SKILL" 'clean (worktree|tree)' "release requires a clean worktree"
run_content_eval "$RELEASE_SKILL" 'tag.*release.*(absent|collision)|collision.*tag' "release rejects tag and release collisions"
run_content_eval "$RELEASE_SKILL" 'RED.*release.metadata|release.metadata.*RED' "release bumps metadata test-first"
run_content_eval "$RELEASE_SKILL" 'skill-manifest\.json' "release updates the source manifest"
run_content_eval "$RELEASE_SKILL" 'both marketplaces|marketplaces.*plugin manifests' "release aligns every version surface"
run_content_eval "$RELEASE_SKILL" 'test-claude-plugin-install\.sh' "release exercises the Claude installer"
run_content_eval "$RELEASE_SKILL" 'test-codex-plugin-install\.sh' "release exercises the Codex installer"
run_content_eval "$RELEASE_SKILL" 'merge permission|permission.*merge' "release preserves the merge permission boundary"
run_content_eval "$RELEASE_SKILL" 'merge commit' "release tags the merged commit"
run_content_eval "$RELEASE_SKILL" 'gh release create' "release publishes through GitHub Releases"
run_content_eval "$RELEASE_SKILL" 'fresh isolated.*Claude|Claude.*fresh isolated' "release replays a fresh Claude install"
run_content_eval "$RELEASE_SKILL" 'fresh isolated.*Codex|Codex.*fresh isolated' "release replays a fresh Codex install"
run_content_eval "$RELEASE_SKILL" 'latest release' "release verifies latest-release identity"

run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"\./release/"' \
  "Claude plugin registers release"
run_content_eval "$REPO_ROOT/scripts/generate-skill-catalog.sh" '"release":' \
  "catalog generator knows release"
run_file_eval "$REPO_ROOT/codex-skills/release/SKILL.md" \
  "Codex release proxy exists"
run_file_eval "$REPO_ROOT/codex-skills/release/agents/openai.yaml" \
  "Codex release interface metadata exists"
run_content_eval "$REPO_ROOT/.github/workflows/evals.yml" '@anthropic-ai/claude-code@[0-9]' \
  "CI pins Claude Code for plugin integration"
run_content_eval "$REPO_ROOT/.github/workflows/evals.yml" 'CLAUDE_PLUGIN_INSTALL_REQUIRED: "1"' \
  "CI requires the Claude installation smoke test"
run_content_eval "$REPO_ROOT/README.md" 'claude plugin marketplace update skills' \
  "README refreshes the Claude marketplace before upgrading"
run_content_eval "$REPO_ROOT/README.md" 'claude plugin update frontend-skills@skills' \
  "README uses the supported Claude plugin update command"
run_content_eval "$REPO_ROOT/README.md" 'claude plugin list --json' \
  "README verifies the active Claude installation instead of a lexicographic cache path"
