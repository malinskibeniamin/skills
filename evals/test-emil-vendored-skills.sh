# Distribution contract: selected Emil skills and their resources work offline
# through both installed plugin surfaces, with the upstream license retained.

if python3 - "$REPO_ROOT" <<'PY'
import json
import pathlib
import re
import sys

repo = pathlib.Path(sys.argv[1]).resolve()
selected = (
    "animate", "remove-animations", "improve-animations", "animation-performance", "animation-vocabulary",
    "mobile-native", "break-ui", "ask-sonner",
)
registered = json.loads((repo / ".claude-plugin/plugin.json").read_text())["skills"]
catalog = (repo / "ask-ben/SKILL-CATALOG.md").read_text()
for name in selected:
    assert f"./{name}/" in registered, f"Claude cannot discover {name}"
    assert f"`/{name}`" in catalog, f"router cannot discover {name}"
    proxy = repo / "codex-skills" / name / "SKILL.md"
    target = re.search(r"\[canonical skill instructions\]\(([^)]+)\)", proxy.read_text())
    assert target, f"Codex cannot load {name}"
    canonical = (proxy.parent / target.group(1)).resolve()
    assert canonical == repo / name / "SKILL.md", f"Codex misroutes {name}"
    # Follow the actual local resource links an installed agent will load.
    pending = [canonical]
    visited = set()
    while pending:
        page = pending.pop()
        if page in visited:
            continue
        visited.add(page)
        assert page.is_file(), f"missing bundled resource: {page}"
        for link in re.findall(r"\[[^\]]+\]\(([^)]+)\)", page.read_text()):
            if ":" in link or link.startswith("#"):
                continue
            resource = (page.parent / link.split("#")[0]).resolve()
            assert resource.is_relative_to(repo), f"resource outside plugin: {resource}"
            assert resource.is_file(), f"broken installed resource: {resource}"
            if resource.suffix == ".md" and resource.parent == canonical.parent:
                pending.append(resource)
    license_text = (canonical.parent / "LICENSE").read_text()
    assert "Copyright (c) 2026 Emil Kowalski" in license_text, f"missing notice: {name}"
    assert "Permission is hereby granted" in license_text, f"missing MIT grant: {name}"
print("  PASS  selected Emil skills load offline on Claude and Codex with licensed resources")
PY
then
  PASS=$((PASS + 1))
else
  echo "  FAIL  Emil skill distribution is incomplete"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Emil skill distribution is incomplete"
fi

# The importer is the public refresh/check boundary. Exercise immutable Git reads,
# offline repeatability and drift rejection without relying on the network.
if python3 - "$REPO_ROOT" <<'PY'
import pathlib
import shutil
import subprocess
import sys
import tempfile

repo = pathlib.Path(sys.argv[1]).resolve()
importer = repo / "scripts/vendor-emil.py"

def run(*args, ok=True):
    result = subprocess.run([sys.executable, str(importer), *map(str, args)], capture_output=True, text=True)
    assert (result.returncode == 0) == ok, result.stdout + result.stderr
    return result

run("--check")
with tempfile.TemporaryDirectory(prefix="emil-refresh-test-") as temporary:
    root = pathlib.Path(temporary)
    source = root / "source"
    shutil.copytree(repo / "vendor/emil", source)
    subprocess.run(["git", "init", "-q", str(source)], check=True)
    subprocess.run(["git", "-C", str(source), "add", "."], check=True)
    subprocess.run(["git", "-C", str(source), "-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid", "commit", "-qm", "fixture"], check=True)
    revision = subprocess.check_output(["git", "-C", str(source), "rev-parse", "HEAD"], text=True).strip()
    original = (source / "skills/remove-animations/SKILL.md").read_bytes()
    (source / "skills/remove-animations/SKILL.md").write_text("dirty working tree is not a reviewed input")
    target = root / "target"
    target.mkdir()
    for name in ("animate", "remove-animations", "improve-animations", "animation-performance", "animation-vocabulary", "mobile-native", "break-ui", "ask-sonner"):
        (target / name).mkdir()
    args = ("--repo-root", target, "--source", source, "--revision", revision)
    run(*args)
    assert (target / "vendor/emil/skills/remove-animations/SKILL.md").read_bytes() == original
    lock_path = target / "vendor/emil.lock.json"
    first_lock = lock_path.read_bytes()
    run(*args)
    assert lock_path.read_bytes() == first_lock, "identical refresh changed the lock"
    run("--repo-root", target, "--check")
    run("--repo-root", target, "--source", source, "--revision", "HEAD", ok=False)
    assert lock_path.read_bytes() == first_lock, "moving ref rejection changed managed state"
    victim = target / "vendor/emil/skills/remove-animations/SKILL.md"
    victim.write_text("uncommitted managed work")
    assert "drift" in run("--repo-root", target, "--check", ok=False).stderr.lower()
    run(*args, ok=False)
    assert victim.read_text() == "uncommitted managed work", "refresh overwrote managed drift"
    victim.write_bytes(original)
    (target / "remove-animations/LICENSE").write_text("missing notice")
    run("--repo-root", target, "--check", ok=False)
print("  PASS  Emil refresh is pinned, repeatable, offline and rejects snapshot/license drift")
PY
then
  PASS=$((PASS + 1))
else
  echo "  FAIL  Emil provenance or refresh contract is broken"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Emil provenance or refresh contract is broken"
fi
