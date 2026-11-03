# Native WebMCP input-format preflight

Use [Chrome's imperative API](https://developer.chrome.com/docs/ai/webmcp/imperative-api)
for the page fallback. Establish the native browser or polyfill's input contract
before invocation:

- **Chrome 153:** set `INPUT_FORMAT` to `"json-string"`. Object arguments fail,
  as documented by [Shopify](https://shopify.dev/docs/api/web-mcp#calling-tools).
- **Chrome 155 and later:** set `INPUT_FORMAT` to `"object"`; JSON-string arguments
  are deprecated.
- **Chrome 154, other hosts and polyfills:** verify their documented contract;
  leave the operation pending if the format cannot be established. A host bridge's
  own schema does not establish the native page API's input format.

Keep `ARGS` a JSON-serializable object in both cases; the
[host adapter's example](../SKILL.md#chrome-page-api-operate-a-page) encodes it for
the verified contract. Never probe formats by attempting or retrying a mutation.
