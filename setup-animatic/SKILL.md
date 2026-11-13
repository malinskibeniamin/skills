---
name: setup-animatic
description: Choose and test the voice, renderer, style and stitcher for animatic videos, then save the target repository's configuration. Run explicitly to set up or change the toolchain.
disable-model-invocation: true
---

Read [host compatibility](../shared/MATT-POCOCK.md) and the
[animatic host boundaries](../animatic/SKILL.md), then follow the complete
[upstream setup](../vendor/mattpocock/upstream/skills/in-progress/setup-animatic/SKILL.md).
Resolve its relative references from that source directory; `<animatic>` is its
vendored sibling, not the local adapter. Keep the staged interview, voice samples,
one-moment build and tested configuration requirements.

## Execution scope

- Inspect the actual machine before asking tool questions. Recommend existing
  working choices, explain online/offline behavior and costs, and wait for the
  user's choices. Key presence alone authorizes neither paid speech nor disclosure.
  Show command errors; a fallback remains the user's decision.
- Record the selected machine and installation/cache scope before modifying it.
  For remote setup, require an explicit remote target and authorized access;
  run discovery and tests there, not on the local machine as a proxy. Use the host's
  secure credential flow; unavailable remote access is a blocker, not a reason to
  provision a machine, copy secrets or change SSH/global settings.
- Reuse the target's toolchain and approved dependency locations. The upstream
  helper installs its own npm dependencies under `ANIMATIC_HOME`; explain that
  behavior before running setup. Use a scratch cache for a disposable test.
- Write only tested flags and environment-variable names to the target repo's
  `docs/agents/animatic.md`, after showing the proposed content. Preserve existing
  choices and keep secret values in the environment or the host's secret manager.
- Add the config pointer through the canonical source of generated instructions,
  then regenerate; edit authored guidance directly only where permitted. In this
  harness `AGENTS.md` is generated from `CLAUDE.md` and `.agents/codex-appendix.md`.
  Create neither instruction file just for this pointer.

Finish with the tested machine, config path, chosen tools, voice sample and test
MP4 paths, and any remaining limitations. Vendoring these skills does not run setup.
