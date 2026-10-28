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
    test(`protobuf discovery: ${locale} ${viewport.name}`, async ({ page }) => {
      await installScreenshotVoices(page);
      await page.setViewportSize(viewport);
      const prefix = locale === "en" ? "" : `/${locale}`;
      const screenshotName = `${locale}-${viewport.name}`;

      await page.goto(`${prefix}/`);
      const main = page.getByRole("main");
      await main.getByRole("searchbox").fill("protobuf");
      const card = main.getByRole("link", { name: /^\/protobuf\s/ });
      await expect(card).toBeVisible();
      await expect(card).toHaveScreenshot(`card-${screenshotName}.png`);
      await card.click();
      await expect(page).toHaveURL(new RegExp(`${prefix}/skills/protobuf/?$`));
      await expect(
        main.getByRole("heading", { name: "/protobuf", exact: true }),
      ).toBeVisible();
      const diagram = main.locator('img[src$="/protobuf.svg"]');
      await expect(diagram).toBeVisible();
      await expect
        .poll(() =>
          diagram.evaluate((image: HTMLImageElement) => image.naturalWidth),
        )
        .toBeGreaterThan(0);
      await expect(
        main.getByRole("link", { name: "aip", exact: true }),
      ).toHaveAttribute(
        "href",
        "https://github.com/malinskibeniamin/skills/blob/main/aip/SKILL.md",
      );
      await stabilizeScreenshotDate(page);
      await expect(page).toHaveScreenshot(`page-${screenshotName}.png`, {
        fullPage: true,
      });
      expect(
        await page.evaluate(() => document.documentElement.scrollWidth),
      ).toBeLessThanOrEqual(viewport.width);

      await page.goto(`${prefix}/skills/ask-ben`);
      const row = page.getByRole("row").filter({ hasText: "/protobuf" });
      await expect(row).toBeVisible();
      await expect(row).toHaveScreenshot(`catalog-${screenshotName}.png`);
    });
  }
}
