# Evals for release/install metadata staying aligned with repo skill surface.

run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"version": "[0-9]+\.[0-9]+\.[0-9]+"' "Claude plugin has semver version"
run_content_eval "$REPO_ROOT/.codex-plugin/plugin.json" '"version": "[0-9]+\.[0-9]+\.[0-9]+"' "Codex plugin has semver version"
run_content_eval "$REPO_ROOT/.claude-plugin/marketplace.json" '"version": "[0-9]+\.[0-9]+\.[0-9]+"' "Claude marketplace has semver version"
run_content_eval "$REPO_ROOT/.agents/plugins/marketplace.json" '"version": "[0-9]+\.[0-9]+\.[0-9]+"' "Codex marketplace has semver version"

if python3 - "$REPO_ROOT" <<'PY'
import json
import pathlib
import sys
repo = pathlib.Path(sys.argv[1])
manifest_version = json.loads((repo / "skill-manifest.json").read_text())["version"]
checks = [
    (repo / ".claude-plugin/plugin.json", lambda data: data),
    (repo / ".codex-plugin/plugin.json", lambda data: data),
    (repo / ".claude-plugin/marketplace.json", lambda data: data["plugins"][0]),
    (repo / ".agents/plugins/marketplace.json", lambda data: data["plugins"][0]),
]
problems = []
for path, pick in checks:
    data = pick(json.loads(path.read_text()))
    if data.get("version") != manifest_version:
        problems.append(f"{path.name} version {data.get('version')} != manifest {manifest_version}")
    if manifest_version not in (data.get("x-changelog") or {}):
        problems.append(f"{path.name} changelog missing {manifest_version}")
if problems:
    print("\n".join(problems))
    raise SystemExit(1)
PY
then
  echo "  PASS  release metadata versions and changelogs match manifest"
  PASS=$((PASS + 1))
else
  echo "  FAIL  release metadata versions and changelogs match manifest"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: release metadata version drift"
fi

if python3 - "$REPO_ROOT" <<'PY'
import json
import pathlib
import sys
repo = pathlib.Path(sys.argv[1])
plugin = json.loads((repo / ".claude-plugin/plugin.json").read_text())
skill_dirs = sorted(path.parent.name for path in repo.glob("*/SKILL.md"))
listed = {entry.strip("./").strip("/") for entry in plugin.get("skills", [])}
missing = [skill for skill in skill_dirs if skill not in listed]
if missing:
    print("missing Claude plugin skills: " + ", ".join(missing))
    raise SystemExit(1)
PY
then
  echo "  PASS  Claude plugin registers every skill directory"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Claude plugin registers every skill directory"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Claude plugin skill surface drift"
fi
