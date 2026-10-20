import { expect, test } from "@playwright/test";
import { installScreenshotVoices } from "./screenshot-date";

// Public catalog coverage: registration tests cannot catch omitted translations
// or unreadable wrapping after the Markdown has passed through the site renderer.
for (const locale of ["en", "pl", "zh-CN", "zh-TW"]) {
  for (const scenario of [
    { name: "desktop", width: 1440, height: 1000, colorScheme: "light" },
    { name: "dark", width: 1440, height: 1000, colorScheme: "dark" },
    { name: "mobile", width: 390, height: 844, colorScheme: "light" },
  ] as const) {
    test(`Cursor CLI catalog ${locale} ${scenario.name}`, async ({ page }) => {
      await installScreenshotVoices(page);
      await page.setViewportSize(scenario);
      await page.emulateMedia({ colorScheme: scenario.colorScheme });
      const prefix = locale === "en" ? "" : `/${locale}`;
      await page.goto(`${prefix}/skills`);
      await page
        .getByRole("link", { name: /^\/ask-ben\s/ })
        .last()
        .click();
      await expect(
        page.getByRole("heading", { name: "/ask-ben", exact: true }).first(),
      ).toBeVisible();
      const entry = page
        .getByRole("row")
        .filter({ hasText: "/cli-for-agents" });
      await expect(entry).toHaveCount(1);
      await entry.scrollIntoViewIfNeeded();
      await expect(entry).toHaveScreenshot(
        `cursor-cli-${locale}-${scenario.name}.png`,
      );
    });
  }
}
