"""Public CLI contracts; external model/GitHub boundaries replaced, never called."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


RUNNER = Path(__file__).with_name("codex_review.py")


class ReviewCliTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name)
        self.bin = self.repo / "bin"
        self.bin.mkdir()
        self.env = {
            **os.environ, "PATH": f"{self.bin}:{os.environ['PATH']}",
            "GIT_CONFIG_GLOBAL": os.devnull, "GIT_CONFIG_NOSYSTEM": "1",
        }
        self.env["FAKE_CALLS"] = str(self.repo / "calls.jsonl")
        self.env["FAKE_REVIEW"] = str(self.repo / "response.json")
        self.write_response({"summary": "No actionable regressions found.", "findings": []})
        self.tool("codex", """
import json, os, pathlib, signal, subprocess, sys
args = sys.argv[1:]
with open(os.environ['FAKE_CALLS'], 'a') as f:
    f.write(json.dumps({'tool': 'codex', 'args': args}) + '\\n')
if os.environ.get('FAKE_MODE') == 'no-output':
    sys.exit(0)
pathlib.Path(args[args.index('--output-last-message') + 1]).write_text(
    pathlib.Path(os.environ['FAKE_REVIEW']).read_text())
mode = os.environ.get('FAKE_MODE')
if mode == 'dirty':
    pathlib.Path('tracked.txt').write_text('changed during review')
elif mode == 'move-head':
    subprocess.run(['git', 'commit', '--allow-empty', '-qm', 'test(fixture): concurrent change'], check=True)
elif mode == 'hang':
    child = subprocess.Popen([sys.executable, '-c', 'import signal; signal.pause()'])
    pathlib.Path('.context/child.pid').write_text(str(child.pid))
    signal.pause()
sys.exit(int(os.environ.get('FAKE_EXIT', '0')))
""")
        self.git("init", "-q")
        self.git("config", "user.name", "Fixture")
        self.git("config", "user.email", "fixture@example.test")
        (self.repo / "tracked.txt").write_text("base\n")
        (self.repo / ".gitignore").write_text("bin/\ncalls.jsonl\nresponse.json\n.context/\n")
        self.git("add", ".")
        self.git("commit", "-qm", "test(fixture): base snapshot")
        self.git("branch", "base")
        (self.repo / "tracked.txt").write_text("candidate\n")
        self.git("commit", "-qam", "test(fixture): candidate snapshot")
        self.configure_pr()

    def configure_pr(self, **changes):
        self.env["FAKE_PR"] = json.dumps({
            "state": "OPEN", "headRefOid": self.git("rev-parse", "HEAD"),
            "baseRefOid": self.git("rev-parse", "base"),
            "url": "https://github.com/sample/repo/pull/17", **changes,
        })
        self.tool("gh", """
import json, os, pathlib, sys
args = sys.argv[1:]
with open(os.environ['FAKE_CALLS'], 'a') as f:
    f.write(json.dumps({'tool': 'gh', 'args': args}) + '\\n')
if args[:2] == ['pr', 'view']:
    calls = [json.loads(line) for line in pathlib.Path(os.environ['FAKE_CALLS']).read_text().splitlines()]
    views = sum(c['args'][:2] == ['pr', 'view'] for c in calls)
    print(os.environ.get('FAKE_PR_AFTER', os.environ['FAKE_PR']) if views > 1 else os.environ['FAKE_PR'])
elif args[:2] == ['pr', 'comment']:
    pathlib.Path('.context/posted.md').write_text(
        pathlib.Path(args[args.index('--body-file') + 1]).read_text())
    sys.exit(int(os.environ.get('FAKE_POST_EXIT', '0')))
else:
    sys.exit(9)
""")

    def git(self, *args):
        return subprocess.check_output(["git", *args], cwd=self.repo, env=self.env, text=True).strip()

    def tool(self, name, source):
        path = self.bin / name
        path.write_text(f"#!{sys.executable}\n" + source)
        path.chmod(0o755)

    def write_response(self, response):
        (self.repo / "response.json").write_text(json.dumps(response))

    def run_cli(self, *args):
        (self.repo / "calls.jsonl").unlink(missing_ok=True)
        return subprocess.run(
            [sys.executable, str(RUNNER), "--base", "base", *args],
            cwd=self.repo, env=self.env, text=True, capture_output=True, timeout=10,
        )

    def calls(self):
        path = self.repo / "calls.jsonl"
        return [json.loads(line) for line in path.read_text().splitlines()] if path.exists() else []

    def reports(self):
        return list(self.repo.glob(".context/codex-review/*/review.md"))

    def test_local_review_captures_advisory_report_without_posting(self):
        result = self.run_cli()
        self.assertEqual(result.returncode, 0, result.stderr)
        report, = self.reports()
        for artifact in report.parent.iterdir():
            self.assertEqual(artifact.stat().st_mode & 0o777, 0o600)
        text = report.read_text()
        self.assertIn("## 🤖 Codex review", text)
        self.assertIn("P0=0 · P1=0 · P2=0 · P3=0", text)
        self.assertIn("No actionable regressions found.", text)
        self.assertIn(self.git("rev-parse", "HEAD"), text)
        self.assertIn("advisory", text.lower())
        self.assertEqual([call["tool"] for call in self.calls()], ["codex"])
        args = self.calls()[0]["args"]
        self.assertEqual(args[args.index("--sandbox") + 1], "read-only")
        self.assertEqual(args[args.index("--base") + 1], self.git("rev-parse", "base"))
        self.assertEqual(args[args.index("--model") + 1], "gpt-6-astra")
        self.assertIn('model_reasoning_effort="high"', args)

    def test_explicit_post_publishes_one_complete_counted_report(self):
        self.configure_pr()
        self.write_response({"summary": "Two regressions.", "findings": [
            {"priority": 1, "title": "Preserve authorization", "body": "Missing permission guard.",
             "file": "src/api.ts", "line": 12},
            {"priority": 2, "title": "Clear stale state", "body": "Body mentions [P0], not another finding.",
             "file": "src/form.ts", "line": 8},
        ]})
        result = self.run_cli("--post", "--pr", "17", "--repo", "sample/repo",
                              "--profile", "team-review", "--model", "chosen-model")
        self.assertEqual(result.returncode, 0, result.stderr)
        report, = self.reports()
        text = report.read_text()
        self.assertEqual((self.repo / ".context/posted.md").read_text(), text)
        self.assertIn("P0=0 · P1=1 · P2=1 · P3=0", text)
        self.assertIn("[P1] Preserve authorization", text)
        self.assertIn("`src/form.ts:8`", text)
        self.assertIn("chosen-model", text)
        self.assertIn("team-review", text)
        calls = self.calls()
        self.assertEqual(sum(c["tool"] == "codex" for c in calls), 1)
        comments = [c for c in calls if c["args"][:2] == ["pr", "comment"]]
        self.assertEqual(len(comments), 1)
        self.assertIn("https://github.com/sample/repo/pull/17", comments[0]["args"])

    def assert_not_posted(self):
        self.assertFalse((self.repo / ".context/posted.md").exists())
        self.assertFalse(any(c["args"][:2] == ["pr", "comment"] for c in self.calls()))

    def test_failed_review_does_not_post_or_retry_with_another_provider(self):
        self.configure_pr()
        self.env["FAKE_EXIT"] = "7"
        result = self.run_cli("--post", "--pr", "17")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("codex failed (exit 7)", result.stderr)
        self.assertEqual(sum(c["tool"] == "codex" for c in self.calls()), 1)
        self.assertEqual(self.reports(), [])
        self.assert_not_posted()

    def test_empty_malformed_or_invalid_reviews_never_become_clean_comments(self):
        self.configure_pr()
        finding = {"priority": 1, "title": "Bug", "body": "Evidence", "file": "src/a.ts", "line": 1}
        for response in ("", "not JSON", "{}", '{"summary":" ","findings":[]}',
                         json.dumps({"summary": "Oops", "findings": [{**finding, "priority": True}]}),
                         json.dumps({"summary": "Oops", "findings": [{**finding, "line": 0}]}),
                         json.dumps({"summary": "Oops", "findings": [{**finding, "file": "../secret"}]})):
            with self.subTest(response=response):
                (self.repo / "response.json").write_text(response)
                result = self.run_cli("--post", "--pr", "17")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("review", result.stderr.lower())
                self.assertEqual(self.reports(), [])
                self.assert_not_posted()

    def test_missing_final_output_cannot_repost_a_previous_success(self):
        result = self.run_cli()
        self.assertEqual(result.returncode, 0, result.stderr)
        previous, = self.reports()
        self.env["FAKE_MODE"] = "no-output"
        result = self.run_cli("--post", "--pr", "17")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Missing, empty, or invalid review output", result.stderr)
        self.assertEqual(self.reports(), [previous])
        self.assertEqual(sum(c["tool"] == "codex" for c in self.calls()), 1)
        self.assert_not_posted()

    def test_closed_or_wrong_snapshot_pr_is_rejected_before_model_call(self):
        for change in ({"state": "MERGED"}, {"headRefOid": "0" * 40}, {"baseRefOid": "0" * 40}):
            with self.subTest(change=change):
                self.configure_pr(**change)
                result = self.run_cli("--post", "--pr", "17")
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(sum(c["tool"] == "codex" for c in self.calls()), 0)
                self.assert_not_posted()

    def test_local_or_remote_changes_during_review_prevent_posting(self):
        self.configure_pr()
        for mode in ("dirty", "move-head", "remote"):
            with self.subTest(mode=mode):
                head = self.git("rev-parse", "HEAD")
                self.env["FAKE_MODE"] = mode
                self.env["FAKE_PR_AFTER"] = json.dumps({"state": "OPEN", "headRefOid": "0" * 40})
                result = self.run_cli("--post", "--pr", "17")
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(sum(c["tool"] == "codex" for c in self.calls()), 1)
                self.assert_not_posted()
                self.git("reset", "--hard", head)

    def test_dirty_worktree_or_unpaired_post_flags_fail_before_external_calls(self):
        for args in (("--post",), ("--pr", "17"), ("--repo", "sample/repo")):
            with self.subTest(args=args):
                result = self.run_cli(*args)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.calls(), [])
        (self.repo / "tracked.txt").write_text("not committed")
        result = self.run_cli()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("clean committed snapshot", result.stderr)
        self.assertEqual(self.calls(), [])

    def test_empty_model_or_profile_cannot_silently_use_saved_defaults(self):
        for args in (("--model", ""), ("--profile", "")):
            with self.subTest(args=args):
                result = self.run_cli(*args)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.calls(), [])

    def test_missing_gh_keeps_review_unstarted_and_failure_visible(self):
        self.tool("gh", "import sys; sys.exit(4)\n")
        result = self.run_cli("--post", "--pr", "17")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("gh failed (exit 4)", result.stderr)
        self.assertEqual(self.calls(), [])
        self.assert_not_posted()

    def test_uncertain_post_is_not_retried_and_preserves_report(self):
        self.configure_pr()
        self.env["FAKE_POST_EXIT"] = "1"
        result = self.run_cli("--post", "--pr", "17")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("outcome may be unknown", result.stderr)
        self.assertEqual(len(self.reports()), 1)
        self.assertEqual(sum(c["args"][:2] == ["pr", "comment"] for c in self.calls()), 1)

    def test_timeout_kills_review_descendants_and_does_not_post(self):
        self.configure_pr()
        self.env["FAKE_MODE"] = "hang"
        result = self.run_cli("--post", "--pr", "17", "--timeout", "1")
        child = int((self.repo / ".context/child.pid").read_text())
        state = subprocess.run(["ps", "-o", "stat=", "-p", str(child)], capture_output=True, text=True).stdout.strip()
        if state and not state.startswith("Z"):
            subprocess.run(["kill", "-KILL", str(child)], check=True)
        self.assertTrue(not state or state.startswith("Z"), f"review child still running: {state}")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("timed out", result.stderr)
        self.assertEqual(self.reports(), [])
        self.assert_not_posted()


if __name__ == "__main__":
    unittest.main()
