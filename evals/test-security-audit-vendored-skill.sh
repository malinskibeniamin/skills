# Public distribution contract: complete, unchanged upstream package and host entrypoints.

if python3 - "$REPO_ROOT" <<'PY'
import hashlib, json, pathlib, re, sys

root = pathlib.Path(sys.argv[1])
try:
    lock = json.loads((root / "vendor/cloudflare-security-audit.lock.json").read_text())
    assert lock["repository"] == "https://github.com/cloudflare/security-audit-skill"
    assert lock["revision"] == "c1c8a8c1471069fb0e188eeaff69b8e8db6564a8"
    assert lock["license"] == "MIT"
    snapshot = root / "vendor/cloudflare-security-audit"
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
    assert hashlib.sha256(inventory.encode()).hexdigest() == "444df6bb9419ddb3509c943bf6bda8bcad28fd33cbea26ee7c4c76dfb067937d", "inventory differs from the pinned Git tree"
    assert "Copyright (c) 2025-2026 Cloudflare, Inc." in (snapshot / "LICENSE").read_text()

    plugin = json.loads((root / ".claude-plugin/plugin.json").read_text())
    assert plugin["skills"].count("./security-audit/") == 1, "Claude entrypoint missing or duplicated"
    assert not any("vendor/cloudflare-security-audit" in p for p in plugin["skills"]), "do not register raw source as a second skill"
    assert json.loads((root / ".codex-plugin/plugin.json").read_text())["skills"] == "./codex-skills/"
    proxy = root / "codex-skills/security-audit/SKILL.md"
    assert "../../security-audit/SKILL.md" in proxy.read_text(), "Codex must load the host adapter"
    assert (proxy.parent / "agents/openai.yaml").is_file(), "Codex interface missing"
    assert "`/security-audit`" in (root / "ask-ben/SKILL-CATALOG.md").read_text(), "router entry missing"
    for path in [root / "security-audit/SKILL.md", root / "security-audit/CREDITS.md", proxy, snapshot / "skills/security-audit/SKILL.md"]:
        for link in re.findall(r"\]\(([^)]+)\)", path.read_text()):
            if not link.startswith(("https://", "http://", "#")):
                assert (path.parent / link.split("#")[0]).is_file(), f"dangling packaged link: {path}: {link}"
except (OSError, ValueError, KeyError, AssertionError) as error:
    print(f"Security audit distribution: {error}", file=sys.stderr)
    sys.exit(1)
PY
then
  echo "  PASS  pinned security audit package, license, and host discovery"
  PASS=$((PASS + 1))
else
  echo "  FAIL  security audit distribution contract"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: security audit distribution contract"
fi

if node --test \
  "$REPO_ROOT/vendor/cloudflare-security-audit/skills/security-audit/validate-findings.test.cjs" \
  "$REPO_ROOT/vendor/cloudflare-security-audit/skills/security-audit/validate-coverage-ledger.test.cjs"; then
  echo "  PASS  packaged upstream findings and coverage validators"
  PASS=$((PASS + 1))
else
  echo "  FAIL  packaged upstream validators"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: packaged upstream validators"
fi
