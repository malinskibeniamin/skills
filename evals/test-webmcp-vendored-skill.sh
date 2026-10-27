# Public package contract: pinned upstream bytes, license, and both host entrypoints.

if python3 - "$REPO_ROOT" <<'PY'
import hashlib, json, pathlib, re, sys

root = pathlib.Path(sys.argv[1])
try:
    assert (root / "vendor/builder-webmcp.lock.json").is_file(), "pinned WebMCP source lock missing"
    lock = json.loads((root / "vendor/builder-webmcp.lock.json").read_text())
    assert lock["repository"] == "https://github.com/BuilderIO/skills"
    assert lock["revision"] == "49528d601d43094cdbf057973c21eb6b52b1ec05"
    assert lock["license"] == "MIT"
    snapshot = root / "vendor/builder-webmcp"
    actual = {p.relative_to(snapshot).as_posix() for p in snapshot.rglob("*") if p.is_file()}
    assert actual == set(lock["files"]), "missing or extra upstream files"
    inventory = ""
    for name, entry in sorted(lock["files"].items()):
        path = snapshot / name
        assert not path.is_symlink(), f"unexpected symlink: {name}"
        data = path.read_bytes()
        blob = hashlib.sha1(f"blob {len(data)}\0".encode() + data).hexdigest()
        assert blob == entry["blob_sha"], f"upstream bytes changed: {name}"
        assert hashlib.sha256(data).hexdigest() == entry["sha256"], f"digest mismatch: {name}"
        mode = "100755" if path.stat().st_mode & 0o111 else "100644"
        assert mode == entry["mode"], f"executable permission changed: {name}"
        inventory += f"{mode} blob {blob}\t{name}\n"
    assert hashlib.sha256(inventory.encode()).hexdigest() == "2e743ec503dc11c910add1e9ad497b4c87f1de6be16e028ba54cb0d399d04968", "inventory differs from the pinned Git tree"
    assert "Copyright (c) 2026 Builder.io" in (snapshot / "LICENSE").read_text()

    plugin = json.loads((root / ".claude-plugin/plugin.json").read_text())
    assert plugin["skills"].count("./webmcp/") == 1, "Claude entrypoint missing or duplicated"
    assert not any("vendor/builder-webmcp" in p for p in plugin["skills"]), "raw upstream must not be a second skill"
    assert json.loads((root / ".codex-plugin/plugin.json").read_text())["skills"] == "./codex-skills/"
    proxy = root / "codex-skills/webmcp/SKILL.md"
    assert "../../webmcp/SKILL.md" in proxy.read_text(), "Codex must load the host adapter"
    metadata = (proxy.parent / "agents/openai.yaml").read_text()
    assert 'display_name: "WebMCP"' in metadata, "Codex display name missing"
    assert "default_prompt:" not in metadata, "upstream host-specific prompt must not bypass the adapter"
    assert "`/webmcp`" in (root / "ask-ben/SKILL-CATALOG.md").read_text(), "router entry missing"
    for path in [root / "webmcp/SKILL.md", root / "webmcp/CREDITS.md", proxy]:
        for link in re.findall(r"\]\(([^)]+)\)", path.read_text()):
            if not link.startswith(("https://", "http://", "#")):
                assert (path.parent / link.split("#")[0]).is_file(), f"dangling packaged link: {path}: {link}"
except (OSError, ValueError, KeyError, AssertionError) as error:
    print(f"WebMCP distribution: {error}", file=sys.stderr)
    sys.exit(1)
PY
then
  echo "  PASS  pinned WebMCP package, license, and host discovery"
  PASS=$((PASS + 1))
else
  echo "  FAIL  WebMCP distribution contract"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: WebMCP distribution contract"
fi
