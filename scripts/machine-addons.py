#!/usr/bin/env python3
"""Opt-in machine add-ons. No account login, transcript ingestion or daemon start."""

import argparse
import fcntl
import hashlib
import importlib.util
import json
import os
import platform
import plistlib
import shutil
import subprocess
import sys
import tempfile
import tomllib
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("machine_sync", Path(__file__).with_name("machine-sync.py"))
sync = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sync)
CAPABILITIES = {"claude-mods", "rea", "react-devtools", "openai-docs", "media", "trace-cli"}


def run(*args, env=None, cwd=None):
    result = subprocess.run([str(a) for a in args], env=env, cwd=cwd, capture_output=True,
                            text=True, stdin=subprocess.DEVNULL, timeout=900)
    if result.returncode:
        raise RuntimeError(f"{args[0]} failed ({result.returncode}): {(result.stderr or result.stdout)[-2000:]}")
    return result.stdout.strip()


def host_config(host):
    if host == "claude":
        root = Path(os.environ.get("CLAUDE_CONFIG_DIR", Path.home()))
        path = root / ".claude.json"
        return sync.read(path).get("mcpServers", {}) if path.exists() else {}
    path = Path(os.environ.get("CODEX_HOME", Path.home() / ".codex")) / "config.toml"
    return tomllib.loads(path.read_text()).get("mcp_servers", {}) if path.exists() else {}


def normalize(value):
    value = {k: v for k, v in value.items() if k not in ["type"]}
    if value.get("enabled", True):
        value.pop("enabled", None)
    if not value.get("env"):
        value.pop("env", None)
    return value


def registration(host, cli, name, desired, previous):
    current = host_config(host).get(name)
    if current is not None:
        if current.get("enabled") is False:
            raise RuntimeError(f"{host}/{name}: disabled setting preserved")
        if normalize(current) == normalize(desired):
            return
        if not previous or normalize(current) != normalize(previous):
            raise RuntimeError(f"{host}/{name}: existing connection differs; refusing to overwrite")
        if host == "claude":
            run(cli, "mcp", "remove", "--scope", "user", name)
        else:
            run(cli, "mcp", "remove", name)
    if host == "claude":
        run(cli, "mcp", "add-json", "--scope", "user", name, json.dumps(desired))
    elif "url" in desired:
        run(cli, "mcp", "add", name, "--url", desired["url"])
    else:
        environment = [arg for k, v in desired.get("env", {}).items() for arg in ["--env", f"{k}={v}"]]
        run(cli, "mcp", "add", name, *environment, "--", desired["command"], *desired["args"])
    actual = host_config(host).get(name)
    if actual is None or normalize(actual) != normalize(desired):
        raise RuntimeError(f"{host}/{name}: native registration readback did not match")


def node_runtime():
    # Do not change the person's default Node. REA 6.8's published engine floor
    # excludes Node 25, which is still common in existing shell environments.
    for candidate in [shutil.which("node"), "/opt/homebrew/opt/node/bin/node", "/usr/local/opt/node/bin/node"]:
        if not candidate or not Path(candidate).is_file():
            continue
        version = tuple(int(n) for n in run(candidate, "--version").lstrip("v").split(".")[:3])
        if ((version[0] == 22 and version >= (22, 23, 4)) or
                (version[0] == 24 and version >= (24, 22, 1)) or version >= (26, 12, 1)):
            return Path(candidate).absolute()
    raise RuntimeError("A Node runtime satisfying REA's engine range is required; the default Node is not changed")


def npm_runtime(state, profile_dir, selected):
    packages = {}
    templates = {}
    for name, filename in [("rea", "rea.mcp.json"), ("react-devtools", "react-devtools.mcp.json")]:
        if name not in selected:
            continue
        value = sync.read(profile_dir / filename)["mcpServers"][name]
        selector = next(arg for arg in value["args"] if "@" in arg and not arg.startswith("--"))
        packages[selector.split("@")[0]] = selector
        templates[name] = value
    node = node_runtime()
    identity = hashlib.sha256(json.dumps(packages, sort_keys=True).encode()).hexdigest()[:16]
    root = state / "runtimes" / f"npm-{identity}"
    root.mkdir(parents=True, exist_ok=True)
    missing = any(not (root / "node_modules" / name / "package.json").is_file() or
                  sync.read(root / "node_modules" / name / "package.json")["version"] != selector.split("@")[1]
                  for name, selector in packages.items())
    if missing:
        npm = node.parent / "npm"
        if not npm.is_file():
            raise RuntimeError(f"npm accompanying {node} is missing")
        env = {**os.environ, "PATH": f"{node.parent}:{os.environ['PATH']}"}
        run(node, npm.resolve(), "install", "--prefix", root, "--ignore-scripts", "--no-audit",
            "--no-fund", "--engine-strict", "--save-exact", *packages.values(), env=env, cwd=root)
    definitions = {}
    for name, template in templates.items():
        selector = next(a for a in template["args"] if "@" in a and not a.startswith("--"))
        package = root / "node_modules" / selector.split("@")[0]
        info = sync.read(package / "package.json")
        entry = info["bin"] if isinstance(info["bin"], str) else next(iter(info["bin"].values()))
        index = template["args"].index(selector)
        definitions[name] = {"type": "stdio", "command": str(node),
                             "args": [str(package / entry), *template["args"][index + 1:]],
                             "env": {"PATH": ":".join([str(node.parent), str(Path.home() / ".local/bin"), str(Path.home() / ".bun/bin"), "/opt/homebrew/bin", "/usr/local/bin", "/usr/bin", "/bin", "/usr/sbin", "/sbin"])}}
    return definitions


def mods(state, cli):
    current = sync.read(state / "current.json")
    bundle = Path(current["bundle"])
    sync.verify(bundle, current["files"])
    source = bundle / "plugins/frontend-skills-mods"
    original = sync.read(source / ".claude-plugin/plugin.json")
    version = f"{original['version']}-sync.{current['revision']}"
    target = state / "marketplace/addons/mods" / current["revision"]
    if not target.exists():
        target.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=target.parent) as temp:
            payload = Path(temp) / "bundle"
            shutil.copytree(source, payload)
            original["version"] = version
            sync.write(payload / ".claude-plugin/plugin.json", original)
            payload.rename(target)
    catalog = state / "marketplace/.claude-plugin/marketplace.json"
    value = sync.read(catalog)
    value["plugins"] = [p for p in value["plugins"] if p["name"] != "frontend-skills-mods"]
    value["plugins"].append({"name": "frontend-skills-mods", "source": f"./addons/mods/{current['revision']}", "version": version})
    sync.write(catalog, value)
    plugin = "frontend-skills-mods@skills"
    run(cli, "plugin", "install", plugin, "--scope", "user")
    items = json.loads(run(cli, "plugin", "list", "--json"))
    item = next((p for p in items if p["id"] == plugin and p["scope"] == "user"), None)
    if item and item["version"] != version:
        run(cli, "plugin", "update", plugin, "--scope", "user")
        items = json.loads(run(cli, "plugin", "list", "--json"))
        item = next((p for p in items if p["id"] == plugin and p["scope"] == "user"), None)
    if not item or item["version"] != version or not item["enabled"]:
        raise RuntimeError("Claude mods are not enabled at the selected revision; disabled settings are not overridden")
    sync.verify(Path(item["installPath"]), sync.inventory(target))
    return {"version": version, "path": item["installPath"], "files": sync.inventory(target)}


def trace_cli(profile):
    existing = shutil.which("tracedecay")
    if existing:
        return {"path": existing, "version": run(existing, "--version"), "daemon": "not started by this installer"}
    definition = profile["tracedecay"]
    with tempfile.TemporaryDirectory(prefix="skills-tracedecay-") as temporary:
        script = Path(temporary) / "install.sh"
        with urllib.request.urlopen(definition["installerUrl"], timeout=60) as response:
            script.write_bytes(response.read())
        if hashlib.sha256(script.read_bytes()).hexdigest() != definition["installerSha256"]:
            raise RuntimeError("TraceDecay installer digest mismatch")
        env = {**os.environ, "TRACEDECAY_VERSION": definition["version"],
               "TRACEDECAY_INSTALL_DIR": str(Path.home() / ".local/bin")}
        env.pop("TRACEDECAY_INSTALL_UNATTESTED", None)
        run("bash", script, env=env)
    binary = Path.home() / ".local/bin/tracedecay"
    return {"path": str(binary), "version": run(binary, "--version"), "daemon": "not started by this installer"}


def apply(args, selected, profile):
    state = args.state_dir
    clis = {host: sync.binary(host) for host in ["claude", "codex"]}
    old = sync.read(state / "addons.json") if (state / "addons.json").exists() else {}
    receipt = {"checkedAt": datetime.now(timezone.utc).isoformat(), "selected": selected,
               "servers": old.get("servers", {}), "components": {}, "errors": []}
    definitions = {}
    if "openai-docs" in selected:
        definitions["openaiDeveloperDocs"] = {"type": "http", "url": profile["docsUrl"]}
    if set(selected) & {"rea", "react-devtools"}:
        try:
            definitions.update(npm_runtime(state, args.profile.parent, selected))
        except (RuntimeError, OSError) as error:
            receipt["errors"].append(str(error))
    for name, desired in definitions.items():
        for host, cli in clis.items():
            try:
                previous = old.get("servers", {}).get(host, {}).get(name)
                registration(host, cli, name, desired, previous)
                receipt["servers"].setdefault(host, {})[name] = desired
            except (RuntimeError, OSError) as error:
                receipt["errors"].append(str(error))
    for component in selected:
        try:
            if component == "claude-mods":
                receipt["components"][component] = mods(state, clis["claude"])
            elif component == "media":
                if sys.platform != "darwin" or platform.machine() != "arm64":
                    raise RuntimeError("This media profile requires Apple Silicon macOS; use the skill's platform adapter elsewhere")
                missing = [name for name in profile["mediaFormulae"] if not shutil.which(name)]
                if missing:
                    run("brew", "install", *missing, env={**os.environ, "HOMEBREW_NO_AUTO_UPDATE": "1"})
                run("uvx", "--python", "3.12", "--from", profile["whisperPackage"], "mlx_whisper", "--help")
                receipt["components"][component] = {"tools": {n: shutil.which(n) for n in profile["mediaFormulae"]}, "whisper": profile["whisperPackage"], "model": "downloaded on first transcription"}
            elif component == "trace-cli":
                receipt["components"][component] = trace_cli(profile)
        except (RuntimeError, OSError, ValueError, subprocess.TimeoutExpired) as error:
            receipt["errors"].append(f"{component}: {error}")
    sync.write(state / "addons.json", receipt)
    summary = {k: v for k, v in receipt.items() if k != "servers"}
    summary["components"] = {name: {k: v for k, v in value.items() if k != "files"} for name, value in receipt["components"].items()}
    print(json.dumps(summary, indent=2))
    return int(bool(receipt["errors"]))


def status(args, emit=True):
    receipt = sync.read(args.state_dir / "addons.json")
    errors = list(receipt["errors"])
    attempt = args.state_dir / "addons-attempt.json"
    if attempt.exists() and not sync.read(attempt)["ok"]:
        errors.append(f"Last add-on reconciliation failed: {sync.read(attempt)['error']}")
    for host, definitions in receipt["servers"].items():
        current = host_config(host)
        for name, expected in definitions.items():
            if name not in current or normalize(current[name]) != normalize(expected):
                errors.append(f"{host}/{name}: configuration drift")
            if "command" in expected and (not os.access(expected["command"], os.X_OK) or not Path(expected["args"][0]).is_file()):
                errors.append(f"{host}/{name}: runtime executable is missing")
    for name, component in receipt["components"].items():
        if name == "claude-mods":
            try:
                sync.verify(Path(component["path"]), component["files"])
                items = json.loads(run(sync.binary("claude"), "plugin", "list", "--json"))
                if not any(p["id"] == "frontend-skills-mods@skills" and p.get("scope") == "user" and p["enabled"] and p["version"] == component["version"] for p in items):
                    errors.append("claude-mods: not enabled at recorded version")
            except RuntimeError as error:
                errors.append(str(error))
        elif name == "media" and any(not shutil.which(n) for n in component["tools"]):
            errors.append("media: required binary missing")
        elif name == "trace-cli" and not Path(component["path"]).is_file():
            errors.append("TraceDecay executable missing")
    probe_path = args.state_dir / "addons-probes.json"
    probes = sync.read(probe_path) if probe_path.exists() else None
    digest = hashlib.sha256(json.dumps(receipt["servers"], sort_keys=True).encode()).hexdigest()
    if probes and probes.get("configurationDigest") != digest:
        probes = {"state": "stale; registrations changed since the probe"}
    output = {"configurationOK": not errors, "runtimeProbes": probes, "selected": receipt["selected"], "errors": errors,
                      "activation": "MCP registration is not a runtime probe; start fresh hosts and review native trust. TraceDecay daemon/history and new account logins are not enabled."}
    if emit or errors:
        print(json.dumps(output, indent=2))
    return int(bool(errors))



def probe(args):
    receipt = sync.read(args.state_dir / "addons.json")
    if status(args, emit=False):
        return 1
    sdk = None
    for desired in receipt["servers"].get("codex", {}).values():
        if "command" not in desired:
            continue
        for parent in Path(desired["args"][0]).parents:
            candidate = parent / "node_modules/@modelcontextprotocol/client/dist"
            if (candidate / "index.mjs").exists():
                sdk = candidate
                break
        if sdk:
            break
    if sdk is None:
        raise RuntimeError("Runtime probes require the SDK installed with the REA or React MCP package; configuration alone is not certification")
    javascript = r"""
const {Client,StreamableHTTPClientTransport}=await import(process.argv[1]+"/index.mjs");
const {StdioClientTransport}=await import(process.argv[1]+"/stdio.mjs");
const definition=JSON.parse(process.argv[2]);
const client=new Client({name:"harness-addon-probe",version:"1.0.0"},{capabilities:{}});
const transport=definition.url ? new StreamableHTTPClientTransport(new URL(definition.url)) : new StdioClientTransport({...definition,stderr:"pipe"});
try {
  await client.connect(transport);
  const {tools}=await client.listTools();
  if(!tools.length) throw new Error("Server exposed no tools");
  console.log(JSON.stringify({toolCount:tools.length,names:tools.slice(0,10).map(t=>t.name)}));
} finally { await client.close(); }
"""
    results = {}
    errors = []
    for name, desired in receipt["servers"].get("codex", {}).items():
        try:
            output = run(node_runtime(), "--input-type=module", "-e", javascript, sdk.as_uri(), json.dumps(desired))
            results[name] = json.loads(output.splitlines()[-1])
        except (RuntimeError, OSError, ValueError, subprocess.TimeoutExpired) as error:
            errors.append(f"{name}: {error}")
    result = {"checkedAt": datetime.now(timezone.utc).isoformat(),
              "configurationDigest": hashlib.sha256(json.dumps(receipt["servers"], sort_keys=True).encode()).hexdigest(),
              "results": results, "errors": errors, "scope": "Fresh direct transports; native host activation is still separate"}
    sync.write(args.state_dir / "addons-probes.json", result)
    print(json.dumps(result, indent=2))
    return int(bool(errors))



def schedule(args):
    if sys.platform != "darwin":
        raise RuntimeError("Login scheduling currently supports macOS only")
    consent = args.state_dir / "addons-consent.json"
    if not consent.exists():
        raise RuntimeError("Run an explicitly approved apply first")
    runner = args.state_dir / "machine-addons.py"
    if Path(__file__).resolve() != runner.resolve():
        shutil.copyfile(__file__, runner)
    for name in ["machine-addons.json", "rea.mcp.json", "react-devtools.mcp.json"]:
        source = args.profile if name == "machine-addons.json" else args.profile.parent / name
        target = args.state_dir / name
        if source.resolve() != target.resolve():
            shutil.copyfile(source, target)
    plist = Path.home() / "Library/LaunchAgents" / f"{sync.LABEL}.plist"
    value = plistlib.loads(plist.read_bytes())
    value["ProgramArguments"] = [sys.executable, str(runner), "--state-dir", str(args.state_dir),
                                 "--profile", str(args.state_dir / "machine-addons.json"), "--sync-core", "apply"]
    value["EnvironmentVariables"]["PATH"] = os.environ["PATH"]
    domain = f"gui/{os.getuid()}"
    subprocess.run(["launchctl", "bootout", f"{domain}/{sync.LABEL}"], capture_output=True)
    plist.write_bytes(plistlib.dumps(value))
    run("launchctl", "bootstrap", domain, plist)
    print("Existing login/daily job now reconciles core first, then the approved add-ons. No second scheduler created.")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="Examples:\n  python3 scripts/machine-addons.py plan\n  python3 scripts/machine-addons.py --yes apply\n  python3 scripts/machine-addons.py --only openai-docs --yes apply\n  python3 scripts/machine-addons.py probe\n  python3 scripts/machine-addons.py schedule")
    parser.add_argument("--state-dir", type=Path, default=Path.home() / ".local/share/frontend-skills")
    sibling_profile = Path(__file__).with_name("machine-addons.json")
    parser.add_argument("--profile", type=Path, default=sibling_profile if sibling_profile.exists() else Path(__file__).parent.parent / "config/machine-addons.json")
    parser.add_argument("--only", help="Comma-separated approved capabilities; defaults to the saved selection")
    parser.add_argument("--yes", action="store_true", help="Approve this machine's explicit capability selection")
    parser.add_argument("--sync-core", action="store_true", help="Run the existing core sync before reconciliation")
    parser.add_argument("command", choices=["plan", "apply", "status", "probe", "schedule"])
    args = parser.parse_args()
    os.umask(0o077)
    args.state_dir = args.state_dir.expanduser().resolve()
    args.profile = args.profile.expanduser().resolve()
    profile = sync.read(args.profile)
    selected = args.only.split(",") if args.only else profile["capabilities"]
    if profile.get("schemaVersion") != 1 or not set(selected) <= CAPABILITIES or not selected or len(set(selected)) != len(selected):
        raise RuntimeError("Unknown, empty, or duplicate capability selection")
    consent = args.state_dir / "addons-consent.json"
    if args.command == "plan":
        print(json.dumps({"capabilities": selected, "profile": profile, "newAccounts": False, "startIndexer": False}, indent=2))
        return 0
    if args.command == "apply" and not args.yes:
        if not consent.exists():
            raise RuntimeError("Review plan, then use --yes to approve the selected add-ons on this machine")
        approved = sync.read(consent)["capabilities"]
        if args.only and not set(selected) <= set(approved):
            raise RuntimeError("Selection exceeds this machine's saved approval; review and explicitly approve it")
        selected = selected if args.only else approved
        if not selected or not set(selected) <= CAPABILITIES or len(set(selected)) != len(selected):
            raise RuntimeError("Saved approval contains unsupported or duplicate capabilities; reenroll explicitly")
    args.state_dir.mkdir(parents=True, exist_ok=True)
    with (args.state_dir / "addons.lock").open("w") as lock:
        if args.command == "status":
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                raise RuntimeError("Add-on reconciliation is running; retry status afterward")
        else:
            fcntl.flock(lock, fcntl.LOCK_EX)
        if args.command == "status":
            return status(args)
        if args.command == "probe":
            return probe(args)
        if args.command == "schedule":
            schedule(args)
            return 0
        try:
            if args.yes:
                sync.write(consent, {"capabilities": selected, "approvedAt": datetime.now(timezone.utc).isoformat()})
                backup = args.state_dir / "backups" / datetime.now(timezone.utc).strftime("addons-%Y%m%dT%H%M%S%f")
                backup.mkdir(parents=True, mode=0o700)
                claude_dir = Path(os.environ.get("CLAUDE_CONFIG_DIR", Path.home() / ".claude"))
                claude_user = claude_dir / ".claude.json" if "CLAUDE_CONFIG_DIR" in os.environ else Path.home() / ".claude.json"
                for name, path in [("claude-user.json", claude_user), ("claude-settings.json", claude_dir / "settings.json"),
                                   ("claude-plugins.json", claude_dir / "plugins/installed_plugins.json"),
                                   ("codex-config.toml", Path(os.environ.get("CODEX_HOME", Path.home() / ".codex")) / "config.toml")]:
                    if path.exists():
                        shutil.copyfile(path, backup / name)
            source_root = None
            if args.sync_core:
                run(sys.executable, args.state_dir / "machine-sync.py", "--state-dir", args.state_dir, "--notify", "sync")
                source_root = Path(sync.read(args.state_dir / "current.json")["bundle"])
                newer_profile = source_root / "config/machine-addons.json"
                if newer_profile.exists():
                    newer = sync.read(newer_profile)
                    if newer.get("schemaVersion") != 1 or not set(selected) <= set(newer["capabilities"]):
                        raise RuntimeError("New main profile cannot represent the saved approval; reenroll explicitly")
                    # A new profile can update approved definitions/pins, but cannot
                    # expand the selected services saved in the machine's consent.
                    args.profile = newer_profile
                    profile = newer
            result = apply(args, selected, profile)
            if result:
                sync.notify("Machine add-ons need attention. Run machine-addons status; existing account settings are preserved.")
            elif source_root and (source_root / "scripts/machine-addons.py").exists():
                for name, source in [("machine-addons.py", source_root / "scripts/machine-addons.py"),
                                     *[(name, source_root / "config" / name) for name in ["machine-addons.json", "rea.mcp.json", "react-devtools.mcp.json"]]]:
                    target = args.state_dir / name
                    temporary = target.with_suffix(".tmp")
                    shutil.copyfile(source, temporary)
                    temporary.replace(target)
            sync.write(args.state_dir / "addons-attempt.json", {"ok": not bool(result), "error": "See addons.json errors" if result else None})
            return result
        except (RuntimeError, OSError, ValueError, KeyError, subprocess.TimeoutExpired) as error:
            sync.write(args.state_dir / "addons-attempt.json", {"ok": False, "error": str(error)})
            raise


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (RuntimeError, OSError, ValueError, KeyError, subprocess.TimeoutExpired) as error:
        print(f"error: {error}", file=sys.stderr)
        sys.exit(1)
