# Connect Query Reference

## connect-query-check.sh

> Script: [`scripts/connect-query-check.sh`](scripts/connect-query-check.sh)

## Protobuf v1 Variant

For projects using `@bufbuild/protobuf` ^1.x, use the same script but **remove checks 5 and 6** (the `new Message()` and `PlainMessage`/`PartialMessage` checks). In v1, these patterns are correct.

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
