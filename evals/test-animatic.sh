# Public discovery/authorization contracts; not a model-adherence evaluation.
if python3 - "$REPO_ROOT" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
registry = json.loads((root / ".claude-plugin/plugin.json").read_text())["skills"]
lock = json.loads((root / "vendor/mattpocock.lock.json").read_text())
for name in ("animatic", "setup-animatic"):
    assert registry.count(f"./{name}/") == 1, f"Missing or duplicate /{name} entrypoint"
    source = next(s for s in lock["skills"] if s["upstream_name"] == name)
    assert source["owner"] == name, f"/{name} bypasses host policy"
    assert (root / name / "SKILL.md").is_file()
    assert (root / "codex-skills" / name / "SKILL.md").is_file()
setup = (root / "setup-animatic/SKILL.md").read_text()
assert "disable-model-invocation: true" in setup, "Setup must be user-invoked"
PY
then
  echo "  PASS  animatic skills reach host owners in Claude and Codex discovery"
  PASS=$((PASS + 1))
else
  echo "  FAIL  animatic discovery or owner routing"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: animatic discovery or owner routing"
fi

run_content_eval "$REPO_ROOT/animatic/SKILL.md" 'ANIMATIC_HOME' \
  "animatic documents its dependency cache boundary"
run_content_eval "$REPO_ROOT/animatic/SKILL.md" 'WARN.*exit|exit.*WARN' \
  "animatic does not mistake exit zero for warning-free verification"
run_content_eval "$REPO_ROOT/setup-animatic/SKILL.md" 'generated.*source|source.*generated' \
  "setup preserves generated instruction ownership"
run_content_eval "$REPO_ROOT/setup-animatic/SKILL.md" 'remote.*explicit|explicit.*remote' \
  "setup requires explicit remote scope"
