# Public harness instruction contract, not evidence of model behavior or code quality.
# Keep design, review, refactoring and health checks on one policy; catch the old
# size/depth rules that contradicted independently verifiable deep modules.

if python3 - "$REPO_ROOT" <<'PY'
from pathlib import Path
import re
import sys

repo = Path(sys.argv[1]).resolve()
reference = repo / "shared/verifiability.md"
routes = (
    "CLAUDE.md",
    "codebase-design/SKILL.md",
    "shared/review-contract.md",
    "tdd/SKILL.md",
    "setup-routines/routines/weekly-health.md",
)
missing = []
for source in routes:
    page = repo / source
    links = {
        (page.parent / target.split("#", 1)[0]).resolve()
        for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", page.read_text())
        if ":" not in target and not target.startswith("#")
    }
    if reference not in links or not reference.is_file():
        missing.append(source)
assert not missing, "Verifiability policy unreachable from: " + ", ".join(missing)
print("  PASS  harness entrypoints reach the canonical verifiability policy")
PY
then
  PASS=$((PASS + 1))
else
  echo "  FAIL  harness entrypoints cannot load verifiability guidance"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: canonical verifiability policy routing"
fi

if python3 - "$REPO_ROOT" <<'PY'
from pathlib import Path
import sys

repo = Path(sys.argv[1])
obsolete = {
    "review/DEEP-AUDIT.md": ("Pushes a file across 1,000 lines", "structural complexity did not regress"),
    "agents/self-reviewer.md": ("Complex branching logic (>3 levels deep)",),
    "development-lifecycle/REFERENCE.md": ("complexity demonstrably drops",),
    "setup-routines/routines/weekly-health.md": ("Large files that may need splitting", '"$lines" -gt 300', "Missing test: $f"),
    "product/CRAFT.md": ("one test line per production line", "complex conditions split into named variables"),
}
remaining = [
    f"{source}: {rule}"
    for source, rules in obsolete.items()
    for rule in rules
    if rule in (repo / source).read_text()
]
assert not remaining, "Conflicting public guidance remains:\n" + "\n".join(remaining)
print("  PASS  published guidance drops size, nesting and test-volume proxies")
PY
then
  PASS=$((PASS + 1))
else
  echo "  FAIL  obsolete code-quality proxies remain in public guidance"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: obsolete code-quality proxies"
fi
