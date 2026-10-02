#!/usr/bin/env python3
"""Resolve team-first review handles; GitHub remains the authority on eligibility."""

import argparse
import re
import subprocess
import sys
from pathlib import Path


def git_output(*args):
    return subprocess.check_output(
        ["git", *args], text=True, stderr=subprocess.PIPE
    ).strip()


def read_codeowners(root, base):
    if base:
        base = git_output(
            "rev-parse", "--verify", "--end-of-options", f"{base}^{{commit}}"
        )
    for candidate in (".github/CODEOWNERS", "CODEOWNERS", "docs/CODEOWNERS"):
        if base:
            if git_output("ls-tree", "--name-only", base, "--", candidate):
                return git_output("show", f"{base}:{candidate}")
        elif (root / candidate).is_file():
            return (root / candidate).read_text()
    return ""


def pattern_regex(pattern):
    rooted = pattern.startswith("/")
    directory = pattern.endswith("/")
    pattern = pattern.strip("/")
    prefix = "^" if rooted or "/" in pattern else r"(?:^|.*/)"
    result = ""
    index = 0
    while index < len(pattern):
        character = pattern[index]
        segment_start = index == 0 or pattern[index - 1] == "/"
        if segment_start and pattern[index:index + 3] == "**/":
            result += r"(?:[^/]+/)*"
            index += 3
        elif pattern[index:index + 2] == "**":
            segment_end = index + 2 == len(pattern) or pattern[index + 2] == "/"
            result += ".*" if segment_start and segment_end else "[^/]*"
            index += 2
        else:
            result += {"*": "[^/]*", "?": "[^/]"}.get(character, re.escape(character))
            index += 1
    suffix = r"/.*$" if directory else r"(?:/.*)?$"
    return re.compile(prefix + result + suffix)


def reviewers(content, paths, teams_only):
    rules = []
    for line in content.splitlines():
        fields = re.findall(r"(?:\\[ \t]|[^\s])+", line.split("#", 1)[0])
        if (
            not fields
            or fields[0].startswith(("!", "\\#"))
            or any(c in fields[0] for c in "[]")
        ):
            continue
        pattern = fields[0].replace("\\ ", " ").replace("\\\t", "\t")
        rules.append((pattern_regex(pattern), fields[1:]))
    selected = set()
    for path in paths:
        owners = []
        for pattern, candidates in rules:
            if pattern.search(path):
                owners = candidates
        teams = [
            owner for owner in owners if re.fullmatch(r"@[^/\s]+/[^/\s]+", owner)
        ]
        candidates = teams if teams or teams_only else owners
        for owner in candidates:
            if "@" in owner and not owner.startswith("@"):
                raise ValueError(
                    f"email owner {owner}: resolve a verified GitHub login "
                    "before requesting review"
                )
            if not re.fullmatch(r"@[^/\s]+(?:/[^/\s]+)?", owner):
                raise ValueError(f"invalid CODEOWNERS owner: {owner}")
            selected.add(owner.removeprefix("@"))
    return sorted(selected)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--teams-only", action="store_true")
    parser.add_argument(
        "--base", help="read CODEOWNERS from the PR base, not the working tree"
    )
    parser.add_argument(
        "--stdin0", action="store_true",
        help="read NUL-separated repository paths on stdin",
    )
    parser.add_argument("paths", nargs="*")
    args = parser.parse_args()
    if not args.paths and not args.stdin0:
        parser.error("provide repository paths or --stdin0")
    try:
        root = Path(git_output("rev-parse", "--show-toplevel")).resolve()
        content = read_codeowners(root, args.base)
        inputs = args.paths
        if args.stdin0:
            inputs += [path for path in sys.stdin.read().split("\0") if path]
        paths = []
        for path in inputs:
            if not path:
                raise ValueError("repository path must not be empty")
            target = Path(path)
            if target.is_absolute():
                target = target.resolve().relative_to(root)
            if ".." in target.parts:
                raise ValueError(f"path must stay inside the repository: {path}")
            paths.append(target.as_posix())
        selected = reviewers(content, paths, args.teams_only)
    except subprocess.CalledProcessError as error:
        parser.error(f"git {error.cmd[1:]}: {error.stderr.strip()}")
    except (OSError, ValueError) as error:
        parser.error(str(error))
    for owner in selected:
        print(owner)


if __name__ == "__main__":
    main()
