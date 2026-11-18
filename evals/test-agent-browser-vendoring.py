"""Exercise pinned imports, drift refusal and installed skill discovery without network."""

import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]
IMPORTER = REPO / "scripts/vendor-agent-browser.py"
SNAPSHOT = REPO / "vendor/agent-browser"
SKILL = "skill-data/modern-web-guidance/SKILL.md"
TEMPLATE = "skill-data/core/templates/form-automation.sh"


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
    (target / ".claude-plugin").mkdir(parents=True)
    (target / ".claude-plugin/plugin.json").write_text('{"skills":["./dogfood/","./webmcp/"]}\n')
    run("git", "init", "-q", source)
    (source / TEMPLATE).chmod(0o755)
    revision = commit(source)
    return source, target, revision


class AgentBrowserVendoring(unittest.TestCase):
    def test_installed_discovery_and_resource_links(self):
        lock = json.loads((REPO / "vendor/agent-browser.lock.json").read_text())
        self.assertEqual(len(lock["skills"]), 10)
        registrations = json.loads((REPO / ".claude-plugin/plugin.json").read_text())["skills"]
        catalog = (REPO / "ask-ben/SKILL-CATALOG.md").read_text()
        pages = [REPO / "shared/AGENT-BROWSER.md", REPO / "vendor/agent-browser-NOTICE.md"]
        for skill in lock["skills"]:
            self.assertEqual(registrations.count(skill["registration"]), 1)
            self.assertIn(f'`/{skill["name"]}`', catalog)
            page = REPO / skill["registration"] / "SKILL.md"
            pages.extend([page, REPO / "codex-skills" / skill["name"] / "SKILL.md"])
        for page in pages:
            for link in re.findall(r"\[[^\]]+\]\(([^)]+)\)", page.read_text()):
                if ":" not in link and not link.startswith("#"):
                    target = (page.parent / link.split("#")[0]).resolve()
                    self.assertTrue(target.is_relative_to(REPO), target)
                    self.assertTrue(target.is_file(), target)
        run(sys.executable, IMPORTER, "--check")
        run("bash", REPO / "scripts/generate-skill-catalog.sh", "--check")

    def test_refresh_committed_source_and_drift_refusal(self):
        with tempfile.TemporaryDirectory(prefix="browser-refresh-") as temp:
            source, target, revision = fixture(Path(temp))
            original = (source / SKILL).read_bytes()
            (source / SKILL).write_text("dirty working copy must not be imported")
            args = (sys.executable, IMPORTER, "--repo-root", target,
                    "--source", source, "--revision", revision)
            run(*args)
            managed = target / "vendor/agent-browser"
            self.assertEqual((managed / SKILL).read_bytes(), original)
            self.assertEqual((managed / TEMPLATE).stat().st_mode & 0o777, 0o755)
            entries = json.loads((target / ".claude-plugin/plugin.json").read_text())["skills"]
            self.assertEqual(entries[:2], ["./dogfood/", "./webmcp/"], "existing owners changed")
            before = tree(target)
            run(*args)
            self.assertEqual(tree(target), before, "refresh was not idempotent")
            run(sys.executable, IMPORTER, "--repo-root", target, "--check", "--source", source)
            run(*args[:-1], "HEAD", ok=False)
            self.assertEqual(tree(target), before)
            for victim in (managed / SKILL, target / "modern-web-guidance/SKILL.md"):
                data = victim.read_bytes()
                victim.write_text("owned local work")
                run(*args, ok=False)
                self.assertEqual(victim.read_text(), "owned local work")
                victim.write_bytes(data)
            extra = managed / "unreviewed.txt"
            extra.write_text("extra resource")
            run(sys.executable, IMPORTER, "--repo-root", target, "--check", ok=False)
            extra.unlink()
            victim = managed / TEMPLATE
            victim.chmod(0o644)
            run(*args, ok=False)
            victim.chmod(0o755)
            victim.unlink()
            victim.symlink_to(source / TEMPLATE)
            run(*args, ok=False)
            self.assertTrue(victim.is_symlink())

    def test_bad_sources_and_unmanaged_destination_preserve_work(self):
        for mutation in ("license", "missing-skill", "new-skill", "symlink", "unmanaged"):
            with self.subTest(mutation=mutation), tempfile.TemporaryDirectory(prefix="browser-reject-") as temp:
                source, target, revision = fixture(Path(temp))
                if mutation == "license":
                    with (source / "LICENSE").open("a") as stream:
                        stream.write("\nAdditional restriction\n")
                elif mutation == "missing-skill":
                    (source / SKILL).unlink()
                elif mutation == "new-skill":
                    page = source / "skill-data/unknown/SKILL.md"
                    page.parent.mkdir()
                    page.write_text("---\nname: unknown\n---\n")
                elif mutation == "symlink":
                    (source / "skill-data/core/unsafe").symlink_to("/etc/passwd")
                else:
                    victim = target / "agent-browser-skills/owned.txt"
                    victim.parent.mkdir()
                    victim.write_text("unmanaged work")
                if mutation != "unmanaged":
                    revision = commit(source)
                before = tree(target)
                run(sys.executable, IMPORTER, "--repo-root", target, "--source", source,
                    "--revision", revision, ok=False)
                self.assertEqual(tree(target), before, "rejected import changed owned files")

    def test_source_comparison_rejects_a_self_consistent_forged_lock(self):
        with tempfile.TemporaryDirectory(prefix="browser-provenance-") as temp:
            source, target, revision = fixture(Path(temp))
            run(sys.executable, IMPORTER, "--repo-root", target, "--source", source,
                "--revision", revision)
            victim = target / "vendor/agent-browser" / SKILL
            victim.write_bytes(victim.read_bytes() + b"\nNot upstream\n")
            lock_path = target / "vendor/agent-browser.lock.json"
            lock = json.loads(lock_path.read_text())
            lock["files"][SKILL]["sha256"] = hashlib.sha256(victim.read_bytes()).hexdigest()
            lock_path.write_text(json.dumps(lock))
            run(sys.executable, IMPORTER, "--repo-root", target, "--check")
            result = run(sys.executable, IMPORTER, "--repo-root", target, "--check",
                         "--source", source, ok=False)
            self.assertIn("does not match committed source", result.stderr)


if __name__ == "__main__":
    unittest.main()
