# Project Rules

This project enforces strict React rules. Read each one carefully.

## Data fetching
- **useEffect is discouraged.** Prefer `useQuery` from `@tanstack/react-query` for data fetching. Also discouraged: `useLayoutEffect`, `useInsertionEffect`. If you must use useEffect, add a `// allow-useEffect: [reason]` comment.
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
- Use shadcn/ui components instead:
  - `<Button>` from `@/components/ui/button`
  - `<Input>` from `@/components/ui/input`
  - `<Form>` from `@/components/ui/form`

## Tailwind CSS
- **NEVER use inline `style={{}}`** — use Tailwind utility classes instead.
- **NEVER use raw hex/rgb values in className** — use design tokens (e.g., `text-destructive` not `text-[#ff0000]`).
- **NEVER use `!important`** — it breaks the Tailwind cascade. Fix specificity instead.

## TypeScript
- **NEVER use `as any`** — fix types properly.
- **NEVER use `@ts-ignore` or `@ts-expect-error`** — fix the type error instead.

## Package manager
- Use bun with `--yarn` flag.

# Task

Create a React component at `src/UserProfile.tsx` that:
1. Fetches user data from `/api/users/:id` using `useQuery` from `@tanstack/react-query` (NOT useEffect)
2. Shows a loading state using `isLoading` from the query result
3. Displays the user's name and email
4. Has a form to update the user's email using `<Form>` from `@/components/ui/form`
5. Has a submit button using `<Button>` from `@/components/ui/button`
6. Uses a zustand store for the current user ID
7. Uses Tailwind utility classes for styling (no inline style={{}}, no raw hex colors, no !important)
