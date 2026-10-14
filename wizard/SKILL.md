---
name: wizard
description: Generate an interactive bash wizard for human-only infrastructure, credentials or CI secrets, third-party dashboards, migrations, and cutovers. Do not invoke it for work the agent can perform.
---

Generate an interactive bash wizard for human-only steps: open URLs, capture values, write `.env`/GitHub secrets, and show stage-by-stage progress.

[template.sh](template.sh) owns the library: gates, WSL/browser opening, hidden input, idempotent env upserts, GitHub secrets/variables, summary. Author only below `STAGES`.

Default to an ephemeral scratch or `scripts/` file deleted after use. Commit only when the user wants a durable setup path.

## 1. Scope

Read the repo before asking. For third-party UI, URLs, scopes, secrets, commands: Call the Skill tool with "read-the-damn-docs". Other hosts: [dependency loading](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

- Setup: inspect `.env*`, README, compose files, framework config, and every `.github/workflows/*` `secrets.*`/`vars.*` reference.
- Migration/cutover: map current state, target state, and irreversible actions.

Confirm ordered stages and values: source, destination (`.env`, GitHub secret, both, or none), hidden entry.

## 2. Map journeys

Specify each stage's URL, clicks, value, and target variable, for example `Dashboard -> Developers -> API keys -> Reveal test key -> copy`. Verify UI/commands from docs or ask; a stranger must be able to follow.

## 3. Author

Copy `template.sh`; replace stages inside `run_wizard`. Keep final `run_wizard "$@"; exit` for parse-before-prompt safety. Use `stage`, `say`/`step`, `open_url`, `ask`/`ask_secret`, `write_env`, `set_secret`/`set_var`, `pause`/`confirm`; set `TOTAL_STAGES`.

Open a URL before asking for its value; use `ask_secret` for secrets, `write_env` for persisted values, and `set_secret` only for CI needs. Confirm irreversible actions. Keep each screen to one focused task. Never touch the library above the marker.

## 4. Verify

- Run `bash -n <script>` and `shellcheck` when available; `chmod +x`.
- With stubbed external commands, prove success, EOF failure, and rerun defaults. Validate `.env` with the project's loader; shell quoting is not universal dotenv.
- Do not run end-to-end: it opens browsers and awaits a human. Trace every captured value to its destination; every `set_secret` name must match CI.
- Tell the user how to run it. For durable setup, commit and link it from README.
