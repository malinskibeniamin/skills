"""Public selection contracts; no source-text assertions or native-tool execution claims."""

import json
import subprocess
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "scripts/resolve-t3-context.py"


class ContextTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.manifest = {"name": "example-app", "scripts": {"test": "vitest"}}
        self.write("package.json", json.dumps(self.manifest))

    def write(self, name, value="fixture\n"):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(value)
        return path

    def t3(self):
        self.manifest = {"name": "@t3tools/monorepo", "scripts": {"check:changed": "node scripts/check-changed.ts"}}
        self.write("package.json", json.dumps(self.manifest))
        for name in ("apps/server/package.json", "scripts/dev-runner.ts", "AGENTS.md"):
            self.write(name)

    def cli(self, entrypoint, *args):
        return subprocess.run(["python3", str(SCRIPT), "--root", str(self.root),
                               "--entrypoint", entrypoint, *args], capture_output=True, text=True, check=False)

    def result(self, entrypoint, *args):
        process = self.cli(entrypoint, *args)
        self.assertEqual(process.returncode, 0, process.stderr)
        return json.loads(process.stdout)

    def test_normal_entrypoints_select_target_native_verification_without_running_it(self):
        self.t3()
        for entrypoint in ("work", "tdd", "dogfood", "full-send"):
            with self.subTest(entrypoint=entrypoint):
                result = self.result(entrypoint)
                self.assertEqual(result["checkout"], "t3code")
                self.assertEqual(result["verification_script"], "check:changed")
                self.assertEqual(result["references"], [str(self.root / "AGENTS.md")])
                self.assertEqual(result["skills"], [])
        # This target command would fail if the resolver executed it.
        self.write("scripts/check-changed.ts", "throw new Error('must not execute')")
        self.assertEqual(self.result("work")["verification_script"], "check:changed")

    def test_dogfood_selects_each_surface_and_reports_missing_tools(self):
        self.t3()
        web = self.result("dogfood", "--surface", "web", "--tool", "preview_status")
        self.assertEqual(web["skills"], ["test-t3-app"])
        self.assertEqual(web["missing"], [])
        mobile = self.result("dogfood", "--surface", "mobile")
        self.assertEqual(mobile["skills"], ["test-t3-mobile"])
        self.assertEqual(mobile["missing"], ["device_list"])
        both = self.result("work", "--surface", "both", "--tool", "device_list")
        self.assertEqual(both["skills"], ["test-t3-app", "test-t3-mobile"])
        self.assertEqual(both["missing"], ["preview_status"])

    def test_generic_repos_and_name_only_lookalikes_do_not_load_t3_skills(self):
        for name in ("example-app", "@t3tools/monorepo"):
            self.manifest["name"] = name
            self.write("package.json", json.dumps(self.manifest))
            result = self.result("dogfood", "--surface", "both", "--tool", "preview_status", "--tool", "device_list")
            self.assertEqual(result["checkout"], "other")
            self.assertEqual(result["skills"], [])
            self.assertIsNone(result["verification_script"])
            self.assertEqual(result["missing"], [])

    def test_effect_uses_installed_guide_only_when_the_task_needs_it(self):
        guide = self.write("node_modules/effect/AGENTS.md", "Installed version authority\n")
        self.write(".repos/effect-smol/AGENTS.md", "Different pinned version\n")
        self.assertEqual(self.result("work")["references"], [])
        result = self.result("tdd", "--effect")
        self.assertEqual(result["references"], [str(guide)])
        self.assertEqual(result["skills"], ["effect-development"])
        guide.unlink()
        self.assertEqual(self.result("tdd", "--effect")["missing"], ["installed Effect guide/source"])
        source = self.root / "node_modules/effect/src"
        source.mkdir()
        self.assertEqual(self.result("work", "--effect")["references"], [str(source)])

    def test_pr_watch_depends_on_host_and_authorization_not_checkout(self):
        for t3 in (False, True):
            if t3:
                self.t3()
            self.assertEqual(self.result("full-send", "--tool", "watch_pull_request")["pr_watch"], "not-requested")
            self.assertEqual(self.result("full-send", "--babysit")["pr_watch"], "foreground")
            self.assertEqual(self.result("full-send", "--babysit", "--tool", "watch_pull_request")["pr_watch"], "native")

    def test_missing_native_check_does_not_invent_a_command(self):
        self.t3()
        self.manifest["scripts"] = {"test": "do-not-run-full-suite"}
        self.write("package.json", json.dumps(self.manifest))
        result = self.result("work")
        self.assertIsNone(result["verification_script"])
        self.assertEqual(result["missing"], ["check:changed script"])

    def test_malformed_manifests_and_invalid_authorization_fail_visibly(self):
        for value in ("{broken", "[]", '{"scripts": []}'):
            self.write("package.json", value)
            result = self.cli("work")
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(result.stdout, "")
            self.assertIn("T3 context:", result.stderr)
        self.write("package.json", json.dumps(self.manifest))
        result = self.cli("tdd", "--babysit")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("full-send", result.stderr)

    def test_root_must_be_a_directory(self):
        process = subprocess.run(["python3", str(SCRIPT), "--root", str(self.root / "package.json"),
                                  "--entrypoint", "work"], capture_output=True, text=True, check=False)
        self.assertNotEqual(process.returncode, 0)
        self.assertEqual(process.stdout, "")
        self.assertIn("directory", process.stderr)


if __name__ == "__main__":
    unittest.main()
