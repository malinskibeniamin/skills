# Rule catalog

Single source of truth for review rules. Every catalog entry is backed by at least three
independent review examples collected over two years. Grades express aggregate support:
S/A is the enforced core; B is adopted; C/D wording is provisional -- flag C/D only when
the diff plainly violates the statement.

Cite the rule id in findings. n = independent evidence count.

## Proto design

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| S | `proto-getters-for-nil-safe-traversal` | Traverse protobuf messages with generated getters instead of manual nil-check ladders. | 27 |
| S | `proto-annotations-own-field-contracts` | Put field behavior, requiredness, format, enum, and numeric bounds in proto annotations rather than duplicating the contract in service code. | 19 |
| S | `proto-optional-only-for-semantic-presence` | Use proto optionality only when unset has different domain meaning from the zero value; express update intent with the update mask. | 8 |
| A | `dedicated-resource-write-and-read-shapes` | Use dedicated create, update, and read-resource proto shapes; share a write shape only when the accepted fields are truly identical. | 8 |
| A | `provider-specific-config-uses-oneof` | Model mutually exclusive provider configuration as typed oneof variants, leaving only truly cross-provider concepts at the top level. | 6 |
| B | `public-resource-references-use-aip-names` | Expose canonical AIP resource names in public references, keep database IDs internal, and parse names through one typed compatibility-aware parser. | 8 |
| B | `reserve-removed-proto-number-and-name` | Never renumber shipped protobuf fields; when removing one, reserve both its number and name. | 4 |
| B | `public-identifier-fields-name-the-concrete-resource` | Name public identifier fields for the concrete resource or domain role they identify and suffix scalar or repeated identifiers with `_id` or `_ids`. | 3 |

## API / gRPC / Connect

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| S | `collection-rpcs-use-list-and-pagination` | Name collection retrieval List, reserve Get for one resource, and design list or bulk APIs with filtering and pagination. | 14 |
| A | `reject-invalid-explicit-input` | Reject invalid values explicitly supplied by a caller instead of silently skipping or replacing them with defaults. | 9 |
| B | `protovalidate-runs-once-at-rpc-boundary` | Run Protovalidate in shared RPC middleware and do not repeat guaranteed nil or format checks in each service handler. | 5 |
| B | `asynchronous-resource-mutations-return-operations` | Return the repository's standard long-running operation shape for asynchronous public resource mutations instead of presenting them as synchronous. | 4 |

## Errors

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| S | `public-errors-use-structured-actionable-details` | Return user-correctable failures as structured Connect or gRPC errors with stable reasons and field violations tied to public request fields. | 18 |
| S | `preserve-upstream-protocol-error-granularity` | Inspect and preserve upstream protocol errors at their native response level, then map them through domain-specific public error helpers. | 18 |
| S | `translate-and-sanitize-errors-at-api-boundary` | Translate storage, provider, and internal failures at the service/API boundary; log the original and expose only safe, actionable public details. | 12 |
| A | `returned-errors-preserve-cause-and-call-context` | Wrap returned errors with `%w` and call-specific operation, resource, and call-site context. | 12 |
| A | `best-effort-batches-preserve-item-results` | When batch items are independent, attempt every bounded item, preserve input order, and return per-item failures instead of discarding partial success. | 9 |
| B | `unrecoverable-process-state-exits-for-supervisor-recovery` | Fail startup or exit for supervisor restart when required configuration, credentials, resource names, or supervised child processes cannot support correct service operation. | 12 |
| B | `string-error-matching-is-a-narrow-documented-last-resort` | Prefer typed errors; when an upstream contract forces string matching, keep the match narrow and document why structured matching is unavailable. | 3 |
| C | `different-failure-states-have-distinct-errors` | Use distinct, accurate messages for different timeout, token-rotation, validation, and workflow failure states. | 4 |
| C | `controller-errors-preserve-last-good-state` | Propagate reconciliation and status-write errors, and never treat a transient dependency failure as proof that observed state was deleted or successfully advanced. | 4 |
| C | `deterministic-temporal-failures-are-nonretryable` | Classify deterministic provider, validation, and immutable-artifact failures as non-retryable Temporal errors. | 3 |
| C | `recoverable-invalid-input-returns-errors-not-panics` | Return errors for recoverable dependency failures and user-controlled invalid input instead of panicking. | 3 |
| D | `numeric-conversions-check-kind-range-and-exactness` | Before numeric conversion, accept every intended input kind and verify range, scale, and exact representability before narrowing. | 6 |
| D | `optional-notifications-never-block-critical-workflow` | Log and continue when an optional courtesy notification fails; never let it block the required billing, suspension, or deletion action. | 4 |
| D | `cleanup-partial-resources-on-error` | Close resources returned alongside errors and clean up partially initialized clients. | 3 |

## Security & tenancy

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| S | `secrets-are-references-with-minimal-exposure` | Accept and store secret references rather than plaintext, never return stored secret material, and expose the minimum environment/capability needed to resolve it. | 11 |
| S | `security-state-and-predicates-fail-closed` | Make security predicates, startup configuration, policy snapshots, and capability checks deny or fail startup when required state is missing, partial, or errored. | 11 |
| A | `tenant-egress-routes-through-safedial` | Route every tenant-controlled outbound destination through safedial, including SDK transports, redirects, nested references, DNS, and cluster-internal CIDRs. | 5 |
| B | `destructive-safeguards-cover-exact-resource-set` | Deletion safeguards must cover every and only the managed resource instances reachable in the selected provider and lifecycle transition. | 7 |
| B | `destructive-tools-require-explicit-scope-and-intent` | Require explicit environment, scope, and confirmation before destructive CLI or cleanup work; default to no mutation. | 6 |
| B | `rotate-credentials-with-overlap` | Rotate live credentials with overlapping old and new material, switching readers before retiring the previous credential. | 5 |
| B | `secret-bearing-log-values-are-redacted` | Redact credential-shaped values before logging and never dump whole secret-capable configuration or request objects. | 4 |
| B | `referential-checks-precede-resource-deletion` | Check authoritative references before entering deletion or invoking the provider, and require the explicit deletion strategy where supported. | 4 |
| B | `tenant-database-isolation-uses-sessionrunner-and-rls` | Run tenant database access in transaction-scoped SessionRunner context backed by RLS, and test through the non-privileged application role. | 3 |
| B | `cross-cutting-gates-cover-every-entrypoint` | Apply authorization and feature gates to every live RPC, interceptor, proxy, hook, attach path, and raw HTTP entrypoint for the capability. | 3 |
| C | `authorization-schema-changes-migrate-existing-relations` | Ship authorization relationship schema changes with sync, backfill, and deletion handling for existing resources and role bindings. | 4 |
| C | `kubernetes-teardown-waits-for-finalizers` | Delete Kubernetes ownership layers in reverse dependency order and keep providers available until dependent resources and finalizers are gone. | 3 |
| C | `dynamic-deletion-safeguards-follow-feature-state` | Derive deletion safeguards for optional resources from the desired feature state, including both enable and disable transitions. | 3 |
| C | `authorization-policy-has-one-central-source` | Keep authorization requirements and fallback checks centralized in one source of truth; require explicit value and failure-mode analysis before adding another source. | 3 |

## Concurrency & lifecycle

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| A | `resource-lifecycle-operations-are-idempotent` | Make retriable resource create and delete operations idempotent and classify AlreadyExists or NotFound as success instead of preflighting with a read. | 8 |
| A | `etag-preconditions-protect-resource-mutations` | Carry resource etags through update and delete calls and enforce the precondition atomically with the storage mutation. | 6 |
| A | `shared-mutable-initialization-has-one-sync-owner` | Give shared mutable state one synchronization owner and initialize expensive process-wide state lazily with a single once-only path. | 6 |
| A | `publish-cache-snapshots-atomically` | Replace shared cache or policy state only after a complete successful refresh; on partial failure keep the last good snapshot. | 5 |
| A | `commit-progress-only-after-durable-processing` | Advance consumer offsets, checkpoints, or drop eligibility only after all required processing and durable side effects complete. | 4 |
| A | `blocking-hooks-stay-outside-critical-locks` | Run blocking I/O, connection teardown, and user callbacks outside locks and protocol-critical progress loops. | 3 |
| A | `async-resource-lifetime-waits-for-all-users` | Do not close channels, processors, or result resources until every producer, callback, and worker has reached a defined happens-before boundary. | 3 |
| B | `serialize-reentrant-workflows-by-stable-id` | Serialize reentrant workflows per resource with a stable workflow ID and a reuse policy that permits recovery after failure without overlapping runs. | 7 |
| B | `continue-as-new-preserves-and-coalesces-signals` | Before Temporal Continue-As-New, drain or carry pending signals, coalesce replaceable snapshots to the newest value, and rotate before history limits. | 7 |
| B | `temporal-retries-at-the-failing-activity` | Keep Temporal activities bounded and retry transient failures at the failing activity rather than rerunning the whole workflow or hiding a long inner poll. | 5 |
| B | `mutable-buffer-ownership-is-explicit` | Document mutable message and buffer ownership, copy only at ownership boundaries, and publish cache state through owned deep clones. | 3 |
| C | `temporal-external-calls-run-as-activities` | Perform external service calls from Temporal workflows through worker-owned activities. | 6 |
| D | `controller-requeue-is-the-retry-loop` | Let controller requeueing own retries; do not recurse or stack inner retry loops around apply and status publication. | 3 |

## Context

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| A | `propagate-caller-context-and-deadline` | Pass the existing caller or root context through call chains and let its cancellation and deadline govern the operation instead of inventing background contexts or shorter library deadlines. | 7 |
| A | `context-lifetime-matches-operation-owner` | Derive long-lived worker, monitor, watcher, and cleanup contexts from their owning lifecycle, not from a short request context. | 5 |

## Testing

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| S | `integration-tests-cross-real-boundaries` | Use real provider or end-to-end integration tests for boundary contracts that mocks cannot prove, including billing, credentials, serialization, and storage plumbing. | 18 |
| S | `tests-assert-stable-observable-behavior` | Make tests assert stable observable behavior, not merely execute a path, retain dead assertions, or pin incidental error-message text. | 15 |
| A | `new-behavior-variants-get-targeted-regressions` | Give each newly supported failure or classification variant a targeted positive or negative regression test. | 9 |
| A | `unit-tests-stay-offline-with-injected-fakes` | Keep unit tests offline with httptest, injected fakes, or no-op boundary clients unless the test explicitly targets integration semantics. | 5 |
| A | `temporal-code-uses-deterministic-runtime-apis` | Use Temporal's deterministic clock and test environment, and check workflow edits for replay nondeterminism. | 5 |
| B | `test-upgrades-from-existing-deployments` | Test compatibility changes by deploying the pre-change version or fixture first, then upgrading and forcing reconciliation with the new code. | 8 |
| B | `test-service-images-use-supported-pins` | Pin test service and container images to supported release tags rather than floating main, master, or latest. | 5 |
| B | `bounded-eventual-tests-poll-observable-state` | Test asynchronous and eventually consistent behavior by polling the observable completion condition with a context deadline that covers the real stabilization window. | 4 |
| C | `canonicalize-unordered-values-before-comparison` | Canonicalize unordered map, database, and Kubernetes values before equality checks, emitted output, or test comparison. | 3 |
| C | `parallel-integration-tests-own-distinct-resources` | Give parallel or failure-prone integration tests distinct external identities and resource names instead of sharing mutable fixtures. | 3 |
| D | `tests-delegate-lifecycle-to-testing-t` | Use testing.T ownership APIs for temporary files, environment, context cancellation, cleanup, and test logging. | 5 |
| D | `controller-tests-use-production-wiring-and-public-readiness` | Exercise controllers through production manager wiring and assert convergence through the resource's public readiness contract. | 3 |
| D | `ci-exceptions-are-narrow-and-visible` | Scope CI skips and ignored failures to the known provider or expected case, and visibly annotate every noncritical exception. | 3 |
| D | `ci-tests-the-artifact-from-current-change` | Make smoke and relaunchable CI consume the artifact built from the current pull-request head and expose the dependency chain. | 3 |

## Configuration & rollout

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| S | `configuration-uses-semantic-types` | Represent known domain and configuration shapes with typed structs, maps, durations, or enums instead of strings, maps of any, or related boolean sets. | 19 |
| S | `retry-backoff-fits-the-operation-lifetime` | Use operation-specific retry and polling backoff with jitter where appropriate, a bounded maximum, and a cumulative horizon that fits the owning timeout. | 12 |
| S | `feature-flag-risky-mixed-version-rollouts` | Gate risky control-plane/dataplane behavior independently of releases, default experimental components off, and preserve mixed-version compatibility during rollout. | 10 |
| A | `stage-destructive-contract-and-schema-removals` | Stage destructive API, configuration, proto, and database removals: add compatibility, migrate consumers, deploy removal-tolerant code, then delete the old surface. | 9 |
| A | `positive-configuration-booleans-unless-zero-must-fail-safe` | Name configuration booleans for the enabled action and avoid double negatives, except when a negative disabled flag makes the zero value fail safe. | 6 |
| B | `feature-surfaces-change-and-retire-together` | Keep feature declarations, Go/defaulting, install packs, tests, dispatch, implementation, and duplicate constants synchronized through changes and removal. | 18 |
| B | `mirrored-control-values-have-one-authoritative-source` | Define values consumed across code and configuration in one authoritative source and generate or drift-check unavoidable mirrors. | 10 |
| B | `operational-timing-policy-is-configurable` | Put operational timeouts, retry/backoff, and polling windows behind named configuration rather than hard-coded literals. | 9 |
| B | `disabled-features-clear-dependent-state` | Make feature toggles reversible: preserve explicit off, and on disable clear dependent persisted configuration and resources in lifecycle order. | 7 |
| B | `provider-specific-settings-come-from-provider-owned-config` | Source provider-specific annotations, ports, and API options from provider-owned configuration instead of hardcoding one cloud's defaults in shared controllers. | 5 |
| C | `configuration-reuses-repository-standard-package` | Extend the repository's existing configuration package instead of creating parallel plumbing, and keep defaults in that owner. | 3 |
| D | `pointers-only-for-semantic-optionality` | Use pointer fields only when nil is a meaningful third state; keep required values non-pointer and preserve zero versus unset where the domain distinguishes them. | 3 |

## Package layout & structure

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| S | `server-files-wire-deep-subsystem-packages` | Keep server/bootstrap files to construction and wiring; place business orchestration and independently deployable responsibilities behind cohesive package APIs. | 14 |
| A | `equivalent-cross-provider-behavior-has-one-implementation` | When provider or API-version behavior is equivalent, keep one shared implementation, factory, or module and branch only for real semantic differences. | 5 |
| B | `comments-change-with-behavior` | Update function and configuration comments whenever the implemented value, failure scope, or operation changes. | 7 |
| B | `persistence-concerns-stay-in-storage-layer` | Keep persistence queries, storage representations, and serialization inside the storage layer; return domain-facing types to services. | 5 |
| B | `storage-access-uses-repository-generators` | Define storage contracts in repository-owned generator inputs and generate Go access and mapping code instead of adding handwritten parallel layers. | 3 |
| C | `kubernetes-ownership-matches-resource-scope` | Use owner references and watches for namespaced children, but add explicit finalizer cleanup when owned resources can be cluster-scoped. | 5 |
| C | `validation-has-one-early-owner` | Validate and default a domain invariant once at the earliest authoritative boundary; remove duplicate downstream guards unless they protect a distinct contract. | 4 |
| C | `separable-breaking-changes-get-separate-prs` | Separate policy or provisioning changes that can break deployments from unrelated fixes. | 3 |
| D | `accept-focused-interfaces-return-concrete-types` | Accept focused interfaces at dependency seams and return concrete types when callers do not need substitutable identity. | 3 |
| D | `controllers-converge-with-server-side-apply` | Use server-side apply patches for controller-owned resources so create and update converge through one ownership-aware path. | 3 |

## Logging & observability

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| A | `service-loggers-come-from-context` | Pull service and storage loggers from context rather than storing or injecting logger fields on request-serving structs. | 13 |
| A | `metrics-have-stable-schema-and-owner` | Give metrics a stable bounded label schema, conventional unit and total names, and an explicit instance owner. | 8 |
| B | `operational-logs-identify-concrete-subject` | Include the concrete resource or workflow identity and relevant compared values in operational logs. | 16 |
| C | `intentionally-ignored-errors-are-logged` | When control flow intentionally continues after an error, emit one contextual log at the owner boundary. | 4 |
| C | `controller-failures-are-visible-in-status` | Before returning a controller or workflow failure, publish the failure or in-progress state through status, events, or the operation record. | 3 |
| D | `material-fallbacks-and-skips-are-observable` | Emit a bounded signal when processing falls back, normalizes imperfectly, or intentionally skips a message. | 3 |

## Performance & bounds

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| S | `bound-workload-and-attacker-controlled-growth` | Put explicit memory, cardinality, fan-out, concurrency, and response-size bounds on every workload- or tenant-controlled path. | 28 |
| B | `reconcile-only-semantic-state-changes` | Hash or diff semantic desired state, skip no-op reconciliations, and coalesce related changes into one update. | 5 |

## Dependencies

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| A | `prefer-official-maintained-protocol-clients` | Use official maintained protocol SDKs, runtimes, serde implementations, and high-level helpers instead of parallel custom or deprecated clients. | 6 |

## Other

| Grade | Rule | Statement | n |
| :---: | --- | --- | ---: |
| A | `version-temporal-workflow-history-then-retire-safely` | Version deterministic changes while deployed Temporal histories can replay them, preserve additive input compatibility, and remove stale version branches only after the history window is gone. | 14 |
| C | `migration-classification-uses-authoritative-full-shape` | Classify node migration type from authoritative machine, storage, profile, and node-pool shape, including documented provider exceptions. | 6 |
