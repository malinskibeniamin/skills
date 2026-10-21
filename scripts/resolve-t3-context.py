#!/usr/bin/env python3
"""Select T3/Effect guidance for existing workflows; read-only, never execute target code."""

import argparse
import json
import sys
from pathlib import Path


def resolve(args):
    root = args.root.resolve(strict=True)
    if not root.is_dir():
        raise ValueError("--root must be a checkout directory")
    manifest = root / "package.json"
    package = json.loads(manifest.read_text()) if manifest.is_file() else {}
    if not isinstance(package, dict) or not isinstance(package.get("scripts", {}), dict):
        raise ValueError("Expected a package.json object with an object-valued scripts field")
    t3 = package.get("name") == "@t3tools/monorepo" and all(
        (root / path).is_file() for path in ("apps/server/package.json", "scripts/dev-runner.ts", "AGENTS.md"))
    result = {"entrypoint": args.entrypoint, "checkout": "t3code" if t3 else "other",
              "skills": [], "references": [], "verification_script": None,
              "pr_watch": "not-requested", "missing": []}
    if t3:
        result["references"].append(str(root / "AGENTS.md"))
        command = package.get("scripts", {}).get("check:changed")
        if isinstance(command, str) and command.strip():
            result["verification_script"] = "check:changed"
        else:
            result["missing"].append("check:changed script")
        for surface, skill, tool in (("web", "test-t3-app", "preview_status"),
                                     ("mobile", "test-t3-mobile", "device_list")):
            if args.surface in (surface, "both"):
                result["skills"].append(skill)
                if tool not in args.tool:
                    result["missing"].append(tool)
    if args.effect:
        result["skills"].append("effect-development")
        guide, source = root / "node_modules/effect/AGENTS.md", root / "node_modules/effect/src"
        if guide.is_file():
            result["references"].append(str(guide))
        elif source.is_dir():
            result["references"].append(str(source))
        else:
            result["missing"].append("installed Effect guide/source")
    if args.babysit:
        result["pr_watch"] = "native" if args.allow_wake and "watch_pull_request" in args.tool else "foreground"
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, required=True, help="Actual target checkout, not the plugin snapshot")
    parser.add_argument("--entrypoint", choices=("work", "tdd", "dogfood", "full-send"), required=True)
    parser.add_argument("--surface", choices=("none", "web", "mobile", "both"), default="none")
    parser.add_argument("--effect", action="store_true", help="The current task changes or reviews Effect code")
    parser.add_argument("--tool", action="append", default=[], help="Observed host capability name; repeat as needed")
    parser.add_argument("--babysit", action="store_true", help="The requested endpoint authorizes PR monitoring")
    parser.add_argument("--allow-wake", action="store_true", help="The current task explicitly authorizes host wake-ups")
    args = parser.parse_args()
    if args.babysit and args.entrypoint != "full-send":
        parser.error("--babysit is only valid for the full-send entrypoint")
    if args.allow_wake and not args.babysit:
        parser.error("--allow-wake requires --babysit and explicit host-wake authorization")
    print(json.dumps(resolve(args), indent=2))


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, RuntimeError) as error:
        print(f"T3 context: {error}", file=sys.stderr)
        sys.exit(1)
