"""Exercise the vendoring CLI against a synthetic upstream package."""

import json
import subprocess
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "scripts/vendor-poteto.py"
REVISION = "1234567890abcdef1234567890abcdef12345678"


class PotetoSyncTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name) / "harness"
        self.source = Path(self.temp.name) / "upstream"
        self.repo.mkdir()
        (self.repo / ".claude-plugin").mkdir()
        (self.repo / ".claude-plugin/plugin.json").write_text(
            json.dumps({"skills": ["./tdd/"], "name": "harness"})
        )
        (self.repo / "tdd").mkdir()
        (self.repo / "tdd/SKILL.md").write_text("existing harness TDD")
        self.write_source("LICENSE", "Copyright fixture author\nMIT\n")
        self.write_source(
            ".cursor-plugin/plugin.json", json.dumps({"version": "1.2.3"})
        )
        for path, title in [
            ("skills/tdd", "tdd"),
            ("skills/poteto-mode", "Poteto Mode"),
            ("automations/benny/skills/setup-benny", "setup-benny"),
        ]:
            self.write_source(
                f"{path}/SKILL.md",
                f'---\nname: {title}\ndescription: "A focused upstream workflow."\n'
                "disable-model-invocation: true\n---\n\nFull upstream instructions.\n",
            )
        self.write_source("skills/tdd/references/example.md", "Supporting evidence\n")
        self.write_source("agents/reviewer.md", "Upstream agent role\n")
        script = self.write_source("skills/poteto-mode/scripts/run.sh", "#!/bin/sh\nexit 0\n")
        script.chmod(0o755)

    def write_source(self, name, content):
        path = self.source / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        return path

    def sync(self, *args):
        return subprocess.run(
            ["python3", str(SCRIPT), "--repo-root", str(self.repo), *args],
            capture_output=True,
            text=True,
            check=False,
        )

    def install(self):
        result = self.sync("--source", str(self.source), "--revision", REVISION)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_every_skill_and_support_file_is_shipped_without_collisions(self):
        self.install()
        manifest = json.loads((self.repo / ".claude-plugin/plugin.json").read_text())
        self.assertEqual(
            set(manifest["skills"]),
            {
                "./tdd/",
                "./poteto-skills/poteto-tdd/",
                "./poteto-skills/poteto-mode/",
                "./poteto-skills/poteto-setup-benny/",
            },
        )
        self.assertEqual((self.repo / "tdd/SKILL.md").read_text(), "existing harness TDD")
        for path in self.source.rglob("*"):
            if path.is_file():
                copied = self.repo / "vendor/pstack" / path.relative_to(self.source)
                self.assertEqual(copied.read_bytes(), path.read_bytes())
                self.assertEqual(copied.stat().st_mode & 0o777, path.stat().st_mode & 0o777)
        lock = json.loads((self.repo / "vendor/pstack.lock.json").read_text())
        self.assertEqual(lock["revision"], REVISION)
        self.assertEqual(len(lock["skills"]), 3)
        adapter = (self.repo / "poteto-skills/poteto-tdd/SKILL.md").read_text()
        self.assertIn("name: poteto-tdd\n", adapter)
        self.assertIn("../../vendor/pstack/skills/tdd/SKILL.md", adapter)
        self.assertIn("../../shared/POTETO-COMPATIBILITY.md", adapter)
        self.assertIn("disable-model-invocation: true", adapter)
        result = self.sync("--check")
        self.assertEqual(result.returncode, 0, result.stderr)


    def test_refresh_discovers_new_skills_and_is_idempotent(self):
        self.install()
        self.write_source(
            "skills/future-upstream-workflow/SKILL.md",
            "---\nname: new-workflow\ndescription: A future upstream addition.\n---\nBody\n",
        )
        self.install()
        adapter = self.repo / "poteto-skills/poteto-future-upstream-workflow/SKILL.md"
        self.assertTrue(adapter.is_file())
        self.assertNotIn("disable-model-invocation: true", adapter.read_text())
        before = {p.relative_to(self.repo): p.read_bytes() for p in self.repo.rglob("*") if p.is_file()}
        self.install()
        after = {p.relative_to(self.repo): p.read_bytes() for p in self.repo.rglob("*") if p.is_file()}
        self.assertEqual(before, after)

    def test_check_detects_modified_support_files_and_missing_registration(self):
        self.install()
        copied = self.repo / "vendor/pstack/skills/tdd/references/example.md"
        copied.write_text("Locally modified")
        result = self.sync("--check")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("drifted", result.stderr)
        copied.write_bytes((self.source / "skills/tdd/references/example.md").read_bytes())
        path = self.repo / ".claude-plugin/plugin.json"
        manifest = json.loads(path.read_text())
        manifest["skills"].remove("./poteto-skills/poteto-setup-benny/")
        path.write_text(json.dumps(manifest))
        result = self.sync("--check")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("register every", result.stderr)

    def test_refresh_preserves_local_changes_by_refusing_drift(self):
        self.install()
        modified = self.repo / "vendor/pstack/skills/tdd/references/example.md"
        modified.write_text("Local patch that must survive")
        result = self.sync("--source", str(self.source), "--revision", REVISION)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("drifted", result.stderr)
        self.assertEqual(modified.read_text(), "Local patch that must survive")

    def test_refresh_preserves_unmanaged_adapter_files(self):
        self.install()
        notes = self.repo / "poteto-skills/poteto-tdd/notes.md"
        notes.write_text("User-owned adapter notes")
        result = self.sync("--source", str(self.source), "--revision", REVISION)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(notes.read_text(), "User-owned adapter notes")

    def test_first_install_preserves_an_unmanaged_snapshot(self):
        notes = self.repo / "vendor/pstack/notes.md"
        notes.parent.mkdir(parents=True)
        notes.write_text("User-owned snapshot")
        result = self.sync("--source", str(self.source), "--revision", REVISION)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(notes.read_text(), "User-owned snapshot")

    def test_invalid_package_or_namespace_collision_cannot_overwrite_files(self):
        directory = self.repo / "poteto-skills/poteto-tdd"
        directory.mkdir(parents=True)
        notes = directory / "notes.md"
        notes.write_text("User owned")
        result = self.sync("--source", str(self.source), "--revision", REVISION)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("overwrite", result.stderr)
        self.assertEqual(notes.read_text(), "User owned")
        self.assertFalse((self.repo / "vendor").exists())
        (self.source / "LICENSE").unlink()
        result = self.sync("--source", str(self.source), "--revision", REVISION)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("complete pstack package", result.stderr)
        self.assertFalse((self.repo / "vendor").exists())


if __name__ == "__main__":
    unittest.main()
