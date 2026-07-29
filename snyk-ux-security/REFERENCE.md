# Snyk security reference router

Read [shared triage](references/triage.md) for every finding. Then load only the branches
that match the target and requested endpoint:

| Branch | Trigger | Completion |
|---|---|---|
| [JavaScript](references/js.md) | target has `package.json` | JS scan, reachability, supply-chain, migration, lockfile, and verification gates are recorded |
| [Go](references/go.md) | target has `go.mod` | Snyk and govulncheck reachability, module update, and verification gates are recorded |
| [Bazel](references/bazel.md) | target has `MODULE.bazel` or `bazel/repositories.bzl` | mirror, FIPS, backport, target-branch, and Bazel verification gates are recorded |
| [Publish](references/publish.md) | requested endpoint includes commit, PR, cloud review, or aggregate report | requested external artifact exists with reviewer, label, and evidence fields |

Do not load publication guidance for a report-only or verified-local endpoint.
