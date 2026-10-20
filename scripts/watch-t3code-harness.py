#!/usr/bin/env python3
"""Propose T3 harness reviews from immutable Git trees; never execute upstream code."""

import argparse
import hashlib
import html
import json
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import quote


UPSTREAM = "https://github.com/pingdotgg/t3code"
CONFIG = "config/t3code-harness-watch.json"
REPORT = "reports/t3code-harness-watch.md"
PREFIX = "ben-malinski/t3-harness/"
ROOTS = (".agents", ".claude", ".codex", ".repos/effect-smol/.agents", ".github/triage")
FILES = {"AGENTS.md", "CLAUDE.md", "CONTRIBUTING.md", "LICENSE",
         ".repos/effect-smol/LICENSE", ".github/TRIAGE_EXEMPTIONS.td", "scripts/lib/reference-repos.ts"}


def run(command, **kwargs):
    result = subprocess.run(command, capture_output=True, timeout=90, check=False, **kwargs)
    if result.returncode:
        error = result.stderr.decode(errors="replace") if isinstance(result.stderr, bytes) else result.stderr
        raise ValueError(f"{command[0]} failed: {error.strip()}")
    return result.stdout


def git(root, *args):
    return run(["git", "-C", str(root), *args])


def sha(value):
    if not isinstance(value, str) or not re.fullmatch(r"[0-9a-f]{40}", value):
        raise ValueError("Expected a full lowercase 40-character commit SHA")
    return value


def inventory(source, revision):
    sha(revision)
    if git(source, "rev-parse", "--verify", f"{revision}^{{commit}}").decode().strip() != revision:
        raise ValueError("Revision must identify a commit directly")
    entries = {}
    for record in git(source, "ls-tree", "-r", "-z", revision).split(b"\0"):
        if not record:
            continue
        metadata, raw_path = record.split(b"\t", 1)
        path = raw_path.decode("utf-8")
        if path in FILES or any(path == root or path.startswith(root + "/") for root in ROOTS):
            entries[path] = metadata.decode("ascii")
    if not entries:
        raise ValueError(f"No watched harness inputs at {revision}; refusing an empty baseline")
    return entries


def category(path):
    if "/skills/" in path or path.endswith("/skills"):
        return "skill"
    if path.endswith("LICENSE"):
        return "license"
    return "harness"


def proposal(source, baseline, revision):
    before, after = inventory(source, baseline), inventory(source, revision)
    changes = [{"path": path, "change": "added" if path not in before else "removed" if path not in after else "modified",
                "category": category(path)}
               for path in sorted(before.keys() | after.keys()) if before.get(path) != after.get(path)]
    fingerprint = hashlib.sha256(json.dumps(after, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
    lines = ["# T3 harness review proposal", "", f"Source: {UPSTREAM}",
             f"Baseline: `{baseline}`", f"Candidate: `{revision}`", f"Fingerprint: `{fingerprint}`", "",
             f"[Pinned comparison]({UPSTREAM}/compare/{baseline}...{revision})", "",
             "Meaningful here means changed watched Git paths, bytes or modes, not semantic AI judgment.",
             "This proposal does not import skills or advance the vendoring lock. Merging acknowledges",
             "the watcher baseline only; adoption remains a separate reviewed change.", "",
             "## Changed inputs", "", "| Change | Input | Before | After |", "| --- | --- | --- | --- |"]
    for change in changes:
        path = change["path"]
        label = html.escape(path).replace("|", "&#124;").replace("\n", "&#10;").replace("\r", "&#13;").replace("`", "&#96;")
        link_path = quote(path, safe="/")
        old = f"[view]({UPSTREAM}/blob/{baseline}/{link_path})" if path in before else "—"
        new = f"[view]({UPSTREAM}/blob/{revision}/{link_path})" if path in after else "—"
        lines.append(f"| {change['change']} ({change['category']}) | <code>{label}</code> | {old} | {new} |")
    lines += ["", "## Suggested review", "",
              "- Added skills: inspect instructions, resources, licensing and host compatibility; add a scoped adapter before importing.",
              "- Modified skills/helpers: inspect pinned diffs and reconcile existing owners; refresh with `scripts/vendor-t3code-skills.py` after review.",
              "- Removed inputs: decide explicitly whether to retain or retire the local adaptation.",
              "- Harness/policy/license changes: reconcile local trust and execution rules; do not blindly copy upstream policy.",
              "- Verify importer integrity, generated registrations, affected tests, lint and types before an adoption PR.", "",
              "Detection is conservative: whitespace counts; app-only paths are ignored. Referenced files outside",
              "the configured watch scope are not recursively followed. Upstream files are never executed.", ""]
    report = "\n".join(lines)
    if len(report.encode()) > 55_000:
        raise ValueError("Proposal exceeds the review size limit; inspect upstream manually")
    return {"status": "changed" if changes else "unchanged", "baseline_revision": baseline,
            "revision": revision, "fingerprint": fingerprint, "changes": changes, "report": report}


def api(repository, method, route, payload=None, paginate=False):
    command = ["gh", "api", "--method", method, "--hostname", "github.com", f"repos/{repository}/{route}".rstrip("/"),
               "-H", "Accept: application/vnd.github+json", "-H", "X-GitHub-Api-Version: 2026-03-10"]
    if paginate:
        command += ["--paginate", "--slurp"]
    if payload is not None:
        command += ["--input", "-"]
    return json.loads(run(command, input=json.dumps(payload) if payload is not None else None, text=True))


def history(repository):
    pages = api(repository, "GET", "pulls?state=all&per_page=100", paginate=True)
    return [pr for page in pages for pr in page
            if pr["head"]["repo"] and pr["head"]["repo"]["full_name"].lower() == repository.lower()
            and pr["head"]["ref"].startswith(PREFIX)]


def prior_proposal(repository, branch):
    pulls = history(repository)
    for pr in pulls:
        if pr["head"]["ref"] == branch:
            return {"status": "existing" if pr["state"] == "open" else "dismissed", "url": pr["html_url"]}
    for pr in pulls:
        if pr["state"] == "open":
            return {"status": "deferred", "url": pr["html_url"]}
    return None


def publish(root, result, repository, base):
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9_.-]+", repository or ""):
        raise ValueError("--repository must be owner/repository")
    git(root, "check-ref-format", "--branch", base)
    metadata = api(repository, "GET", "")
    if metadata["default_branch"] != base:
        raise ValueError("Publication targets the repository default branch only")
    branch = PREFIX + result["fingerprint"]
    result["branch"] = branch
    previous = prior_proposal(repository, branch)
    if previous:
        return {**result, **previous}
    local_head = sha(git(root, "rev-parse", "HEAD").decode().strip())
    base_route = "git/ref/heads/" + quote(base, safe="")
    remote_head = sha(api(repository, "GET", base_route)["object"]["sha"])
    if local_head != remote_head or git(root, "show", f"HEAD:{CONFIG}") != (root / CONFIG).read_bytes():
        raise ValueError("Default branch or watcher config moved; rerun from a fresh trusted checkout")
    refs = api(repository, "GET", "git/matching-refs/heads/" + quote(branch, safe=""))
    if any(ref["ref"] == "refs/heads/" + branch for ref in refs):
        raise ValueError(f"Existing branch without a proposal: {branch}; inspect before recovery, never overwrite")
    base_tree = sha(api(repository, "GET", f"git/commits/{remote_head}")["tree"]["sha"])
    files = {CONFIG: json.dumps({"schema_version": 1, "baseline_revision": result["revision"]}, indent=2) + "\n",
             REPORT: result["report"]}
    tree = sha(api(repository, "POST", "git/trees", {"base_tree": base_tree, "tree": [
        {"path": path, "mode": "100644", "type": "blob", "content": content} for path, content in files.items()]})["sha"])
    commit = sha(api(repository, "POST", "git/commits", {"message": "chore(harness): propose t3 upstream review",
                                                       "tree": tree, "parents": [remote_head]})["sha"])
    if sha(api(repository, "GET", base_route)["object"]["sha"]) != remote_head:
        raise ValueError("Default branch moved during proposal; no branch created, rerun")
    # No PATCH/ref update, force push, adoption or merge path exists here.
    try:
        api(repository, "POST", "git/refs", {"ref": "refs/heads/" + branch, "sha": commit})
        created = api(repository, "POST", "pulls", {
            "title": "chore(harness): review t3 upstream changes", "head": branch, "base": base, "draft": True,
            "body": result["report"] + "\nAutomation: proposal only; no approval or merge. "
                    "With GITHUB_TOKEN, PR workflows may need a maintainer to approve their runs.\n"})
    except (ValueError, KeyError, TypeError, OSError, subprocess.TimeoutExpired) as error:
        # A lost response may have committed. Read, never replay uncertain writes.
        matching = [pr for pr in history(repository) if pr["head"]["ref"] == branch]
        if not matching:
            raise ValueError(f"Publication not confirmed; inspect branch {branch} and PR history before recovery: {error}") from error
        created = matching[0]
    observed = api(repository, "GET", f"pulls/{created['number']}")
    if (observed["state"] != "open" or not observed["draft"] or observed["head"]["ref"] != branch
            or observed["head"]["sha"] != commit or observed["base"]["ref"] != base):
        raise ValueError("Draft PR readback does not match the proposal; inspect before recovery")
    return {**result, "status": "published", "url": observed["html_url"]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--source", type=Path, required=True, help="Git object store (bare allowed); never checked out")
    parser.add_argument("--revision", required=True, help="Full upstream commit SHA")
    parser.add_argument("--publish", action="store_true", help="Open a draft proposal through gh; default is read-only")
    parser.add_argument("--repository", help="Destination owner/repository, required with --publish")
    parser.add_argument("--base", default="main", help="Destination default branch")
    args = parser.parse_args()
    config = json.loads((args.repo_root / CONFIG).read_text())
    if config.get("schema_version") != 1 or set(config) != {"schema_version", "baseline_revision"}:
        raise ValueError("Unsupported watcher config")
    result = proposal(args.source, sha(config["baseline_revision"]), sha(args.revision))
    if args.publish and result["status"] == "changed":
        result = publish(args.repo_root, result, args.repository, args.base)
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    try:
        main()
    except (ValueError, KeyError, TypeError, OSError, subprocess.TimeoutExpired) as error:
        print(f"T3 harness watcher: {error}", file=sys.stderr)
        sys.exit(1)
