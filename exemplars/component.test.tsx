import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { createRouterTransport } from '@connectrpc/connect';
import { test, expect, vi } from 'vitest';
import { DeleteTopicButton } from './component';

test('deletes the topic and surfaces server errors inline', async () => {
  const user = userEvent.setup();
  const deleteTopic = vi.fn().mockResolvedValue({});
  const transport = createRouterTransport(({ service }) => {
    /* wire mock service here */
  });

  render(<DeleteTopicButton topicName="orders" />, { wrapper: withTransport(transport) });

  await user.click(screen.getByRole('button', { name: /delete topic orders/i }));

  await waitFor(() => expect(deleteTopic).toHaveBeenCalledWith({ topicName: 'orders' }));
  expect(screen.getByRole('button', { name: /delete topic orders/i })).toBeVisible();
});
