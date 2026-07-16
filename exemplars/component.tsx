import { useMutation } from '@connectrpc/connect-query';
import { Button } from '@/components/ui/button';
import { Tooltip, TooltipContent, TooltipTrigger } from '@/components/ui/tooltip';
import { deleteResource } from '@/gen/resource-ResourceService_connectquery';
import { ConnectError } from '@connectrpc/connect';
import { formatToastErrorMessageGRPC } from '@/lib/errors';
import { toast } from 'sonner';

interface DeleteResourceButtonProps {
  resourceName: string;
  disabled?: boolean;
}

export function DeleteResourceButton({ resourceName, disabled }: DeleteResourceButtonProps) {
  const { mutate, isPending } = useMutation(deleteResource, {
    onError: (error) => toast.error(formatToastErrorMessageGRPC(ConnectError.from(error))),
  });

  const button = (
    <Button
      variant="destructive"
      disabled={disabled || isPending}
      onClick={() => mutate({ resourceName })}
      aria-label={`Delete resource ${resourceName}`}
      data-testid="delete-resource-button"
    >
      {isPending ? 'Deleting…' : 'Delete resource'}
    </Button>
  );

  if (!disabled) return button;
  return (
    <Tooltip>
      <TooltipTrigger asChild>{button}</TooltipTrigger>
      <TooltipContent>Resources with active dependents cannot be deleted</TooltipContent>
    </Tooltip>
  );
}
