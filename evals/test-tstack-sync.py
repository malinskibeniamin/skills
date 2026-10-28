"""Exercise tstack imports through the public CLI, with committed fixture inputs."""

import hashlib
import json
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts/vendor-tstack.py"
NAMES = {"full-send", "full-stop", "council", "sol-loop", "file-pr", "takeover",
         "babysit-pr", "modernize", "leaving-pr-comments"}


class TstackSyncTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name) / "harness"
        self.source = Path(self.temp.name) / "upstream"
        self.repo.mkdir()
        self.source.mkdir()
        self.write(self.repo, ".claude-plugin/plugin.json", '{"skills":["./full-send/","./tdd/"]}\n')
        self.write(self.repo, "full-send/SKILL.md", "Existing full-send owner\n")
        self.write(self.repo, "tdd/SKILL.md", "Existing TDD owner\n")
        self.write(self.source, "LICENSE", "MIT License\nCopyright tstack fixture\n")
        self.write(self.source, "README.md", "Fixture source\n")
        for name in sorted(NAMES):
            self.write(self.source, f"skills/{name}/SKILL.md",
                       f"---\nname: {name}\ndescription: Fixture.\n---\nInstructions.\n")
        self.write(self.source, "skills/full-stop/agents/openai.yaml", "interface:\n  display_name: Full stop\n")
        helper = self.write(self.source, "skills/babysit-pr/scripts/pr-wait", "#!/bin/sh\necho fixture-event\n")
        helper.chmod(0o755)
        self.git("init", "-q")
        self.revision = self.commit()

    def write(self, root, name, content):
        path = root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        return path

    def git(self, *args):
        return subprocess.check_output(["git", "-C", str(self.source), *args], text=True)

    def commit(self):
        self.git("add", ".")
        self.git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.com", "commit", "-qm", "fixture")
        return self.git("rev-parse", "HEAD").strip()

    def cli(self, *args):
        return subprocess.run(["python3", str(SCRIPT), "--repo-root", str(self.repo), *args],
                              capture_output=True, text=True, check=False)

    def install(self, revision=None):
        return self.cli("--source", str(self.source), "--revision", revision or self.revision)

    def snapshot(self):
        return {p.relative_to(self.repo).as_posix(): (p.read_bytes(), p.stat().st_mode & 0o777)
                for p in self.repo.rglob("*") if p.is_file()}

    def test_complete_pinned_snapshot_preserves_owner_resources_and_modes(self):
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        lock = json.loads((self.repo / "vendor/tstack.lock.json").read_text())
        self.assertEqual(lock["repository"], "https://github.com/t3dotgg/tstack")
        self.assertEqual(lock["revision"], self.revision)
        self.assertEqual({s["name"] for s in lock["skills"]}, NAMES)
        for relative, record in lock["files"].items():
            original = self.source / relative
            copied = self.repo / "vendor/tstack" / relative
            self.assertEqual(copied.read_bytes(), original.read_bytes())
            self.assertEqual(record["sha256"], hashlib.sha256(original.read_bytes()).hexdigest())
            self.assertEqual(copied.stat().st_mode & 0o777, original.stat().st_mode & 0o777)
        self.assertEqual((self.repo / "full-send/SKILL.md").read_text(), "Existing full-send owner\n")
        manifest = json.loads((self.repo / ".claude-plugin/plugin.json").read_text())["skills"]
        self.assertEqual(set(manifest), {"./full-send/", "./tdd/"} |
                         {f"./tstack-skills/{name}/" for name in NAMES - {"full-send"}})
        self.assertEqual(len(manifest), 10)
        self.assertEqual({p.name for p in (self.repo / "tstack-skills").iterdir()}, NAMES - {"full-send"})
        helper = self.repo / "vendor/tstack/skills/babysit-pr/scripts/pr-wait"
        self.assertEqual(subprocess.check_output([str(helper)], text=True), "fixture-event\n")
        self.assertTrue((self.repo / "vendor/tstack/skills/full-stop/agents/openai.yaml").is_file())
        self.assertEqual(self.cli("--check").returncode, 0)

    def test_duplicate_host_owner_is_detected_after_install(self):
        self.assertEqual(self.install().returncode, 0)
        path = self.repo / ".claude-plugin/plugin.json"
        manifest = json.loads(path.read_text())
        manifest["skills"].append("./file-pr/")
        path.write_text(json.dumps(manifest))
        result = self.cli("--check")
        self.assertNotEqual(result.returncode, 0, result.stdout)

    def test_committed_inputs_and_repeat_import_are_deterministic(self):
        self.assertEqual(self.install().returncode, 0)
        self.write(self.source, "skills/file-pr/SKILL.md", "Dirty upstream work is not the pin\n")
        before = self.snapshot()
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.snapshot(), before)

    def test_drift_is_reported_and_refresh_preserves_local_work(self):
        self.assertEqual(self.install().returncode, 0)
        helper = self.repo / "vendor/tstack/skills/babysit-pr/scripts/pr-wait"
        original = helper.read_bytes()
        adapter = self.repo / "tstack-skills/council/SKILL.md"
        adapter_original = adapter.read_bytes()
        for mutation in ("source", "mode", "adapter", "extra"):
            with self.subTest(mutation=mutation):
                extra = self.repo / "vendor/tstack/local-notes.md"
                if mutation == "source":
                    helper.write_text("Local work must survive\n")
                elif mutation == "mode":
                    helper.chmod(0o644)
                elif mutation == "adapter":
                    adapter.write_text("Local adapter edit must survive\n")
                else:
                    extra.write_text("Unmanaged addition\n")
                before = self.snapshot()
                self.assertNotEqual(self.cli("--check").returncode, 0)
                self.assertNotEqual(self.install().returncode, 0)
                self.assertEqual(self.snapshot(), before)
                helper.write_bytes(original)
                helper.chmod(0o755)
                adapter.write_bytes(adapter_original)
                extra.unlink(missing_ok=True)

    def test_unreviewed_skill_or_missing_license_cannot_partially_refresh(self):
        self.assertEqual(self.install().returncode, 0)
        for mutation in ("unknown", "license"):
            with self.subTest(mutation=mutation):
                if mutation == "unknown":
                    self.write(self.source, "skills/new-action/SKILL.md",
                               "---\nname: new-action\ndescription: Unreviewed.\n---\nBody\n")
                else:
                    (self.source / "LICENSE").unlink()
                revision = self.commit()
                before = self.snapshot()
                self.assertNotEqual(self.install(revision).returncode, 0)
                self.assertEqual(self.snapshot(), before)
                self.git("reset", "--hard", self.revision)

    def test_unmanaged_output_and_name_collisions_survive_rejected_import(self):
        for name in ("vendor/tstack/notes.md", "tstack-skills/local/SKILL.md"):
            with self.subTest(name=name):
                path = self.write(self.repo, name, "Keep this\n")
                before = self.snapshot()
                self.assertNotEqual(self.install().returncode, 0)
                self.assertEqual(self.snapshot(), before)
                path.unlink()
                path.parent.rmdir()
                if (self.repo / "tstack-skills").exists():
                    (self.repo / "tstack-skills").rmdir()
        self.write(self.repo, ".claude-plugin/plugin.json",
                   '{"skills":["./full-send/","./council/"]}\n')
        self.write(self.repo, "council/SKILL.md", "Existing council owner\n")
        before = self.snapshot()
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("collide", result.stderr)
        self.assertEqual(self.snapshot(), before)

    def test_moving_revision_and_source_symlink_fail_before_writes(self):
        before = self.snapshot()
        for revision in ("main", "0" * 40):
            with self.subTest(revision=revision):
                self.assertNotEqual(self.install(revision).returncode, 0)
                self.assertEqual(self.snapshot(), before)
        (self.source / "skills/file-pr/leak").symlink_to("/etc/passwd")
        revision = self.commit()
        self.assertNotEqual(self.install(revision).returncode, 0)
        self.assertEqual(self.snapshot(), before)

    def test_destination_symlink_cannot_redirect_writes(self):
        outside = Path(self.temp.name) / "outside"
        outside.mkdir()
        (self.repo / "vendor").symlink_to(outside, target_is_directory=True)
        before = self.snapshot()
        self.assertNotEqual(self.install().returncode, 0)
        self.assertEqual(list(outside.iterdir()), [])
        self.assertEqual(self.snapshot(), before)


if __name__ == "__main__":
    unittest.main()
