import { useForm, useWatch } from 'react-hook-form';
import { create } from '@bufbuild/protobuf';
import { ConnectError } from '@connectrpc/connect';
import { useMutation } from '@connectrpc/connect-query';
import { Button } from '@/components/ui/button';
import { Form, FormField, FormMessage, FormErrorSummary, RequiredIndicator } from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { createResource } from '@/gen/resource-ResourceService_connectquery';
import { CreateResourceRequestSchema } from '@/gen/resource_pb';
import { setServerFieldErrors } from '@/lib/errors';

interface CreateResourceFormProps {
  onCreated: (name: string) => Promise<void>;
}

// Submit contract: the button stays clickable — errors surface via the
// summary + inline messages. Native disabled is for in-flight state only.
export function CreateResourceForm({ onCreated }: CreateResourceFormProps) {
  const form = useForm({ mode: 'onChange', defaultValues: { name: '', value: '' } });
  const name = useWatch({ control: form.control, name: 'name' });

  const { mutate, isPending } = useMutation(createResource, {
    onSuccess: async () => {
      await onCreated(name); // caller invalidates the list — awaited, never fire-and-forget
    },
    // Unpacks BadRequest fieldViolations into form.setError per field;
    // toast only ever carries non-field errors.
    onError: (error) => setServerFieldErrors(form, ConnectError.from(error)),
  });

  const onSubmit = form.handleSubmit((values) =>
    mutate(create(CreateResourceRequestSchema, values)),
  );

  return (
    <Form {...form}>
      <form onSubmit={onSubmit} noValidate>
        <FormErrorSummary />
        <FormField
          control={form.control}
          name="name"
          // Validate format, not presence: the constraint text mirrors the regex.
          rules={{ pattern: { value: /^[A-Z][A-Z0-9_]*$/, message: 'Name must be uppercase letters, numbers, or underscores' } }}
          render={({ field }) => (
            <label>
              Resource name <RequiredIndicator />
              <Input
                {...field}
                data-testid="resource-name-input"
                aria-invalid={!!form.formState.errors.name}
                aria-describedby="resource-name-error"
              />
              <FormMessage id="resource-name-error" />
            </label>
          )}
        />
        <Button type="submit" disabled={isPending} data-testid="create-resource-submit">
          {isPending ? 'Creating…' : 'Create resource'}
        </Button>
      </form>
    </Form>
  );
}
