# Evals for /improve release metadata bump.

run_content_eval "$REPO_ROOT/skill-manifest.json" '"version": "4\.17\.0"' "skill manifest bumped to 4.17.0"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"version": "4\.17\.0"' "Claude plugin bumped to 4.17.0"
run_content_eval "$REPO_ROOT/.codex-plugin/plugin.json" '"version": "4\.17\.0"' "Codex plugin bumped to 4.17.0"
run_content_eval "$REPO_ROOT/.claude-plugin/marketplace.json" '"version": "4\.17\.0"' "Claude marketplace bumped to 4.17.0"
run_content_eval "$REPO_ROOT/.agents/plugins/marketplace.json" '"version": "4\.17\.0"' "Codex marketplace bumped to 4.17.0"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '74 skills' "Claude plugin describes 74 skills"
run_content_eval "$REPO_ROOT/.codex-plugin/plugin.json" '74 skills' "Codex plugin describes 74 skills"
run_content_eval "$REPO_ROOT/.claude-plugin/marketplace.json" '74 skills' "Claude marketplace describes 74 skills"
run_content_eval "$REPO_ROOT/.agents/plugins/marketplace.json" '74 skills' "Codex marketplace describes 74 skills"
run_content_eval "$REPO_ROOT/CHANGELOG.md" '^## 4\.17\.0$' "changelog has 4.17.0 section"
run_content_eval "$REPO_ROOT/README.md" 'v4\.17\.0' "README pinned release example updated"
run_content_eval "$REPO_ROOT/.claude-plugin/marketplace.json" '98 hooks, 74 skills' "Claude marketplace top-level description has 74 skills"
