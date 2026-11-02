"""Public distribution, refresh and self-contained build contracts; no network."""

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
IMPORTER = REPO / "scripts/vendor-stack-diagram.py"
SNAPSHOT = REPO / "vendor/stack-diagram"
SKILL = "skills/stack-diagram"


def run(*args, ok=True):
    result = subprocess.run(list(map(str, args)), capture_output=True, text=True)
    if (result.returncode == 0) != ok:
        raise AssertionError(result.stdout + result.stderr)
    return result


def tree(root):
    return {p.relative_to(root).as_posix(): (p.read_bytes(), p.stat().st_mode & 0o777)
            for p in root.rglob("*") if p.is_file()}


class StackDiagramVendoring(unittest.TestCase):
    def test_installed_discovery_and_resource_closure(self):
        registrations = json.loads((REPO / ".claude-plugin/plugin.json").read_text())["skills"]
        self.assertEqual(registrations.count("./stack-diagram/"), 1)
        proxy = REPO / "codex-skills/stack-diagram/SKILL.md"
        self.assertIn("../../stack-diagram/SKILL.md", proxy.read_text())
        self.assertIn("`/stack-diagram`", (REPO / "ask-ben/SKILL-CATALOG.md").read_text())
        for page in [REPO / "stack-diagram/SKILL.md", REPO / "shared/STACK-DIAGRAM.md"]:
            for link in re.findall(r"\[[^\]]+\]\(([^)]+)\)", page.read_text()):
                if ":" not in link and not link.startswith("#"):
                    target = (page.parent / link.split("#")[0]).resolve()
                    self.assertTrue(target.is_relative_to(REPO), target)
                    self.assertTrue(target.is_file(), target)
        run(sys.executable, IMPORTER, "--check")
        run("bash", REPO / "scripts/generate-skill-catalog.sh", "--check")

    def test_refresh_reads_committed_blobs_and_preserves_drift(self):
        with tempfile.TemporaryDirectory(prefix="stack-diagram-refresh-") as temp:
            root = pathlib.Path(temp)
            source, target = root / "source", root / "target"
            shutil.copytree(SNAPSHOT, source)
            target.mkdir()
            run("git", "init", "-q", source)
            (source / SKILL / "scripts/build.py").chmod(0o755)
            run("git", "-C", source, "add", ".")
            run("git", "-C", source, "-c", "user.name=Fixture", "-c",
                "user.email=fixture@example.invalid", "commit", "-qm", "fixture")
            revision = run("git", "-C", source, "rev-parse", "HEAD").stdout.strip()
            original = (source / SKILL / "SKILL.md").read_bytes()
            (source / SKILL / "SKILL.md").write_text("dirty, not a reviewed input")
            args = (sys.executable, IMPORTER, "--repo-root", target,
                    "--source", source, "--revision", revision)
            run(*args)
            managed = target / "vendor/stack-diagram"
            self.assertEqual((managed / SKILL / "SKILL.md").read_bytes(), original)
            self.assertEqual((managed / SKILL / "scripts/build.py").stat().st_mode & 0o777, 0o755)
            before = tree(target)
            run(*args)
            self.assertEqual(tree(target), before, "identical refresh changed files")
            run(sys.executable, IMPORTER, "--repo-root", target, "--check")
            run(*args[:-1], "HEAD", ok=False)
            self.assertEqual(tree(target), before, "moving ref rejection wrote files")
            victim = managed / SKILL / "SKILL.md"
            victim.write_text("owned local work")
            run(sys.executable, IMPORTER, "--repo-root", target, "--check", ok=False)
            run(*args, ok=False)
            self.assertEqual(victim.read_text(), "owned local work")
            victim.write_bytes(original)
            victim.chmod(0o755)
            run(sys.executable, IMPORTER, "--repo-root", target, "--check", ok=False)
            victim.chmod(0o644)
            victim.unlink()
            victim.symlink_to(source / SKILL / "SKILL.md")
            run(*args, ok=False)
            victim.unlink()
            victim.write_bytes(original)
            extra = managed / "unreviewed.txt"
            extra.write_text("unexpected resource")
            run(sys.executable, IMPORTER, "--repo-root", target, "--check", ok=False)
            extra.unlink()
            (managed / SKILL / "assets/fonts/OFL-Geist.txt").unlink()
            run(*args, ok=False)

    def test_unsafe_or_incomplete_source_writes_nothing(self):
        with tempfile.TemporaryDirectory(prefix="stack-diagram-reject-") as temp:
            root = pathlib.Path(temp)
            source, target = root / "source", root / "target"
            shutil.copytree(SNAPSHOT, source)
            target.mkdir()
            run("git", "init", "-q", source)
            for mutation in ("license", "license-clause", "missing-font", "symlink"):
                license_path = source / "LICENSE"
                license_path.write_text("unreviewed license" if mutation == "license"
                                        else (SNAPSHOT / "LICENSE").read_text())
                if mutation == "license-clause":
                    license_path.write_text((SNAPSHOT / "LICENSE").read_text() + "\nAdditional restriction\n")
                if mutation == "missing-font":
                    (source / SKILL / "assets/fonts/Geist.woff2").unlink()
                elif mutation == "symlink":
                    shutil.copy(SNAPSHOT / SKILL / "assets/fonts/Geist.woff2",
                                source / SKILL / "assets/fonts/Geist.woff2")
                    (source / SKILL / "unsafe").symlink_to("/etc/passwd")
                run("git", "-C", source, "add", ".")
                run("git", "-C", source, "-c", "user.name=Fixture", "-c",
                    "user.email=fixture@example.invalid", "commit", "-qm", mutation)
                revision = run("git", "-C", source, "rev-parse", "HEAD").stdout.strip()
                run(sys.executable, IMPORTER, "--repo-root", target, "--source", source,
                    "--revision", revision, ok=False)
                self.assertEqual(tree(target), {}, "rejected input changed output")

    def test_unmanaged_destination_and_symlinked_parent_are_preserved(self):
        with tempfile.TemporaryDirectory(prefix="stack-diagram-owned-") as temp:
            target = pathlib.Path(temp) / "target"
            destination = target / "vendor/stack-diagram"
            destination.mkdir(parents=True)
            victim = destination / "owned.txt"
            victim.write_text("unmanaged work")
            # A local Git fixture supplies valid committed input, independent of the network.
            source = pathlib.Path(temp) / "source"
            shutil.copytree(SNAPSHOT, source)
            run("git", "init", "-q", source)
            run("git", "-C", source, "add", ".")
            run("git", "-C", source, "-c", "user.name=Fixture", "-c",
                "user.email=fixture@example.invalid", "commit", "-qm", "fixture")
            revision = run("git", "-C", source, "rev-parse", "HEAD").stdout.strip()
            args = (sys.executable, IMPORTER, "--repo-root", target,
                    "--source", source, "--revision", revision)
            before = tree(target)
            run(*args, ok=False)
            self.assertEqual(tree(target), before)
            destination.rename(target / "vendor/owned")
            destination.symlink_to(target / "vendor/owned", target_is_directory=True)
            run(*args, ok=False)
            self.assertEqual(victim.read_text(), "unmanaged work")

    def test_build_embeds_bundled_fonts_and_icon_and_rejects_missing_tokens(self):
        with tempfile.TemporaryDirectory(prefix="stack-diagram-build-") as temp:
            root = pathlib.Path(temp)
            icons = root / "icons"
            icons.mkdir()
            icon = SNAPSHOT / SKILL / "assets/generic/user.svg"
            shutil.copy(icon, icons / "user.svg")
            draft, output = root / "draft.html", root / "out.html"
            draft.write_text('%%FONT_DISPLAY%% %%FONT_JBM%% <img src="%%ICON_user%%">')
            command = (sys.executable, SNAPSHOT / SKILL / "scripts/build.py", draft,
                       icons, output, "--fonts", SNAPSHOT / SKILL / "assets/fonts")
            run(*command)
            built = output.read_text()
            self.assertNotIn("%%", built)
            self.assertIn("data:image/svg+xml;base64,", built)
            before = hashlib.sha256(output.read_bytes()).hexdigest()
            draft.write_text("%%ICON_missing%%")
            result = run(*command, ok=False)
            self.assertIn("unresolved tokens: %%ICON_missing%%", result.stderr)
            self.assertEqual(hashlib.sha256(output.read_bytes()).hexdigest(), before)


if __name__ == "__main__":
    unittest.main()
