# Evals for latest release metadata bump.

run_content_eval "$REPO_ROOT/skill-manifest.json" '"version": "4\.28\.0"' "skill manifest bumped to 4.28.0"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"version": "4\.28\.0"' "Claude plugin bumped to 4.28.0"
run_content_eval "$REPO_ROOT/.codex-plugin/plugin.json" '"version": "4\.28\.0"' "Codex plugin bumped to 4.28.0"
run_content_eval "$REPO_ROOT/.claude-plugin/marketplace.json" '"version": "4\.28\.0"' "Claude marketplace bumped to 4.28.0"
run_content_eval "$REPO_ROOT/.agents/plugins/marketplace.json" '"version": "4\.28\.0"' "Codex marketplace bumped to 4.28.0"

# Count strings were removed from metadata descriptions (PR #46 feedback:
# hand-maintained counts drift). Assert their ABSENCE instead.
for metadata_file in \
  "$REPO_ROOT/.claude-plugin/plugin.json" \
  "$REPO_ROOT/.codex-plugin/plugin.json" \
  "$REPO_ROOT/.claude-plugin/marketplace.json" \
  "$REPO_ROOT/.agents/plugins/marketplace.json"
do
  desc=$(jq -r 'if .plugins then .plugins[0].description else .description end' "$metadata_file" 2>/dev/null || true)
  if printf '%s' "$desc" | grep -qE '[0-9]+ (hooks|skills|hook scripts|agents|routines)'; then
    echo "  FAIL  $(basename "$metadata_file") description still hardcodes counts"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $(basename "$metadata_file") hardcodes counts"
  else
    echo "  PASS  $(basename "$metadata_file") description has no hardcoded counts"
    PASS=$((PASS + 1))
  fi
done

run_content_eval "$REPO_ROOT/CHANGELOG.md" '^## 4\.28\.0$' "changelog has 4.28.0 section"
run_content_eval "$REPO_ROOT/README.md" 'v4\.28\.0' "README pinned release example updated"

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
