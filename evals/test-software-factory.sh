# Public installation and immutable-source contract, not an agent behavior eval.
# Generic proxy parity and Markdown link checks belong to packaging-integrity.

if python3 - "$REPO_ROOT" <<'PY'
import hashlib
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
manifest = json.loads((root / ".claude-plugin/plugin.json").read_text())
if "./software-factory/" not in manifest["skills"]:
    raise SystemExit("software-factory is missing from the shipped skill registry")

for relative in ("software-factory/SKILL.md", "software-factory/ORCHESTRATORS.md",
                 "software-factory/HARNESS-FIT.md", "vendor/software-factory-NOTICE.md"):
    if not (root / relative).is_file():
        raise SystemExit(f"Missing factory design resource: {relative}")

lock = json.loads((root / "vendor/mattpocock.lock.json").read_text())
skill = next(s for s in lock["skills"] if s["upstream_name"] == "software-factory")
if skill["owner"] != "software-factory":
    raise SystemExit("Factory source bypasses the existing planning owner")
snapshot = root / "vendor/mattpocock/upstream"
source = (snapshot / skill["source"]).parent
expected = {"SKILL.md", "EXAMPLE-TASKS.md", "GIT-HOSTS.md", "TICKET-TRACKERS.md",
            "RUNNERS.md", "OBSERVABILITY-PLATFORMS.md"}
actual = {path.name for path in source.iterdir()} if source.is_dir() else set()
if actual != expected:
    raise SystemExit(f"Incomplete factory source snapshot: {sorted(actual)}")
for path in [source / name for name in expected] + [snapshot / "LICENSE"]:
    record = lock["files"][path.relative_to(snapshot).as_posix()]
    if hashlib.sha256(path.read_bytes()).hexdigest() != record["sha256"] or path.stat().st_mode & 0o777 != record["mode"]:
        raise SystemExit(f"Factory source differs from the reviewed upstream pin: {path.name}")
if str(source.relative_to(root)) not in (root / "software-factory/SKILL.md").read_text():
    raise SystemExit("Factory planning still points at the superseded draft snapshot")
if "../vendor/mattpocock/software-factory/" in (root / "software-factory/SKILL.md").read_text():
    raise SystemExit("Factory planning still loads the superseded draft snapshot")
PY
then
  echo "  PASS  factory design resources ship with the complete pinned MIT source"
  PASS=$((PASS + 1))
else
  echo "  FAIL  factory design resources or upstream provenance are incomplete"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: factory design installation/provenance contract"
fi
