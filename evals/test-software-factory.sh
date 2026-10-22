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

# Independently fetched from mattpocock/skills at b59cab42bf1206e1363eafc37f71b21c3bcaa12f.
expected = {
    "EXAMPLE-TASKS.md": "34bfb01ced8fbbff8185d347df423533d157c29e8d58bf044f8450602f162875",
    "GIT-HOSTS.md": "f6b453cd0b1601c329dcfbffcb4added077683a4b777c819530ff0a940b1147f",
    "LICENSE": "0e7ac423bf2c6e223b7c5b156f8cf72da49d748e56a1641402c31f22ad07dbb5",
    "OBSERVABILITY-PLATFORMS.md": "c3bd68e1bd105ccdda407a7aa909807131a20117bbf510d1ad0cfefffa25cb4c",
    "RUNNERS.md": "85aacfb9acac67948c1659562d60b52c2a13936faddd24de26c9094b35ff70e7",
    "SKILL.md": "645ab761b6cca61a480072b1b510eb05fe0fe5cde2ce0495b6fc234311692253",
    "TICKET-TRACKERS.md": "4b68a198d6c1a6d47f9ad7eb1f02cc3e60778a2b1610f8b2ac23f72230d575b2",
}
source = root / "vendor/mattpocock/software-factory"
actual = {path.name for path in source.iterdir()} if source.is_dir() else set()
if actual != set(expected):
    raise SystemExit(f"Incomplete factory source snapshot: {sorted(actual)}")
for name, digest in expected.items():
    if hashlib.sha256((source / name).read_bytes()).hexdigest() != digest:
        raise SystemExit(f"Factory source differs from the reviewed upstream pin: {name}")
PY
then
  echo "  PASS  factory design resources ship with the complete pinned MIT source"
  PASS=$((PASS + 1))
else
  echo "  FAIL  factory design resources or upstream provenance are incomplete"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: factory design installation/provenance contract"
fi
