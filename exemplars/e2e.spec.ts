import { test, expect } from '../fixtures/base';

// Deterministic e2e shape: every wait has a cause (URL, request, element
// state) — never a duration. Route matchers name Service/Method only, so
// an API version bump cannot break the spec.
test('creates a resource and shows it in the list', async ({ page }) => {
  await test.step('navigate to resources', async () => {
    await page.getByTestId('nav-resources').click();
    await page.waitForURL('**/resources');
  });

  await test.step('submit the create form', async () => {
    await page.getByTestId('create-resource-button').click();
    await page.getByTestId('resource-name-input').fill('ALPHA_KEY');

    const createResponse = page.waitForResponse((r) =>
      r.url().includes('ResourceService/CreateResource'),
    );
    await page.getByTestId('create-resource-submit').click();
    // Assert the side effect, not the toast — toasts are ephemeral.
    expect((await createResponse).ok()).toBe(true);
  });

  await test.step('new resource is listed', async () => {
    await expect(page.getByRole('row', { name: /ALPHA_KEY/ })).toBeVisible();
  });
});
