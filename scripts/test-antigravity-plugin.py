#!/usr/bin/env python3
"""Exercise the staged plugin and its command-hook protocol without credentials."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
import uuid

ROOT = Path(__file__).resolve().parents[1]


class PluginTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        scratch = tempfile.TemporaryDirectory()
        cls.addClassCleanup(scratch.cleanup)
        cls.root = Path(scratch.name).resolve()
        cls.workspace = cls.root / "a workspace"
        cls.workspace.mkdir()
        subprocess.run(["git", "init", "-q", str(cls.workspace)], check=True)
        (cls.workspace / "package.json").write_text('{"dependencies":{"react":"19.0.0"}}')
        cls.bundle = cls.root / "plugin"
        subprocess.run([sys.executable, str(ROOT / "scripts/build-antigravity-plugin.py"),
                        str(cls.bundle)], check=True)
        cls.hooks = json.loads((cls.bundle / "hooks.json").read_text())["frontend-skills"]

    def setUp(self):
        self.conversation = str(uuid.uuid4())
        key = hashlib.sha256(f"{self.conversation}\n{self.workspace}".encode()).hexdigest()[:24]
        self.addCleanup(shutil.rmtree, Path("/tmp") / f"hook-session-agy-{key}", True)

    def call(self, event, tool=None, **kwargs):
        rule = self.hooks[event][0]
        command = (rule["hooks"][0] if tool else rule)["command"]
        payload = {
            "conversationId": self.conversation, "workspacePaths": [str(self.workspace)], **kwargs,
        }
        if tool:
            payload["toolCall"] = tool
        result = subprocess.run(command, shell=True, input=json.dumps(payload), text=True,
                                capture_output=True, cwd=self.bundle, check=True)
        return json.loads(result.stdout), result.stderr

    def shell(self, command, cwd=None):
        return self.call("PreToolUse", {
            "name": "run_command", "args": {"CommandLine": command, "Cwd": str(cwd or self.workspace)},
        })[0]

    def test_packaged_catalog_and_constraints(self):
        manifest = json.loads((self.bundle / "plugin.json").read_text())
        canonical = json.loads((ROOT / ".claude-plugin/plugin.json").read_text())
        self.assertEqual(manifest["version"], canonical["version"])
        self.assertEqual(len(list(self.bundle.glob("skills/*/SKILL.md"))), len(canonical["skills"]))
        proxies = [path.read_text() for path in self.bundle.glob("skills/*/SKILL.md")]
        self.assertEqual(sum("disable-model-invocation: true" in proxy for proxy in proxies),
                         sum("disable-model-invocation: true" in (ROOT / path / "SKILL.md").read_text()
                             for path in canonical["skills"]))
        reviewer = (self.bundle / "agents/code-reviewer.md").read_text()
        self.assertIn("model: inherit", reviewer)
        self.assertIn("mainAgent: false", reviewer)
        self.assertNotIn("run_command", reviewer)
        self.assertTrue((self.bundle / "source/tdd/SKILL.md").is_file())
        self.assertFalse(any(path.is_symlink() for path in self.bundle.rglob("*")))

    def test_shell_denial_rewrite_and_allow(self):
        self.assertEqual(self.shell("pwd"), {"decision": "allow"})
        rejected = self.shell("npm test")
        self.assertEqual(rejected["decision"], "deny")
        self.assertIn("npm banned", rejected["reason"])
        rewrite = self.shell("sleep 1 && pwd")
        self.assertEqual(rewrite, {"decision": "allow", "overwrite": {"CommandLine": "pwd"}})
        self.assertEqual(self.shell("pwd", self.root)["decision"], "deny")

    def test_edit_findings_reach_next_invocation(self):
        file = self.workspace / "Widget.tsx"
        content = 'export const Widget = () => <div role="tablist" />;\n'
        file.write_text(content)
        self.addCleanup(file.unlink)
        tool = {"name": "write_to_file", "args": {"TargetFile": str(file), "CodeContent": content}}
        self.assertEqual(self.call("PostToolUse", tool, error="failed")[0], {})
        self.assertEqual(self.call("PostInvocation")[0], {})
        self.assertEqual(self.call("PostToolUse", tool)[0], {})
        self.assertIn('role="tablist"', str(self.call("PostInvocation")[0]).replace("\\", ""))
        self.assertEqual(self.call("PostInvocation")[0], {})

    def test_stop_retry_is_bounded_and_not_requested_for_busy_or_errored_turns(self):
        # Exercise the native retry protocol without running a consumer's build.
        stop = self.bundle / "source/.claude/hooks/stop-dispatch.sh"
        original = stop.read_bytes()
        self.addCleanup(stop.write_bytes, original)
        stop.write_text("#!/bin/sh\necho '{\"reason\":\"fixture quality failure\"}' >&2\nexit 2\n")
        file = self.workspace / "stop-fixture.txt"
        file.touch()
        self.addCleanup(file.unlink)
        self.call("PostToolUse", {"name": "write_to_file", "args": {"TargetFile": str(file)}})
        stopped = {"terminationReason": "model_stop", "fullyIdle": True, "lastUserInput": "implement test"}
        self.assertEqual(self.call("Stop", **{**stopped, "fullyIdle": False})[0], {})
        self.assertEqual(self.call("Stop", **{**stopped, "terminationReason": "error"})[0], {})
        result, _ = self.call("Stop", **stopped)
        self.assertEqual(result, {"decision": "continue", "reason": "fixture quality failure"})
        result, log = self.call("Stop", **stopped)
        self.assertEqual(result, {})
        self.assertIn("not a pass", log)


if __name__ == "__main__":
    unittest.main()
