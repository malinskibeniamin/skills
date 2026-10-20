# Bazel must be discoverable in both hosts with its reference graph intact.
if python3 - "$REPO_ROOT" <<'PY'
import json
import pathlib
import re
import sys

repo = pathlib.Path(sys.argv[1]).resolve()
claude = json.loads((repo / ".claude-plugin/plugin.json").read_text())
codex = json.loads((repo / ".codex-plugin/plugin.json").read_text())
assert claude["skills"].count("./bazel/") == 1, "Bazel missing or duplicated in Claude discovery"
proxy = repo / codex["skills"] / "bazel" / "SKILL.md"
links = re.findall(r"\]\(([^)]+)\)", proxy.read_text())
canonical = (proxy.parent / "../../bazel/SKILL.md").resolve()
assert any((proxy.parent / link).resolve() == canonical for link in links), "Codex does not load canonical Bazel skill"
assert (proxy.parent / "agents/openai.yaml").is_file(), "Codex interface missing"
assert re.search(r"^name: bazel$", canonical.read_text(), re.M), "Skill identity mismatches discovery"
assert "/bazel" in (repo / "ask-ben/SKILL-CATALOG.md").read_text(), "Router cannot discover Bazel"
PY
then
  echo "  PASS  Bazel resolves through Claude, Codex, and the router"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Bazel discovery is incomplete"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Bazel discovery is incomplete"
fi

# Command examples are a copyable interface; parse them without running builds.
if python3 - "$REPO_ROOT/bazel" <<'PY'
import pathlib
import re
import subprocess
import sys

for path in pathlib.Path(sys.argv[1]).rglob("*.md"):
    for block in re.findall(r"```bash\n(.*?)```", path.read_text(), re.S):
        result = subprocess.run(["bash", "-n"], input=block, text=True, capture_output=True)
        assert result.returncode == 0, f"Invalid command example in {path.name}: {result.stderr}"
PY
then
  echo "  PASS  Bazel command examples have valid shell syntax"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Bazel command examples have invalid shell syntax"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Bazel command examples have invalid shell syntax"
fi

if python3 - "$REPO_ROOT/bazel" <<'PY'
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1]).resolve()
pending = [root / "SKILL.md"]
visited = set()
while pending:
    path = pending.pop()
    if path in visited:
        continue
    assert path.is_relative_to(root), f"Reference escapes the packaged skill: {path.name}"
    text = path.read_text()
    visited.add(path)
    for link in re.findall(r"\]\(([^)]+)\)", text):
        if re.match(r"[a-z]+:", link) or link.startswith("#"):
            continue
        target = (path.parent / link.split("#", 1)[0]).resolve()
        assert target.is_file(), f"Missing packaged reference: {link}"
        pending.append(target)
bundled = set(root.rglob("*.md"))
assert visited == bundled, "Bazel reference files are unreachable from the entrypoint"
PY
then
  echo "  PASS  Bazel references are self-contained and reachable"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Bazel reference graph is incomplete"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Bazel reference graph is incomplete"
fi
