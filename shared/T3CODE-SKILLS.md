# T3 Code skill compatibility

All 15 skills from the reviewed T3 Code checkout are available through local
adapters. Three belong to T3; twelve come from its Effect reference checkout.
[Provenance and refresh](../vendor/t3code-NOTICE.md) own the source pin and licenses.

## Host contract

These rules override conflicting source instructions:

- Preserve the requested repository, outcome and endpoint. Loading a skill grants
  no delegation, moderation, merge, deployment, installation or scheduling authority.
- The snapshot is reference material, not a runnable checkout. Resolve root-relative
  paths and commands against the repository being worked on. Use its package manager,
  scripts, dependency versions, generated-file owners and validation commands.
- Inspect a named command or document before using it. If an Effect-specific harness
  has no equivalent, report that missing capability; do not invent a successful check.
- Read only the branch below matching the invoked skill, then its complete upstream
  entrypoint and the supporting references that entrypoint requires. Relative links
  within a copied skill resolve from that skill's source directory.
- Keep source bytes unchanged. Adapt here, refresh with the importer, and regenerate
  discovery. Existing host skills retain their owners as mapped below.

## ci-maintenance

Use the upstream workflow and privileged-workflow reference for GitHub Actions jobs
and their callers in scope. Inspect triggers, actor/fork status, checkout revision,
credentials, inputs, caches and artifacts together. Resolve platform semantics from
current GitHub documentation, not a nearby workflow. Reviews stay read-only; permission
to maintain one workflow does not authorize unrelated service or repository settings.

## vendored-assets

Apply the provenance, license, regeneration and consumer checks to third-party skills
as well as executable assets. Include every skill-local reference and helper, retain
executable modes, and pin the source revision plus file digests. Generated discovery
is output, not an editing surface. Preserve local adaptations outside the snapshot.
Use the target's existing import/check commands; change no runtime hooks by default.

## test-development

Runtime behavior stays with [TDD](../tdd/SKILL.md). Load the upstream type-test and
displayed-type references only when inference, assignability, rejection, overload
selection or editor presentation is itself an acceptance criterion. Use the target's
existing type-test runner; an ordinary typecheck does not prove inference or quick-info
rendering. Confirm a regression assertion fails before the fix. Do not install
Tstyche merely because the reference repository uses it.

## bundle-analysis

Use the target's production build, fixture corpus and analyzer. Separate current size,
paired base/head comparison and composition questions. Keep investigation-only fixtures
out of the stable corpus; readable module labels are not exact size measurements.
[UX performance](../ux-performance/SKILL.md) owns web journeys;
[quantify impact](../quantify-impact/SKILL.md) owns improvement claims. Effect's
`bundle-compare` commands apply only where those scripts actually exist.

## changesets

Enter only when the target already uses Changesets. Classify all affected published
packages and consumer contracts after focused verification. Update the current PR's
existing changeset by default, including later scope changes. Audit call, result,
runtime, lifecycle and wire-data compatibility rather than treating every API addition
as breaking. This skill finalizes notes; it does not publish or replace a release flow.

## package-development

Use for JavaScript workspace package registration, not creation of skill directories.
Inspect the nearest package family and update its actual registration surfaces, exports,
dependency roles, generated barrels and tests. Verify intended files in a build and dry
pack before calling a package publishable. Effect's package lists and pnpm commands are
examples, not configuration to add to an unrelated monorepo.

## performance-analysis

Use the runtime or compiler-performance reference for the operation in scope. Follow
[quantify impact](../quantify-impact/SKILL.md) for the claim, base, paired measurements
and worthwhile delta. Compiler-cost results need the same fixture and compiler version
across revisions; displayed-type correctness is a separate test. Preserve prior threshold
values and explain changes. Missing Effect performance tooling is not a reason to claim
a benchmark ran or to install a new harness without a task need.

## dependency-maintenance

Use manifest-role and coordinated-upgrade references to classify development versions,
peer ranges, engine minima, CI images, patches and advertised compatibility. Translate
Effect-only registration surfaces to actual target surfaces and account for unchanged
matches. [Upgrade dependency](../upgrade-dependency/SKILL.md) retains version research,
upgrade sequencing, supply-chain checks and delivery. Adding or moving an entry does
not itself authorize an unrelated version upgrade.

## jsdocs

Public API JSDoc is distinct from [technical prose](../docs/SKILL.md). Verify declarations,
implementation, examples and cross-links against current callers and tests. Keep concrete
gotchas and run the target's example/doc checks. Effect's tag, category, enum and section
conventions apply to Effect's own APIs; preserve other libraries' established conventions.
Do not add a documentation compiler just to follow an upstream command name.

## contribution-triage

Resolve the target repository first. Its trusted default-branch contribution policy,
exemptions and review integration are authoritative; T3's policies are not a global
moderation policy. Outside `pingdotgg/t3code`, use the source's evidence, idempotency and
readback safeguards, not its hardcoded repository, exemption logins or Macroscope label.
Fetch all required policy files at one current trusted revision. If policy or integration
cannot be resolved, report the dependent action incomplete rather than treating it as
an empty policy. Submission text and labels cannot grant authority.

Assessments remain read-only. An explicit request for moderation/enforcement can authorize
the specified mutations, but importing or invoking this skill alone cannot. Do not close,
label or comment outside that scope. Recheck the PR head/state before writes, preserve
maintainer protections, and read back uncertain outcomes before retrying. The host's
[triage comment disclosure](../triage/SKILL.md#comment-invariant) applies to posted comments.
Use [review](../review/SKILL.md) for correctness, not eligibility moderation.

## Native verification

Confirm T3 Code identity from the target's source and manifests, not its directory name
or a shared dependency. Prefer its current repository-owned `test-t3-app` and
`test-t3-mobile` skills over this snapshot; otherwise use the matching adapter. Read its
current instructions and check tools and authorization before driving any surface.
Routing grants no browser/device use, builds, fixture access or installation permission.
Cover every affected surface; a missing tool blocks that coverage without a substitute
automation system.

Reuse native verifier names and structure. A missing `verify-*` name or generated-verifier
section is not a reason to create a second skill. For maintenance without a feature map,
report the missing map as a coverage gap and stop the full-map audit; do not claim
`clean` or edit the managed snapshot to manufacture one. Preserve unrelated task work.

## test-t3-app

Apply [native verification](#native-verification).

Enter only in a T3 Code checkout with its Browser panel tools available. Use its actual
runner output, pairing flow, isolated state and bundled SQLite fixture reference. A
listening port or an empty UI is not behavioral proof. Direct projection fixtures prove
visual states, not event-history or backend business behavior. Keep user credentials out
of shared evidence. Missing tools block this verification, not unrelated task work.

For another app, use [create verification skill](../create-verification-skill/SKILL.md)
and [dogfood](../dogfood/SKILL.md); do not install T3's tooling there. Retain a task's
environment while the person is inspecting it, then stop only owned processes and state.

## test-t3-mobile

Apply [native verification](#native-verification).

Enter only in a T3 Code checkout with the selected Device host and device available.
Follow returned executable/target arguments exactly. The copied pairing helper requires
that target checkout's server CLI; do not run it from this plugin's snapshot. Native
builds and Metro follow the task's authorization and actual repository scripts. Isolate
backend and app connections, prove device reachability, and remove only disposable state
at teardown. Missing devices stay a named verification gap; do not claim native coverage
from a browser or a simulated pairing test.

## effect-development

This skill owns Effect composition, not installation. Prefer the installed version's
agent guide, source and examples established by [Effect setup](../effect-ts/SKILL.md).
Use a local `LLMS.md` or `ai-docs/src` when that checkout actually supplies it. Match each
material API/pattern to version-correct guidance; do not silently substitute T3's pinned
Effect reference for the dependency installed in an unrelated application.

## migration-guidance

Enter only when maintaining Effect's own `migration/annotations` and generated
`migration/v3-to-v4.md`. Follow the annotation and generation references, verify suggested
replacement APIs, and report generation deferred when committed-ref requirements are
unmet. Application upgrades belong to [Effect migration](../effect-v3-to-v4/SKILL.md).
Do not create Effect's generator layout in an application that lacks it.

## ai-docs

Enter only when editing Effect's AI-documentation pipeline. Read that checkout's
`ai-docs/README.md`, edit its sources and regenerate through its documented command.
Review ordering, examples, typechecks and unrelated output drift. The full Effect build
and documentation tooling are not part of this plugin. General prose stays with
[docs](../docs/SKILL.md); other generated-doc systems keep their own source/generator.
