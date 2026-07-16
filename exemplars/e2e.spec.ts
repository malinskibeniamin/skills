import { test, expect } from '../fixtures/base';

// Deterministic e2e shape: every wait has a cause (URL, request, element
// state) — never a duration. Route matchers name Service/Method only, so
// an API version bump cannot break the spec.
test('creates a secret and shows it in the list', async ({ page }) => {
  await test.step('navigate to secrets', async () => {
    await page.getByTestId('nav-secrets').click();
    await page.waitForURL('**/secrets');
  });

  await test.step('submit the create form', async () => {
    await page.getByTestId('create-secret-button').click();
    await page.getByTestId('secret-name-input').fill('API_KEY');

    const createResponse = page.waitForResponse((r) =>
      r.url().includes('SecretService/CreateSecret'),
    );
    await page.getByTestId('create-secret-submit').click();
    // Assert the side effect, not the toast — toasts are ephemeral.
    expect((await createResponse).ok()).toBe(true);
  });

  await test.step('new secret is listed', async () => {
    await expect(page.getByRole('row', { name: /API_KEY/ })).toBeVisible();
  });
});
