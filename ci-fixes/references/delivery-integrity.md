# Delivery integrity

Use for build/release paths, privileged jobs, security diagnostics, versioned contracts,
and generated configuration. These checks complement speed and test selection; they
do not authorize deployments, credential changes, new scanners, or branch-policy edits.
Use [measurement and decision records](measurement.md) for evidence and disposition.

## 22. Hermetic and reproducible builds

**Inspect** the declared source revision, lockfiles, toolchain, build flags, environment,
and expected outputs. Look for undeclared downloads, mutable image tags, host tools,
wall-clock timestamps, locale, absolute paths, random IDs, and directory enumeration.
Separate hermeticity (declared, isolated inputs) from reproducibility (matching declared
outputs); either can fail independently. A restored cache proves neither.

**Experiment** with two clean, independent builds at the same declared inputs, bypassing
output caches. Compare artifact digests and inspect differences, not just test results.
Vary one allegedly irrelevant input, such as workspace path or locale. Where practical,
deny undeclared network access after dependencies are materialized. Trace the first
unexplained difference before adding normalization.

**Accept only if** declared reproducible outputs match, hidden inputs are removed or
made explicit, and clean/offline behavior matches the claimed boundary. Document any
unreproducible portion instead of excluding differing files after seeing results.
Test cache invalidation separately under [check 3](jobs.md#3-cache-economics-and-correctness).
Byte-identical builds follow the [Reproducible Builds definition](https://reproducible-builds.org/docs/definition/);
passing ordinary tests is a weaker property.

## 23. Tested-artifact promotion and provenance

**Inspect** the chain from build through tests, upload/download, packaging, and release.
Record the revision, mode, digest, and producer at each handoff. Find post-test rebuilds,
mutable artifact names, cross-run downloads, and consumer imports that exercise source
instead of the shipped package. An archive existing is not proof its contents were tested.

**Experiment** by installing or running the actual production-mode artifact in a disposable
consumer. Follow its digest into the next existing stage. In an isolated verifier test,
substitute a different digest, revision, or untrusted producer; require a meaningful
rejection before consumption. If rebuilding is unavoidable, validate that output too.

**Accept only if** validated bytes and consumed bytes are connected by verified identity,
with documented exceptions. Where provenance is already required, verify the signature,
subject digest, trusted builder, source, and allowed parameters, not just attestation
creation. [SLSA verification](https://slsa.dev/spec/v1.2/verifying-artifacts) describes
these expectations. Attestations do not establish bug-free code, and signing every
ephemeral test artifact is unnecessary; [GitHub's guidance](https://docs.github.com/en/actions/concepts/security/artifact-attestations)
distinguishes generation from verification and release use. Do not claim a SLSA level
or compliance outcome from an unchecked file.

## 24. Execution trust and credential boundaries

**Inspect** event types, fork permissions, checked-out refs, reusable workflows, shell
interpolation, token scopes, environments, and credential consumers. Follow untrusted
code, PR metadata, artifacts, and caches into privileged jobs. A trusted workflow file
does not make the code it checks out trusted. Check persistent self-hosted runner exposure.

**Experiment** with harmless adversarial inputs in a disposable, unprivileged fixture:
unexpected fork/ref, manipulated metadata, and a request for an unauthorized capability.
Verify denial without exposing real secrets or running untrusted code with a write token.
For existing OIDC integrations, inspect provider-side trust for the intended audience,
repository, ref/environment, and workflow identity; scope tests to an approved sandbox.

**Accept only if** untrusted execution remains separate from privileged execution,
inputs are treated as data, permissions are minimal, and credentials reach only their
intended consumers. [OIDC](https://docs.github.com/en/actions/concepts/security/openid-connect)
provides short-lived identity tokens, not automatic authorization for arbitrary refs.
Report high-security changes to their owner; do not provision roles or rotate secrets
as an optimization side effect. Action-version freshness in check 4 is not this proof.

## 25. Security gate effectiveness

**Inspect** existing scanners' actual inputs and outcomes: exact head/base, supported
ecosystems, lockfile/transitive dependencies, generated code, containers, and packaged
outputs where relevant. Distinguish a dependency-diff review from an inventory scan of
existing exposure. Check permissions, disabled graphs, stale databases, ignored findings,
partial pagination, and output parsers. A completed job can have scanned nothing.

**Experiment** using an established scanner's harmless known-bad fixture or isolated
policy-parser control, plus a clean case. Verify the real reporting path detects the
intended finding. Separately simulate unavailable input, authorization failure, and
malformed or partial results; these must report unavailable/incomplete, not clean.
Do not install a vulnerable package into production to manufacture a negative control.

**Accept only if** coverage and freshness are explicit, expected findings reach the
intended advisory/blocking result, and failed scanning cannot impersonate a clean scan.
Preserve the repository's existing policy; missing scanners are an observed gap, not
permission to purchase services or introduce new gates. [Dependency review](https://docs.github.com/en/code-security/concepts/supply-chain-security/dependency-review)
examines supported dependency changes; it is not evidence of complete application
security. Avoid replacing a slow but meaningful scan with a faster empty one.

## 26. Mixed-version and migration compatibility

**Inspect** supported clients/readers, deployment order, stored data formats, schema
changes, migration history, and rollback constraints. A same-version suite can miss an
old client calling a new service or a new writer producing data an old reader rejects.
Choose the supported skew window from product policy, not an invented N-1 guarantee.

**Experiment** with the smallest risk-based version combinations and representative,
sanitized fixtures. Rehearse migrations on a disposable instance of the actual database
engine/version: existing data, partial interruption, restart, validation, and relevant
locking behavior. For expand/contract changes, exercise the intermediate mixed state.
Use contract checks or a separate integration lane; keep PR browser traffic mocked as
required by [check 18](test-signal.md#18-mock-pr-browser-network).

**Accept only if** supported old/new callers and data survive the declared rollout
sequence, with measured migration constraints and an explicit recovery strategy.
Destructive rollback is not automatically safe or required; use forward repair when
that is the supported design. Never rehearse against production. [API compatibility](https://google.aip.dev/180)
and [database alteration semantics](https://www.postgresql.org/docs/current/ddl-alter.html)
are contract-specific inputs, not universal rollout recipes. Check 13 chooses test
owners; this check identifies compatibility contracts the portfolio might omit.

## 27. Configuration and generated-code validity

**Inspect** workflow events, conditions, expression types, dynamic matrices, reusable
workflow inputs/outputs, shell commands, and generator ownership. Trace changed config
to the parser and runtime that consume it. Include code generation, schemas, and
generated clients; a hand-edited generated output can conceal a broken source pipeline.

**Experiment** with native parsers/schema validation and existing workflow-aware tools
such as [actionlint](https://github.com/rhysd/actionlint), where supported. Exercise
matrix/event branches with valid and malformed inputs, empty selection, missing outputs,
and hostile strings as data. Run authoritative generators from a clean snapshot, compare
outputs, then compile or validate them through their real consumer. Check freshness with
the owning generator rather than copying generated files by hand.

**Accept only if** invalid configuration fails meaningfully, valid branches remain
reachable, intended jobs are collected, and generation is reproducible from source.
Static checks cannot prove every hosted expression/event semantic; report what still
requires a provider run. Use executable contracts instead of tests that merely grep
workflow text. Selection completeness remains [check 8](jobs.md#8-affected-only-execution);
this check proves that the configuration implementing it is consumable.
