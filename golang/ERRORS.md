# Errors, logging, observability

Boundary translation and public error shape live in [PROTO-API.md](PROTO-API.md).
Catalog: [rule catalog](../golang-review/RULES.md).

## Returning errors

- **returned-errors-preserve-cause-and-call-context** -- wrap with `%w` plus the
  concrete operation and resource: `fmt.Errorf("lock cluster %s: %w", id, err)`.
  Callers keep `errors.Is/As`; operators learn which step failed.
- **different-failure-states-have-distinct-errors** -- timeout vs rotation vs validation
  vs workflow-stage failures read differently; automation and on-call must tell them apart.
- **recoverable-invalid-input-returns-errors-not-panics** -- user-controlled input and
  dependency failures return errors; a panic converts one bad item into process-wide
  unavailability.
- **string-error-matching-is-a-narrow-documented-last-resort** -- prefer typed errors;
  when an upstream forces substring matching, keep the match minimal and document why
  structured matching is unavailable.
- **cleanup-partial-resources-on-error** -- APIs can return a usable resource *with* an
  error; close what came back and unwind partial client initialization or reconnect
  state stays poisoned.
- **unrecoverable-process-state-exits-for-supervisor-recovery** -- when required config,
  credentials, or a supervised child cannot support correct operation, fail startup or
  exit; limping past hides the misconfiguration from the supervisor that could fix it.
- **optional-notifications-never-block-critical-workflow** -- courtesy notifications log
  and continue; billing, suspension, and deletion never wait on them.

## Logging

- **service-loggers-come-from-context** -- pull the logger from context (it carries
  request, tenant, and session fields); never store logger fields on request-serving structs.
- **operational-logs-identify-concrete-subject** -- name the resource, workflow, region,
  version, or compared values; a log line that cannot be correlated explains nothing.
- **intentionally-ignored-errors-are-logged** -- best-effort continuation emits exactly
  one contextual log at the owner boundary: invisible partial failure or duplicate
  noise are both wrong.
- **secret-bearing-log-values-are-redacted** -- see [SECURITY.md](SECURITY.md).
- **material-fallbacks-and-skips-are-observable** -- fallback paths, imperfect
  normalization, and intentional skips emit a bounded signal; silent degradation reads
  as success until the data is gone.

## Metrics

- **metrics-have-stable-schema-and-owner** -- bounded label schema, conventional
  unit/total naming, one explicit owner per instance; ad hoc labels are cardinality
  debt and duplicate registrations merge unrelated state.
