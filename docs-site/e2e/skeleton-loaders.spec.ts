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
    test(`skeleton loaders: ${locale} ${viewport.name}`, async ({ page }) => {
      await installScreenshotVoices(page);
      await page.setViewportSize(viewport);
      const prefix = locale === "en" ? "" : `/${locale}`;
      const screenshotName = `${locale}-${viewport.name}`;

      await page.goto(`${prefix}/`);
      const main = page.getByRole("main");
      await main.getByRole("searchbox").fill("skeleton-loaders");
      const card = main.getByRole("link", { name: /^\/skeleton-loaders\s/ });
      await expect(card).toBeVisible();
      await expect(card).toHaveScreenshot(`card-${screenshotName}.png`);
      await card.click();
      await expect(page).toHaveURL(
        new RegExp(`${prefix}/skills/skeleton-loaders/?$`),
      );
      await expect(
        main.getByRole("heading", { name: "/skeleton-loaders", exact: true }),
      ).toBeVisible();
      await expect(main.locator("pre")).toHaveCount(2);
      const diagram = main.locator('img[src$="/skeleton-loaders.svg"]');
      await expect(diagram).toBeVisible();
      await expect
        .poll(() =>
          diagram.evaluate((image: HTMLImageElement) => image.naturalWidth),
        )
        .toBeGreaterThan(0);
      await stabilizeScreenshotDate(page);
      await expect(page).toHaveScreenshot(`page-${screenshotName}.png`, {
        fullPage: true,
      });
      expect(
        await page.evaluate(() => document.documentElement.scrollWidth),
      ).toBeLessThanOrEqual(viewport.width);

      await page.goto(`${prefix}/skills/ask-ben`);
      const catalogRow = page
        .getByRole("row")
        .filter({ hasText: "/skeleton-loaders" });
      await expect(catalogRow).toBeVisible();
      await expect(catalogRow).toHaveScreenshot(
        `catalog-${screenshotName}.png`,
      );
    });
  }
}
