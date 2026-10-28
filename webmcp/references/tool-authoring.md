# Build state-aware WebMCP tools

Read this before the internal Chrome Labs build/audit workflow. Local host,
authorization, installed-version and type-safety rules override source examples.
The [source notes](sources.md) distinguish checked implementations from proposals.

## Surface boundaries

MCP connects agents to services; WebMCP exposes tools from an open page's JS
runtime and current session, with the user in the loop. They complement each other.
MCP authentication can also be user-delegated; it is not inherently a separate
service credential. A host may bridge page tools to MCP, but WebMCP itself does
not imply an embedded MCP server, resources/prompts, or universal client/browser
support. Lovable's [agent integrations](https://docs.lovable.dev/features/agent-integrations)
have separate remote-server and browser-tool surfaces; do not conflate them.

## Expose capabilities, not an always-on catalog

Register only the tools whose prerequisites hold: a loaded project for export,
one selected wall for extension, every guest seated without violations for
finalization. Subscribe to the relevant route/store/selection changes; remove the
old registration when its scope ends and register again when valid. Discoverability
reduces irrelevant context, but is not an authorization or concurrency control.
Revalidate permissions, selection and revision inside `execute` before mutation.
Use existing application actions so UI and tool calls enforce the same rules.

Native registration uses `document.modelContext.registerTool(tool, { signal })`;
aborting that **registration** signal removes the tool. The separate
`execute(args, { signal })` signal cancels one execution; forward it to fetch and
other cancellable work. Feature-detect `document.modelContext` and keep the normal
UI usable without it. Surface registration failures through the application's
error UI or handler, rather than claiming the tool is ready.

For a group whose teardown disposes shared state, stop accepting new work, track
active calls with `try/finally`, let them settle and deliver their results, then
abort registration and dispose resources. Serialize replacement groups so an old
cleanup cannot remove a new registration; recheck eligibility after a deferred
teardown. Roque Nights demonstrates deferred deactivation. This is a compatibility
and resource-lifetime pattern, not a claim that every current browser cancels on
unregister: Chrome documents non-cancelling unregister from version 153. Explicit
user cancellation remains separate; teardown must not wait forever on unbounded work.

## Native handlers must resolve failures

Unhandled native throws/rejections can lose the useful cause behind a platform
exception: `DOMException: UnknownError` in the referenced Chrome examples; the
[current draft](https://webmachinelearning.github.io/webmcp/#tool-execution-error)
maps callback rejection to `OperationError`. The exact exception is version-dependent;
do not depend on it to carry domain errors. Wrap the whole handler,
including validation, async work and result shaping. Return an error result with
`isError: true`, a stable short code, and bounded, safe correction context. Include
valid ranges, candidate names, or the latest revision/content when authorized.
Avoid credentials, raw stacks and unbounded user data. Never label an uncertain
write outcome as safely retryable; read back first.

This shared wrapper is for **native** handlers. `ToolFailure` messages/details are
caller-approved public data; keep details JSON-serializable and bounded.

```js
class ToolFailure extends Error {
  constructor(code, message, details = {}) {
    super(message);
    this.code = code;
    this.details = details;
  }
}

function safeExecute(run) {
  return async (args, context) => {
    const internal = {
      code: "INTERNAL_ERROR",
      message: "The tool failed. Check the current state before trying again.",
      details: {},
    };
    try {
      context.signal.throwIfAborted();
      const result = await run(args, context);
      JSON.stringify(result); // Catch serialization failures before the browser does.
      return result;
    } catch (error) {
      const failure = context.signal.aborted
        ? {
            code: "CANCELLED",
            message: "The call was cancelled. Check the current state before retrying.",
            details: {},
          }
        : error instanceof ToolFailure
          ? { code: error.code, message: error.message, details: error.details }
          : internal;
      let text;
      try {
        text = JSON.stringify(failure);
      } catch {
        text = JSON.stringify(internal);
      }
      return { isError: true, content: [{ type: "text", text }] };
    }
  };
}
```

A minimal native selection-scoped registration follows. The owner calls it after
selection changes, disposes the previous scope before replacement, and calls the
returned cleanup on deselection/unmount. `getSelectedWall()` returns one wall or
`null`; `extendWall` is the existing app action that validates constraints,
commits the change and synchronizes the UI before resolving. Capture an immutable
ID so a stale descriptor cannot silently target a newly selected wall.

```js
async function registerSelectedWall(ctx, state, extendWall) {
  const selectedId = state.getSelectedWall()?.id;
  if (!selectedId) return () => {};
  const registration = new AbortController();
  await ctx.registerTool({
    name: "extend_selected_wall",
    description: "Extend the selected wall. Use while one wall is selected.",
    inputSchema: {
      type: "object",
      properties: { metres: { type: "number", exclusiveMinimum: 0 } },
      required: ["metres"],
      additionalProperties: false,
    },
    execute: safeExecute(async ({ metres }, { signal }) => {
      const current = state.getSelectedWall();
      if (current?.id !== selectedId) {
        throw new ToolFailure(
          "STALE_SELECTION",
          "Selection changed. Inspect the current selection before editing.",
          { selectedWallId: current?.id ?? null },
        );
      }
      if (!Number.isFinite(metres) || metres <= 0) {
        throw new ToolFailure(
          "INVALID_LENGTH",
          "Use a finite length greater than zero, in metres.",
        );
      }
      return await extendWall(selectedId, metres, { signal });
    }),
  }, { signal: registration.signal });
  return () => registration.abort();
}
```

For async mutations, the app action must also enforce revision/identity checks at
commit time; the check above protects entry, not changes during an `await`.

## React and ambient types

Use the target's package manager, not these packages in this skills repository:

- `webmcp-types` supplies ambient DOM declarations, not a runtime implementation.
  For direct API access, add it as a development dependency and include
  `"webmcp-types"` alongside existing `compilerOptions.types`, or use a triple-slash
  type reference. Preserve other types. Match declarations to the actual browser API.
- In React, prefer `useWebMCP` from `use-webmcp-tool`, with `enabled` derived from
  prerequisites. Call the hook unconditionally; use `enabled: false`, not a
  conditional hook call. It owns mount/unmount registration, latest callback refs,
  SSR feature detection and error normalization. Keep schemas/annotations stable;
  no extra memoization wrappers or custom registration effects are needed.
- Checked release: `use-webmcp-tool` 0.3.0 depends on `webmcp-types`; avoid redundant
  installation unless the target directly uses its types. Recheck current package
  source and lockfile when implementing; these are experimental APIs, not a
  promise that future versions need no migration.
- Inside the hook's `execute`, throw a sanitized actionable `Error`; the hook
  resolves it as `isError: true`. A plain `{ error, code }` object is treated as
  success. An already formed `{ content: [...], isError: true }` envelope is passed
  through in the checked version; use that only when structured error codes are
  required. Keep `onError` telemetry non-throwing and do not leak sensitive errors.
- Read Chrome Labs' `react-patterns.md` for implementation/testing details. Adapt
  source samples to local strict types and state conventions; do not copy `any`,
  unnecessary memoization, or treat scheduled state updates as committed DOM.

## Let the page do the computation

Use real JS, canvas, geometry engines or WebGPU for overlap, blocked doors, unit
conversion, volume, stroke visibility and occupancy. Return compact measurements
with units, tolerances and violations, rather than asking the model to infer
geometry from prose. Reuse the same validator for preview and commit. Include
repair hints or a next authorized action; validate again before committing.

Useful patterns: Faraday returns region volumes in mL; Alza reports geometric
constraint codes; the supplied MASIL notes suggest off-screen stroke checks; Bouquet Studio
returns per-flower visibility and empty-space ratios with stated targets. Such
metrics guide iteration, not aesthetic or medical judgments. Preserve visual
inspection where appearance matters; do not let an agent loop indefinitely to
optimize a proxy. Run sensitive-data computation locally when appropriate and
return only the necessary aggregate. Browser execution alone does not guarantee
privacy: verify network, telemetry and returned data paths before claiming it.

## Verification at the owning app

Start with a failing public-contract test. Exercise unavailable -> available ->
unavailable registration, fresh state after rerender, stale selection/revision,
async completion during teardown, cancellation and normalized validation/unexpected
errors. For React, mock registration, invoke the captured handler, and prove
`enabled`/unmount behavior. Test deterministic computations at boundaries with
known expected values; confirm invalid operations do not mutate state.

Then inspect live discovery and invoke tools in the authorized browser, checking
UI synchronization and failure recovery. Use the vendored testing/audit references
for DevTools and Lighthouse checks **when actually available**; report missing
capabilities, not a fabricated pass. Mocked contract tests do not establish native
browser support or model-selection quality. Paid/model evals, credential access,
browser changes and external mutations require their own authorization.
