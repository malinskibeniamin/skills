# One personal harness across machines

Use the same `main` revision of `malinskibeniamin/skills` in Claude Code and Codex,
without copying host configuration folders. Each machine enrolls once; macOS can
then reconcile at login and every 24 hours. Credentials, model choices, permissions,
project settings and native hook trust remain machine-local.

## Bootstrap a Mac

Prerequisites: Git, Python 3, jq, and working Claude Code and Codex CLIs. Bun is the
harness's expected project package manager; install project tools through the
existing starter-kit guidance, not through this sync manager.

From a checkout of this repository containing `scripts/machine-sync.py`:

```sh
python3 scripts/machine-sync.py sync
python3 scripts/machine-sync.py status
python3 scripts/machine-sync.py schedule
```

On another machine, clone this repository first:

```sh
git clone --depth 1 https://github.com/malinskibeniamin/skills.git "$HOME/.local/src/frontend-skills"
cd "$HOME/.local/src/frontend-skills"
```

Then run the same sync/status/schedule commands above.
No per-machine path substitutions or configuration-folder copying are needed.
`--source URL_OR_PATH` supports a personal fork with a `main` branch. The default
is `https://github.com/malinskibeniamin/skills.git`; it always fetches `main`, never
the current feature branch or uncommitted work. Use Git's normal authentication
for private forks. Do not put credentials in the source URL.

The manager probes the CLI on PATH and falls back to `~/.local/bin/claude` if a
legacy Node-based Claude install crashes. `CLAUDE_BIN` and `CODEX_BIN` select explicit
executables. It does not rewrite shell startup files or remove old CLI installs.

## Activation is a separate boundary

After the first installation, start fresh sessions in **both** hosts. Confirm a
representative skill such as `review` is discoverable. In Codex, open `/hooks` and
review/trust the installed definitions when requested; changed definitions can
require another review. Exercise a representative hook event in a disposable
consumer before relying on enforcement. Sync never disables or bypasses trust.

`status` reports **bundle integrity**, not proof that an already-running host loaded
the bundle or executed hooks. Global installation does not override a project's
explicitly disabled plugin, managed policy, old project-scoped installations or
permissions. Review those overrides in that project's plugin UI rather than copying
or overwriting work settings.

The complete core plugin includes all registered skills, hook scripts, shared
references, helpers and reviewer definitions. Host-specific supported lifecycle
mappings still differ. Definitions do not authorize automatic delegation.
Claude mods, MCP integrations, media tooling and the TraceDecay CLI are separate
opt-ins through the capability profile below. Core-only sync does not install them.
The add-on installer never starts an indexer or connects new accounts.
`status` reports the presence of common companion tools, not their configuration
or authentication. The existing `scripts/verify-install.sh` remains a supplemental
consumer diagnostic, not the authoritative revision-sync receipt.

## Why this scales

- **Objective → source:** every enrolled machine independently fetches the same
  `main` source; offline machines retain their last installed bundle and retry on
  the next scheduled run. Machines can temporarily differ while offline or while
  `main` moves between fetches; no cross-machine atomic rollout is claimed.
- **Source → immutable bundle:** one Git SHA becomes a generated deployment version
  such as `4.44.0-sync.<full-sha>`. This avoids stale host caches when skills change
  without a published release. Release manifests in the source repo are untouched.
- **Bundle → hosts:** a stable local `skills` marketplace points to that revision;
  each native plugin manager installs its own copy. The initial Codex migration
  replaces only this repo's old marketplace registration and retains old caches.
- **Hosts → evidence:** actual installed files, executable bits, version and enabled
  user scope must match before publishing `current.json`. The previous successful
  receipt and revision stay available. A partial install is an error, not success.
- **Schedule → repair:** a machine-local runner survives removal of the bootstrap
  checkout. It adopts newer manager code from successfully verified `main` bundles.
  No host restart, user-session termination or background AI calls occur.

## Operate and recover

Default machine state: `~/.local/share/frontend-skills/`. The scheduled runner is
`machine-sync.py` there; invoke it with Python from any directory:

```sh
python3 ~/.local/share/frontend-skills/machine-sync.py status
python3 ~/.local/share/frontend-skills/machine-sync.py sync
python3 ~/.local/share/frontend-skills/machine-sync.py rollback
python3 ~/.local/share/frontend-skills/machine-sync.py unschedule
```

`rollback` reinstalls the previous retained bundle in both hosts, offline. It does
not pin future runs: unschedule first if you need to stay rolled back. It retains
the displaced revision, so another rollback can restore it. Do not delete retained
revisions or host caches while sessions may still reference them. Automatic pruning
is intentionally absent; inspect disk use periodically.

The macOS job is `com.malinskibeniamin.skills-sync`, registered in
`~/Library/LaunchAgents/`. `RunAtLoad` runs on registration/login; `StartInterval`
runs every 86,400 seconds while launchd can run the job, not at a fixed wall-clock
time. `sync.log`, `sync-error.log`, and `attempt.json` expose outcomes. Update/failure
desktop notices are best-effort and depend on macOS notification permissions;
the durable logs and nonzero failure exit are authoritative. An OS lock serializes
mutating invocations, including the job started during registration. A concurrent
`status` reports busy; retry after the running command finishes.

If one host fails, the successful receipt is not advanced and `status` fails visibly.
A partially updated host is not automatically rolled back: fix the reported cause
and run `sync`, or use `rollback` if a previous complete revision exists. Missing or
modified installed files are reported, not silently certified. Use the host's plugin
manager to repair that installation, then rerun sync. Do not erase entire host caches.

Automatic scheduling currently targets macOS. On Linux, `sync`, `status` and
`rollback` use the same Python/Git workflow; enroll it in the machine's existing
scheduler explicitly. Windows is not supported by this POSIX manager.

## Verification and external contracts

```sh
bun test ./scripts/machine-sync.test.ts
```

The CLI tests protect same-release revision updates, installed-byte drift, partial
failure and rollback at external host-process seams. Native installers are also
covered by `scripts/test-claude-plugin-install.sh` and
`scripts/test-codex-plugin-install.sh`. Test sync/update/rollback with isolated
`HOME`, `CLAUDE_CONFIG_DIR` and `CODEX_HOME` before changing manager/host contracts.

References: [Claude marketplace source semantics](https://code.claude.com/docs/en/plugins/marketplace-reference),
[OpenAI local plugins and hook trust](https://developers.openai.com/plugins/build/plugins).


## Approved machine add-ons

After core enrollment, opt in on each machine:

```sh
python3 scripts/machine-addons.py plan
python3 scripts/machine-addons.py --yes apply
python3 scripts/machine-addons.py probe
python3 scripts/machine-addons.py schedule
```

`config/machine-addons.json` names the supported capabilities. `--yes` saves only
that machine's selected capability names in `addons-consent.json`; it is not a
credential or permission export. `--only openai-docs,rea` enrolls a smaller set.
Later `apply` without `--yes` reconciles the saved selection, never every new
capability added to the repo. Skipping a previously installed capability does not
uninstall it or revoke an existing registration; remove it explicitly through its
native manager. Existing same-name connections and disabled settings are preserved;
a mismatch returns a visible failure rather than overwriting work configuration.
Local config backups precede explicitly approved enrollment.

The current Apple Silicon macOS profile covers:

- **Harness Desk:** export a revision-stamped copy of the bundled Claude-only mod,
  preserving core bundle bytes and old active-session caches. No prompt enrichment
  is enabled by setup. Native reload/trust and SDK compatibility remain host checks.
- **REA and React DevTools:** install the versions from the repo's MCP templates in
  a machine-local npm prefix, not a consuming project. Acquire with install scripts
  disabled and enforce package engine constraints. Select a compatible existing
  Node without changing the shell's default. Register absolute executable/package
  paths in both hosts; preserve React's isolated loopback URL restrictions and
  disabled usage/CrUX reporting. Native decompilers, target execution and app
  instrumentation are separate scopes. React tool discovery needs the named app's
  development-only bootstrap; listing generic MCP tools does not prove that.
- **OpenAI Docs:** a read-only remote documentation endpoint, without account login
  or paid API calls. Both hosts receive the same connection definition.
- **Media:** install missing Tesseract/asciinema Homebrew formulae and prepare the
  pinned MLX Whisper runtime through uv/Python 3.12. Existing FFmpeg/yt-dlp remain
  prerequisites for relevant media tasks. Model weights download on first local
  transcription; this installer does not enable cloud transcription. Homebrew
  formulae are installed if missing, not forcibly upgraded to arbitrary new releases.
  Other platforms need a reviewed media adapter, not this macOS-specific profile.
- **TraceDecay CLI:** acquire the profile's pinned upstream installer, verify its
  digest, then require the installer's archive/build-provenance verification.
  An existing executable is preserved and its actual version reported, not silently
  upgraded across storage schemas. This includes **no daemon start, host hook
  installation, transcript backfill, automation loop or remote authority setup**.
  Indexing scopes and session-history ingestion need explicit approval first.

`probe` opens fresh direct transports for the registered MCP definitions and checks
initialization plus nonempty tool discovery. It uses the MCP client shipped with
the REA runtime; a docs-only installation can instead use its native host's MCP
health view. Probe results bind to a digest of the recorded definitions and become
stale after registration changes. They do not certify native host activation,
individual tools, browser behavior, accounts or production readiness.

Add-on scheduling **reuses** `com.malinskibeniamin.skills-sync`; it does not add a
second periodic job. Its stable runner calls core sync first, then reconciles the
saved add-on selection, restoring the mod catalog entry after core refresh. Once
this implementation reaches `main`, verified bundles can refresh the approved
profile/pins and runner without expanding machine consent. Until then the local
runner/profile survive independently of the feature checkout. Re-running core
`schedule` alone restores core-only scheduling; run add-on `schedule` afterward to
restore the combined job. Core `unschedule` stops the combined job as well.

From any directory after enrollment:

```sh
python3 ~/.local/share/frontend-skills/machine-addons.py status
python3 ~/.local/share/frontend-skills/machine-addons.py probe
```

`addons.json`, `addons-attempt.json` and `addons-probes.json` distinguish configured
state, reconciliation failure and runtime probe evidence. The existing sync logs
and native launchd exit status cover the scheduled chain. No account credentials,
OAuth grants or production changes are created by this profile. GitHub, Jira,
LaunchDarkly, Snyk, Google Workspace and incident.io authentication remain separate
machine-local enrollment decisions.
