import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

for (const locale of ["en", "pl", "zh-CN", "zh-TW"]) {
  for (const viewport of [
    { name: "desktop", width: 1440, height: 1000 },
    { name: "mobile", width: 390, height: 844 },
  ]) {
    test(`ux-copy: ${locale} ${viewport.name}`, async ({ page }) => {
      await page.setViewportSize(viewport);
      await installScreenshotVoices(page);
      const prefix = locale === "en" ? "" : `/${locale}`;
      const name = `${locale}-${viewport.name}`;

      await page.goto(`${prefix}/`);
      await page.getByRole("main").getByRole("searchbox").fill("ux-copy");
      await expect(page.locator('main [aria-live="polite"]')).toContainText(
        "ux-copy",
      );
      const card = page
        .getByRole("main")
        .getByRole("link", { name: /^\/ux-copy\s/ });
      await expect(card).toHaveCount(1);
      await expect(card).toHaveScreenshot(`ux-copy-card-${name}.png`);
      await card.click();
      await expect(page).toHaveURL(new RegExp(`${prefix}/skills/ux-copy/?$`));
      await expect(
        page.getByRole("heading", { name: "/ux-copy", exact: true }),
      ).toBeVisible();
      await stabilizeScreenshotDate(page);
      await expect(page).toHaveScreenshot(`ux-copy-page-${name}.png`, {
        fullPage: true,
      });

      await page.goto(`${prefix}/skills`);
      const entry = page
        .getByRole("main")
        .getByRole("link", { name: /^\/ux-copy\s/ })
        .last();
      await expect(entry).toHaveAttribute("href", `${prefix}/skills/ux-copy`);
      await expect(entry).toHaveScreenshot(`ux-copy-directory-${name}.png`);

      await page.goto(`${prefix}/skills/ask-ben`);
      const row = page.getByRole("row").filter({ hasText: "/ux-copy" });
      await expect(row).toHaveCount(1);
      await expect(row).toHaveScreenshot(`ux-copy-catalog-${name}.png`);
    });
  }
}
