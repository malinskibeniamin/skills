# Static public prompt/link contract, not proof of model selection or T3 runtime
# behavior. Snapshot integrity and installed adapters are owned by t3code-vendored-skills.

if python3 - "$REPO_ROOT" <<'PY'
import pathlib
import re
import sys

repo = pathlib.Path(sys.argv[1]).resolve()
shared = repo / "shared/change-evidence.md"
routes = {
    "development-lifecycle": ("ci-maintenance", "package-development", "vendored-assets", "effect-development"),
    "review": ("ci-maintenance", "package-development", "vendored-assets", "effect-development"),
    "dogfood": ("test-t3-app", "test-t3-mobile"),
}
missing = []
def dependencies(entry):
    return {
        (entry.parent / target.split("#", 1)[0]).resolve()
        for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", entry.read_text())
        if ":" not in target and not target.startswith("#")
    }

for owner, specialists in routes.items():
    entry = repo / owner / "SKILL.md"
    links = dependencies(entry)
    if owner != "dogfood":
        assert shared in links, f"{owner} must load the shared evidence router"
        links = dependencies(shared)
    for specialist in specialists:
        target = repo / "t3code-skills" / specialist / "SKILL.md"
        if target not in links or not target.is_file():
            missing.append(f"{owner} -> {specialist}")
assert not missing, "Missing bundled workflow dependencies: " + ", ".join(missing)
print("  PASS  lifecycle, review and dogfood link their scoped T3/Effect dependencies")
PY
then
  PASS=$((PASS + 1))
else
  echo "  FAIL  T3/Effect workflow dependency links are incomplete"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: T3/Effect workflow dependency links are incomplete"
fi
