"""Exercise pinned skill imports through their public CLI in disposable repos."""

import hashlib
import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path
from urllib.parse import parse_qs, urlparse


SCRIPT = Path(__file__).resolve().parents[1] / "scripts/vendor-t3code-skills.py"
APP = ".agents/skills/test-t3-app"
EFFECT = ".repos/effect-smol/.agents/skills/test-development"


class T3CodeSyncTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name) / "harness"
        self.source = Path(self.temp.name) / "upstream"
        self.repo.mkdir()
        self.source.mkdir()
        self.write(self.repo, ".claude-plugin/plugin.json", '{"skills":["./tdd/"]}\n')
        self.write(self.repo, "tdd/SKILL.md", "Existing TDD owner\n")
        self.write(self.source, "LICENSE", "MIT\nCopyright T3 fixture\n")
        self.write(self.source, ".repos/effect-smol/LICENSE", "MIT\nCopyright Effect fixture\n")
        for path, name in [(APP, "test-t3-app"), (EFFECT, "test-development")]:
            self.write(self.source, f"{path}/SKILL.md", f"---\nname: {name}\ndescription: Fixture workflow.\n---\nInstructions.\n")
        self.write(self.source, f"{EFFECT}/types.md", "Compiler contract examples\n")
        helper = self.write(self.source, f"{APP}/scripts/fixture.sh", "#!/bin/sh\nprintf 'fixture evidence\\n'\n")
        helper.chmod(0o755)
        self.write(self.source, "CONTRIBUTING.md", "Read [policy](docs/policy.md).\n")
        self.write(self.source, "docs/policy.md", "Trusted fixture policy\n")
        self.git("init", "-q")
        self.git("add", ".")
        self.git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.com", "commit", "-qm", "fixture")
        self.revision = self.git("rev-parse", "HEAD").strip()

    def write(self, root, name, content):
        path = root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        return path

    def git(self, *args):
        return subprocess.check_output(["git", "-C", str(self.source), *args], text=True)

    def cli(self, *args):
        return subprocess.run(["python3", str(SCRIPT), "--repo-root", str(self.repo), *args], capture_output=True, text=True, check=False)

    def install(self, revision=None):
        return self.cli("--source", str(self.source), "--revision", revision or self.revision)

    def snapshot(self):
        return {p.relative_to(self.repo).as_posix(): (p.read_bytes(), p.stat().st_mode & 0o777)
                for p in self.repo.rglob("*") if p.is_file()}

    def test_pinned_bytes_resources_modes_and_collision_free_registration(self):
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        lock = json.loads((self.repo / "vendor/t3code-skills.lock.json").read_text())
        self.assertEqual(lock["revision"], self.revision)
        self.assertEqual({s["name"] for s in lock["skills"]}, {"test-t3-app", "test-development"})
        for relative, record in lock["files"].items():
            original = self.source / relative
            copied = self.repo / "vendor/t3code" / relative
            self.assertEqual(copied.read_bytes(), original.read_bytes())
            self.assertEqual(record["sha256"], hashlib.sha256(original.read_bytes()).hexdigest())
            self.assertEqual(copied.stat().st_mode & 0o777, original.stat().st_mode & 0o777)
        self.assertEqual((self.repo / "tdd/SKILL.md").read_text(), "Existing TDD owner\n")
        manifest = json.loads((self.repo / ".claude-plugin/plugin.json").read_text())
        self.assertEqual(set(manifest["skills"]), {"./tdd/", "./t3code-skills/test-t3-app/", "./t3code-skills/test-development/"})
        self.assertTrue((self.repo / f"vendor/t3code/{EFFECT}/types.md").is_file())
        command = self.repo / f"vendor/t3code/{APP}/scripts/fixture.sh"
        self.assertEqual(subprocess.check_output([str(command)], text=True), "fixture evidence\n")
        self.assertEqual(self.cli("--check").returncode, 0)

    def test_refresh_uses_committed_bytes_and_is_idempotent(self):
        first = self.install()
        self.assertEqual(first.returncode, 0, first.stderr)
        self.write(self.source, f"{EFFECT}/types.md", "Uncommitted change is not the pinned revision\n")
        manifest = self.repo / ".claude-plugin/plugin.json"
        manifest.write_text(json.dumps(json.loads(manifest.read_text()), separators=(",", ":")) + "\n")
        before = self.snapshot()
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.snapshot(), before)
        self.assertEqual(self.cli("--check").returncode, 0)

    def test_policy_links_are_pinned_without_importing_the_app(self):
        source = self.source / f"{APP}/SKILL.md"
        source.write_text(source.read_text() + "Read [policy](../../../CONTRIBUTING.md) or [runtime](t3-context://v1/projects/fixture).\n")
        self.write(self.source, "docs/policy.md", "See [examples](examples) or [runtime](t3-context://v1/projects/fixture).\n")
        self.write(self.source, "docs/examples/example.ts", "export const example = 1;\n")
        self.git("add", ".")
        self.git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.com", "commit", "-qm", "linked policy")
        result = self.install(self.git("rev-parse", "HEAD").strip())
        self.assertEqual(result.returncode, 0, result.stderr)
        revision = self.git("rev-parse", "HEAD").strip()
        policy = self.repo / "vendor/t3code/CONTRIBUTING.md"
        self.assertIn(f"https://github.com/pingdotgg/t3code/blob/{revision}/docs/policy.md", policy.read_text())
        self.assertEqual(policy.with_suffix(".md.upstream").read_bytes(), (self.source / "CONTRIBUTING.md").read_bytes())
        self.assertFalse((self.repo / "vendor/t3code/docs/examples/example.ts").exists())

    def test_integrity_failure_blocks_refresh_without_destroying_local_work(self):
        self.assertEqual(self.install().returncode, 0)
        changed = self.repo / f"vendor/t3code/{EFFECT}/types.md"
        changed.write_text("Local work must survive\n")
        before = self.snapshot()
        self.assertNotEqual(self.cli("--check").returncode, 0)
        self.assertNotEqual(self.install().returncode, 0)
        self.assertEqual(self.snapshot(), before)

    def test_rejects_unmanaged_destination(self):
        for path in ["vendor/t3code/notes.txt", "t3code-skills/test-development/SKILL.md"]:
            with self.subTest(path=path):
                self.write(self.repo, path, "Preserve this file\n")
                before = self.snapshot()
                self.assertNotEqual(self.install().returncode, 0)
                self.assertEqual(self.snapshot(), before)
                (self.repo / path).unlink()
                (self.repo / path).parent.rmdir()

    def test_existing_skill_name_collision_preserves_output(self):
        self.write(self.repo, ".claude-plugin/plugin.json",
                   '{"skills":["./tdd/","./test-development/"]}\n')
        self.write(self.repo, "test-development/SKILL.md", "Existing compiler-test owner\n")
        before = self.snapshot()
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("collide with an existing skill", result.stderr)
        self.assertEqual(self.snapshot(), before)

    def test_missing_license_bad_revision_and_symlinks_fail_before_writes(self):
        for revision in ["main", "0" * 40]:
            before = self.snapshot()
            self.assertNotEqual(self.install(revision).returncode, 0)
            self.assertEqual(self.snapshot(), before)
        self.git("rm", ".repos/effect-smol/LICENSE")
        self.git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.com", "commit", "-qm", "missing license")
        self.assertNotEqual(self.install(self.git("rev-parse", "HEAD").strip()).returncode, 0)
        self.git("reset", "--hard", self.revision)
        (self.source / f"{EFFECT}/outside.md").symlink_to("/etc/passwd")
        self.git("add", ".")
        self.git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.com", "commit", "-qm", "symlink")
        before = self.snapshot()
        self.assertNotEqual(self.install(self.git("rev-parse", "HEAD").strip()).returncode, 0)
        self.assertEqual(self.snapshot(), before)

    def test_modes_adapters_and_duplicate_registration_are_checked(self):
        self.assertEqual(self.install().returncode, 0)
        helper = self.repo / f"vendor/t3code/{APP}/scripts/fixture.sh"
        helper.chmod(0o644)
        self.assertNotEqual(self.cli("--check").returncode, 0)

        helper.chmod(0o755)
        self.assertEqual(self.cli("--check").returncode, 0)
        adapter = self.repo / "t3code-skills/test-development/SKILL.md"
        original = adapter.read_text()
        adapter.write_text(original + "Local adaptation belongs in the host contract.\n")
        self.assertNotEqual(self.cli("--check").returncode, 0)
        adapter.write_text(original)
        manifest_path = self.repo / ".claude-plugin/plugin.json"
        manifest = json.loads(manifest_path.read_text())
        manifest["skills"].append("./t3code-skills/test-development/")
        manifest_path.write_text(json.dumps(manifest))
        self.assertNotEqual(self.cli("--check").returncode, 0)

    def test_managed_symlinks_cannot_redirect_writes_outside_the_repo(self):
        outside = Path(self.temp.name) / "outside"
        outside.mkdir()
        (self.repo / "vendor").symlink_to(outside, target_is_directory=True)
        before = self.snapshot()
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(list(outside.iterdir()), [])
        self.assertEqual(self.snapshot(), before)

    def test_unadapted_new_skill_does_not_partially_refresh(self):
        self.assertEqual(self.install().returncode, 0)
        self.write(self.source, ".agents/skills/unreviewed/SKILL.md", "---\nname: unreviewed\ndescription: New upstream capability.\n---\nBody\n")
        self.git("add", ".")
        self.git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.com", "commit", "-qm", "new skill")
        before = self.snapshot()
        result = self.install(self.git("rev-parse", "HEAD").strip())
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Unadapted", result.stderr)
        self.assertEqual(self.snapshot(), before)


class T3PairingHelperTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name)
        subprocess.run(["git", "init", "-q", str(self.repo)], check=True)
        self.helper = SCRIPT.parent.parent / "vendor/t3code/.agents/skills/test-t3-mobile/scripts/pair-client.sh"
        server = self.repo / "apps/server/src/bin.ts"
        server.parent.mkdir(parents=True)
        server.write_text("if (process.env.PAIR_MODE === 'mint-fails') process.exit(1);\n"
                          "console.log('Pair URL: http://127.0.0.1:4312/pair?token=fixture-token');\n")
        self.device = self.repo / "device"
        self.device.write_text("#!/usr/bin/env python3\nimport json, os, sys\n"
                               "from pathlib import Path\n"
                               "Path('device-args.json').write_text(json.dumps(sys.argv[1:]))\n"
                               "sys.exit(1 if os.environ.get('PAIR_MODE') == 'device-fails' else 0)\n")
        self.device.chmod(0o755)

    def invoke(self, mode="success"):
        return subprocess.run(["bash", str(self.helper), "4312", str(self.repo / "state"),
                               "http://127.0.0.1:4312", str(self.device), "--device", "fixture-device"],
                              cwd=self.repo, env={**os.environ, "PAIR_MODE": mode},
                              capture_output=True, text=True, check=False)

    def test_pairing_route_preserves_target_and_hides_credential(self):
        result = self.invoke()
        self.assertEqual(result.returncode, 0, result.stderr)
        arguments = json.loads((self.repo / "device-args.json").read_text())
        self.assertEqual(arguments[:2], ["open", "com.t3tools.t3code.dev"])
        self.assertEqual(arguments[3:], ["--device", "fixture-device"])
        route = urlparse(arguments[2])
        self.assertEqual((route.scheme, route.netloc, route.path), ("t3code-dev", "connections", "/new"))
        self.assertEqual(parse_qs(route.query), {"pairingUrl": ["http://127.0.0.1:4312/pair?token=fixture-token"], "autoConnect": ["1"]})
        self.assertNotIn("fixture-token", result.stdout + result.stderr)

    def test_mint_and_device_failures_stay_visible_without_leaking_credentials(self):
        for mode in ["mint-fails", "device-fails"]:
            with self.subTest(mode=mode):
                result = self.invoke(mode)
                self.assertNotEqual(result.returncode, 0)
                self.assertTrue(result.stderr.strip())
                self.assertNotIn("fixture-token", result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
