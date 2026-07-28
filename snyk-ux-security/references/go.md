# Go dependency branch

Read after [shared triage](triage.md) for a `go.mod` target.

## Go ecosystem notes

- Use `snyk test --file=go.mod --file=go.sum`. Snyk supports Go
  modules natively.
- `govulncheck` is the Go-native static reachability tool from the Go
  security team. Prefer its reachability verdict over raw CVE lists
  -- it flags only vulns actually reachable from call graph. This
  feeds the exploitability triage (2b) for Go paths.
- For transitive-only vulns that `govulncheck` marks non-reachable,
  dismiss via `snyk ignore` with reason `govulncheck: not reachable
  from call graph`.
- Never use `replace` directive as a first move. Direct
  `go get -u <module>` comes first; `replace` is last resort and
  needs a tracking issue.
- `go mod tidy` after every change. Never hand-edit `go.sum`.
- Ensure `go.mod` `go 1.XX` directive stays within the repo's
  supported range (don't bump the toolchain line as part of a CVE
  sweep -- that's a separate change).
