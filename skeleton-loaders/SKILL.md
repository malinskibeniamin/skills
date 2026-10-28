---
name: skeleton-loaders
description: "Build skeleton loading states for async content, pending routes, and shimmer placeholders. Use when matching loaded layouts or preventing layout shift during data fetching."
---

## Match the content

Treat the snippets below as templates. Inspect the real component and installed styling
stack; adapt imports, tokens, translations, and file paths to that repository.

1. Reuse its existing skeleton primitive and loading conventions where compatible.
2. Copy the loaded layout's containers, spacing, breakpoints, borders, and typography.
   Keep the same element types, line-height, font-size, weight, wrapping, and truncation.
3. Fill transparent text elements with the same `t()` values for static labels. For
   unknown runtime values, use representative placeholder text and realistic line counts.
   Typography matches known geometry; unknown text widths and wrapping remain approximate.
   Block elements still fill their container unless the loaded layout sizes them otherwise.
4. Reserve images, icons, and avatars with their real dimensions or aspect ratio. Use
   explicit sizing for these non-text slots, not guessed text `h-*` / `w-*` rectangles.

## Shimmer, defined once

Reuse an existing animation before adding one. For **Tailwind v4**, locate the stylesheet
that owns the theme and add a missing token/keyframes to its existing `@theme` block:

```css
@theme {
  --animate-shimmer: shimmer 2s linear infinite;
  @keyframes shimmer {
    from { background-position: 100% 0; }
    to { background-position: -100% 0; }
  }
}
```

`animate-shimmer` is custom, not built in. For other versions, use the project's animation
configuration; verify generated CSS and class linting. Keep a static muted background
when reduced motion is requested. Share the class string within the component:

```tsx
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

const shimmer =
  "motion-safe:animate-shimmer rounded-sm bg-muted bg-linear-to-r from-muted via-accent to-muted bg-size-[200%_100%] text-transparent select-none";

export function ProfileSkeleton({ heading, actionLabel }: {
  heading: string;
  actionLabel: string;
}) {
  return (
    <div aria-hidden="true" className="border border-border bg-card p-3">
      <h2 className={cn("text-lg font-bold", shimmer)}>{heading}</h2>
      <div className="flex items-center gap-3">
        <div className={cn("size-14 shrink-0", shimmer)} />
        <div className="min-w-0 flex-1">
          <p className={cn("truncate text-sm font-semibold", shimmer)}>Name</p>
          <p className={cn("truncate text-xs", shimmer)}>Example value</p>
        </div>
      </div>
      <Button disabled type="button" className={cn("w-full", shimmer)}>
        {actionLabel}
      </Button>
    </div>
  );
}
```

Pass the loaded component's translated heading and action label. Match its actual
Button variant, size, and classes; remove foreground utilities that override transparency.
Keep placeholder controls disabled and without handlers or navigation targets;
`tabIndex={-1}` alone does not prevent activation. Hide the skeleton root from assistive
technology. On the persistent content region, set `aria-busy` while pending and clear it
on success or failure. If announcing loading, keep one localized `role="status"` outside
the hidden/busy subtree so the announcement is not suppressed.

## Delay without layout shift

Prefer the router/query's existing pending-delay mechanism. Around **200 ms** is a
starting point, not a mandatory wait: render available data immediately and keep stale
content during background refreshes. When no content exists, reserve the loaded region's
geometry throughout the delay rather than collapsing it with an unreserved `null`.

If a local timer is needed, mount the delay component only for that pending operation;
use a named Effect and clear the timeout on unmount. Remount/reset for each new operation,
including request-identity changes while still pending. Cancel pending reveals on
completion, cancellation, or failure; show the error/empty state instead of an endless loader.

## Verify the swap

Compare loading and loaded views at the same viewport, font, locale, and theme, including
long text and narrow layouts. Check region bounds during the delay and reveal; claim
pixel-perfect matching only for geometry actually compared. Exercise fast and slow loads,
repeated navigation, cancellation/unmount, background refresh, empty/error recovery,
keyboard focus, and reduced motion. Use fake timers for delay tests, not real sleeps.

For syntax details, consult [Tailwind animation](https://tailwindcss.com/docs/animation).
For timer cleanup, consult [React Effects](https://react.dev/reference/react/useEffect).
For loading semantics, consult [ARIA busy](https://www.w3.org/TR/wai-aria-1.2/#aria-busy).
