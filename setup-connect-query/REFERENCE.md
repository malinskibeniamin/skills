# Connect Query Reference

## connect-query-check.sh

> Script: [`scripts/connect-query-check.sh`](scripts/connect-query-check.sh)

## Protobuf v1 Variant

For projects using `@bufbuild/protobuf` ^1.x, use the same script but **remove checks 5 and 6** (the `new Message()` and `PlainMessage`/`PartialMessage` checks). In v1, these patterns are correct.

## TanStack Query Hooks That Don't Trigger False Positives

The hook uses `\buseQuery\b` word boundaries, so these TanStack Query hooks are **safe to import from `@tanstack/react-query`** and will NOT be flagged:

- `useQueryClient` — stripped before matching
- `useQueries` — word boundary prevents match
- `useSuspenseQuery` — word boundary prevents match
- `useInfiniteQuery` — word boundary prevents match
- `useMutationState` — word boundary prevents match

You do **NOT** need to create barrel re-exports or wrapper modules to avoid false positives. If you have existing workarounds for this, they can be safely removed.

## Cache Invalidation Patterns

### Invalidate by Service Type Name

```tsx
// Invalidate all queries for a specific service
await queryClient.invalidateQueries({
  queryKey: [listTopics.service.typeName],
  exact: false,
})

// Invalidate a specific RPC method
await queryClient.invalidateQueries({
  queryKey: createConnectQueryKey(listTopics, { filter: 'active' }),
})
```

### Mutation with Invalidation

```tsx
import { useMutation } from '@connectrpc/connect-query'
import { createTopic, listTopics } from './gen/topics-TopicService_connectquery'

function CreateTopicButton() {
  const queryClient = useQueryClient()
  const mutation = useMutation(createTopic, {
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: [listTopics.service.typeName],
        exact: false,
      })
    },
  })
}
```

## TanStack Query + useTransport/callUnaryMethod Pattern

When using `useTransport` and `callUnaryMethod` from `@connectrpc/connect` directly, raw TanStack Query hooks are allowed. This is a legitimate pattern for cases where Connect Query's generated hooks don't fit:

```tsx
import { useTransport, callUnaryMethod } from '@connectrpc/connect'
import { useQuery } from '@tanstack/react-query'
import { SomeService } from './gen/some_pb'

function MyComponent() {
  const transport = useTransport()
  const { data } = useQuery({
    queryKey: ['some-service', 'method'],
    queryFn: () => callUnaryMethod(transport, SomeService.method, { id: '123' }),
  })
}
```

The hook allows this because the file imports from `@connectrpc/connect`, indicating intentional use of the transport layer.

## Protobuf v2 Message Construction

Always use `create()` with a schema for type-safe message construction:

```tsx
import { create, toBinary, fromBinary, fromJson, toJson } from '@bufbuild/protobuf'
import { MyMessageSchema } from './gen/my_pb'

// Construction
const msg = create(MyMessageSchema, { field: 'value' })

// Serialization (schema-first functions)
const bytes = toBinary(MyMessageSchema, msg)
const restored = fromBinary(MyMessageSchema, bytes)
const json = toJson(MyMessageSchema, msg)
const fromJ = fromJson(MyMessageSchema, jsonData)
```

Do not construct messages as manual object literals with `$typeName` — `create()` breaks at compile time when the schema changes, object literals silently pass stale fields.

## Standard Schema + Protovalidate

When protobuf messages have validation rules via `protovalidate`, use the Standard Schema adapter as your react-hook-form resolver instead of duplicating validation in Zod:

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

This ensures:
- Single source of truth for validation (protobuf schema)
- Server and client validate identically
- Schema changes propagate automatically — no Zod drift

## Protobuf Type Registry for google.protobuf.Any

When using `google.protobuf.Any` (e.g., for polymorphic config fields), you must provide a type registry so protobuf knows how to serialize/deserialize the packed message types. Without it, `toJson`/`fromJson` fails with:

```
cannot encode message google.protobuf.Any to JSON:
"type.googleapis.com/your.package.MessageType" is not in the type registry
```

### Create a registry

```ts
import { createRegistry } from '@bufbuild/protobuf'
import { PluginConfigASchema } from './gen/plugin_a_config_pb'
import { PluginConfigBSchema } from './gen/plugin_b_config_pb'
import { PluginConfigCSchema } from './gen/plugin_c_config_pb'
// ... import all schemas that can be packed into Any

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

// Serialize — registry resolves Any.typeUrl to the correct schema
const json = toJson(MyMessageSchema, msg, { typeRegistry })

// Deserialize
const restored = fromJson(MyMessageSchema, jsonData, { typeRegistry })
```

### Use with ConnectRPC transport

Pass the registry to the transport so all RPC calls can handle Any fields:

```ts
import { createConnectTransport } from '@connectrpc/connect-web'
import { typeRegistry } from './registry'

const transport = createConnectTransport({
  baseUrl: '/api',
  jsonOptions: { typeRegistry },
})
```

### Common mistake

Forgetting to add a new message schema to the registry when adding a new config type. If you add a new proto message, you must also add its schema to the registry — otherwise Any serialization fails at runtime.

## Well-Known Types (Timestamp, Duration, Any)

Protobuf well-known types have special JSON serialization rules. Do NOT construct them as plain objects.

### Timestamp

```ts
// BAD — fails: "cannot decode Timestamp from JSON: object"
const msg = create(MySchema, {
  createdAt: { seconds: BigInt(Date.now() / 1000), nanos: 0 },
})

// BAD — raw Date object, not a Timestamp
const msg = create(MySchema, { createdAt: new Date() })

// GOOD — use @bufbuild/protobuf/wkt helpers
import { timestampFromDate, timestampDate } from '@bufbuild/protobuf/wkt'

const msg = create(MySchema, {
  createdAt: timestampFromDate(new Date()),
})

// Read back as Date
const date = timestampDate(msg.createdAt)
```

### Duration

```ts
import { durationFromJson } from '@bufbuild/protobuf/wkt'

const msg = create(MySchema, {
  timeout: durationFromJson('30s'),
})
```

### Any (with @type)

```ts
// BAD — fails: "@type" is empty
const anyMsg = create(AnySchema, { value: toBinary(ConfigSchema, config) })

// GOOD — use anyPack which sets @type automatically
import { anyPack, anyUnpack } from '@bufbuild/protobuf/wkt'

const anyMsg = anyPack(ConfigSchema, config)
const unpacked = anyUnpack(anyMsg, typeRegistry)
```

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
