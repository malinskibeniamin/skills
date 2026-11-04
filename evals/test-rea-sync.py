"""Exercise release imports through the public CLI, without downloading or running REA."""

import base64
import gzip
import hashlib
import io
import json
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts/vendor-rea.py"
SKILL = "skills/reverse-engineer-anything/SKILL.md"


class ReaSyncTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name) / "harness"
        self.repo.mkdir()
        self.write(".claude-plugin/plugin.json", '{"skills":["./tdd/"]}\n')
        self.write(".codex-plugin/plugin.json", '{"skills":"./codex-skills/"}\n')
        self.write("tdd/SKILL.md", "Existing owner\n")
        self.payload = {
            "package.json": (json.dumps({"name": "rea-agents", "version": "6.8.0", "license": "MIT",
                                         "engines": {"node": "^22.23.4 || ^24.22.1 || >=26.12.1"}}).encode(), 0o644),
            "LICENSE": (b"MIT License\nCopyright fixture\n", 0o644),
            "THIRD_PARTY_NOTICES.md": (b"Fixture notices\n", 0o644),
            SKILL: (b"---\nname: reverse-engineer-anything\ndescription: Inspect artifacts.\n"
                    b"metadata:\n  version: \"49\"\n---\nRead [guide](references/guide.md).\n", 0o644),
            "skills/reverse-engineer-anything/references/guide.md": (b"Use evidence.\n", 0o644),
            "skills/reverse-engineer-anything/scripts/helper": (b"#!/bin/sh\necho fixture\n", 0o755),
            "dist/not-vendored.js": (b"throw new Error('must not execute or copy');\n", 0o644),
        }
        self.archive = Path(self.temp.name) / "release.tgz"

    def write(self, name, content):
        path = self.repo / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        return path

    def pack(self):
        tar_bytes = io.BytesIO()
        with tarfile.open(fileobj=tar_bytes, mode="w") as archive:
            for name, (data, mode) in self.payload.items():
                member = tarfile.TarInfo(f"package/{name}")
                member.size, member.mode = len(data), mode
                archive.addfile(member, io.BytesIO(data))
        self.archive.write_bytes(gzip.compress(tar_bytes.getvalue(), mtime=0))
        return "sha512-" + base64.b64encode(hashlib.sha512(self.archive.read_bytes()).digest()).decode()

    def cli(self, *args):
        return subprocess.run(["python3", str(SCRIPT), "--repo-root", str(self.repo), *args],
                              capture_output=True, text=True, check=False)

    def install(self):
        return self.cli("--archive", str(self.archive), "--revision", "a" * 40,
                        "--integrity", self.pack())

    def snapshot(self):
        return {p.relative_to(self.repo).as_posix(): (p.read_bytes(), p.stat().st_mode & 0o777)
                for p in self.repo.rglob("*") if p.is_file()}

    def test_release_import_is_complete_pinned_opt_in_and_repeatable(self):
        with patch("time.time", return_value=1_700_000_000):
            result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        lock = json.loads((self.repo / "vendor/rea.lock.json").read_text())
        self.assertEqual(lock["revision"], "a" * 40)
        self.assertEqual(lock["version"], "6.8.0")
        expected = {"LICENSE", "package.json", SKILL,
                    "skills/reverse-engineer-anything/references/guide.md",
                    "skills/reverse-engineer-anything/scripts/helper"}
        self.assertEqual(set(lock["files"]), expected)
        for name in expected:
            copied = self.repo / "vendor/rea" / name
            data, mode = self.payload[name]
            self.assertEqual(copied.read_bytes(), data)
            self.assertEqual(copied.stat().st_mode & 0o777, mode)
            self.assertEqual(lock["files"][name]["sha256"], hashlib.sha256(data).hexdigest())
        manifest = json.loads((self.repo / ".claude-plugin/plugin.json").read_text())
        self.assertEqual(manifest, {"skills": ["./tdd/", "./reverse-engineer-anything/"]})
        self.assertEqual((self.repo / ".codex-plugin/plugin.json").read_text(),
                         '{"skills":"./codex-skills/"}\n')
        self.assertEqual((self.repo / "tdd/SKILL.md").read_text(), "Existing owner\n")
        config = json.loads((self.repo / "config/rea.mcp.json").read_text())
        self.assertEqual(config, {"mcpServers": {"rea": {
            "command": "npx", "args": ["-y", "rea-agents@6.8.0", "mcp"]}}})
        self.assertFalse((self.repo / ".mcp.json").exists())
        self.assertEqual(self.cli("--check").returncode, 0)
        before = self.snapshot()
        # Cross a gzip timestamp boundary without a timing-dependent sleep.
        with patch("time.time", return_value=1_700_000_060):
            result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.snapshot(), before)

    def test_bad_pin_or_corrupt_archive_is_rejected_without_writes(self):
        integrity = self.pack()
        before = self.snapshot()
        for revision, digest in (("main", integrity), ("a" * 40, "sha512-invalid"),
                                 ("a" * 40, "sha512-" + "A" * 86 + "==")):
            with self.subTest(revision=revision, integrity=digest):
                result = self.cli("--archive", str(self.archive), "--revision", revision,
                                  "--integrity", digest)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.snapshot(), before)

    def test_runtime_notices_are_not_required_or_shipped_with_the_skill(self):
        self.payload["THIRD_PARTY_NOTICES.md"] = (
            "Runtime attribution — [runtime license](licenses/runtime.txt)\n".encode(), 0o644)
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.repo / "vendor/rea/THIRD_PARTY_NOTICES.md").exists())
        self.assertEqual((self.repo / "vendor/rea/LICENSE").read_bytes(), self.payload["LICENSE"][0])
        del self.payload["THIRD_PARTY_NOTICES.md"]
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.cli("--check").returncode, 0)

    def test_unsafe_or_unreviewed_release_cannot_partially_refresh(self):
        self.assertEqual(self.install().returncode, 0)
        original = self.payload.copy()
        cases = {
            "traversal": ("../escape", (b"escape", 0o644)),
            "alias": ("skills/./alias.md", (b"alias", 0o644)),
            "new skill": ("skills/new/SKILL.md", (b"unreviewed", 0o644)),
            "policy": (SKILL, (self.payload[SKILL][0].replace(
                b"metadata:", b"disable-model-invocation: true\nmetadata:"), 0o644)),
            "mode": (SKILL, (self.payload[SKILL][0], 0o777)),
            "license": ("LICENSE", (b"Changed terms", 0o644)),
            "metadata": ("package.json", (b'{"name":"not-rea"}', 0o644)),
            "oversized": ("skills/reverse-engineer-anything/huge", (b"x" * (4 * 1024 * 1024), 0o644)),
        }
        for case, (path, record) in cases.items():
            with self.subTest(case=case):
                self.payload = original | {path: record}
                before = self.snapshot()
                result = self.install()
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertEqual(self.snapshot(), before)
        self.payload = original.copy()
        del self.payload["LICENSE"]
        before = self.snapshot()
        self.assertNotEqual(self.install().returncode, 0)
        self.assertEqual(self.snapshot(), before)

    def test_archive_links_and_duplicate_files_are_rejected(self):
        for kind in (tarfile.SYMTYPE, tarfile.LNKTYPE, tarfile.REGTYPE):
            with self.subTest(kind=kind):
                self.pack()
                with tarfile.open(self.archive, "r:gz") as archive:
                    entries = [(m, archive.extractfile(m).read()) for m in archive]
                with tarfile.open(self.archive, "w:gz") as archive:
                    for member, data in entries:
                        archive.addfile(member, io.BytesIO(data))
                    member = tarfile.TarInfo(f"package/{SKILL}")
                    member.type, member.mode = kind, 0o644
                    member.linkname = "../../outside"
                    archive.addfile(member, io.BytesIO(b""))
                integrity = "sha512-" + base64.b64encode(hashlib.sha512(self.archive.read_bytes()).digest()).decode()
                before = self.snapshot()
                result = self.cli("--archive", str(self.archive), "--revision", "a" * 40,
                                  "--integrity", integrity)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.snapshot(), before)

    def test_drift_blocks_check_and_refresh_without_overwriting_work(self):
        self.assertEqual(self.install().returncode, 0)
        for name in ("vendor/rea/LICENSE", "reverse-engineer-anything/SKILL.md",
                     "config/rea.mcp.json", "vendor/rea/local-notes.md"):
            with self.subTest(name=name):
                path = self.repo / name
                original = path.read_bytes() if path.exists() else None
                path.write_text("Local work must survive\n")
                before = self.snapshot()
                self.assertNotEqual(self.cli("--check").returncode, 0)
                self.assertNotEqual(self.install().returncode, 0)
                self.assertEqual(self.snapshot(), before)
                path.unlink() if original is None else path.write_bytes(original)
        helper = self.repo / "vendor/rea/skills/reverse-engineer-anything/scripts/helper"
        helper.chmod(0o644)
        before = self.snapshot()
        self.assertNotEqual(self.cli("--check").returncode, 0)
        self.assertNotEqual(self.install().returncode, 0)
        self.assertEqual(self.snapshot(), before)

    def test_refresh_prunes_removed_files_and_updates_runtime_with_skill(self):
        self.assertEqual(self.install().returncode, 0)
        del self.payload["skills/reverse-engineer-anything/scripts/helper"]
        metadata = json.loads(self.payload["package.json"][0])
        metadata["version"] = "6.9.0"
        self.payload["package.json"] = (json.dumps(metadata).encode(), 0o644)
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.repo / "vendor/rea/skills/reverse-engineer-anything/scripts/helper").exists())
        config = json.loads((self.repo / "config/rea.mcp.json").read_text())
        self.assertEqual(config["mcpServers"]["rea"]["args"], ["-y", "rea-agents@6.9.0", "mcp"])
        self.archive.unlink()
        before = self.snapshot()
        self.assertEqual(self.cli("--check").returncode, 0)
        self.assertEqual(self.snapshot(), before)

    def test_unmanaged_paths_and_duplicate_owners_are_preserved(self):
        for name in ("vendor/rea/notes.md", "reverse-engineer-anything/SKILL.md", "config/rea.mcp.json"):
            with self.subTest(name=name):
                path = self.write(name, "Unmanaged content\n")
                before = self.snapshot()
                self.assertNotEqual(self.install().returncode, 0)
                self.assertEqual(self.snapshot(), before)
                path.unlink()
                if not name.startswith("config/"):
                    path.parent.rmdir()
        manifest = self.write(".claude-plugin/plugin.json", '{"skills":["./other/reverse-engineer-anything/"]}')
        before = self.snapshot()
        self.assertNotEqual(self.install().returncode, 0)
        self.assertEqual(self.snapshot(), before)
        manifest.write_text('{"skills":["./tdd/"]}')
        self.assertEqual(self.install().returncode, 0)
        manifest.write_text('{"skills":["./reverse-engineer-anything/","./other/reverse-engineer-anything/"]}')
        self.assertNotEqual(self.cli("--check").returncode, 0)

    def test_symlinked_managed_paths_cannot_write_outside_the_repo(self):
        outside = Path(self.temp.name) / "outside"
        outside.mkdir()
        marker = outside / "keep"
        marker.write_text("Keep external work\n")
        for name in ("vendor", "config", "reverse-engineer-anything"):
            with self.subTest(name=name):
                linked = self.repo / name
                linked.symlink_to(outside, target_is_directory=True)
                result = self.install()
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("Symlinked", result.stderr)
                self.assertEqual([p.name for p in outside.iterdir()], ["keep"])
                self.assertEqual(marker.read_text(), "Keep external work\n")
                linked.unlink()

    def test_missing_linked_reference_fails_before_writing(self):
        del self.payload["skills/reverse-engineer-anything/references/guide.md"]
        before = self.snapshot()
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("reference", result.stderr)
        self.assertEqual(self.snapshot(), before)

    def test_blocking_parent_file_fails_before_publishing_any_output(self):
        self.write("config", "Keep blocking file\n")
        before = self.snapshot()
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.snapshot(), before)


if __name__ == "__main__":
    unittest.main()
