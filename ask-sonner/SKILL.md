---
name: ask-sonner
description: "Set up, style, or troubleshoot Sonner React toasts: Toaster placement, promise/loading lifecycles, duplicate messages, theme, portals, and custom content."
---

Use the installed Sonner version and existing design-system wrapper. Adapted from
Emil Kowalski; [provenance](../shared/EMIL-SKILLS-CREDITS.md).
Read installed types/current [official docs](https://sonner.emilkowal.ski) before
using version-dependent props or return values; this is guidance, not a frozen API spec.

## Integration

- Reuse the project's Toaster wrapper, usually under `@/components/ui/`. Mount once
  at a stable app root outside clipping/stacking ancestors. Additional Toasters need
  a supported, explicit targeting scheme; do not assume multi-toaster props exist.
- Call `toast` on the client at the operation boundary. Server code returns a result;
  the client announces it. Prefer event/mutation outcomes over render/effect side effects.
- Use success/error/info/warning calls for outcomes; `toast.loading` plus a stable id
  for manual lifecycle, or `toast.promise` for a promise that actually settles.
  Read [RECIPES.md](RECIPES.md) for update/dismiss and error-handling patterns.
- Keep important failure/recovery state inline as well as transient notification.
  Never treat a loading toast, optimistic start, or swallowed rejection as success.

## Diagnosis

| Symptom | Inspect before changing |
|---|---|
| Missing toast | Toaster lifetime, client call, targeted id if supported |
| Duplicates | Multiple Toasters or effect replay; stable operation id |
| Loading forever | Unsettled promise, missed catch/finally, persistent duration |
| Wrong theme | Resolved theme passed by the existing provider/wrapper |
| Behind dialog/clipped | Portal placement, ancestor transform/filter/overflow, stacking layers |
| Lost styles | Installed package CSS export and framework stylesheet lifecycle |
| Classes ignored | Cascade/layers and wrapper configuration; scope override at its owner |
| Mobile overlap | Supported offset props, safe area, keyboard and placement |

## Styling and verification

Use wrapper variants/tokens first; fix specificity at the source instead of scattering
`!important`. Consider `unstyled` or `toast.custom` only when the installed API supports
the needed behavior. Custom controls use the project's Button/Link and accessible labels;
headless content does not supply semantics automatically.

Verify one operation gives one notification, resolves/rejects correctly, can dismiss,
and stays usable with keyboard, screen reader announcements, reduced motion, themes,
and dialogs. Verify the persistent error path too. Explain/review requests return findings;
build/fix requests continue through project tests and delivery gates.
