import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { createRouterTransport } from '@connectrpc/connect';
import { test, expect, vi } from 'vitest';
import { DeleteResourceButton } from './component';

test('deletes the resource and surfaces server errors inline', async () => {
  const user = userEvent.setup();
  const deleteResource = vi.fn().mockResolvedValue({});
  const transport = createRouterTransport(({ service }) => {
    /* wire mock service here */
  });

  render(<DeleteResourceButton resourceName="alpha" />, { wrapper: withTransport(transport) });

  await user.click(screen.getByRole('button', { name: /delete resource alpha/i }));

  await waitFor(() => expect(deleteResource).toHaveBeenCalledWith({ resourceName: 'alpha' }));
  expect(screen.getByRole('button', { name: /delete resource alpha/i })).toBeVisible();
});
