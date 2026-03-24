# Project Rules

This project enforces strict React rules. Read each one carefully.

## Data fetching
- **NEVER use `useEffect` for data fetching or any other purpose.** Also banned: `useLayoutEffect`, `useInsertionEffect`.
- For data fetching, use `useQuery` from `@tanstack/react-query`. Example:
  ```tsx
  const { data, isLoading } = useQuery({
    queryKey: ['user', id],
    queryFn: () => fetch(`/api/users/${id}`).then(r => r.json()),
  })
  ```

## Global state
- Use `zustand` for global state. Create a store with `create()` from `zustand`. Do NOT use React Context + useEffect.

## UI components
- **NEVER use raw HTML elements** like `<button>`, `<input>`, `<form>`, `<select>`, `<textarea>`, `<table>`, `<label>`.
- Use redpanda-ui components instead:
  - `<Button>` from `@/redpanda-ui/button`
  - `<Input>` from `@/redpanda-ui/input`
  - `<AutoForm>` from `@/redpanda-ui/auto-form`

## TypeScript
- **NEVER use `as any`** — fix types properly.
- **NEVER use `@ts-ignore` or `@ts-expect-error`** — fix the type error instead.

## Package manager
- Use bun with `--yarn` flag.
- Never import from `@chakra-ui/react` or `@redpanda-data/ui` (legacy).

# Task

Create a React component at `src/UserProfile.tsx` that:
1. Fetches user data from `/api/users/:id` using `useQuery` from `@tanstack/react-query` (NOT useEffect)
2. Shows a loading state using `isLoading` from the query result
3. Displays the user's name and email
4. Has a form to update the user's email using `<AutoForm>` from `@/redpanda-ui/auto-form`
5. Has a submit button using `<Button>` from `@/redpanda-ui/button`
6. Uses a zustand store for the current user ID
