"""Offline contracts for the public shadcn/improve import and verification CLI."""

import hashlib
import json
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile
import unittest


REPO = pathlib.Path(__file__).resolve().parents[1]
SNAPSHOT = REPO / "vendor/shadcn-improve"
IMPORTER = REPO / "scripts/vendor-shadcn-improve.py"
SKILL = "skills/improve"


def run(*args, ok=True):
    result = subprocess.run(list(map(str, args)), capture_output=True, text=True)
    if (result.returncode == 0) != ok:
        raise AssertionError(result.stdout + result.stderr)
    return result


def tree(root):
    return {p.relative_to(root).as_posix(): (p.read_bytes(), p.stat().st_mode & 0o777)
            for p in root.rglob("*") if p.is_file()}


def commit(source):
    run("git", "-C", source, "add", ".")
    run("git", "-C", source, "-c", "user.name=Fixture", "-c",
        "user.email=fixture@example.invalid", "commit", "-qm", "fixture")
    return run("git", "-C", source, "rev-parse", "HEAD").stdout.strip()


def fixture(root):
    source, target = root / "source", root / "target"
    shutil.copytree(SNAPSHOT, source)
    target.mkdir()
    run("git", "init", "-q", source)
    return source, target


def cli(target, *args, ok=True):
    return run(sys.executable, IMPORTER, "--repo-root", target, *args, ok=ok)


class ImproveVendoring(unittest.TestCase):
    def test_complete_snapshot_and_license_are_distributed(self):
        self.assertTrue((SNAPSHOT / "skills/improve/SKILL.md").is_file(),
                        "missing pinned upstream skill")
        license_bytes = (SNAPSHOT / "LICENSE.md").read_bytes()
        self.assertIn(b"Copyright (c) 2026 shadcn", license_bytes)
        self.assertIn(b"Permission is hereby granted", license_bytes)
        self.assertEqual((REPO / "improve/LICENSE.md").read_bytes(), license_bytes)
        run(sys.executable, IMPORTER, "--check")
        registrations = json.loads((REPO / ".claude-plugin/plugin.json").read_text())["skills"]
        self.assertEqual(registrations.count("./improve/"), 1)
        proxy = (REPO / "codex-skills/improve/SKILL.md").read_text()
        self.assertIn("../../improve/SKILL.md", proxy)
        for page in (REPO / "improve/SKILL.md", REPO / "vendor/shadcn-improve-NOTICE.md"):
            for link in re.findall(r"\[[^\]]+\]\(([^)]+)\)", page.read_text()):
                if ":" not in link and not link.startswith("#"):
                    target = (page.parent / link.split("#")[0]).resolve()
                    self.assertTrue(target.is_relative_to(REPO), target)
                    self.assertTrue(target.is_file(), target)
        run("bash", REPO / "scripts/generate-skill-catalog.sh", "--check")

    def test_refresh_uses_committed_complete_inventory_and_is_repeatable(self):
        with tempfile.TemporaryDirectory(prefix="improve-refresh-") as temp:
            source, target = fixture(pathlib.Path(temp))
            # A new helper must be copied even when not in the required-resource list.
            helper = source / SKILL / "scripts/example.sh"
            helper.parent.mkdir()
            helper.write_text("#!/bin/sh\nprintf 'example\\n'\n")
            helper.chmod(0o755)
            revision = commit(source)
            expected = tree(source / "skills")
            (source / SKILL / "SKILL.md").write_text("dirty checkout; not a reviewed input")
            args = ("--source", source, "--revision", revision)
            cli(target, *args)
            managed = target / "vendor/shadcn-improve"
            self.assertEqual(tree(managed / "skills"), expected)
            cli(target, "--check", "--source", source)
            before = tree(target)
            cli(target, *args)
            self.assertEqual(tree(target), before, "identical refresh changed output")
            cli(target, "--source", source, "--revision", "HEAD", ok=False)
            self.assertEqual(tree(target), before, "moving ref rejection wrote output")

    def test_drift_is_detected_and_never_overwritten(self):
        with tempfile.TemporaryDirectory(prefix="improve-drift-") as temp:
            source, target = fixture(pathlib.Path(temp))
            revision = commit(source)
            args = ("--source", source, "--revision", revision)
            cli(target, *args)
            managed = target / "vendor/shadcn-improve"
            victim = managed / SKILL / "SKILL.md"
            original = victim.read_bytes()
            victim.write_text("owned local work")
            before = tree(target)
            cli(target, "--check", ok=False)
            cli(target, *args, ok=False)
            self.assertEqual(tree(target), before)
            victim.write_bytes(original)
            victim.chmod(0o755)
            cli(target, "--check", ok=False)
            victim.chmod(0o644)
            extra = managed / "extra.txt"
            extra.write_text("unexpected")
            cli(target, "--check", ok=False)
            extra.unlink()
            victim.unlink()
            cli(target, "--check", ok=False)
            victim.symlink_to(source / SKILL / "SKILL.md")
            cli(target, *args, ok=False)
            victim.unlink()
            victim.write_bytes(original)
            license_path = target / "improve/LICENSE.md"
            license_path.write_text("local license edit")
            cli(target, *args, ok=False)
            self.assertEqual(license_path.read_text(), "local license edit")

    def test_source_verification_rejects_self_consistent_but_forged_snapshot(self):
        with tempfile.TemporaryDirectory(prefix="improve-origin-") as temp:
            source, target = fixture(pathlib.Path(temp))
            revision = commit(source)
            cli(target, "--source", source, "--revision", revision)
            relative = SKILL + "/references/audit-playbook.md"
            victim = target / "vendor/shadcn-improve" / relative
            victim.write_text("forged content with a matching local digest")
            lock_path = target / "vendor/shadcn-improve.lock.json"
            lock = json.loads(lock_path.read_text())
            lock["files"][relative]["sha256"] = hashlib.sha256(victim.read_bytes()).hexdigest()
            lock_path.write_text(json.dumps(lock))
            cli(target, "--check")  # A local digest alone does not prove provenance.
            before = tree(target)
            result = cli(target, "--check", "--source", source, ok=False)
            self.assertIn("differs from the recorded upstream commit", result.stderr)
            self.assertEqual(tree(target), before, "read-only verification wrote output")

    def test_unsafe_incomplete_or_unreviewed_source_writes_nothing(self):
        for mutation in ("license", "missing-reference", "symlink", "gitlink"):
            with self.subTest(mutation=mutation), tempfile.TemporaryDirectory(prefix="improve-reject-") as temp:
                source, target = fixture(pathlib.Path(temp))
                initial = commit(source)
                if mutation == "license":
                    with (source / "LICENSE.md").open("a") as output:
                        output.write("\nAdditional restriction\n")
                elif mutation == "missing-reference":
                    (source / SKILL / "references/closing-the-loop.md").unlink()
                elif mutation == "symlink":
                    (source / SKILL / "unsafe").symlink_to("/etc/passwd")
                if mutation == "gitlink":
                    run("git", "-C", source, "update-index", "--add", "--cacheinfo",
                        f"160000,{initial},{SKILL}/nested")
                    run("git", "-C", source, "-c", "user.name=Fixture", "-c",
                        "user.email=fixture@example.invalid", "commit", "-qm", "gitlink")
                    revision = run("git", "-C", source, "rev-parse", "HEAD").stdout.strip()
                else:
                    revision = commit(source)
                cli(target, "--source", source, "--revision", revision, ok=False)
                self.assertEqual(tree(target), {}, "rejected input changed output")

    def test_unmanaged_output_and_symlinked_parent_are_preserved(self):
        with tempfile.TemporaryDirectory(prefix="improve-owned-") as temp:
            source, target = fixture(pathlib.Path(temp))
            revision = commit(source)
            args = ("--source", source, "--revision", revision)
            destination = target / "vendor/shadcn-improve"
            destination.mkdir(parents=True)
            (destination / "owned.txt").write_text("unmanaged")
            before = tree(target)
            cli(target, *args, ok=False)
            self.assertEqual(tree(target), before)
            destination.rename(target / "vendor/owned")
            destination.symlink_to(target / "vendor/owned", target_is_directory=True)
            cli(target, *args, ok=False)
            self.assertEqual((destination / "owned.txt").read_text(), "unmanaged")
            destination.unlink()
            license_path = target / "improve/LICENSE.md"
            license_path.parent.mkdir()
            license_path.write_text("unmanaged license")
            cli(target, *args, ok=False)
            self.assertEqual(license_path.read_text(), "unmanaged license")


if __name__ == "__main__":
    unittest.main()
