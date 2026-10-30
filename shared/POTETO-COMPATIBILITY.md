# Poteto in this harness

All pstack skills and support files ship unchanged in `vendor/pstack/`. The
`poteto-skills/poteto-*` adapters expose every skill, including Benny's three operational/setup
skills. Existing `/tdd`, `/swarm`, `/teach`, and the curated verification skills
keep their current behavior. [Inventory and source pin](../vendor/pstack.lock.json).

## Apply in the current host

- Existing owners automatically load the applicable [native adaptation](POTETO-NATIVE.md)
  through scoped links in their own skills. Structural design retains the
  [curated engineering rules](POTETO-ENGINEERING.md). Source links are provenance;
  adaptations do not invoke explicit-only `poteto-*` workflows. Keep those user-invoked.
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
- Discover available tools and the host identifiers for the permitted models instead
  of copying Cursor-only defaults. If a required tool, control skill, automation editor, or agent role is
  unavailable, state the limitation. Use an available equivalent only when it
  preserves the contract; never claim unperformed verification or delegation.
- Keep model configuration in `config/model-routing.json`. Before applying any
  upstream role or setup workflow, run
  `python3 <plugin-root>/scripts/vendor-poteto.py --model-rule` and use its generated
  role assignments, not upstream defaults.
  This read-only command rejects unsupported models and reasoning budgets.
- Only **Opus 5.5** (`claude-opus-5-5`) and **GPT-6.1 Sol** (`gpt-6.1-sol`), at
  `xhigh`, may execute work. Grok and every other model are forbidden across defaults,
  panels, fallbacks, automation workers, and bots. Ignore incompatible upstream or
  existing Cursor role rules; `auto` and `inherit-parent` cannot bypass this limit.
  If the permitted host model is unavailable, follow the canonical routing policy's
  two-model fallback or report the lane blocked. Never fall back to an upstream model.
- `/poteto-setup-pstack` may write the generated rule only during explicitly requested
  Cursor setup, without offering upstream model/budget choices. Reading a skill in
  Codex does not authorize writing Cursor rules or changing Codex settings. Model
  assignments do not authorize delegation; all existing consent rules still apply.
- For each authorized delegate or automation, pass this compatibility file's absolute
  path and the permitted role assignments. Require compatibility loading before
  upstream instructions so a cold delegate cannot resume upstream Grok defaults.
- Benny's source pack, templates, and setup flow are included. Only set up or
  enable live automation when requested, with its required integrations and
  upstream readiness checks. Vendoring does not install or enable automations.
- Formal/statechart tools and video recaps remain explicit requests. Model results
  need implementation replay and stated bounds; neither a chart nor a passing model
  proves the real code. A source helper's automatic Java/TLC/mise installation,
  external rendering, Tailscale setup or webhook exposure needs its own authorization.
  Use exposed host tools and secret delivery instead of copying Cursor-only APIs.

The snapshot is source material, not an installed second plugin. No upstream
agents, sticky modes, background scripts, or automations are activated by packaging.
