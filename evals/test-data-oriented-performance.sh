# Public instruction-link contracts only: performance workflows must reach their
# shared owners. This does not prove optimization quality, adherence or speed.

if python3 - "$REPO_ROOT" <<'PY'
from pathlib import Path
import re
import sys

repo = Path(sys.argv[1]).resolve()
reference = repo / "shared/data-oriented-performance.md"
routes = (
    ("ux-performance/SKILL.md", None),
    ("ux-performance/OPTIMIZATION.md", None),
    ("shared/T3CODE-SKILLS.md", "performance-analysis"),
)
missing = []
for source, section in routes:
    page = repo / source
    text = page.read_text()
    if section:
        text = text.split(f"## {section}\n", 1)[1].split("\n## ", 1)[0]
    links = {
        (page.parent / target.split("#", 1)[0]).resolve()
        for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", text)
        if ":" not in target and not target.startswith("#")
    }
    if reference not in links or not reference.is_file():
        missing.append(source)
assert not missing, "Data-oriented guidance unreachable from: " + ", ".join(missing)
print("  PASS  UX and runtime performance routes reach one data-oriented reference")

experiments = repo / "quantify-impact/REFERENCE.md"
anchor = "optimization-experiments"
anchors = {
    re.sub(r"[^\w\- ]", "", heading.lower()).replace(" ", "-")
    for heading in re.findall(r"^#+ (.+)$", experiments.read_text(), re.M)
}
assert anchor in anchors, "Optimization experiment anchor does not resolve"
for source in ("quantify-impact/SKILL.md", "ux-performance/SKILL.md", "animation-performance/SKILL.md"):
    page = repo / source
    links = {
        ((page.parent / target.split("#", 1)[0]).resolve(), target.partition("#")[2])
        for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", page.read_text())
        if ":" not in target and not target.startswith("#")
    }
    assert (experiments, anchor) in links, f"Experiment guidance unreachable from: {source}"
print("  PASS  optimization entrypoints resolve the shared experiment section")
PY
then
  PASS=$((PASS + 1))
else
  echo "  FAIL  performance workflows cannot load shared guidance"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: shared performance routing"
fi
