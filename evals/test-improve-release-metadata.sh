# Evals for latest release metadata bump.

run_content_eval "$REPO_ROOT/skill-manifest.json" '"version": "4\.27\.0"' "skill manifest bumped to 4.26.0"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"version": "4\.27\.0"' "Claude plugin bumped to 4.26.0"
run_content_eval "$REPO_ROOT/.codex-plugin/plugin.json" '"version": "4\.27\.0"' "Codex plugin bumped to 4.26.0"
run_content_eval "$REPO_ROOT/.claude-plugin/marketplace.json" '"version": "4\.27\.0"' "Claude marketplace bumped to 4.26.0"
run_content_eval "$REPO_ROOT/.agents/plugins/marketplace.json" '"version": "4\.27\.0"' "Codex marketplace bumped to 4.26.0"
skill_count=$(find "$REPO_ROOT" -maxdepth 2 -name SKILL.md -not -path '*/agent-evals/*' | wc -l | tr -d ' ')
hook_count=$(jq '[.hooks[][][]] | length' "$REPO_ROOT/skill-manifest.json")
hook_script_count=$(find "$REPO_ROOT/.claude/hooks" -maxdepth 1 -type f -name '*.sh' | wc -l | tr -d ' ')
agent_count=$(jq '.agents | length' "$REPO_ROOT/.claude-plugin/plugin.json")
routine_count=$(find "$REPO_ROOT/setup-routines/routines" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')
for metadata_file in \
  "$REPO_ROOT/.claude-plugin/plugin.json" \
  "$REPO_ROOT/.codex-plugin/plugin.json" \
  "$REPO_ROOT/.claude-plugin/marketplace.json" \
  "$REPO_ROOT/.agents/plugins/marketplace.json" \
  "$REPO_ROOT/CHANGELOG.md"
do
  run_content_eval "$metadata_file" "${hook_count} hooks" "$(basename "$metadata_file") describes current hook count"
  run_content_eval "$metadata_file" "${skill_count} skills" "$(basename "$metadata_file") describes current skill count"
  run_content_eval "$metadata_file" "${hook_script_count} hook scripts" "$(basename "$metadata_file") describes current hook script count"
  run_content_eval "$metadata_file" "${agent_count} agents" "$(basename "$metadata_file") describes current agent count"
  run_content_eval "$metadata_file" "${routine_count} routines" "$(basename "$metadata_file") describes current routine count"
done
run_content_eval "$REPO_ROOT/.claude-plugin/marketplace.json" "${hook_count} hooks, ${skill_count} skills" "Claude marketplace top-level description has current counts"
run_content_eval "$REPO_ROOT/CHANGELOG.md" '^## 4\.27\.0$' "changelog has 4.26.0 section"
run_content_eval "$REPO_ROOT/README.md" 'v4\.27\.0' "README pinned release example updated"

if python3 - "$REPO_ROOT" <<'PY'
import json
import pathlib
import sys
repo = pathlib.Path(sys.argv[1])
checks = [
    (repo / ".claude-plugin/plugin.json", lambda data: data["description"], 900),
    (repo / ".codex-plugin/plugin.json", lambda data: data["description"], 900),
    (repo / ".codex-plugin/plugin.json", lambda data: data["interface"]["shortDescription"], 160),
    (repo / ".codex-plugin/plugin.json", lambda data: data["interface"]["longDescription"], 900),
    (repo / ".claude-plugin/marketplace.json", lambda data: data["metadata"]["description"], 180),
    (repo / ".claude-plugin/marketplace.json", lambda data: data["plugins"][0]["description"], 900),
    (repo / ".agents/plugins/marketplace.json", lambda data: data["plugins"][0]["description"], 900),
]
problems = []
for path, pick, limit in checks:
    value = pick(json.loads(path.read_text()))
    if len(value) > limit:
        problems.append(f"{path}: description is {len(value)} chars, limit {limit}")
if problems:
    print("\n".join(problems))
    raise SystemExit(1)
PY
then
  echo "  PASS  marketplace and plugin descriptions stay concise"
  PASS=$((PASS + 1))
else
  echo "  FAIL  marketplace and plugin descriptions stay concise"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS
  FAIL: marketplace and plugin descriptions concise"
fi
