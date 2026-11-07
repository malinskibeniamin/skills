# Public prompt/distribution contract, not evidence of model adherence or refactor quality.
if python3 - "$REPO_ROOT" <<'PY'
import hashlib, json, pathlib, re, sys

root = pathlib.Path(sys.argv[1])
expected = {
    "LICENSE": "cbe11503c54a6eeecf65772e66fbbca7a37750bff9812c742b11dca47ceb539c",
    "skills/untangle-codebase/SKILL.md": "b4eb6b5130c38ca04532601e99d2d174cf4faa4df520b5b7ba609e8707e55761",
}
try:
    lock = json.loads((root / "vendor/caldoai.lock.json").read_text())
    assert lock["repository"] == "https://github.com/caldoai/skills"
    assert lock["revision"] == "f3cf47774975a7d9fca45730babf4ff7ad765ada"
    assert lock["license"] == "MIT"
    snapshot = root / "vendor/caldoai"
    assert not snapshot.is_symlink()
    actual = set()
    for path in snapshot.rglob("*"):
        assert not path.is_symlink(), f"unexpected symlink: {path}"
        if path.is_file():
            actual.add(path.relative_to(snapshot).as_posix())
    assert actual == set(lock["files"]) == set(expected), "source inventory drifted"
    for name, digest in expected.items():
        path = snapshot / name
        data = path.read_bytes()
        entry = lock["files"][name]
        assert hashlib.sha256(data).hexdigest() == entry["sha256"] == digest, name
        assert hashlib.sha1(f"blob {len(data)}\0".encode() + data).hexdigest() == entry["blob_sha"], name
        assert path.stat().st_mode & 0o777 == int(entry["mode"][-3:], 8) == 0o644, name

    plugin = json.loads((root / ".claude-plugin/plugin.json").read_text())
    assert plugin["skills"].count("./untangle-codebase/") == 1, "missing/duplicate Claude entrypoint"
    assert not any("vendor/caldoai" in p for p in plugin["skills"]), "raw source must stay unregistered"
    assert json.loads((root / ".codex-plugin/plugin.json").read_text())["skills"] == "./codex-skills/"
    proxy = root / "codex-skills/untangle-codebase/SKILL.md"
    assert "../../untangle-codebase/SKILL.md" in proxy.read_text(), "Codex must load the adaptation"
    metadata = (proxy.parent / "agents/openai.yaml").read_text()
    assert "allow_implicit_invocation: false" in metadata, "explicit invocation only"
    assert "`/untangle-codebase`" in (root / "ask-ben/SKILL-CATALOG.md").read_text()
    skill = (root / "untangle-codebase/SKILL.md").read_text()
    assert "disable-model-invocation: true" in skill
    for guardrail in ("explicit delegation consent", "first clean scoped review", "behavior-preserving",
                      "Remove comments that only restate the code.",
                      "Remove tests that wouldn't catch a real bug, and fix the ones that fail without one."):
        assert guardrail in skill, f"missing public prompt guardrail: {guardrail}"
    for path in (root / "untangle-codebase/SKILL.md", root / "untangle-codebase/CREDITS.md", proxy,
                 snapshot / "skills/untangle-codebase/SKILL.md"):
        for link in re.findall(r"\]\(([^)]+)\)", path.read_text()):
            if not link.startswith(("https://", "http://", "#")):
                assert (path.parent / link.split("#")[0]).is_file(), f"dangling link: {path}: {link}"
except (OSError, ValueError, KeyError, AssertionError) as error:
    print(f"Untangle-codebase distribution: {error}", file=sys.stderr)
    sys.exit(1)
PY
then
  echo "  PASS  untangle-codebase source integrity, consent, scope and host discovery"
  PASS=$((PASS + 1))
else
  echo "  FAIL  untangle-codebase distribution contract"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: untangle-codebase distribution contract"
fi
