# Public instruction-link contract only: both performance workflows must reach
# the same maintained guidance. This does not prove optimization quality or speed.

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
PY
then
  PASS=$((PASS + 1))
else
  echo "  FAIL  performance workflows cannot load shared data-oriented guidance"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: shared data-oriented performance routing"
fi
