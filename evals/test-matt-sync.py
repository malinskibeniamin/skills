"""Public importer contract: complete, pinned, auditable and safe to refresh."""

import difflib
import hashlib
import json
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts/vendor-mattpocock.py"


class MattSyncTest(unittest.TestCase):
    def security_patch(self, target, before="before\n", after="after\n"):
        self.write(self.source, target, before)
        revision = self.commit() if self.git("status", "--porcelain").strip() else self.git("rev-parse", "HEAD").strip()
        patch = "".join(difflib.unified_diff(before.splitlines(True), after.splitlines(True),
                                            fromfile=f"a/{target}", tofile=f"b/{target}"))
        self.write(self.repo, "vendor/mattpocock-patches/0001-calibration.patch", patch)
        return revision

    def test_security_patch_retains_both_inventories_and_rejects_input_drift(self):
        target = "skills/in-progress/animatic/scripts/animatic.mjs"
        revision = self.security_patch(target)
        result = self.install(revision)
        self.assertEqual(result.returncode, 0, result.stderr)
        lock = json.loads((self.repo / "vendor/mattpocock.lock.json").read_text())
        self.assertIn("upstream_files", lock)
        self.assertEqual(lock["upstream_files"][target]["sha256"], hashlib.sha256(b"before\n").hexdigest())
        self.assertEqual(lock["files"][target]["sha256"], hashlib.sha256(b"after\n").hexdigest())
        self.assertEqual((self.repo / "vendor/mattpocock/upstream" / target).read_text(), "after\n")
        before = self.snapshot()
        self.assertEqual(self.install(revision).returncode, 0)
        self.assertEqual(self.snapshot(), before)
        self.assertEqual(self.cli("--check").returncode, 0)
        lock_path = self.repo / "vendor/mattpocock.lock.json"
        published = lock_path.read_text()
        del lock["upstream_files"]
        lock_path.write_text(json.dumps(lock))
        self.assertNotEqual(self.cli("--check").returncode, 0)
        lock_path.write_text(published)
        patch = self.repo / "vendor/mattpocock-patches/0001-calibration.patch"
        patch.write_text(patch.read_text() + "\n")
        self.assertNotEqual(self.cli("--check").returncode, 0)

    def test_security_patch_cannot_change_attribution(self):
        self.assertEqual(self.install().returncode, 0)
        self.security_patch("LICENSE", "MIT License\nCopyright Matt Pocock\n", "Changed license\n")
        before = self.snapshot()
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("outside approved animatic helper", result.stderr)
        self.assertEqual(self.snapshot(), before)

    def test_security_patch_cannot_add_a_file_even_at_an_approved_path(self):
        self.assertEqual(self.install().returncode, 0)
        target = "skills/in-progress/animatic/scripts/animatic.mjs"
        self.write(self.repo, "vendor/mattpocock-patches/0001-create.patch",
                   f"--- /dev/null\n+++ b/{target}\n@@ -0,0 +1 @@\n+unexpected\n")
        before = self.snapshot()
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("preserve the complete upstream inventory", result.stderr)
        self.assertEqual(self.snapshot(), before)

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name) / "host"
        self.source = Path(self.temp.name) / "source"
        self.repo.mkdir()
        self.source.mkdir()
        self.write(self.repo, ".claude-plugin/plugin.json", '{"skills":["./pr/"],"instructions":["CLAUDE.md", "AGENTS.md"]}\n')
        self.write(self.repo, "pr/SKILL.md", "Local PR policy stays authoritative\n")
        self.write(self.repo, "vendor/mattpocock/software-factory/SKILL.md", "Separate draft pin\n")
        self.write(self.source, "LICENSE", "MIT License\nCopyright Matt Pocock\n")
        self.write(self.source, "README.md", "Source documentation\n")
        for category, name in (("engineering", "pr"), ("misc", "fixture-tool")):
            self.write(self.source, f"skills/{category}/{name}/SKILL.md",
                       f"---\nname: {name}\ndescription: Fixture skill.\n---\nUse the local reference.\n")
        self.write(self.source, "skills/engineering/pr/CREDITS.md", "Credit original author\n")
        self.helper = self.write(self.source, "skills/misc/fixture-tool/scripts/check.sh", "#!/bin/sh\necho fixture-ok\n")
        self.helper.chmod(0o755)
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
                              capture_output=True, text=True)

    def install(self, revision=None):
        return self.cli("--source", str(self.source), "--revision", revision or self.revision)

    def snapshot(self):
        return {p.relative_to(self.repo).as_posix(): (p.read_bytes(), p.stat().st_mode & 0o777)
                for p in self.repo.rglob("*") if p.is_file()}

    def test_complete_import_includes_pr_helpers_and_credits_without_replacing_host(self):
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        lock = json.loads((self.repo / "vendor/mattpocock.lock.json").read_text())
        self.assertEqual(lock["repository"], "https://github.com/mattpocock/skills")
        self.assertEqual(lock["revision"], self.revision)
        self.assertEqual({s["upstream_name"] for s in lock["skills"]}, {"pr", "fixture-tool"})
        for name, record in lock["files"].items():
            original = self.source / name
            copied = self.repo / "vendor/mattpocock/upstream" / name
            self.assertEqual(copied.read_bytes(), original.read_bytes())
            self.assertEqual(record["sha256"], hashlib.sha256(original.read_bytes()).hexdigest())
            self.assertEqual(copied.stat().st_mode & 0o777, original.stat().st_mode & 0o777)
        helper = self.repo / "vendor/mattpocock/upstream/skills/misc/fixture-tool/scripts/check.sh"
        self.assertEqual(subprocess.check_output([str(helper)], text=True), "fixture-ok\n")
        self.assertEqual((self.repo / "pr/SKILL.md").read_text(), "Local PR policy stays authoritative\n")
        self.assertEqual((self.repo / "vendor/mattpocock/software-factory/SKILL.md").read_text(), "Separate draft pin\n")
        registrations = json.loads((self.repo / ".claude-plugin/plugin.json").read_text())["skills"]
        self.assertEqual(registrations, ["./pr/", "./matt-skills/matt-fixture-tool/", "./matt-skills/matt-pr/"])
        self.assertIn('"instructions":["CLAUDE.md", "AGENTS.md"]',
                      (self.repo / ".claude-plugin/plugin.json").read_text())
        adapter = (self.repo / "matt-skills/matt-pr/SKILL.md").read_text()
        self.assertIn("../../pr/SKILL.md", adapter)
        self.assertIn("../../shared/MATT-POCOCK.md", adapter)
        self.assertIn("disable-model-invocation: true", adapter)
        self.assertEqual(self.cli("--check").returncode, 0)

    def test_refresh_discovers_new_skills_updates_existing_and_prunes_removed_resources(self):
        self.assertEqual(self.install().returncode, 0)
        self.helper.unlink()
        (self.source / "skills/misc/fixture-tool/SKILL.md").unlink()
        self.write(self.source, "skills/engineering/pr/CREDITS.md", "Updated credit\n")
        self.write(self.source, "skills/in-progress/new-skill/SKILL.md",
                   "---\nname: new-skill\ndescription: New upstream skill.\n---\nInstructions\n")
        revision = self.commit()
        # Worktree edits are not committed source inputs.
        self.write(self.source, "skills/engineering/pr/CREDITS.md", "Uncommitted work\n")
        result = self.install(revision)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Reconcile fixture-tool -> matt-fixture-tool (removed)", result.stdout)
        self.assertIn("Reconcile new-skill -> matt-new-skill (added)", result.stdout)
        self.assertIn("Reconcile pr -> pr (changed)", result.stdout)
        self.assertFalse((self.repo / "vendor/mattpocock/upstream/skills/misc/fixture-tool/scripts/check.sh").exists())
        self.assertFalse((self.repo / "matt-skills/matt-fixture-tool").exists())
        self.assertEqual((self.repo / "vendor/mattpocock/upstream/skills/engineering/pr/CREDITS.md").read_text(), "Updated credit\n")
        self.assertTrue((self.repo / "matt-skills/matt-new-skill/SKILL.md").is_file())
        before = self.snapshot()
        self.assertEqual(self.install(revision).returncode, 0)
        self.assertEqual(self.snapshot(), before)

    def test_same_pin_preserves_registration_order_among_other_vendors(self):
        self.assertEqual(self.install().returncode, 0)
        manifest_path = self.repo / ".claude-plugin/plugin.json"
        manifest = json.loads(manifest_path.read_text())
        manifest["skills"].insert(2, "./another-vendor/skill/")
        manifest["skills"].append("./local-tail/")
        manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
        before = self.snapshot()
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.snapshot(), before)
        self.assertNotIn("Reconcile ", result.stdout)

    def test_removing_source_owner_keeps_host_workflow_and_reports_reconciliation(self):
        self.assertEqual(self.install().returncode, 0)
        (self.source / "skills/engineering/pr/SKILL.md").unlink()
        (self.source / "skills/engineering/pr/CREDITS.md").unlink()
        result = self.install(self.commit())
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Reconcile pr -> pr (removed)", result.stdout)
        self.assertEqual((self.repo / "pr/SKILL.md").read_text(), "Local PR policy stays authoritative\n")
        self.assertFalse((self.repo / "matt-skills/matt-pr").exists())
        registrations = json.loads((self.repo / ".claude-plugin/plugin.json").read_text())["skills"]
        self.assertEqual(registrations, ["./pr/", "./matt-skills/matt-fixture-tool/"])
        self.assertEqual(self.cli("--check").returncode, 0)

    def test_new_software_factory_skill_keeps_existing_host_owner(self):
        self.assertEqual(self.install().returncode, 0)
        self.write(self.repo, "software-factory/SKILL.md", "Local planning and authorization policy\n")
        manifest_path = self.repo / ".claude-plugin/plugin.json"
        manifest = json.loads(manifest_path.read_text())
        manifest["skills"].append("./software-factory/")
        manifest_path.write_text(json.dumps(manifest) + "\n")
        self.write(self.source, "skills/in-progress/software-factory/SKILL.md",
                   "---\nname: software-factory\ndescription: Factory design language.\n---\nUse the source survey.\n")
        self.write(self.source, "skills/in-progress/software-factory/RUNNERS.md", "Source runner survey\n")
        result = self.install(self.commit())
        self.assertEqual(result.returncode, 0, result.stderr)
        lock = json.loads((self.repo / "vendor/mattpocock.lock.json").read_text())
        skill = next(s for s in lock["skills"] if s["upstream_name"] == "software-factory")
        self.assertEqual(skill["owner"], "software-factory")
        adapter = (self.repo / "matt-skills/matt-software-factory/SKILL.md").read_text()
        self.assertIn("../../software-factory/SKILL.md", adapter)
        self.assertIn("disable-model-invocation: true", adapter)
        self.assertEqual((self.repo / "software-factory/SKILL.md").read_text(),
                         "Local planning and authorization policy\n")
        self.assertEqual((self.repo / "vendor/mattpocock/upstream/skills/in-progress/software-factory/RUNNERS.md").read_text(),
                         "Source runner survey\n")
        self.assertEqual(self.cli("--check").returncode, 0)

    def test_drift_is_rejected_without_overwriting_local_work(self):
        self.assertEqual(self.install().returncode, 0)
        for relative in ("vendor/mattpocock/upstream/LICENSE", "matt-skills/matt-pr/SKILL.md"):
            with self.subTest(relative=relative):
                path = self.repo / relative
                original = path.read_bytes()
                path.write_text("Local work\n")
                before = self.snapshot()
                self.assertNotEqual(self.cli("--check").returncode, 0)
                self.assertNotEqual(self.install().returncode, 0)
                self.assertEqual(self.snapshot(), before)
                path.write_bytes(original)

    def test_bad_inputs_cannot_partially_install(self):
        self.assertEqual(self.install().returncode, 0)
        for mutation in ("missing-license", "duplicate-name", "symlink", "bad-frontmatter"):
            with self.subTest(mutation=mutation):
                if mutation == "missing-license":
                    (self.source / "LICENSE").unlink()
                elif mutation == "duplicate-name":
                    self.write(self.source, "skills/other/pr/SKILL.md",
                               "---\nname: pr\ndescription: Duplicate.\n---\nBody\n")
                elif mutation == "symlink":
                    (self.source / "skills/misc/fixture-tool/escape").symlink_to("../../../../outside")
                else:
                    self.write(self.source, "skills/engineering/pr/SKILL.md", "---\nname: pr\n---\nNo description\n")
                revision = self.commit()
                before = self.snapshot()
                self.assertNotEqual(self.install(revision).returncode, 0)
                self.assertEqual(self.snapshot(), before)
                self.git("reset", "--hard", self.revision)


if __name__ == "__main__":
    unittest.main()
