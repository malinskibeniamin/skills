# Evals for latest release metadata bump.

run_content_eval "$REPO_ROOT/skill-manifest.json" '"version": "4\.18\.0"' "skill manifest bumped to 4.18.0"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"version": "4\.18\.0"' "Claude plugin bumped to 4.18.0"
run_content_eval "$REPO_ROOT/.codex-plugin/plugin.json" '"version": "4\.18\.0"' "Codex plugin bumped to 4.18.0"
run_content_eval "$REPO_ROOT/.claude-plugin/marketplace.json" '"version": "4\.18\.0"' "Claude marketplace bumped to 4.18.0"
run_content_eval "$REPO_ROOT/.agents/plugins/marketplace.json" '"version": "4\.18\.0"' "Codex marketplace bumped to 4.18.0"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '75 skills' "Claude plugin describes 75 skills"
run_content_eval "$REPO_ROOT/.codex-plugin/plugin.json" '75 skills' "Codex plugin describes 75 skills"
run_content_eval "$REPO_ROOT/.claude-plugin/marketplace.json" '75 skills' "Claude marketplace describes 75 skills"
run_content_eval "$REPO_ROOT/.agents/plugins/marketplace.json" '75 skills' "Codex marketplace describes 75 skills"
run_content_eval "$REPO_ROOT/CHANGELOG.md" '^## 4\.18\.0$' "changelog has 4.18.0 section"
run_content_eval "$REPO_ROOT/README.md" 'v4\.18\.0' "README pinned release example updated"
run_content_eval "$REPO_ROOT/.claude-plugin/marketplace.json" '98 hooks, 75 skills' "Claude marketplace top-level description has 75 skills"
