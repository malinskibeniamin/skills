# React Rules Reference

## react-rules-check.sh

> Script: [`scripts/react-rules-check.sh`](scripts/react-rules-check.sh)

## Escape Hatch for useEffect

When useEffect is genuinely needed (e.g., WebSocket cleanup, third-party library integration), add a comment on the line before:

```tsx
// allow-useEffect: WebSocket subscription cleanup required
useEffect(() => {
  const ws = new WebSocket(url)
  return () => ws.close()
}, [url])
```

The hook checks for `// allow-useEffect:` anywhere in the file. A reason is required for code review.

## Raw HTML → Component Library Mapping

| Banned | Replacement | Import (shadcn/ui convention) |
|--------|-------------|-------------------------------|
| `<button>` | `<Button>` | `@/components/ui/button` |
| `<input>` | `<Input>` | `@/components/ui/input` |
| `<select>` | `<Select>` | `@/components/ui/select` |
| `<textarea>` | `<Textarea>` | `@/components/ui/textarea` |
| `<dialog>` | `<Dialog>` | `@/components/ui/dialog` |
| `<table>` | `<Table>` | `@/components/ui/table` |
| `<label>` | `<Label>` | `@/components/ui/label` |

Note: `<form>` and `<a>` are allowed — `<form>` has no standard registry replacement, `<a>` can't always be replaced with TanStack Router Link.

## Auto-Generated Files

The following files are automatically skipped by all hooks:

| Pattern | Source |
|---------|--------|
| `*.gen.ts` / `*.gen.tsx` | TanStack Router (`routeTree.gen.ts`) |
| `*_pb.ts` / `*_pb.js` | Protobuf codegen |
| `*_connectquery.ts` | Connect Query codegen |
| Files with `@generated` / `auto-generated` / `DO NOT EDIT` in first 5 lines | Any codegen tool |

## Named useEffect Functions

When writing `useEffect`, always use a named function expression instead of an anonymous arrow:

```tsx
// BAD — anonymous arrow
useEffect(() => {
  const ws = new WebSocket(url)
  return () => ws.close()
}, [url])

// GOOD — named function with symmetrical cleanup
useEffect(function connectToWebSocket() {
  const ws = new WebSocket(url)
  return function disconnectWebSocket() {
    ws.close()
  }
}, [url])
```

### Why

- Named functions appear in stack traces and React DevTools (instead of `(anonymous)`)
- Forces you to articulate what the effect does — reveals split opportunities
- If you can't name it without "and" or "also", the effect does too much — split it
- If the name starts with "sync" or "update" followed by state, it's probably derived state — compute inline during render instead

### Naming conventions

| Verb | Use for |
|------|---------|
| `subscribe`/`listen` | Event-based effects |
| `connect`/`disconnect` | WebSocket, SSE, external services |
| `synchronize`/`apply` | Syncing React state with external systems |
| `initialize` | One-time setup |
| `poll` | Interval-based data fetching |
