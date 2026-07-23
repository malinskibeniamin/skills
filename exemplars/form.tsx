import { useForm } from 'react-hook-form';
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

interface CreateResourceFormValues {
  name: string;
}

const CREATE_RESOURCE_DEFAULT_VALUES = {
  name: '',
} satisfies CreateResourceFormValues;

// Submit contract: the button stays clickable — errors surface via the
// summary + inline messages. Native disabled is for in-flight state only.
export function CreateResourceForm({ onCreated }: CreateResourceFormProps) {
  const form = useForm<CreateResourceFormValues>({
    mode: 'onSubmit',
    reValidateMode: 'onChange',
    defaultValues: CREATE_RESOURCE_DEFAULT_VALUES,
  });

  const { mutate, isPending } = useMutation(createResource, {
    onSuccess: async (_response, request) => {
      if (!request.name) {
        throw new Error('Submitted create-resource request is missing its name');
      }
      await onCreated(request.name); // use the submitted request, not mutable live form state
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
        <FormErrorSummary form={form} />
        <FormField
          control={form.control}
          name="name"
          // Validate presence and format; each message mirrors its constraint.
          rules={{
            required: 'Name is required',
            pattern: {
              value: /^[A-Z][A-Z0-9_]*$/,
              message: 'Name must be uppercase letters, numbers, or underscores',
            },
          }}
          render={({ field, fieldState }) => (
            <label>
              Resource name <RequiredIndicator />
              <Input
                {...field}
                data-testid="resource-name-input"
                aria-invalid={fieldState.invalid}
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
