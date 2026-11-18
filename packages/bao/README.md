# Bao

Bao is a standalone Bun CLI for local, source-cited wiki knowledge and repository
pointers. It does not require T3 Code or an installed skills plugin.

## Install from this checkout

Requires Bun to run and npm to build the local install archive. From the repository root:

```sh
cd packages/bao
mkdir -p dist
npm pack --offline --pack-destination ./dist
bun add --global ./dist/frontend-skills-bao-0.1.0.tgz
bao --help
```

Build and install are local; this package is not published to a registry. The
archive bundles the existing wiki implementation. Run commands against the
same home directory to see the same pages and repo pointers.

```sh
bao wiki --home /path/to/skills/.context/wiki-home search "home repo"
bao repo --home /path/to/skills/.context/wiki-home list
bao doctor --json
```

`doctor` needs the local `codex` executable on PATH. It checks the app-server and
reports whether Codex is signed into ChatGPT. It does not check quota, start an
agent turn, store credentials, or validate sandbox permissions.

The planned coding loop and SDK are not available in this build.
