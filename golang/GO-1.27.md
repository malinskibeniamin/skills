# Go 1.27 release contracts

Use these source-backed checks for Go 1.27 language and runtime behavior. They are
versioned contracts, not additions to the empirical review-rule catalog.

## Contents

- [Version gate](#version-gate)
- [Generic methods in SDKs and libraries](#generic-methods-in-sdks-and-libraries)
- [Goroutine leak profile](#goroutine-leak-profile)
- [Primary sources](#primary-sources)

## Version gate

- **generic-method-version-floor** -- before adding Go 1.27 syntax to a module,
  confirm its `go` directive, CI toolchain, analyzers, generators, and supported consumer
  floor can all move to Go 1.27. A generic method is a
  [Go 1.27 language feature](https://go.dev/ref/spec#Method_declarations); do not make a
  library's compiler requirement an accidental side effect of API cleanup.
- Run the module's tests with the declared minimum Go version. In Go 1.27, `go test`
  [runs the `stdversion` vet check by default](https://go.dev/doc/go1.27#go-command), but
  that check does not replace compiling and testing the public surface at the promised
  consumer floor.

## Generic methods in SDKs and libraries

Generic methods let a concrete receiver own a generic operation:

```go
func (c *Client) Decode[T any](data []byte) (T, error)
```

Use one when the receiver owns meaningful state or policy and the method improves
discovery or left-to-right composition. Keep a package-level generic function when no
receiver owns the operation. Do not add a client or service object only to namespace a
generic function.

For an exported API:

- **generic-method-interface-boundary** -- interface methods cannot declare type
  parameters, and a generic concrete method cannot implement a non-generic interface
  method. This is an explicit
  [language boundary](https://go.dev/issue/77273). Keep or add a focused non-generic
  adapter where substitution, mocking, or a plugin contract is required. Preserve
  compile-time interface assertions for every interface the type is intended to satisfy.
- **generic-method-reflection-boundary** -- reflection cannot retrieve an
  [uninstantiated generic method by name or index](https://go.dev/issue/77273). Keep a
  non-generic entry point for frameworks that discover methods through reflection.
- **generic-method-public-api-migration** -- prefer adding a generic method alongside
  an existing exported function or typed method. Removing the old call path is a
  separate compatibility and versioning decision, not cleanup implied by Go 1.27.
- Test inferred and explicit type arguments. When callers may use them, also test method
  values and method expressions. Examples should show the common inferred form first.
- Verify every shipped analyzer, generator, mock tool, documentation tool, and API
  extractor against the syntax before adopting it in a public package.

When consuming a Go 1.27 SDK, inspect generic methods on their concrete receiver. Do not
assume a same-named interface method is implemented, and do not hide the concrete client
behind an interface until the required non-generic seam is identified.

## Goroutine leak profile

The `goroutineleak` profile is
[generally available in Go 1.27](https://go.dev/doc/go1.27#runtime) through
`runtime/pprof` and `/debug/pprof/goroutineleak`.
**goroutineleak-experiment-removed** -- `GOEXPERIMENT=goroutineleakprofile` was deleted;
remove it from build and CI configuration.

Use it as targeted lifecycle evidence:

1. Exercise a credible early-return, cancellation, or shutdown path. Synchronize on the
   owned lifecycle boundary; do not wait an arbitrary duration for a leak.
2. Collect the profile. `Profile.WriteTo`
   [initiates the leak-detection GC cycle](https://go.dev/src/runtime/pprof/pprof.go), so
   do not add a separate `runtime.GC` call and do not collect it on a hot request path.
3. **goroutineleak-detection-boundary** -- treat any reported stack as a defect lead. A
   clean profile cannot prove the process is leak-free: reachability-based detection can
   miss goroutines blocked on primitives reachable through globals or runnable goroutine
   locals.

For a focused Go 1.27 test or diagnostic:

```go
profile := pprof.Lookup("goroutineleak")
if profile == nil {
	t.Fatal("goroutine leak profile requires Go 1.27")
}

var stacks bytes.Buffer
if err := profile.WriteTo(&stacks, 1); err != nil {
	t.Fatalf("write goroutine leak profile: %v", err)
}
if got := profile.Count(); got != 0 {
	t.Fatalf("found %d leaked goroutine stacks:\n%s", got, stacks.String())
}
```

The profile is process-wide. Keep this assertion in a targeted, non-parallel test or CI
lane so unrelated package work cannot contaminate the result.

For a locally bound or access-controlled diagnostic server:

```sh
go tool pprof http://127.0.0.1:6060/debug/pprof/goroutineleak
curl 'http://127.0.0.1:6060/debug/pprof/goroutineleak?debug=1'
```

Use `debug=0` for pprof's binary format or `debug=1` for leak-only readable stacks.
[`debug=2` falls back to all goroutine stacks](https://go.dev/src/runtime/pprof/pprof.go).
**goroutineleak-endpoint-exposure** -- preserve the repository's authentication, network
exposure, and redaction policy; never expose pprof publicly just to enable this check.

## Primary sources

- [Go 1.27 release notes](https://go.dev/doc/go1.27)
- [Go 1.27 language specification](https://go.dev/ref/spec)
- [Accepted generic methods proposal](https://go.dev/issue/77273)
- [`runtime/pprof` package](https://pkg.go.dev/runtime/pprof)
- [`runtime/pprof` leak-profile implementation](https://go.dev/src/runtime/pprof/pprof.go)
- [`net/http/pprof` package](https://pkg.go.dev/net/http/pprof)
