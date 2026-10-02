import { expect, test } from "@playwright/test";

for (const scenario of [
  { name: "desktop", width: 1440, height: 1000, dark: false },
  { name: "dark", width: 1440, height: 1000, dark: true },
  { name: "mobile", width: 390, height: 844, dark: false },
]) {
  test(`visual: complete Poteto catalog ${scenario.name}`, async ({ page }) => {
    await page.setViewportSize({
      width: scenario.width,
      height: scenario.height,
    });
    await page.emulateMedia({
      colorScheme: scenario.dark ? "dark" : "light",
    });
    await page.goto("/skills/ask-ben");
    await expect(
      page.getByRole("heading", { name: "/ask-ben", exact: true }).first(),
    ).toBeVisible();
    await expect(
      page.getByRole("row").filter({ hasText: /\/poteto-/ }),
    ).toHaveCount(50);
    for (const name of [
      "/poteto-setup-benny",
      "/poteto-triage-issue-reports",
      "/poteto-reproduce-and-fix-issues",
    ]) {
      await expect(page.getByRole("cell", { name, exact: true })).toHaveCount(
        1,
      );
    }
    await page
      .getByRole("row")
      .filter({ hasText: "/postgresql" })
      .scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot(`poteto-catalog-${scenario.name}.png`);
  });
}
