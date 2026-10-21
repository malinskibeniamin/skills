# Public instruction-link contract only: this does not prove model selection,
# rendered UI behavior, frame rate, or physical-device verification.

if python3 - "$REPO_ROOT" <<'PY'
import pathlib
import re
import sys

repo = pathlib.Path(sys.argv[1]).resolve()
routes = {
    "shared/change-evidence.md": ("mobile-native", "break-ui", "ask-sonner"),
    "visual-review/REFERENCE.md": ("animate", "animation-vocabulary", "mobile-native", "ask-sonner"),
    "prototype/UI.md": ("animate", "break-ui", "mobile-native"),
    "ux-performance/OPTIMIZATION.md": ("animation-performance",),
}
missing = []
for source, owners in routes.items():
    page = repo / source
    links = {
        (page.parent / target.split("#", 1)[0]).resolve()
        for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", page.read_text())
        if ":" not in target and not target.startswith("#")
    }
    for owner in owners:
        target = repo / owner / "SKILL.md"
        if target not in links or not target.is_file():
            missing.append(f"{source} -> {owner}")
assert not missing, "Missing scoped Emil handoffs: " + ", ".join(missing)
print("  PASS  author/review routing, visual critique, prototypes and profiling link Emil owners")
PY
then
  PASS=$((PASS + 1))
else
  echo "  FAIL  existing workflows cannot load their scoped Emil owners"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: existing workflows cannot load their scoped Emil owners"
fi
