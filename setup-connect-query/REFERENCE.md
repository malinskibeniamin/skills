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
