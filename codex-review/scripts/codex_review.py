#!/usr/bin/env python3
"""One authorized, read-only Codex review of a committed branch snapshot."""

import argparse
from contextlib import ExitStack
import json
import os
from pathlib import Path, PurePosixPath
import signal
import subprocess
import sys
import tempfile
from urllib.parse import urlsplit


ROOT = Path(__file__).resolve().parents[2]
SCHEMA = Path(__file__).with_name("review-schema.json")


class ReviewError(Exception):
    pass


def git(*args):
    result = subprocess.run(
        ["git", *args], text=True, capture_output=True, timeout=30, check=False,
    )
    if result.returncode:
        raise ReviewError(f"git {' '.join(args)} failed: {result.stderr.strip()}")
    return result.stdout.strip()


def snapshot():
    if git("status", "--porcelain", "--untracked-files=all", "--", ".",
           ":(exclude).context/codex-review"):
        raise ReviewError("Review requires a clean committed snapshot; review WIP inline instead.")
    return git("rev-parse", "--verify", "HEAD")


def run_logged(command, log, timeout, stdout_path=None):
    with ExitStack() as files:
        output = files.enter_context(log.open("w"))
        stdout = files.enter_context(stdout_path.open("w")) if stdout_path else output
        process = subprocess.Popen(
            command, stdin=subprocess.DEVNULL, stdout=stdout, stderr=output,
            start_new_session=True,
        )
        try:
            code = process.wait(timeout=timeout)
        except (subprocess.TimeoutExpired, KeyboardInterrupt):
            os.killpg(process.pid, signal.SIGKILL)
            process.wait()
            raise ReviewError(f"{command[0]} interrupted or timed out; see {log}")
    if code:
        raise ReviewError(f"{command[0]} failed (exit {code}); see {log}")


def check_pr(args, head, base, folder, phase):
    command = ["gh", "pr", "view", str(args.pr), "--json", "state,headRefOid,baseRefOid,url"]
    if args.repo:
        command.extend(["--repo", args.repo])
    output = folder / f"pr-{phase}.json"
    run_logged(command, folder / f"pr-{phase}.log", 30, stdout_path=output)
    try:
        pr = json.loads(output.read_text())
    except ValueError as error:
        raise ReviewError("Invalid PR metadata; nothing posted.") from error
    if not isinstance(pr, dict) or pr.get("state") != "OPEN":
        raise ReviewError("PR must be OPEN; nothing posted.")
    if pr.get("headRefOid") != head or pr.get("baseRefOid") != base:
        raise ReviewError("PR head/base differs from the local snapshot; fetch/reconcile before posting.")
    url = pr.get("url", "")
    if not isinstance(url, str) or urlsplit(url).scheme != "https" or not urlsplit(url).hostname:
        raise ReviewError("Invalid PR URL; nothing posted.")
    return url


def nonempty(value):
    return isinstance(value, str) and bool(value.strip())


def load_review(path):
    try:
        review = json.loads(path.read_text())
    except (OSError, ValueError) as error:
        raise ReviewError(f"Missing, empty, or invalid review output: {path}") from error
    if (not isinstance(review, dict) or set(review) != {"summary", "findings"}
            or not nonempty(review["summary"]) or not isinstance(review["findings"], list)):
        raise ReviewError("Invalid review: expected summary and findings array.")
    for finding in review["findings"]:
        if (not isinstance(finding, dict)
                or set(finding) != {"priority", "title", "body", "file", "line"}
                or type(finding["priority"]) is not int or finding["priority"] not in range(4)
                or type(finding["line"]) is not int or finding["line"] < 1
                or not all(nonempty(finding[key]) for key in ("title", "body", "file"))):
            raise ReviewError("Invalid finding: expected P0-P3, text, relative file, positive line.")
        file = finding["file"]
        if (PurePosixPath(file).is_absolute() or ".." in PurePosixPath(file).parts
                or any(char in file for char in "\n\r`\\")):
            raise ReviewError("Invalid finding file: expected a repository-relative path.")
    return review


def render(review, head, base, model, effort, profile):
    counts = " · ".join(
        f"P{priority}={sum(f['priority'] == priority for f in review['findings'])}"
        for priority in range(4)
    )
    lines = [
        "## 🤖 Codex review", "",
        f"Automated second opinion via `codex exec review` — model **{model}**, effort **{effort}**.",
        f"Profile: `{profile or 'saved default'}`. HEAD: `{head}`. Base: `{base}`.", "",
        f"**Findings:** {counts}", "", review["summary"], "",
    ]
    for finding in review["findings"]:
        lines.extend([
            f"### [P{finding['priority']}] {finding['title']}",
            f"`{finding['file']}:{finding['line']}`", "", finding["body"], "",
        ])
    lines.append("AI-generated advisory review; owner verifies findings and test claims. Not merge approval.")
    return "\n".join(lines) + "\n"


def positive_int(value):
    number = int(value)
    if number <= 0:
        raise argparse.ArgumentTypeError("must be positive")
    return number


def selection_name(value):
    if not value or any(char.isspace() for char in value):
        raise argparse.ArgumentTypeError("must be a nonempty model/profile name without whitespace")
    return value


def main():
    os.umask(0o077)
    routing = json.loads((ROOT / "config/model-routing.json").read_text())["quality_first"]["review"]["primary"]
    parser = argparse.ArgumentParser(description=__doc__, allow_abbrev=False)
    parser.add_argument("--base", required=True, help="Existing local base ref; pinned to its SHA.")
    parser.add_argument("--model", type=selection_name, default=routing["model"])
    parser.add_argument("--effort", choices=("low", "medium", "high", "xhigh"), default=routing["effort"])
    parser.add_argument("--profile", type=selection_name, help="Explicit configured Codex profile; no provider fallback.")
    parser.add_argument("--timeout", type=positive_int, default=900, help="Review deadline in seconds.")
    parser.add_argument("--post", action="store_true", help="Explicitly publish one advisory PR comment.")
    parser.add_argument("--pr", type=positive_int, help="PR number to post to; requires --post.")
    parser.add_argument("--repo", help="GitHub owner/repo; otherwise gh resolves the current repository.")
    args = parser.parse_args()
    if args.post != bool(args.pr) or (args.repo and not args.post):
        parser.error("--post and --pr must be supplied together; --repo requires --post")
    os.chdir(git("rev-parse", "--show-toplevel"))
    head = snapshot()
    base = git("rev-parse", "--verify", "--end-of-options", f"{args.base}^{{commit}}")
    artifacts = Path(".context/codex-review")
    artifacts.mkdir(parents=True, exist_ok=True)
    folder = Path(tempfile.mkdtemp(prefix=f"{head[:8]}-", dir=artifacts)).resolve()
    if args.post:
        check_pr(args, head, base, folder, "before")
    result = folder / "review.json"
    command = ["codex", "exec", "--sandbox", "read-only", "-c", 'approval_policy="never"']
    if args.profile:
        command.extend(["--profile", args.profile])
    command.extend([
        "review", "--base", base, "--model", args.model,
        "-c", f"model_reasoning_effort={json.dumps(args.effort)}", "--ephemeral",
        "--output-schema", str(SCHEMA), "--output-last-message", str(result),
    ])
    run_logged(command, folder / "codex.log", args.timeout)
    review = load_review(result)
    if snapshot() != head:
        raise ReviewError("HEAD changed during review; rerun for the new snapshot.")
    report = folder / "review.md"
    report.write_text(render(review, head, base, args.model, args.effort, args.profile))
    print(f"Report: {report}", flush=True)
    if args.post:
        url = check_pr(args, head, base, folder, "after")
        if snapshot() != head:
            raise ReviewError("HEAD changed before posting; rerun for the new snapshot.")
        try:
            run_logged(["gh", "pr", "comment", url, "--body-file", str(report)], folder / "post.log", 30)
        except ReviewError as error:
            raise ReviewError(f"{error}. Posting outcome may be unknown; inspect PR comments before retrying.") from error
        print(f"Posted: {url}")
    else:
        print("Local only; nothing posted.")


if __name__ == "__main__":
    try:
        main()
    except (ReviewError, OSError, subprocess.TimeoutExpired) as error:
        print(f"codex-review: {error}", file=sys.stderr)
        sys.exit(1)
