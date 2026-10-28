# Codex review/fix presets

Recall this harness's review and local-fix prompts without retyping them. The exporter
prints native Codex preset configuration; it never reads or changes your personal configuration.
Installing the plugin does not install presets or change models, permissions, or shortcuts.

Verified with Codex CLI **0.164.0** using its configuration validator and `/presets` picker.
The release pin in the README predates this helper; use this checkout until a release includes it.

## Export and choose free slots

From this checkout, run:

```bash
bun run codex:presets --slots 7,8,9
```

For an installed plugin version containing the helper, run
`bun <installed-plugin-root>/scripts/codex-presets.ts --slots 7,8,9` instead.
Find its `installedPath` with `codex plugin list --json`.

Choose 3 unused slots from `0` through `9`. The defaults are `7,8,9`, in this order:

- **Review:** requests the installed harness review skill inline, with findings only and no editing or publishing.
- **Fix locally:** requests TDD and dogfood for the preceding review, stopping before commits, pushes, PRs, merges, or delegation.
- **Review model:** recalls the model and reasoning from [model routing](../config/model-routing.json). It runs only when selected.

Inspect the output. Back up your configuration, then merge only the generated tables into
`$CODEX_HOME/config.toml`, or `~/.codex/config.toml` when `CODEX_HOME` is unset.
Preserve existing settings and occupied slots. Do not redirect with `>` or blindly append
with `>>` to your live configuration: replacement loses settings, and duplicate tables break TOML.
Restart Codex after the manual edit.

## Run a review/fix loop

Open `/presets` or press **Ctrl+X, then P**. Select **Review model** if you want the configured
review model; otherwise keep the current model. Reopen the picker and select **Review**.
Inspect its findings, then select **Fix locally**. Re-run **Review** after verification.
Publication remains a separate, explicit request.

## Sharp edges

- A slot contains a prompt **or** a slash command. Model selection and the review prompt
  are separate presets; the exporter does not silently switch your current model.
- These prompt presets request the harness skills. Codex's built-in `/review` is a
  different entrypoint, not an alias for this harness's review skill.
- **Fix locally** depends on the preceding review in the same conversation. It does not
  recover findings from another thread or turn a review into independent coverage.
- Review is inline, not a fresh-context or independent-agent review. Presets grant no delegation.
- Model availability depends on your account and provider. Check `/model`; there is no
  automatic fallback. To keep another model, skip or edit the model preset.
- Permission, approval-policy, speed, hook, and provider settings are omitted. Native
  **from settings** can capture other settings; inspect those commands before saving them.
- Export again after a harness/model-routing update if you want updated prompts or model settings.
  Existing user presets are copies, not automatically synchronized.

General references: [OpenAI configuration documentation](https://developers.openai.com/codex/config-reference/)
and [CLI slash commands](https://developers.openai.com/codex/cli/slash-commands/).
The preset slot format and settings-command syntax above were verified locally, not inferred from those pages.
