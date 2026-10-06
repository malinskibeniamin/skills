# Public packaging contracts for the docs skill and opt-in writing style.

if python3 - "$REPO_ROOT" <<'PY'
import hashlib, json, pathlib, sys

root = pathlib.Path(sys.argv[1])
try:
    lock = json.loads((root / "vendor/flightrules.lock.json").read_text())
    assert lock["repository"] == "flightrules", "source identifier must omit organization and URL"
    assert lock["revision"] == "14b0652079bc5b1de4ef97a991be17193709a973"
    assert lock["license"] is None, "do not invent an upstream license"
    assert list(lock["files"]) == ["skills/docs/SKILL.md"], "vendor docs only"
    source = (root / "vendor/flightrules/skills/docs/SKILL.md").read_bytes()
    digest = hashlib.sha256(source).hexdigest()
    assert digest == "1ca8ada59dd6618eaf325a889d7b3afba41804fdff803d9c243cdf8969a9fe7f", "upstream bytes changed"
    assert lock["files"]["skills/docs/SKILL.md"]["sha256"] == digest
    notice = (root / "vendor/flightrules/NOTICE.md").read_text()
    assert "github.com/" not in notice, "notice must not expose the source repository URL"
    assert "does not relicense" in notice, "retain the source license caveat"
    assert "AminBlg/SimpleEnglish" in notice, "retain the skill's original attribution"
except (OSError, ValueError, KeyError, AssertionError) as error:
    print(f"Snapshot contract: {error}", file=sys.stderr)
    sys.exit(1)
PY
then
  echo "  PASS  docs-only snapshot matches the reviewed upstream bytes"
  PASS=$((PASS + 1))
else
  echo "  FAIL  docs-only snapshot integrity or provenance"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: docs-only snapshot integrity or provenance"
fi

if python3 - "$REPO_ROOT" <<'PY'
import json, pathlib, re, sys

root = pathlib.Path(sys.argv[1])
try:
    plugin = json.loads((root / ".claude-plugin/plugin.json").read_text())
    assert "./docs/" in plugin["skills"], "Claude must expose /docs"
    assert "./vendor/flightrules/skills/docs/" not in plugin["skills"], "raw upstream is not an installed second skill"
    assert plugin["outputStyles"] == "./output-styles/"
    proxy = (root / "codex-skills/docs/SKILL.md").read_text()
    assert "../../docs/SKILL.md" in proxy, "Codex must load the same canonical skill"
    assert (root / "codex-skills/docs/agents/openai.yaml").is_file()
    style = (root / "output-styles/factual-docs.md").read_text()
    assert re.search(r"^keep-coding-instructions: true$", style, re.M)
    assert re.search(r"^force-for-plugin: false$", style, re.M), "never override the selected style"
    for path in [".claude/settings.json", ".codex-plugin/plugin.json"]:
        assert "outputStyle" not in json.loads((root / path).read_text()), "style must remain opt-in and Claude-only"
    for name in ["docs/SKILL.md", "shared/FLIGHTRULES-COMPATIBILITY.md"]:
        path = root / name
        for target in re.findall(r"\]\(([^)]+)\)", path.read_text()):
            if not target.startswith(("https://", "http://", "#")):
                assert (path.parent / target.split("#")[0]).is_file(), f"dangling link: {target}"
except (OSError, ValueError, KeyError, AssertionError) as error:
    print(f"Host contract: {error}", file=sys.stderr)
    sys.exit(1)
PY
then
  echo "  PASS  both hosts expose docs and Claude ships an opt-in coding-safe style"
  PASS=$((PASS + 1))
else
  echo "  FAIL  docs or output-style packaging"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: docs or output-style packaging"
fi

run_content_eval "$REPO_ROOT/docs/SKILL.md" "FLIGHTRULES-COMPATIBILITY.md" "docs loads host adaptations before upstream guidance"
run_content_eval "$REPO_ROOT/docs/SKILL.md" "verification|Verify" "docs includes verification, not only tone"
run_content_eval "$REPO_ROOT/shared/FLIGHTRULES-COMPATIBILITY.md" "uncertainty" "docs preserves uncertainty instead of upgrading claims"
run_content_eval "$REPO_ROOT/shared/FLIGHTRULES-COMPATIBILITY.md" "optional" "docs does not impose upstream sections or filenames"
run_file_eval "$REPO_ROOT/docs-site/public/diagrams/skills/docs.excalidraw" "docs page ships its editable diagram"
run_file_eval "$REPO_ROOT/docs-site/public/diagrams/skills/docs.svg" "docs page ships its rendered diagram"
