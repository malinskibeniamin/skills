import { expect, test } from "@playwright/test";

for (const locale of ["en", "pl", "zh-CN", "zh-TW"]) {
  const prefix = locale === "en" ? "" : `/${locale}`;

  test(`model routes: ${locale} codex`, async ({ page }) => {
    await page.goto(`${prefix}/skills/codex`);
    await expect(
      page.getByRole("heading", { name: "/codex", exact: true }).first(),
    ).toBeVisible();
    const routes = page.getByRole("table");
    await expect(routes).toContainText("gpt-6.1-sol");
    await expect(routes).toContainText("claude-opus-5-5");
    await expect(routes.getByRole("row")).toHaveCount(3);
    await expect(routes).not.toContainText(/Astra|Luna|Fable|gpt-6-sol/);
    await expect(page).toHaveScreenshot(`model-codex-${locale}.png`, {
      fullPage: true,
    });
  });

  test(`model routes: ${locale} skill search`, async ({ page }) => {
    await page.goto(prefix || "/");
    await page.getByRole("searchbox").fill("codex");
    const codex = page.getByRole("link", { name: /^\/codex\s/ }).last();
    await expect(codex).toContainText("GPT-6.1 Sol");
    await expect(page).toHaveScreenshot(`model-search-${locale}.png`);
    await codex.click();
    await expect(page).toHaveURL(new RegExp(`${prefix}/skills/codex$`));
    await expect(page.getByRole("table")).toContainText("gpt-6.1-sol");
  });
}

test("model routes: mobile codex and dark search", async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto("/skills/codex");
  await expect(page.getByRole("table")).toContainText("gpt-6.1-sol");
  await expect(page).toHaveScreenshot("model-codex-mobile.png", {
    fullPage: true,
  });
  await page.emulateMedia({ colorScheme: "dark" });
  await page.goto("/");
  await page.getByRole("searchbox").fill("codex");
  await expect(
    page.getByRole("link", { name: /^\/codex\s/ }).last(),
  ).toContainText("GPT-6.1 Sol");
  await expect(page).toHaveScreenshot("model-search-dark-mobile.png");
});
