# Connect Query Setup

## Steps

### 1. Detect protobuf version

Check `package.json` for `@bufbuild/protobuf` version:
- `^1.x` → install **v1 variant** (skips protobuf v2 checks)
- `^2.x` → install **v2 variant** (includes protobuf v2 checks)

### 2. Create hook script

Copy [`scripts/connect-query-check.sh`](scripts/connect-query-check.sh) and [`scripts/_hook-lib.sh`](scripts/_hook-lib.sh) into `.claude/hooks/`. Make executable.

### 3. Configure hook in `.claude/settings.json`

Add to hooks config: **PostToolUse** (matcher: `Edit|Write`): `.claude/hooks/connect-query-check.sh`

### 4. Verify

- [ ] Hook blocks `useQuery` from `@tanstack/react-query` in files with ConnectRPC imports
- [ ] Hook allows `useQuery` from `@tanstack/react-query` in files without ConnectRPC imports
- [ ] Hook blocks `invalidateQueries()` with no args
- [ ] Hook warns on `axios` imports
- [ ] Hook respects `// allow-direct-query:` escape hatch
- [ ] (v2 only) Hook blocks `new MessageRequest()` protobuf construction
- [ ] (v2 only) Hook blocks `PlainMessage<T>` usage
- [ ] (v2 only) Hook blocks manual object literals with `$typeName`
- [ ] Hook allows raw `useQuery`/`useMutation` when file imports from `@connectrpc/connect`

### 5. Commit

Stage and commit: `Add Connect Query and protobuf enforcement hook`

## Standard Schema + Protovalidate

Use protobuf schema as form validation — no duplicate Zod schema needed:

```tsx
import { createStandardSchemaResolver } from '@hookform/resolvers/standard-schema'
import { createValidator } from '@bufbuild/protovalidate'
import { CreateTopicRequestSchema } from './gen/topics_pb'

const validator = createValidator()

// The protobuf schema IS your form validation — no duplicate Zod schema needed
const form = useForm({
  resolver: createStandardSchemaResolver(validator.standardSchema(CreateTopicRequestSchema)),
})
```

## Protobuf Type Registry for google.protobuf.Any

Required for `toJson`/`fromJson` when using `Any` fields — without it: `"is not in the type registry"` error.

```ts
import { createRegistry } from '@bufbuild/protobuf'
import { PluginConfigASchema } from './gen/plugin_a_config_pb'
import { PluginConfigBSchema } from './gen/plugin_b_config_pb'
import { PluginConfigCSchema } from './gen/plugin_c_config_pb'

export const typeRegistry = createRegistry(
  PluginConfigASchema,
  PluginConfigBSchema,
  PluginConfigCSchema,
  // Add every message type that gets packed into google.protobuf.Any
)
```

### Use the registry with toJson/fromJson

```ts
import { toJson, fromJson } from '@bufbuild/protobuf'
import { MyMessageSchema } from './gen/my_pb'
import { typeRegistry } from './registry'

const json = toJson(MyMessageSchema, msg, { typeRegistry })
const restored = fromJson(MyMessageSchema, jsonData, { typeRegistry })
```

### Use with ConnectRPC transport

```ts
import { createConnectTransport } from '@connectrpc/connect-web'
import { typeRegistry } from './registry'

const transport = createConnectTransport({
  baseUrl: '/api',
  jsonOptions: { typeRegistry },
})
```

When adding new proto messages, always add their schema to the registry.

## Transport Setup

```tsx
import { TransportProvider } from '@connectrpc/connect-query'
import { createConnectTransport } from '@connectrpc/connect-web'

const transport = createConnectTransport({
  baseUrl: '/api',
})

function App() {
  return (
    <TransportProvider transport={transport}>
      <QueryClientProvider client={queryClient}>
        {children}
      </QueryClientProvider>
    </TransportProvider>
  )
}
```
