# Sonner operation recipes

Confirm these calls against installed types. Reuse the project's toast wrapper and
operation error handler; preserve existing return values and rejection semantics.

## Manual loading -> outcome

```tsx
const id = toast.loading("Saving changes...");
try {
  await saveChanges();
  toast.success("Changes saved", { id });
} catch (error) {
  toast.error("Changes could not be saved", { id });
  handleSaveError(error); // existing inline error/recovery path
}
```

Updating the same id avoids stacking a second message. Handle cancellation distinctly
when the underlying operation supports it. Use `toast.dismiss(id)` for cleanup where
appropriate; dismissing UI does not cancel an operation or prove it succeeded.
Do not call global `toast.dismiss()` from a component's unmount cleanup.

## Promise-owned toast

```tsx
const operation = saveChanges();
toast.promise(operation, {
  loading: "Saving changes...",
  success: "Changes saved",
  error: "Changes could not be saved",
});
try {
  await operation;
} catch (error) {
  handleSaveError(error);
}
```

Start the operation once. Do not assume `toast.promise` returns the operation promise;
its return shape is version-dependent. Notification handling is not the application's
error handling. If failures must propagate, use the existing error boundary/rethrow path.

## Persistent/custom content

`duration: Infinity` keeps a toast visible; provide a discoverable dismissal/recovery
path and keep essential failure detail in page/form state. `toast.custom` delegates
content rendering, not operation correctness. Use semantic text, labeled buttons,
and actual links; duplicate decorative layers stay hidden from assistive technology.

Check separate `onDismiss` and `onAutoClose` semantics in the installed version before
using them for cleanup. Neither callback substitutes for completion of business work.
