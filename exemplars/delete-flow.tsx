import { useState } from 'react';
import { useMutation, useQuery } from '@connectrpc/connect-query';
import { ConnectError } from '@connectrpc/connect';
import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent } from '@/components/ui/alert-dialog';
import { Alert } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { deleteWebhook, listWebhookReferences } from '@/gen/webhook-WebhookService_connectquery';
import { formatToastErrorMessageGRPC } from '@/lib/errors';
import { toast } from 'sonner';

interface DeleteWebhookFlowProps {
  webhookName: string;
  onDeleted: () => Promise<void>;
}

// Destructive flows fail CLOSED: confirm enables only after a fresh,
// successful, zero-reference lookup. Loading or errored lookup is NOT
// confirmable. An unknown blast radius never gets a one-click delete.
export function DeleteWebhookFlow({ webhookName, onDeleted }: DeleteWebhookFlowProps) {
  const [open, setOpen] = useState(false);

  const references = useQuery(
    listWebhookReferences,
    { name: webhookName },
    // Fresh-lookup semantics: a passive "used by" card may have cached an
    // empty result; the delete dialog always re-checks.
    // allow: cache-tier destructive dialogs deliberately bypass tiers with staleTime 0
    { enabled: open, staleTime: 0, refetchOnMount: 'always' },
  );

  const { mutate, isPending } = useMutation(deleteWebhook, {
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
      <Button variant="destructive" onClick={() => setOpen(true)} data-testid="delete-webhook-button">
        Delete webhook
      </Button>
      <AlertDialogContent aria-label={`Delete webhook ${webhookName}`}>
        {/* The dialog names its exact subject, never a generic "Are you sure?" */}
        <p>
          Permanently delete <strong>{webhookName}</strong>? This cannot be undone.
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
          aria-describedby="delete-webhook-blocked-reason"
          onClick={() => mutate({ name: webhookName })}
          data-testid="confirm-delete-webhook"
        >
          {isPending ? 'Deleting…' : 'Delete'}
        </AlertDialogAction>
        {!confirmable && (
          <span id="delete-webhook-blocked-reason" className="sr-only">
            Delete is unavailable until the reference check succeeds with zero references.
          </span>
        )}
      </AlertDialogContent>
    </AlertDialog>
  );
}
