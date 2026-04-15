# Connect Query Reference

## connect-query-check.sh

> Script: [`scripts/connect-query-check.sh`](scripts/connect-query-check.sh)

## Protobuf v1 Variant

For `@bufbuild/protobuf` ^1.x, remove checks 5-6 (`new Message()` and `PlainMessage`/`PartialMessage`). In v1 these correct.

## TanStack Query Hooks That Don't Trigger False Positives

Hook uses `\buseQuery\b` word boundaries. These TanStack Query hooks **safe** from `@tanstack/react-query` (NOT flagged):

- `useQueryClient` — stripped before matching
- `useQueries` — word boundary prevents match
- `useSuspenseQuery` — word boundary prevents match
- `useInfiniteQuery` — word boundary prevents match
- `useMutationState` — word boundary prevents match

No barrel re-exports or wrappers needed.

## Cache Invalidation Patterns

### Invalidate by Service Type Name

```tsx
await queryClient.invalidateQueries({
  queryKey: [listTopics.service.typeName],
  exact: false,
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

When using `useTransport`/`callUnaryMethod` from `@connectrpc/connect`, raw TanStack Query hooks allowed:

```tsx
import { useTransport, callUnaryMethod } from '@connectrpc/connect'
import { useQuery } from '@tanstack/react-query'

function MyComponent() {
  const transport = useTransport()
  const { data } = useQuery({
    queryKey: ['some-service', 'method'],
    queryFn: () => callUnaryMethod(transport, SomeService.method, { id: '123' }),
  })
}
```

## Protobuf v2 Message Construction

```tsx
import { create, toBinary, fromBinary, fromJson, toJson } from '@bufbuild/protobuf'
import { MyMessageSchema } from './gen/my_pb'

const msg = create(MyMessageSchema, { field: 'value' })
const bytes = toBinary(MyMessageSchema, msg)
const restored = fromBinary(MyMessageSchema, bytes)
```

Never construct with `$typeName` literals — use `create()`.

## Well-Known Types (Timestamp, Duration, Any)

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