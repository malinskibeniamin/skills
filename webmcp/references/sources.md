# Evidence and refresh notes

Checked 2026-10-28. Recheck live API/package documentation when implementing;
pinned examples establish patterns, not current support in every host. These
repositories are cited, not additional vendored runtimes or commands to execute.

## API and packages

- [Chrome imperative API](https://developer.chrome.com/docs/ai/webmcp/imperative-api):
  registration and execution signals are separate; unregister preserves in-flight
  executions from Chrome 153; object execution arguments supersede JSON strings.
- [WebMCP draft error model](https://webmachinelearning.github.io/webmcp/#tool-execution-error):
  the 2026-10-27 draft maps callback rejection and unserializable results to
  `OperationError`. The pinned Chrome Labs error guide and user-provided reports
  describe `UnknownError`. The stable advice is to resolve actionable error data,
  not depend on a browser exception carrying the handler's message.
- [Chrome comparison](https://developer.chrome.com/docs/ai/webmcp/compare-mcp) and
  [Lovable agent integrations](https://docs.lovable.dev/features/agent-integrations#let-browser-agents-use-your-app):
  page-session WebMCP complements service-facing MCP. Lovable's browser tools are
  separate from its published remote MCP server and inherit the current tab session.
- [`use-webmcp-tool` 0.3.0](https://www.npmjs.com/package/use-webmcp-tool), checked
  against [hook source](https://github.com/GoogleChromeLabs/use-webmcp-tool/blob/9f0dc6eddf88cff65ebe877f199d4547e74ab31e/useWebMCP.js)
  and [types](https://github.com/GoogleChromeLabs/use-webmcp-tool/blob/9f0dc6eddf88cff65ebe877f199d4547e74ab31e/useWebMCP.d.ts):
  `enabled`, lifecycle cleanup, latest callback refs, SSR detection, error
  normalization and existing-envelope passthrough. Plain error objects become
  success content; thrown errors become `isError: true`. Telemetry callbacks can
  throw, so keep them non-throwing. This is Sarah Drasner's React hook published
  by Google Chrome Labs, not a built-in browser hook.
- [`webmcp-types` 0.1.10](https://www.npmjs.com/package/webmcp-types) and its
  [configuration guide](https://github.com/webmachinelearning/webmcp-types/blob/a8d8292ff645b691bfdb529484d3c089e81e8c28/README.md):
  ambient declarations require type inclusion; types do not enable a runtime.
  Package versions are research observations, not dependencies of this plugin.

## Implementation patterns

- **Aisle:** [`toolFlags` / `currentTools`](https://github.com/ergjus/aisle/blob/2cb19db819bdee55a603c25b38c021974757e160/src/webmcp/tools.ts)
  expose `finalize_chart` only with at least one attending guest, all attending
  guests seated and no seating-rule violations. Its
  [adapter](https://github.com/ergjus/aisle/blob/2cb19db819bdee55a603c25b38c021974757e160/src/webmcp/adapter.ts)
  uses registration controllers. Do not generalize this to all geometric conflicts;
  floor-plan overlap is reported separately.
- **Alza:** [selection-scoped registration](https://github.com/Elioz404/Alza/blob/b672279761813fafb42871a4d17348d14d004651/src/mcp/bootstrap.ts)
  adds/removes `extend_selected_wall`; its
  [tool action](https://github.com/Elioz404/Alza/blob/b672279761813fafb42871a4d17348d14d004651/src/mcp/tools.ts)
  re-reads selection. The [constraint checker](https://github.com/Elioz404/Alza/blob/b672279761813fafb42871a4d17348d14d004651/src/model/issues.ts)
  computes geometry issues instead of asking the model to calculate overlap.
- **Roque Nights:** [`runWhenIdle` / `flushDeferred`](https://github.com/sebastianfernandezgarcia/roque-nights/blob/984afce350f97ccbf3629a5fcfe94ba15543a55a/src/webmcp/contextual.ts)
  defer group removal until calls settle, then one task later to allow delivery.
  This workaround's browser-cancellation explanation is historical; compare current
  Chrome behavior above. Its [sky-map tool](https://github.com/sebastianfernandezgarcia/roque-nights/blob/984afce350f97ccbf3629a5fcfe94ba15543a55a/src/tools/pointSkyMap.ts)
  supplies corrective target hints rather than opaque failures.
- **JupyterLite WebMCP:** [`resolveWritableCell`](https://github.com/alliecatowo/jupyterlite-web-mcp/blob/7bc6273259c9d7850516acbac4e18ae9182eca49/packages/jupyterlite-webmcp/src/jupyter/cells.ts)
  returns `STALE_CELL` context through its error envelope: current hash and bounded
  source preview, not necessarily the entire new cell. Preserve concurrent human edits.
- **Faraday:** [region measurements](https://github.com/thegreataxios/faraday/blob/dde39060dda04e00b743eac1a98cb47c500fffcb/src/regions.ts)
  convert voxel counts/spacing to mL; [tools](https://github.com/thegreataxios/faraday/blob/dde39060dda04e00b743eac1a98cb47c500fffcb/src/tools.tsx)
  return compact measurements and detect changed studies. In this source the
  connected-component calculation is CPU JavaScript, with WebGPU noted as a possible
  upgrade; do not claim that the region math currently runs on the GPU or that
  browser-local execution alone proves the scan never leaves the machine.
- **Bouquet Studio:** [inspection tool](https://github.com/jane-chao/bouquet-studio/blob/a4fabf5887e427d3f287f7e726bae6230f87f641/src/lib/webmcp.ts)
  returns flower visibility and occupancy metrics plus images. Its description
  sets targets such as `visibleRatio >= 0.7` and `emptyRatio <= 0.3`; these are
  bouquet-specific design targets, not general quality thresholds.
- **MASIL:** [calligraphy surface](https://github.com/SonSangjoon/masil/blob/fa3e551bf27936d90edae51db4a7db5b70c886fc/src/features/calligraphy/components/air-calligraphy-canvas.tsx)
  and [WebMCP design](https://github.com/SonSangjoon/masil/blob/fa3e551bf27936d90edae51db4a7db5b70c886fc/docs/WEBMCP.md)
  keep tool actions tied to visible creative state. The supplied hackathon notes
  describe off-screen stroke checking; verify that specific preflight path in the
  target revision before copying or asserting it. The reusable recommendation is
  to measure a proposed rendering before committing it.
