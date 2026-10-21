"""Exercise the watcher CLI against committed trees, not source-text assertions."""

import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "scripts/watch-t3code-harness.py"
CONFIG = "config/t3code-harness-watch.json"
REPORT = "reports/t3code-harness-watch.md"
SKILL = ".agents/skills/example/SKILL.md"


class HarnessWatchTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / "upstream"
        self.repo = self.root / "local"
        for root in (self.source, self.repo):
            root.mkdir()
            self.git(root, "init", "-q")
            self.git(root, "config", "user.name", "Fixture")
            self.git(root, "config", "user.email", "fixture@example.com")
        self.write(self.source, SKILL, "Fixture skill\n")
        self.write(self.source, "AGENTS.md", "Fixture harness rules\n")
        self.write(self.source, "app.ts", "Initial application\n")
        self.baseline = self.commit(self.source)
        self.write(self.repo, CONFIG, json.dumps({"schema_version": 1, "baseline_revision": self.baseline}) + "\n")
        self.local_head = self.commit(self.repo)

    def write(self, root, relative, text):
        path = root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
        return path

    def git(self, root, *args):
        return subprocess.check_output(["git", "-C", str(root), *args], text=True).strip()

    def commit(self, root):
        self.git(root, "add", ".")
        self.git(root, "commit", "-qm", "fixture")
        return self.git(root, "rev-parse", "HEAD")

    def cli(self, revision, *args, env=None):
        return subprocess.run(["python3", str(SCRIPT), "--repo-root", str(self.repo),
                               "--source", str(self.source), "--revision", revision, *args],
                              capture_output=True, text=True, env=env, check=False)

    def result(self, revision, *args, env=None):
        result = self.cli(revision, *args, env=env)
        self.assertEqual(result.returncode, 0, result.stderr)
        return json.loads(result.stdout)

    def transport(self, **overrides):
        state = {"base": self.local_head, "pulls": [], "refs": [], "calls": []}
        state.update(overrides)
        self.state = self.root / "github.json"
        self.state.write_text(json.dumps(state))
        executable = self.write(self.root, "bin/gh", """#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
file = Path(os.environ['FAKE_GITHUB_STATE'])
state = json.loads(file.read_text())
args = sys.argv[1:]
method = args[args.index('--method') + 1]
route = args[args.index('--hostname') + 2]
payload = json.load(sys.stdin) if '--input' in args else None
state['calls'].append({'method': method, 'route': route, 'payload': payload})
result = None
failure = state.get('failure') == route and method == state.get('failure_method', 'POST')
if method == 'GET':
    if '/pulls?' in route:
        result = [[], state['pulls']]
    elif '/pulls/' in route:
        result = next(p for p in state['pulls'] if str(p['number']) == route.rsplit('/', 1)[1])
        if state.get('readback_not_draft'):
            result['draft'] = False
    elif '/git/ref/' in route:
        result = {'object': {'sha': state['base']}}
    elif '/git/commits/' in route:
        result = {'tree': {'sha': '1' * 40}}
    elif '/git/matching-refs/' in route:
        result = state['refs']
    elif route == 'repos/fixture/skills':
        result = {'full_name': 'fixture/skills', 'default_branch': 'main'}
    else:
        raise SystemExit('Unknown GET endpoint: ' + route)
elif route.endswith('/git/trees'):
    result = {'sha': '2' * 40}
elif route.endswith('/git/commits'):
    result = {'sha': '3' * 40}
    if state.get('base_moves'):
        state['base'] = '9' * 40
elif route.endswith('/git/refs'):
    result = payload
    state['refs'].append({'ref': payload['ref'], 'object': {'sha': payload['sha']}})
elif route.endswith('/pulls'):
    branch = payload['head']
    result = {'number': 7, 'html_url': 'https://github.com/fixture/skills/pull/7',
              'state': 'open', 'draft': payload['draft'], 'body': payload['body'],
              'head': {'ref': branch, 'sha': '3' * 40, 'repo': {'full_name': 'fixture/skills'}},
              'base': {'ref': payload['base']}}
    if not failure or state.get('save_before_error'):
        state['pulls'].append(result)
else:
    raise SystemExit('Unexpected API call: ' + route)
file.write_text(json.dumps(state))
if failure:
    raise SystemExit('Fixture remote failure')
print(json.dumps(result))
""")
        executable.chmod(0o755)
        return {**os.environ, "PATH": f"{executable.parent}:{os.environ['PATH']}",
                "FAKE_GITHUB_STATE": str(self.state)}

    def published(self):
        return json.loads(self.state.read_text())

    def changed_revision(self):
        self.write(self.source, SKILL, "Meaningful fixture update\n")
        return self.commit(self.source)

    def test_publish_creates_only_review_files_and_a_draft_then_deduplicates(self):
        revision = self.changed_revision()
        env = self.transport()
        result = self.result(revision, "--publish", "--repository", "fixture/skills", env=env)
        self.assertEqual(result["status"], "published")
        self.assertEqual(result["url"], "https://github.com/fixture/skills/pull/7")
        calls = self.published()["calls"]
        writes = [call for call in calls if call["method"] == "POST"]
        self.assertEqual([call["route"].rsplit("/", 1)[1] for call in writes], ["trees", "commits", "refs", "pulls"])
        entries = {entry["path"]: entry for entry in writes[0]["payload"]["tree"]}
        self.assertEqual(set(entries), {CONFIG, REPORT})
        self.assertEqual(writes[0]["payload"]["base_tree"], "1" * 40)
        self.assertEqual(json.loads(entries[CONFIG]["content"])["baseline_revision"], revision)
        self.assertIn(revision, entries[REPORT]["content"])
        self.assertEqual(writes[1]["payload"]["parents"], [self.local_head])
        self.assertIs(writes[-1]["payload"]["draft"], True)
        self.assertEqual(writes[-1]["payload"]["base"], "main")
        # A maintainer edits the proposal; later app-only churn must not overwrite it.
        state = self.published()
        state["pulls"][0]["body"] = "Maintainer-owned review notes"
        state["pulls"][0]["head"]["sha"] = "4" * 40
        self.state.write_text(json.dumps(state))
        self.write(self.source, "app.ts", "Later app-only change\n")
        repeated = self.result(self.commit(self.source), "--publish", "--repository", "fixture/skills", env=env)
        self.assertEqual(repeated["status"], "existing")
        self.assertEqual(len([c for c in self.published()["calls"] if c["method"] == "POST"]), 4)
        self.assertEqual(self.published()["pulls"][0]["body"], "Maintainer-owned review notes")
        self.assertEqual(self.published()["pulls"][0]["head"]["sha"], "4" * 40)
        self.assertEqual(self.git(self.repo, "status", "--porcelain"), "")

    def test_inventory_includes_new_removed_helpers_modes_policies_and_symlinks(self):
        (self.source / SKILL).unlink()
        helper = self.write(self.source, ".agents/hooks/check.sh", "exit 99\n")
        self.write(self.source, ".repos/effect-smol/.agents/skills/new/SKILL.md", "New skill\n")
        self.write(self.source, ".codex/config.toml", "[agents]\n")
        self.write(self.source, "LICENSE", "New terms\n")
        (self.source / ".claude").symlink_to("/never-follow-this-path")
        revision = self.commit(self.source)
        changes = {item["path"]: (item["change"], item["category"]) for item in self.result(revision)["changes"]}
        self.assertEqual(changes[SKILL], ("removed", "skill"))
        self.assertEqual(changes[".repos/effect-smol/.agents/skills/new/SKILL.md"], ("added", "skill"))
        self.assertEqual(changes[".claude"], ("added", "harness"))
        self.assertEqual(changes["LICENSE"], ("added", "license"))
        self.assertIn(".codex/config.toml", changes)
        helper.chmod(0o755)
        mode_revision = self.commit(self.source)
        mode_changes = self.result(mode_revision)
        self.assertNotEqual(mode_changes["fingerprint"], self.result(revision)["fingerprint"])
        self.assertIn(".agents/hooks/check.sh", [item["path"] for item in mode_changes["changes"]])
        # App commits do not change the deduplication identity.
        self.write(self.source, "app.ts", "App again\n")
        self.assertEqual(self.result(self.commit(self.source))["fingerprint"], mode_changes["fingerprint"])

    def test_untrusted_filenames_cannot_inject_report_markup(self):
        self.write(self.source, ".agents/<script>|`bad`\nname.md", "Never render upstream content\n")
        result = self.result(self.commit(self.source))
        self.assertNotIn("<script>", result["report"])
        self.assertNotIn("Never render upstream content", result["report"])
        self.assertIn("%3Cscript%3E", result["report"])

    def test_mutable_or_missing_revision_fails_without_output(self):
        for revision in ("main", "--help", "a" * 40):
            with self.subTest(revision=revision):
                result = self.cli(revision)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(result.stdout, "")

    def test_pending_or_dismissed_proposals_are_preserved_without_writes(self):
        revision = self.changed_revision()
        fingerprint = self.result(revision)["fingerprint"]
        for state, branch, expected in [
            ("open", "different", "deferred"),
            ("closed", fingerprint, "dismissed"),
        ]:
            with self.subTest(state=state):
                pr = {"state": state, "html_url": "https://github.com/fixture/skills/pull/2",
                      "head": {"repo": {"full_name": "fixture/skills"}, "ref": "ben-malinski/t3-harness/" + branch}}
                env = self.transport(pulls=[pr])
                result = self.result(revision, "--publish", "--repository", "fixture/skills", env=env)
                self.assertEqual(result["status"], expected)
                self.assertFalse(any(c["method"] != "GET" for c in self.published()["calls"]))

    def test_stale_checkout_and_existing_orphan_ref_fail_without_writes(self):
        revision = self.changed_revision()
        branch = "ben-malinski/t3-harness/" + self.result(revision)["fingerprint"]
        for override, message in [
            ({"base": "4" * 40}, "fresh trusted checkout"),
            ({"refs": [{"ref": "refs/heads/" + branch, "object": {"sha": "5" * 40}}]}, "never overwrite"),
        ]:
            with self.subTest(override=override):
                env = self.transport(**override)
                result = self.cli(revision, "--publish", "--repository", "fixture/skills", env=env)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(message, result.stderr)
                self.assertFalse(any(c["method"] != "GET" for c in self.published()["calls"]))

    def test_mismatched_readback_is_not_reported_as_success(self):
        revision = self.changed_revision()
        env = self.transport(readback_not_draft=True)
        result = self.cli(revision, "--publish", "--repository", "fixture/skills", env=env)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("readback", result.stderr)
        self.assertEqual(result.stdout, "")

    def test_oversized_report_fails_before_publication(self):
        for index in range(140):
            self.write(self.source, f".agents/skills/new-{index}/" + "x" * 150 + ".md", "Fixture instructions\n")
        revision = self.commit(self.source)
        env = self.transport()
        result = self.cli(revision, "--publish", "--repository", "fixture/skills", env=env)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("size limit", result.stderr)
        self.assertEqual(self.published()["calls"], [])

    def test_remote_failure_and_base_race_do_not_create_a_ref(self):
        revision = self.changed_revision()
        for override in ({"failure": "repos/fixture/skills/pulls?state=all&per_page=100", "failure_method": "GET"},
                         {"base_moves": True}):
            with self.subTest(override=override):
                env = self.transport(**override)
                result = self.cli(revision, "--publish", "--repository", "fixture/skills", env=env)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.published()["refs"], [])
                self.assertEqual(result.stdout, "")

    def test_failed_publication_is_visible_and_uncertain_create_is_read_back(self):
        revision = self.changed_revision()
        for saved in (False, True):
            with self.subTest(saved=saved):
                env = self.transport(failure="repos/fixture/skills/pulls", save_before_error=saved)
                result = self.cli(revision, "--publish", "--repository", "fixture/skills", env=env)
                if saved:
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(json.loads(result.stdout)["status"], "published")
                else:
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn("Publication not confirmed", result.stderr)
                    self.assertEqual(result.stdout, "")
                writes = [c for c in self.published()["calls"] if c["method"] != "GET"]
                self.assertEqual(len(writes), 4, "Uncertain writes must not be replayed")

    def test_app_changes_are_ignored_but_committed_harness_change_is_reported(self):
        self.write(self.source, "app.ts", "Application-only change\n")
        app_revision = self.commit(self.source)
        self.assertEqual(self.result(app_revision)["status"], "unchanged")
        self.write(self.source, SKILL, "Changed harness instructions\n")
        revision = self.commit(self.source)
        self.write(self.source, SKILL, "Dirty bytes must not be used\n")
        before = self.git(self.repo, "status", "--porcelain")
        report = self.result(revision)
        self.assertEqual(report["status"], "changed")
        self.assertEqual(report["changes"], [{"path": SKILL, "change": "modified", "category": "skill"}])
        self.assertIn(revision, report["report"])
        self.assertNotIn("Dirty bytes", report["report"])
        self.assertEqual(self.git(self.repo, "status", "--porcelain"), before)
        self.assertFalse((self.repo / REPORT).exists(), "Dry-run must not modify tracked files")


if __name__ == "__main__":
    unittest.main()
