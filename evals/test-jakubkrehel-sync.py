"""Exercise jakubkrehel imports through the public CLI, with committed fixture inputs."""

import hashlib
import json
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts/vendor-jakubkrehel.py"
NAMES = {"better-interface", "better-ui", "better-typography", "better-colors",
         "better-accessibility", "better-layout", "better-writing", "interface-review",
         "explain-interface", "break", "build-design", "teardown", "state-machine", "variant"}
EXPLICIT = {"interface-review", "explain-interface", "break", "state-machine", "variant"}


class JakubkrehelSyncTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name) / "harness"
        self.source = Path(self.temp.name) / "upstream"
        self.repo.mkdir()
        self.source.mkdir()
        self.write(self.repo, ".claude-plugin/plugin.json", '{"skills":["./accessibility/","./tdd/"]}\n')
        self.write(self.repo, "accessibility/SKILL.md", "Existing accessibility owner\n")
        self.write(self.repo, "tdd/SKILL.md", "Existing TDD owner\n")
        self.write(self.source, "LICENSE", "MIT License\nCopyright jakubkrehel fixture\n")
        self.write(self.source, "README.md", "Fixture source\n")
        for name in sorted(NAMES):
            self.write(self.source, f"skills/{name}/SKILL.md",
                       f"---\nname: {name}\ndescription: Fixture.\n"
                       + ("disable-model-invocation: true\n" if name in EXPLICIT else "")
                       + "---\nInstructions.\n")
        self.write(self.source, "skills/variant/agents/openai.yaml", "interface:\n  display_name: Variant\n")
        helper = self.write(self.source, "skills/teardown/scripts/fixture-helper", "#!/bin/sh\necho fixture-event\n")
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
        lock = json.loads((self.repo / "vendor/jakubkrehel.lock.json").read_text())
        self.assertEqual(lock["repository"], "https://github.com/jakubkrehel/skills")
        self.assertEqual(lock["revision"], self.revision)
        self.assertEqual({s["name"] for s in lock["skills"]}, NAMES)
        for relative, record in lock["files"].items():
            original = self.source / relative
            copied = self.repo / "vendor/jakubkrehel" / relative
            self.assertEqual(copied.read_bytes(), original.read_bytes())
            self.assertEqual(record["sha256"], hashlib.sha256(original.read_bytes()).hexdigest())
            self.assertEqual(copied.stat().st_mode & 0o777, original.stat().st_mode & 0o777)
        self.assertEqual((self.repo / "accessibility/SKILL.md").read_text(), "Existing accessibility owner\n")
        manifest = json.loads((self.repo / ".claude-plugin/plugin.json").read_text())["skills"]
        self.assertEqual(set(manifest), {"./accessibility/", "./tdd/"} |
                         {f"./jakubkrehel-skills/{name}/" for name in NAMES})
        self.assertEqual(len(manifest), 16)
        self.assertEqual({p.name for p in (self.repo / "jakubkrehel-skills").iterdir()}, NAMES)
        helper = self.repo / "vendor/jakubkrehel/skills/teardown/scripts/fixture-helper"
        self.assertEqual(subprocess.check_output([str(helper)], text=True), "fixture-event\n")
        self.assertTrue((self.repo / "vendor/jakubkrehel/skills/variant/agents/openai.yaml").is_file())
        for name in NAMES:
            adapter = (self.repo / f"jakubkrehel-skills/{name}/SKILL.md").read_text()
            self.assertEqual("disable-model-invocation: true" in adapter, name in EXPLICIT)
            self.assertIn(f"../../vendor/jakubkrehel/skills/{name}/SKILL.md", adapter)
            self.assertIn("../../shared/INTERFACES.md", adapter)
        self.assertEqual(self.cli("--check").returncode, 0)

    def test_duplicate_host_owner_is_detected_after_install(self):
        self.assertEqual(self.install().returncode, 0)
        path = self.repo / ".claude-plugin/plugin.json"
        manifest = json.loads(path.read_text())
        manifest["skills"].append("./build-design/")
        path.write_text(json.dumps(manifest))
        result = self.cli("--check")
        self.assertNotEqual(result.returncode, 0, result.stdout)

    def test_committed_inputs_and_repeat_import_are_deterministic(self):
        self.assertEqual(self.install().returncode, 0)
        self.write(self.source, "skills/build-design/SKILL.md", "Dirty upstream work is not the pin\n")
        before = self.snapshot()
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.snapshot(), before)

    def test_reviewed_refresh_updates_pin_and_prunes_removed_resources(self):
        self.assertEqual(self.install().returncode, 0)
        (self.source / "skills/teardown/scripts/fixture-helper").unlink()
        self.write(self.source, "skills/teardown/assets/new.txt", "Reviewed resource\n")
        revision = self.commit()
        result = self.install(revision)
        self.assertEqual(result.returncode, 0, result.stderr)
        lock = json.loads((self.repo / "vendor/jakubkrehel.lock.json").read_text())
        self.assertEqual(lock["revision"], revision)
        self.assertNotIn("skills/teardown/scripts/fixture-helper", lock["files"])
        self.assertEqual((self.repo / "vendor/jakubkrehel/skills/teardown/assets/new.txt").read_text(),
                         "Reviewed resource\n")
        self.assertEqual(self.cli("--check").returncode, 0)

    def test_malformed_frontmatter_is_rejected_without_writes(self):
        for content in ("---\nname: better-ui\ndescription: Broken\nNo closing delimiter\n",
                        "---\nname: better-ui\n---\nMissing description\n"):
            with self.subTest(content=content):
                self.write(self.source, "skills/better-ui/SKILL.md", content)
                revision = self.commit()
                before = self.snapshot()
                result = self.install(revision)
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertEqual(self.snapshot(), before)

    def test_drift_is_reported_and_refresh_preserves_local_work(self):
        self.assertEqual(self.install().returncode, 0)
        helper = self.repo / "vendor/jakubkrehel/skills/teardown/scripts/fixture-helper"
        original = helper.read_bytes()
        adapter = self.repo / "jakubkrehel-skills/better-colors/SKILL.md"
        adapter_original = adapter.read_bytes()
        for mutation in ("source", "mode", "adapter", "extra"):
            with self.subTest(mutation=mutation):
                extra = self.repo / "vendor/jakubkrehel/local-notes.md"
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
        for mutation in ("unknown", "license", "missing", "policy"):
            with self.subTest(mutation=mutation):
                if mutation == "unknown":
                    self.write(self.source, "skills/new-action/SKILL.md",
                               "---\nname: new-action\ndescription: Unreviewed.\n---\nBody\n")
                elif mutation == "license":
                    (self.source / "LICENSE").unlink()
                elif mutation == "missing":
                    (self.source / "skills/better-ui/SKILL.md").unlink()
                else:
                    path = self.source / "skills/variant/SKILL.md"
                    path.write_text(path.read_text().replace("disable-model-invocation: true", ""))
                revision = self.commit()
                before = self.snapshot()
                self.assertNotEqual(self.install(revision).returncode, 0)
                self.assertEqual(self.snapshot(), before)
                self.git("reset", "--hard", self.revision)

    def test_unmanaged_output_and_name_collisions_survive_rejected_import(self):
        for name in ("vendor/jakubkrehel/notes.md", "jakubkrehel-skills/local/SKILL.md"):
            with self.subTest(name=name):
                path = self.write(self.repo, name, "Keep this\n")
                before = self.snapshot()
                self.assertNotEqual(self.install().returncode, 0)
                self.assertEqual(self.snapshot(), before)
                path.unlink()
                path.parent.rmdir()
                if (self.repo / "jakubkrehel-skills").exists():
                    (self.repo / "jakubkrehel-skills").rmdir()
        self.write(self.repo, ".claude-plugin/plugin.json",
                   '{"skills":["./accessibility/","./better-colors/"]}\n')
        self.write(self.repo, "better-colors/SKILL.md", "Existing better-colors owner\n")
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
        (self.source / "skills/build-design/leak").symlink_to("/etc/passwd")
        revision = self.commit()
        self.assertNotEqual(self.install(revision).returncode, 0)
        self.assertEqual(self.snapshot(), before)

    def test_reviewed_security_patch_is_reproducible_and_invalid_patch_preserves_output(self):
        patch = self.write(self.repo, "vendor/jakubkrehel-patches/helper.patch",
                           "diff --git a/skills/teardown/scripts/fixture-helper b/skills/teardown/scripts/fixture-helper\n"
                           "--- a/skills/teardown/scripts/fixture-helper\n"
                           "+++ b/skills/teardown/scripts/fixture-helper\n"
                           "@@ -1,2 +1,2 @@\n #!/bin/sh\n-echo fixture-event\n+echo patched-event\n")
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        helper = self.repo / "vendor/jakubkrehel/skills/teardown/scripts/fixture-helper"
        self.assertEqual(subprocess.check_output([str(helper)], text=True), "patched-event\n")
        lock = json.loads((self.repo / "vendor/jakubkrehel.lock.json").read_text())
        name = "skills/teardown/scripts/fixture-helper"
        self.assertEqual(lock["upstream_files"][name]["sha256"],
                         hashlib.sha256((self.source / name).read_bytes()).hexdigest())
        self.assertNotEqual(lock["upstream_files"][name]["sha256"], lock["files"][name]["sha256"])
        before = self.snapshot()
        self.assertEqual(self.install().returncode, 0)
        self.assertEqual(self.snapshot(), before)
        patch.write_text(patch.read_text().replace("-echo fixture-event", "-echo nonexistent"))
        self.assertNotEqual(self.cli("--check").returncode, 0)
        before = self.snapshot()
        self.assertNotEqual(self.install().returncode, 0)
        self.assertEqual(self.snapshot(), before)

    def test_refresh_regenerates_reviewed_description_changes_without_ignoring_output_drift(self):
        self.assertEqual(self.install().returncode, 0)
        lock_path = self.repo / "vendor/jakubkrehel.lock.json"
        lock = json.loads(lock_path.read_text())
        skill = next(s for s in lock["skills"] if s["name"] == "variant")
        previous_description = "Previously published description."
        path = self.repo / "jakubkrehel-skills/variant/SKILL.md"
        path.write_text(path.read_text().replace(json.dumps(skill["description"]), json.dumps(previous_description)))
        skill["description"] = previous_description
        lock_path.write_text(json.dumps(lock, indent=2) + "\n")
        self.assertNotEqual(self.cli("--check").returncode, 0)
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn(previous_description, path.read_text())
        self.assertEqual(self.cli("--check").returncode, 0)

    def test_destination_symlink_cannot_redirect_writes(self):
        outside = Path(self.temp.name) / "outside"
        outside.mkdir()
        (self.repo / "vendor").symlink_to(outside, target_is_directory=True)
        before = self.snapshot()
        self.assertNotEqual(self.install().returncode, 0)
        self.assertEqual(list(outside.iterdir()), [])
        self.assertEqual(self.snapshot(), before)


class InstalledGuidanceTest(unittest.TestCase):
    """Public prompt/discovery contracts, not predictions of agent adherence."""

    def test_existing_skills_reach_compatible_guidance(self):
        expected = {
            "visual-review/SKILL.md": "../jakubkrehel-skills/better-interface/SKILL.md",
            "accessibility/SKILL.md": "../jakubkrehel-skills/better-accessibility/SKILL.md",
            "ux-copy/SKILL.md": "../jakubkrehel-skills/better-writing/SKILL.md",
            "animate/SKILL.md": "../shared/INTERFACES.md#better-ui",
            "break-ui/SKILL.md": "../shared/INTERFACES.md#break",
            "mobile-native/SKILL.md": "../shared/INTERFACES.md#better-layout",
            "prototype/SKILL.md": "../shared/INTERFACES.md#workbench-retention",
            "development-lifecycle/SKILL.md": "../jakubkrehel-skills/build-design/SKILL.md",
            "review/SKILL.md": "../shared/INTERFACES.md#interface-review",
            "show-me/SKILL.md": "../shared/INTERFACES.md#explain-interface",
        }
        for path, target in expected.items():
            with self.subTest(path=path):
                text = (ROOT / path).read_text()
                self.assertIn(f"]({target})", text)
                self.assertTrue((ROOT / path).parent.joinpath(target.split("#")[0]).is_file())

    def test_registered_adapters_and_codex_policy_resolve_offline(self):
        import re

        manifest = json.loads((ROOT / ".claude-plugin/plugin.json").read_text())["skills"]
        contract = (ROOT / "shared/INTERFACES.md").read_text()
        catalog = (ROOT / "ask-ben/SKILL-CATALOG.md").read_text()
        for name in NAMES:
            with self.subTest(name=name):
                entry = f"./jakubkrehel-skills/{name}/"
                self.assertEqual(manifest.count(entry), 1)
                self.assertIn(f"## {name}\n", contract)
                self.assertIn(f"`/{name}`", catalog)
                proxy = ROOT / f"codex-skills/{name}/SKILL.md"
                self.assertIn(f"../../jakubkrehel-skills/{name}/SKILL.md", proxy.read_text())
                policy = (proxy.parent / "agents/openai.yaml").read_text()
                self.assertEqual("allow_implicit_invocation: false" in policy, name in EXPLICIT)
        for path in [ROOT / "shared/INTERFACES.md", *
                     (ROOT / "vendor/jakubkrehel/skills").rglob("*.md")]:
            for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", path.read_text()):
                if ":" in target or target.startswith("#"):
                    continue
                resource = (path.parent / target.split("#")[0]).resolve()
                self.assertTrue(resource.is_relative_to(ROOT), str(resource))
                self.assertTrue(resource.is_file(), f"{path}: {target}")
        license_text = (ROOT / "vendor/jakubkrehel/LICENSE").read_text()
        self.assertIn("Copyright (c) 2026 Jakub Krehel", license_text)
        self.assertIn("Permission is hereby granted", license_text)


if __name__ == "__main__":
    unittest.main()
