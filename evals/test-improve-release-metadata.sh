# Evals for latest release metadata bump.

run_content_eval "$REPO_ROOT/skill-manifest.json" '"version": "4\.20\.0"' "skill manifest bumped to 4.20.0"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"version": "4\.20\.0"' "Claude plugin bumped to 4.20.0"
run_content_eval "$REPO_ROOT/.codex-plugin/plugin.json" '"version": "4\.20\.0"' "Codex plugin bumped to 4.20.0"
run_content_eval "$REPO_ROOT/.claude-plugin/marketplace.json" '"version": "4\.20\.0"' "Claude marketplace bumped to 4.20.0"
run_content_eval "$REPO_ROOT/.agents/plugins/marketplace.json" '"version": "4\.20\.0"' "Codex marketplace bumped to 4.20.0"
skill_count=$(find "$REPO_ROOT" -maxdepth 2 -name SKILL.md -not -path '*/agent-evals/*' | wc -l | tr -d ' ')
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "${skill_count} skills" "Claude plugin describes current skill count"
run_content_eval "$REPO_ROOT/.codex-plugin/plugin.json" "${skill_count} skills" "Codex plugin describes current skill count"
run_content_eval "$REPO_ROOT/.claude-plugin/marketplace.json" "${skill_count} skills" "Claude marketplace describes current skill count"
run_content_eval "$REPO_ROOT/.agents/plugins/marketplace.json" "${skill_count} skills" "Codex marketplace describes current skill count"
run_content_eval "$REPO_ROOT/CHANGELOG.md" '^## 4\.20\.0$' "changelog has 4.20.0 section"
run_content_eval "$REPO_ROOT/README.md" 'v4\.20\.0' "README pinned release example updated"
run_content_eval "$REPO_ROOT/.claude-plugin/marketplace.json" "98 hooks, ${skill_count} skills" "Claude marketplace top-level description has current skill count"
