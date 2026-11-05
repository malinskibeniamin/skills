# Model launch policy

`config/model-routing.json` is the source of truth for preferred model IDs and
provider-specific defaults. Model aliases and unlisted overrides fail before
launch; an allowed GPT ID is not a Claude CLI model, or vice versa.

- Agent-eval experiment configs resolve routes through `scripts/model-policy.ts`.
- `model-switch-router.sh` denies unlisted switches, including SDK selections.
- `bun scripts/model-policy.ts hook` validates direct structured Agent, Task,
  native spawn and T3 model selections. Unverified fixed-model specialists are
  blocked; built-in Claude Explore/Plan roles are not presumed to inherit.
  Generic agents keep the already selected model.
- `bun scripts/model-policy.ts check MODEL...` preflights explicit IDs.
- `bun scripts/model-policy.ts claude-settings` prints managed Claude settings
  derived from the current route. Preview only; it does not install policy.

The installed `~/.config/frontend-skills/model-routing.json` takes precedence
over environment or project defaults. Without that profile, `MODEL_ROUTING_FILE`
can select the canonical live checkout. Dangling profile symlinks fail closed. The
separate docs-team-standards evaluator supports this personal policy at subject
and judge dispatch; no personal policy leaves that team's defaults unchanged.

## Enforcement boundaries

Hooks do not see arbitrary subprocess/API calls, and a host can bypass user
hooks or supply its own model restrictions. Local profile defaults are not a
machine-wide ban. Claude's strict initial/default/background/SDK model coverage
requires managed `availableModels`, `availableModelsMatch: "exact"`, and
`enforceAvailableModels`, deployed by an administrator. Embedding hosts and
remote/CI machines need their own enforced policy. Do not describe uninstalled
managed policy or unmerged evaluator changes as active universal enforcement.

Offline regressions: `bun test ./scripts/model-policy.test.ts`.
