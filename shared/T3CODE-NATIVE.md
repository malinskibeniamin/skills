# Native T3 composition

Keep `/work`, `/tdd`, `/dogfood` and `/full-send` as owners. Select only applicable
branches; the person need not invoke T3 specialists separately. Preserve the
[host compatibility contract](T3CODE-SKILLS.md) and the target's current instructions.

## Resolve context

Run the read-only [resolver](../scripts/resolve-t3-context.py) from the plugin, passing
the **target checkout** explicitly:

```sh
python3 <plugin-root>/scripts/resolve-t3-context.py --root <target-root> --entrypoint work
```

Use the current entrypoint (`work`, `tdd`, `dogfood`, `full-send`). Add `--surface web`,
`mobile` or `both` only for surfaces in scope, and `--effect` only for Effect work.
Add repeated `--tool NAME` only for capabilities actually exposed by the current host:
`preview_status`, `device_list`, `watch_pull_request`. These are discovery entrypoints,
not proof that every interaction tool or device works. Read their actual schemas before use.
Pass `--babysit` only for an authorized `/full-send` monitoring endpoint, never a PR-only stop.
Add `--allow-wake` only when host wake-ups are explicitly authorized for the current task;
tool availability or merge/ship intent alone does not grant that permission. Otherwise
stop after the current status snapshot; monitoring needs an explicit request.

The JSON selects guidance; it does **not** execute checks, invoke tools, grant authority,
or prove verification. Repository markers identify a layout, not a trusted identity.
Malformed input fails visibly. Missing capabilities block only dependent verification;
report them rather than install tools or substitute unrelated coverage.

## Work and tests

Read returned target references completely. For Effect, the installed guide/source wins
over a pinned reference checkout; resolve the owning workspace's installation if the root
has none. Load the returned [Effect development](../t3code-skills/effect-development/SKILL.md)
adapter separately. Do not upgrade or install Effect merely to resolve guidance.

In a T3 checkout, inspect its `check:changed` script and run it through the documented
runner before push. Use focused tests while iterating; do not replace target policy with
our generic repo-wide commands. The current target `AGENTS.md` owns test conventions:
Effect clock/worker milestones instead of sleeps, disposable browser renders, fixture
lifecycle and quarantine rules. Apply them where that checkout supplies the relevant APIs;
do not transplant T3 render helpers or lint plugins into another app.

## Dogfood

Load each returned skill separately through its local adapter: [web/desktop](../t3code-skills/test-t3-app/SKILL.md)
or [mobile](../t3code-skills/test-t3-mobile/SKILL.md). Follow target authorization for
computer use. Reuse owned isolated state and native panels; missing tools remain a named
gap. Outside a T3 checkout, keep the existing project verifier/dogfood path, even if the
host happens to expose Browser or Device tools. A resolver result is not a dogfood receipt.

## PR monitoring

Host and repository are separate: a T3 host can watch a PR for another application.
For `pr_watch: native`, save repository/PR, verified head/base, evidence and pending work
to the session checkpoint, then call the exposed `watch_pull_request` using its actual
schema. Confirm registration before ending the turn for the host to wake it. Do not also
poll or sleep. A failed or uncertain registration requires readback/recovery from the tool
contract; never report it as successful or register duplicate watchers blindly.

On wake, refresh head/base, checks and feedback before continuing `/full-send`. Registration
or pending CI is not completion, approval or merge permission. If the tool is unavailable,
use the existing foreground GitHub check loop; do not install a daemon or change hosts.

[Upstream guidance reviewed at 96f09c65](https://github.com/pingdotgg/t3code/blob/96f09c6558b098f05ad0c027afa3846209c03d4f/AGENTS.md).
The current target and exposed tool contracts remain authoritative, not this review date.
