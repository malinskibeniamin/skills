import { useMutation } from '@connectrpc/connect-query';
import { Button } from '@/components/ui/button';
import { Tooltip, TooltipContent, TooltipTrigger } from '@/components/ui/tooltip';
import { deleteTopic } from '@/gen/topic-TopicService_connectquery';
import { ConnectError } from '@connectrpc/connect';
import { formatToastErrorMessageGRPC } from '@/lib/errors';
import { toast } from 'sonner';

interface DeleteTopicButtonProps {
  topicName: string;
  disabled?: boolean;
}

export function DeleteTopicButton({ topicName, disabled }: DeleteTopicButtonProps) {
  const { mutate, isPending } = useMutation(deleteTopic, {
    onError: (error) => toast.error(formatToastErrorMessageGRPC(ConnectError.from(error))),
  });

  const button = (
    <Button
      variant="destructive"
      disabled={disabled || isPending}
      onClick={() => mutate({ topicName })}
      aria-label={`Delete topic ${topicName}`}
      data-testid="delete-topic-button"
    >
      {isPending ? 'Deleting…' : 'Delete topic'}
    </Button>
  );

  if (!disabled) return button;
  return (
    <Tooltip>
      <TooltipTrigger asChild>{button}</TooltipTrigger>
      <TooltipContent>Topics with active consumers cannot be deleted</TooltipContent>
    </Tooltip>
  );
}
