import { useState } from 'react';
import { useMutation, useQuery } from '@connectrpc/connect-query';
import { ConnectError } from '@connectrpc/connect';
import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent } from '@/components/ui/alert-dialog';
import { Alert } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { deleteGuardrail, listGuardrailReferences } from '@/gen/guardrail-GuardrailService_connectquery';
import { formatToastErrorMessageGRPC } from '@/lib/errors';
import { toast } from 'sonner';

interface DeleteGuardrailFlowProps {
  guardrailName: string;
  onDeleted: () => Promise<void>;
}

// Destructive flows fail CLOSED: confirm enables only after a fresh,
// successful, zero-reference lookup. Loading or errored lookup is NOT
// confirmable — an unknown blast radius never gets a one-click delete.
export function DeleteGuardrailFlow({ guardrailName, onDeleted }: DeleteGuardrailFlowProps) {
  const [open, setOpen] = useState(false);

  const references = useQuery(
    listGuardrailReferences,
    { name: guardrailName },
    // fresh:true semantics — a passive "used by" card may have cached an
    // empty result; the delete dialog always re-checks.
    { enabled: open, staleTime: 0, refetchOnMount: 'always' },
  );

  const { mutate, isPending } = useMutation(deleteGuardrail, {
    onSuccess: async () => {
      await onDeleted(); // awaited invalidation before the dialog closes
      setOpen(false);
    },
    onError: (error) => toast.error(formatToastErrorMessageGRPC(ConnectError.from(error))),
  });

  const referenceCount = references.data?.references.length;
  const confirmable = references.isSuccess && referenceCount === 0 && !isPending;

  return (
    <AlertDialog open={open} onOpenChange={(next) => !isPending && setOpen(next)}>
      <Button variant="destructive" onClick={() => setOpen(true)} data-testid="delete-guardrail-button">
        Delete guardrail
      </Button>
      <AlertDialogContent aria-label={`Delete guardrail ${guardrailName}`}>
        {/* The dialog names its exact subject — never a generic "Are you sure?" */}
        <p>
          Permanently delete <strong>{guardrailName}</strong>? This cannot be undone.
        </p>
        {references.isError && (
          <Alert variant="destructive">
            References could not be checked. Deletion is blocked.{' '}
            <Button variant="outline" onClick={() => references.refetch()}>Retry check</Button>
          </Alert>
        )}
        {references.isSuccess && referenceCount !== undefined && referenceCount > 0 && (
          <Alert variant="destructive">In use by {referenceCount} resources. Detach them first.</Alert>
        )}
        <AlertDialogCancel disabled={isPending}>Cancel</AlertDialogCancel>
        <AlertDialogAction
          disabled={!confirmable}
          aria-describedby="delete-guardrail-blocked-reason"
          onClick={() => mutate({ name: guardrailName })}
          data-testid="confirm-delete-guardrail"
        >
          {isPending ? 'Deleting…' : 'Delete'}
        </AlertDialogAction>
        {!confirmable && (
          <span id="delete-guardrail-blocked-reason" className="sr-only">
            Delete is unavailable until the reference check succeeds with zero references.
          </span>
        )}
      </AlertDialogContent>
    </AlertDialog>
  );
}
