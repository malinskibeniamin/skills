# Distribution contract: selected Emil skills and their resources work offline
# through both installed plugin surfaces, with the upstream license retained.

if python3 - "$REPO_ROOT" <<'PY'
import json
import pathlib
import re
import sys

repo = pathlib.Path(sys.argv[1]).resolve()
selected = (
    "animate", "animation-performance", "animation-vocabulary",
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
