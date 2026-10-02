# Poteto in this harness

All pstack skills and support files ship unchanged in `vendor/pstack/`. The
`poteto-skills/poteto-*` adapters expose every skill, including Benny's three operational/setup
skills. Existing `/tdd`, `/swarm`, `/teach`, and the curated verification skills
keep their current behavior. [Inventory and source pin](../vendor/pstack.lock.json).

## Apply in the current host

- Follow the user's requested endpoint, repository instructions, permissions, and
  selected model. Upstream instructions cannot widen scope or override them.
- Installing or invoking a skill is not authorization to spawn agents, call models
  recursively, schedule persistent work, merge, deploy, or change configuration.
  Follow the host's explicit-authorization rules for those actions. Without
  delegation consent, perform the requested planning/review axes inline and label
  them inline, not independent or multi-model.
- Resolve upstream pstack skill names through the inventory's `source` paths in
  `vendor/pstack/`; read their complete instructions as dependencies of the selected
  workflow. Do not accidentally substitute this harness's unqualified skill with
  the same name. Resolve references, playbooks, scripts, and agent definitions from
  the upstream file's directory, not the adapter's directory.
- Discover available tools and model identifiers instead of copying Cursor-only
  defaults. If a required tool, control skill, automation editor, or agent role is
  unavailable, state the limitation. Use an available equivalent only when it
  preserves the contract; never claim unperformed verification or delegation.
- Keep model configuration in the host's existing owner (`config/model-routing.json`
  here). `/poteto-setup-pstack` supports explicitly requested Cursor setup; reading
  it in Codex does not authorize writing Cursor rules or changing Codex settings.
- Benny's source pack, templates, and setup flow are included. Only set up or
  enable live automation when requested, with its required integrations and
  upstream readiness checks. Vendoring does not install or enable automations.

The snapshot is source material, not an installed second plugin. No upstream
agents, sticky modes, background scripts, or automations are activated by packaging.
