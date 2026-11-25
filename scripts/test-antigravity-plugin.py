#!/usr/bin/env python3
"""Exercise the Antigravity plugin builder and ACP/IDE hook protocol without credentials."""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
import uuid

ROOT = Path(__file__).resolve().parents[1]


def load_builder():
    spec = importlib.util.spec_from_file_location(
        "build_antigravity_plugin", ROOT / "scripts/build-antigravity-plugin.py"
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class PluginTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.builder = load_builder()
        scratch = tempfile.TemporaryDirectory()
        cls.addClassCleanup(scratch.cleanup)
        cls.root = Path(scratch.name).resolve()
        cls.workspace = cls.root / "a workspace"
        cls.workspace.mkdir()
        subprocess.run(["git", "init", "-q", str(cls.workspace)], check=True)
        (cls.workspace / "package.json").write_text(
            '{"dependencies":{"react":"19.0.0"},"scripts":{"test":"vitest"}}'
        )
        cls.bundle = cls.root / "plugin"
        subprocess.run(
            [
                sys.executable,
                str(ROOT / "scripts/build-antigravity-plugin.py"),
                "--verify",
                str(cls.bundle),
            ],
            check=True,
        )
        cls.hooks = json.loads((cls.bundle / "hooks.json").read_text())["frontend-skills"]

    def setUp(self):
        self.conversation = str(uuid.uuid4())
        key = hashlib.sha256(f"{self.conversation}\n{self.workspace}".encode()).hexdigest()[:24]
        self.addCleanup(shutil.rmtree, Path("/tmp") / f"hook-session-agy-{key}", True)

    def call(self, event, tool=None, **kwargs):
        rule = self.hooks[event][0]
        command = (rule["hooks"][0] if tool else rule)["command"]
        payload = {
            "conversationId": self.conversation,
            "workspacePaths": [str(self.workspace)],
            **kwargs,
        }
        if tool:
            payload["toolCall"] = tool
        result = subprocess.run(
            command,
            shell=True,
            input=json.dumps(payload),
            text=True,
            capture_output=True,
            cwd=self.bundle,
            check=True,
            env={**os.environ, "HOOK_SESSION_SWEEP_DISABLED": "1"},
        )
        return json.loads(result.stdout), result.stderr

    def shell_ide(self, command, cwd=None):
        return self.call(
            "PreToolUse",
            {"name": "run_command", "args": {"CommandLine": command, "Cwd": str(cwd or self.workspace)}},
        )[0]

    def shell_acp(self, command, cwd=None):
        # Antigravity ACP passes cwd at top level, not inside toolCall.args.
        return self.call(
            "PreToolUse",
            {"name": "run_command", "args": {"CommandLine": command}},
            cwd=str(cwd or self.workspace),
        )[0]

    def test_packaged_catalog_inline_skills_and_profiles(self):
        manifest = json.loads((self.bundle / "plugin.json").read_text())
        canonical = json.loads((ROOT / ".claude-plugin/plugin.json").read_text())
        self.assertEqual(manifest["version"], canonical["version"])
        self.assertEqual(manifest["logo"], "assets/logo.svg")
        self.assertTrue((self.bundle / "assets/logo.svg").is_file())
        self.assertTrue((self.bundle / "rules/AGENTS.md").is_file())
        self.assertTrue((self.bundle / "source/GEMINI.md").is_file())
        self.assertTrue((self.bundle / "source/config/antigravity-model-routing.json").is_file())
        self.assertEqual(len(list(self.bundle.glob("skills/*/SKILL.md"))), len(canonical["skills"]))

        # Verify inline canonical skill body (no double-hop proxy stub) and link integrity.
        tdd = (self.bundle / "skills/tdd/SKILL.md").read_text()
        self.assertNotIn("Read the complete [skill instructions](", tdd)
        self.assertIn("RED", tdd.upper())
        report = self.builder.verify_bundle(self.bundle, profile="core", run_agy=False)
        self.assertTrue(report["ok"], report["errors"])
        self.assertLessEqual(report["auto_desc_chars"], self.builder.CORE_AUTO_DESC_CHAR_CAP)

        # Vendored/other-host adapters stay slash-accessible but manual-only in core profile.
        codex_skill = (self.bundle / "skills/codex/SKILL.md").read_text()
        self.assertIn("disable-model-invocation: true", codex_skill)

        # Subagents expose both ACP and IDE read-only tools without widening shell access.
        reviewer = (self.bundle / "agents/code-reviewer.md").read_text()
        self.assertIn("model: inherit", reviewer)
        self.assertIn("mainAgent: false", reviewer)
        self.assertIn('"read_file"', reviewer)
        self.assertIn('"view_file"', reviewer)
        self.assertNotIn('"run_command"', reviewer)
        self.assertNotIn("Read and follow the complete [agent instructions](", reviewer)

        verifier = (self.bundle / "agents/verifier.md").read_text()
        self.assertIn('"run_command"', verifier)
        self.assertFalse(any(path.is_symlink() for path in self.bundle.rglob("*")))

        # Verify --profile full preserves canonical auto-invocation and --update replaces the bundle.
        full_bundle = self.root / "plugin-full"
        subprocess.run(
            [
                sys.executable,
                str(ROOT / "scripts/build-antigravity-plugin.py"),
                "--profile",
                "full",
                "--verify",
                str(full_bundle),
            ],
            check=True,
        )
        full_report = self.builder.verify_bundle(full_bundle, profile="full", run_agy=False)
        self.assertGreater(full_report["auto_invocable_skills"], report["auto_invocable_skills"])
        subprocess.run(
            [
                sys.executable,
                str(ROOT / "scripts/build-antigravity-plugin.py"),
                "--profile",
                "core",
                "--update",
                "--verify",
                str(full_bundle),
            ],
            check=True,
        )
        updated_report = self.builder.verify_bundle(full_bundle, profile="core", run_agy=False)
        self.assertEqual(updated_report["auto_invocable_skills"], report["auto_invocable_skills"])

    def test_session_start_injects_gemini_calibration(self):
        started, _ = self.call("SessionStart", modelName="gemini-4-neon")
        text = json.dumps(started)
        self.assertIn("model-prompting.md#gemini-4-on-antigravity", text)
        self.assertIn("antigravity-model-routing.json", text)

    def test_pre_invocation_context_and_dedup(self):
        prompt = "Implement pagination for PR #42 and open a draft PR"
        first, _ = self.call(
            "PreInvocation",
            cwd=str(self.workspace),
            initialNumSteps=0,
            lastUserInput=prompt,
        )
        text = json.dumps(first)
        self.assertIn("Branch:", text)
        self.assertIn("Scripts: test", text)
        self.assertIn("PR #42", text)
        # Tool calls advance the trajectory without starting a new user turn.
        second, _ = self.call(
            "PreInvocation",
            cwd=str(self.workspace),
            initialNumSteps=4,
            lastUserInput=prompt,
        )
        self.assertEqual(second, {})
        self.call("Stop", terminationReason="ERROR", fullyIdle=True, lastUserInput=prompt)
        # An idle stop ends the turn, so identical text in the next one is fresh.
        third, _ = self.call(
            "PreInvocation",
            cwd=str(self.workspace),
            initialNumSteps=5,
            lastUserInput=prompt,
        )
        self.assertIn("PR #42", json.dumps(third))

    def test_shell_denial_rewrite_and_allow_for_both_acp_and_ide(self):
        for runner in (self.shell_acp, self.shell_ide):
            self.assertEqual(runner("pwd"), {"decision": "allow"})
            rejected = runner("npm test")
            self.assertEqual(rejected["decision"], "deny")
            self.assertIn("npm banned", rejected["reason"])
            rewrite = runner("sleep 1 && pwd")
            self.assertEqual(rewrite, {"decision": "allow", "overwrite": {"CommandLine": "pwd"}})
            self.assertEqual(runner("pwd", self.root)["decision"], "deny")

    def test_mcp_guard_allows_t3_and_blocks_bloated_mcps(self):
        t3 = self.call(
            "PreToolUse",
            {"name": "mcp_t3-code_preview_open", "args": {"url": "http://localhost:3000"}},
        )[0]
        self.assertEqual(t3, {"decision": "allow"})
        playwright = self.call(
            "PreToolUse",
            {"name": "mcp_playwright_click", "args": {"selector": "button"}},
        )[0]
        self.assertEqual(playwright["decision"], "deny")
        self.assertIn("agent-browser", playwright["reason"])
        jira = self.call(
            "PreToolUse",
            {"name": "mcp_claude_ai_Atlassian_getJiraIssue", "args": {"key": "ABC-1"}},
        )[0]
        self.assertEqual(jira["decision"], "deny")
        self.assertIn("acli", jira["reason"])

    def test_acp_and_ide_edits_enforce_pre_checks_and_surface_post_findings(self):
        file = self.workspace / "Widget.tsx"
        bad_header = "// Copyright 2026 Example Corp\nexport const Widget = () => <div />;\n"
        # ACP write_file PreToolUse catches copyright header.
        denied = self.call(
            "PreToolUse",
            {"name": "write_file", "args": {"Path": str(file), "Content": bad_header}},
        )[0]
        self.assertEqual(denied["decision"], "deny")
        self.assertIn("Copyright", denied["reason"])

        # Clean ACP write_file passes PreToolUse.
        content = 'export const Widget = () => <div role="tablist" />;\n'
        allowed = self.call(
            "PreToolUse",
            {"name": "write_file", "args": {"Path": str(file), "Content": content}},
        )[0]
        self.assertEqual(allowed, {"decision": "allow"})

        # ACP write_file PostToolUse queues a11y diagnostic for PostInvocation.
        file.write_text(content)
        self.addCleanup(file.unlink)
        acp_write = {"name": "write_file", "args": {"Path": str(file), "Content": content}}
        self.assertEqual(self.call("PostToolUse", acp_write, error="failed")[0], {})
        self.assertEqual(self.call("PostInvocation")[0], {})
        self.assertEqual(self.call("PostToolUse", acp_write)[0], {})
        self.assertIn('role="tablist"', str(self.call("PostInvocation")[0]).replace("\\", ""))
        self.assertEqual(self.call("PostInvocation")[0], {})

        # ACP edit_file PostToolUse works with Target/Replacement diff schema.
        acp_edit = {
            "name": "edit_file",
            "args": {
                "Path": str(file),
                "Target": "<div />",
                "Replacement": '<div role="tablist" />',
            },
        }
        self.assertEqual(self.call("PostToolUse", acp_edit)[0], {})
        self.assertIn('role="tablist"', str(self.call("PostInvocation")[0]).replace("\\", ""))

        # IDE write_to_file PostToolUse remains supported.
        ide_write = {"name": "write_to_file", "args": {"TargetFile": str(file), "CodeContent": content}}
        self.assertEqual(self.call("PostToolUse", ide_write)[0], {})
        self.assertIn('role="tablist"', str(self.call("PostInvocation")[0]).replace("\\", ""))

        repaired = """export const Widget = () => <>
  <div role="tablist" aria-label="Sections">
    <button type="button" role="tab" id="tab" aria-controls="panel"
      aria-selected="true">Details</button>
  </div>
  <div role="tabpanel" id="panel" aria-labelledby="tab">Details content</div>
</>;
"""
        file.write_text(repaired)
        ide_write["args"]["CodeContent"] = repaired
        self.assertEqual(self.call("PostToolUse", ide_write), ({}, ""))
        self.assertEqual(self.call("PostInvocation"), ({}, ""))

    def test_ide_multi_edit_checks_all_chunks_without_flagging_retained_lines(self):
        file = self.workspace / "Widget.tsx"
        header = "// Copyright 2026 Example Corp"
        file.write_text("export const Widget = () => <div />;\n// end\n")
        self.addCleanup(file.unlink)
        chunks = [
            {"TargetContent": "<div />", "ReplacementContent": "<div>Updated</div>"},
            {"TargetContent": "// end", "ReplacementContent": "// Copyright 2026 New Corp"},
        ]
        tool = {
            "name": "multi_replace_file_content",
            "args": {"TargetFile": str(file), "ReplacementChunks": chunks},
        }
        denied, _ = self.call("PreToolUse", tool)
        self.assertEqual(denied["decision"], "deny")
        self.assertIn("Copyright", denied["reason"])
        file.write_text(header + "\n" + file.read_text())
        chunks[0] = {"TargetContent": header, "ReplacementContent": header + "\n// retained"}
        chunks[1]["ReplacementContent"] = "export const Footer = () => <div role=\"tablist\" />;"
        self.assertEqual(self.call("PreToolUse", tool), ({"decision": "allow"}, ""))
        file.write_text(f'{chunks[0]["ReplacementContent"]}\n'
                        f'export const Widget = () => <div />;\n{chunks[1]["ReplacementContent"]}\n')
        self.assertEqual(self.call("PostToolUse", tool), ({}, ""))
        diagnostics, _ = self.call("PostInvocation")
        self.assertIn('role="tablist"', str(diagnostics).replace("\\", ""))
        self.assertNotIn("Copyright/license header", str(diagnostics))

    def test_consecutive_shell_failures_escalate_and_reset(self):
        cmd = {"name": "run_command", "args": {"CommandLine": "bun test"}}
        for step in range(3):
            self.call("PreInvocation", lastUserInput="Run the tests", initialNumSteps=step * 3)
            if step:
                self.assertEqual(self.call("PostInvocation")[0], {})
            self.call("PostToolUse", cmd, error="exit status 1")
        note = json.dumps(self.call("PostInvocation")[0])
        self.assertIn("consecutive-failure", note)
        # Success resets the streak.
        self.call("PostToolUse", cmd)
        self.call("PostToolUse", cmd, error="exit status 1")
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
        self.call("PostToolUse", {"name": "write_file", "args": {"Path": str(file), "Content": "ok\n"}})

        # Real Antigravity ACP/CLI/2.0 Stop payload uses NO_TOOL_CALL + continuationActive.
        stopped = {
            "terminationReason": "NO_TOOL_CALL",
            "fullyIdle": True,
            "continuationActive": False,
            "lastUserInput": "implement test",
        }
        self.assertEqual(self.call("Stop", **{**stopped, "fullyIdle": False})[0], {})
        self.assertEqual(self.call("Stop", **{**stopped, "terminationReason": "ERROR"})[0], {})
        self.assertEqual(self.call("Stop", **{**stopped, "terminationReason": "error"})[0], {})
        result, _ = self.call("Stop", **stopped)
        self.assertEqual(result, {"decision": "continue", "reason": "fixture quality failure"})
        # Native continuationActive=True bounds retries at one continuation.
        result, log = self.call("Stop", **{**stopped, "continuationActive": True})
        self.assertEqual(result, {})
        self.assertIn("not a pass", log)

        legacy = {**stopped, "terminationReason": "model_stop"}
        legacy.pop("continuationActive")
        self.call("PreInvocation", lastUserInput=legacy["lastUserInput"], initialNumSteps=1)
        self.assertEqual(self.call("Stop", **legacy)[0]["decision"], "continue")
        self.assertEqual(
            self.call("PreInvocation", lastUserInput=legacy["lastUserInput"], initialNumSteps=2)[0],
            {},
        )
        result, log = self.call("Stop", **legacy)
        self.assertEqual(result, {})
        self.assertIn("not a pass", log)


if __name__ == "__main__":
    unittest.main()
