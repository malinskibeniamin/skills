#!/usr/bin/env python3
"""Reconcile the personal Claude/Codex bundle; never copy host settings or trust."""

import argparse
import fcntl
import hashlib
import json
import os
import plistlib
import re
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

SOURCE = "https://github.com/malinskibeniamin/skills.git"
PLUGIN = "frontend-skills@skills"
LABEL = "com.malinskibeniamin.skills-sync"


def read(path):
    return json.loads(path.read_text())


def write(path, value):
    temporary = path.with_suffix(".tmp")
    temporary.write_text(json.dumps(value, indent=2) + "\n")
    temporary.replace(path)


def run(*args, cwd=None):
    result = subprocess.run([str(a) for a in args], cwd=cwd, capture_output=True,
                            text=True, timeout=300, stdin=subprocess.DEVNULL)
    if result.returncode:
        # Avoid dumping entire minified CLI source when a legacy binary crashes.
        raise RuntimeError(f"{args[0]} {' '.join(str(a) for a in args[1:3])}: "
                           f"exit {result.returncode}: {result.stderr[-1500:]}")
    return result.stdout.strip()


def binary(host):
    override = os.environ.get(f"{host.upper()}_BIN")
    candidates = [override] if override else [shutil.which(host)]
    if not override and host == "claude":
        candidates.append(str(Path.home() / ".local/bin/claude"))
    for candidate in dict.fromkeys(candidates):
        if candidate and Path(candidate).is_file():
            try:
                run(candidate, "--version")
                return str(Path(candidate).absolute())
            except (RuntimeError, subprocess.TimeoutExpired):
                pass
    raise RuntimeError(f"Working {host} CLI required; install it or set {host.upper()}_BIN")


def inventory(root):
    return {str(p.relative_to(root)): {"sha256": hashlib.sha256(p.read_bytes()).hexdigest(),
                                           "executable": bool(p.stat().st_mode & 0o111)}
            for p in sorted(root.rglob("*")) if p.is_file() and not p.is_symlink()}


def verify(root, expected):
    for name, digest in expected.items():
        path = root / name
        if not path.is_file() or (hashlib.sha256(path.read_bytes()).hexdigest() != digest["sha256"]
                                  or bool(path.stat().st_mode & 0o111) != digest["executable"]):
            raise RuntimeError(f"Bundle drift: {path}")


def snapshot(args):
    mirror = args.state_dir / "source.git"
    if not mirror.exists():
        run("git", "init", "--bare", mirror)
    run("git", "-C", mirror, "fetch", "--depth=1", args.source, "refs/heads/main")
    revision = run("git", "-C", mirror, "rev-parse", "FETCH_HEAD")
    root = args.state_dir / "marketplace/revisions" / revision
    metadata = root.parent / f"{revision}.json"
    if root.exists():
        verify(root, read(metadata))
        return root
    root.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=root.parent) as temporary:
        staging = Path(temporary)
        archive = staging / "source.tar"
        run("git", "-C", mirror, "archive", f"--output={archive}", revision)
        payload = staging / "bundle"
        payload.mkdir()
        run("tar", "-xf", archive, "-C", payload)
        # Generated deployment metadata, not edits to repository/release files.
        # Distinct versions prevent host caches reusing stale same-release bytes.
        base = read(payload / ".codex-plugin/plugin.json")["version"]
        version = f"{base.split('-')[0].split('+')[0]}-sync.{revision}"
        for manifest in [".claude-plugin/plugin.json", ".codex-plugin/plugin.json"]:
            value = read(payload / manifest)
            value["version"] = version
            write(payload / manifest, value)
        for manifest in [".claude-plugin/marketplace.json", ".agents/plugins/marketplace.json"]:
            value = read(payload / manifest)
            value["plugins"] = [p for p in value["plugins"] if p["name"] == "frontend-skills"]
            if len(value["plugins"]) != 1:
                raise RuntimeError(f"Expected one frontend-skills entry: {manifest}")
            value["plugins"][0]["version"] = version
            if manifest.startswith(".claude"):
                value["plugins"][0]["source"] = "./"
            write(payload / manifest, value)
        write(metadata, inventory(payload))
        payload.rename(root)
    return root


def installed(host, cli):
    value = json.loads(run(cli, "plugin", "list", "--json"))
    items = value if host == "claude" else value["installed"]
    return [p for p in items if p.get("id", p.get("pluginId")) == PLUGIN
            and (host != "claude" or p.get("scope") == "user")]


def check_hosts(receipt, clis):
    for host, cli in clis.items():
        matches = installed(host, cli)
        if len(matches) != 1 or not matches[0].get("enabled") or matches[0]["version"] != receipt["version"]:
            raise RuntimeError(f"{host}: expected one enabled user bundle at {receipt['version']}")
        if host == "codex":
            flags = {line.split()[0]: line.split()[-1] for line in run(cli, "features", "list").splitlines() if line.split()}
            for name in ["hooks", "plugins"]:
                if flags.get(name) != "true":
                    raise RuntimeError(f"Codex {name} feature is not enabled")
        verify(Path(receipt["hosts"][host]["path"]), receipt["files"])


def apply(root, clis):
    if not shutil.which("jq"):
        raise RuntimeError("jq is required by the harness hooks; install it before syncing")
    version = read(root / ".codex-plugin/plugin.json")["version"]
    receipt = {"revision": root.name, "version": version, "bundle": str(root),
               "checkedAt": datetime.now(timezone.utc).isoformat(),
               "files": read(root.parent / f"{root.name}.json"), "hosts": {}}
    verify(root, receipt["files"])
    marketplace = root.parent.parent
    migrate_codex = False
    for host, cli in clis.items():
        sources = json.loads(run(cli, "plugin", "marketplace", "list", "--json"))
        entries = sources if host == "claude" else sources.get("marketplaces", [])
        prior = next((p for p in entries if p["name"] == "skills"), None)
        if not prior:
            continue
        path = prior.get("installLocation" if host == "claude" else "root", "")
        if path and Path(path).resolve() == marketplace.resolve():
            continue
        origin = prior.get("repo", prior.get("url", "")) if host == "claude" else prior.get("marketplaceSource", {}).get("source", "")
        if not re.fullmatch(r"(?:https://github\.com/|git@github\.com:)?malinskibeniamin/skills(?:\.git)?/?", origin):
            raise RuntimeError(f"Refusing to replace an unrelated {host} skills marketplace")
        migrate_codex = host == "codex" or migrate_codex
    for name in [".claude-plugin/marketplace.json", ".agents/plugins/marketplace.json"]:
        value = read(root / name)
        source = f"./revisions/{root.name}"
        value["plugins"][0]["source"] = source if name.startswith(".claude") else {"source": "local", "path": source}
        (marketplace / name).parent.mkdir(parents=True, exist_ok=True)
        write(marketplace / name, value)
    for host, cli in clis.items():
        if host == "codex" and migrate_codex:
            # Native removal retains old version caches (verified on 0.167).
            # Only migrate our source registration; never remove a plugin.
            run(cli, "plugin", "marketplace", "remove", "skills")
        run(cli, "plugin", "marketplace", "add", marketplace)
        if host == "claude":
            run(cli, "plugin", "install", PLUGIN, "--scope", "user")
            matches = installed(host, cli)
            if len(matches) == 1 and matches[0]["version"] != version:
                run(cli, "plugin", "update", PLUGIN, "--scope", "user")
                matches = installed(host, cli)
            if len(matches) == 1 and not matches[0].get("enabled"):
                run(cli, "plugin", "enable", PLUGIN, "--scope", "user")
            if len(matches) != 1:
                raise RuntimeError("Claude: expected exactly one user installation")
            path = matches[0]["installPath"]
        else:
            run(cli, "features", "enable", "plugins")
            run(cli, "features", "enable", "hooks")
            result = json.loads(run(cli, "plugin", "add", PLUGIN, "--json"))
            path = result["installedPath"]
        receipt["hosts"][host] = {"path": path, "cli": cli}
    check_hosts(receipt, clis)
    return receipt


def status(args, clis):
    receipt_path = args.state_dir / "current.json"
    if not receipt_path.exists():
        raise RuntimeError("No successful sync recorded. Run sync first.")
    receipt = read(receipt_path)
    errors = []
    if not shutil.which("jq"):
        errors.append("jq is required by the harness hooks but is missing")
    attempt = args.state_dir / "attempt.json"
    if attempt.exists() and not read(attempt)["ok"]:
        errors.append(f"Last sync failed: {read(attempt)['error']}")
    try:
        check_hosts(receipt, clis)
    except RuntimeError as error:
        errors.append(str(error))
    print(json.dumps({"bundleOK": not errors, "revision": receipt["revision"],
                      "checkedAt": receipt["checkedAt"], "hosts": receipt["hosts"],
                      "errors": errors, "requiredTools": {"jq": bool(shutil.which("jq"))}, "runtime": "Not certified: in a new Codex session review /hooks; in both hosts verify skill discovery and a hook event.",
                      "optionalTools": {name: bool(shutil.which(name)) for name in
                                        ["bun", "rg", "rtk", "tracedecay", "gh"]}}, indent=2))
    return int(bool(errors))


def schedule(args, clis):
    if sys.platform != "darwin":
        raise RuntimeError("Automatic scheduling currently supports macOS only; run sync from your scheduler on other OSes.")
    path = Path.home() / "Library/LaunchAgents" / f"{LABEL}.plist"
    domain = f"gui/{os.getuid()}"
    if args.command == "unschedule":
        result = subprocess.run(["launchctl", "bootout", f"{domain}/{LABEL}"], capture_output=True)
        if result.returncode and result.returncode != 3:
            raise RuntimeError(f"Could not unload {LABEL}: {result.stderr.decode()}")
        path.unlink(missing_ok=True)
        print("Login/daily sync removed; installed bundles retained.")
        return
    # Keep a stable, machine-local runner, outside any feature worktree/cache.
    runner = args.state_dir / "machine-sync.py"
    if Path(__file__).resolve() != runner.resolve():
        shutil.copyfile(Path(__file__), runner)
    environment = {"PATH": os.environ["PATH"], **{f"{k.upper()}_BIN": v for k, v in clis.items()}}
    for key in ["CODEX_HOME", "CLAUDE_CONFIG_DIR"]:
        if key in os.environ:
            environment[key] = os.environ[key]
    value = {"Label": LABEL, "ProgramArguments": [sys.executable, str(runner),
             "--state-dir", str(args.state_dir), "--source", args.source, "--notify", "sync"],
             "EnvironmentVariables": environment, "RunAtLoad": True,
             "StartInterval": 86400, "ProcessType": "Background",
             "StandardOutPath": str(args.state_dir / "sync.log"),
             "StandardErrorPath": str(args.state_dir / "sync-error.log")}
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(plistlib.dumps(value))
    # Reinstall only our own launch agent; absent jobs are normal on first setup.
    subprocess.run(["launchctl", "bootout", f"{domain}/{LABEL}"], capture_output=True)
    run("launchctl", "bootstrap", domain, path)
    print(f"Login/daily sync installed: {path}\nLogs: {args.state_dir}/sync*.log")


def notify(message):
    if sys.platform == "darwin":
        # A denied notification is not a successful sync; durable logs/receipts
        # remain the authoritative channel, independent of desktop permissions.
        try:
            subprocess.run(["osascript", "-e", f'display notification {json.dumps(message)} with title "Skills sync"'],
                           capture_output=True, timeout=10)
        except (OSError, subprocess.TimeoutExpired):
            pass


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--state-dir", type=Path, default=Path.home() / ".local/share/frontend-skills")
    parser.add_argument("--source", default=SOURCE, help="Git repository with a main branch")
    parser.add_argument("--notify", action="store_true", help="macOS desktop notices after updates/failures (best effort)")
    parser.add_argument("command", choices=["sync", "status", "rollback", "schedule", "unschedule"])
    args = parser.parse_args()
    args.state_dir = args.state_dir.expanduser().resolve()
    args.state_dir.mkdir(parents=True, exist_ok=True)
    # OS lock releases on failure/kill; no stale PID-file recovery or overlap.
    with (args.state_dir / "lock").open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            if args.command == "status":
                raise RuntimeError("Another sync/status command is running; retry when it finishes.")
            print("Waiting for another sync/status operation...", flush=True)
            fcntl.flock(lock, fcntl.LOCK_EX)
        if args.command == "unschedule":
            schedule(args, {})
            return 0
        try:
            clis = {host: binary(host) for host in ["claude", "codex"]}
        except RuntimeError as error:
            if args.command in ["sync", "rollback"]:
                write(args.state_dir / "attempt.json", {"ok": False, "error": str(error)})
                if args.notify:
                    notify("Skills sync could not find a working host CLI. Inspect sync-error.log.")
            raise
        if args.command == "status":
            return status(args, clis)
        if args.command in ["schedule", "unschedule"]:
            schedule(args, clis)
            return 0
        old = read(args.state_dir / "current.json") if (args.state_dir / "current.json").exists() else None
        try:
            if args.command == "rollback":
                root = Path(read(args.state_dir / "previous.json")["bundle"])
                if not re.fullmatch(r"[a-f0-9]{40}", root.name) or root.parent != args.state_dir / "marketplace/revisions":
                    raise RuntimeError("Rollback bundle must be a retained managed revision")
            else:
                root = snapshot(args)
            receipt = apply(root, clis)
            if old and old["revision"] != receipt["revision"]:
                write(args.state_dir / "previous.json", old)
            write(args.state_dir / "current.json", receipt)
            write(args.state_dir / "attempt.json", {"ok": True, "revision": root.name})
            # Adopt future manager fixes only after the new bundle verifies.
            newer = root / "scripts/machine-sync.py"
            runner = args.state_dir / "machine-sync.py"
            if newer.exists() and runner.exists() and args.command != "rollback":
                temporary = runner.with_suffix(".tmp")
                shutil.copyfile(newer, temporary)
                temporary.replace(runner)
            if args.notify and (not old or old["revision"] != receipt["revision"]):
                notify("Skills updated. Start new sessions; review Codex /hooks. Run machine-sync status for details.")
            print(f"Bundle verified: {receipt['revision']} ({receipt['version']})")
            print("New sessions load the update. Codex: review /hooks. Runtime activation is not certified by file checks.")
            return 0
        except (RuntimeError, OSError, ValueError, KeyError, subprocess.TimeoutExpired) as error:
            write(args.state_dir / "attempt.json", {"ok": False, "error": str(error)})
            if args.notify:
                notify("Skills sync failed. Last good receipt retained; run machine-sync status or inspect sync-error.log.")
            raise


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (RuntimeError, OSError, ValueError, KeyError, subprocess.TimeoutExpired) as error:
        print(f"error: {error}", file=sys.stderr)
        sys.exit(1)
