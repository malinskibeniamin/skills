import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

for (const appearance of ["desktop-light", "mobile-dark"]) {
  test.describe(appearance, () => {
    test.use({
      viewport:
        appearance === "desktop-light"
          ? { width: 1440, height: 1000 }
          : { width: 390, height: 844 },
      colorScheme: appearance === "desktop-light" ? "light" : "dark",
    });

    for (const locale of ["en", "pl", "zh-CN", "zh-TW"]) {
      test(`${locale}: author and review share explicit delivery guidance`, async ({
        page,
      }) => {
        await installScreenshotVoices(page);
        const prefix = locale === "en" ? "" : `/${locale}`;
        await page.goto(`${prefix}/skills/work`);
        const main = page.getByRole("main");
        await expect(
          main.getByRole("heading", { name: "/work", exact: true }),
        ).toBeVisible();
        await expect(
          main.locator('a[href$="/development-lifecycle/SKILL.md"]'),
        ).toBeVisible();

        await page.goto(prefix || "/");
        await page.getByRole("searchbox").fill("review");
        await page
          .getByRole("article")
          .getByRole("link", { name: /^\/review\s/ })
          .click();
        await expect(
          main.getByRole("heading", { name: "/review", exact: true }),
        ).toBeVisible();
        await expect(
          main.locator('a[href$="/shared/delivery-workflow.md"]'),
        ).toBeVisible();

        await page.goto(`${prefix}/skills/go`);
        const sharedDelivery = main.locator(
          'a[href$="/shared/delivery-workflow.md"]',
        );
        await expect(sharedDelivery).toBeVisible();
        await stabilizeScreenshotDate(page, false);
        await sharedDelivery.scrollIntoViewIfNeeded();
        await expect(page).toHaveScreenshot(
          `shared-author-${locale}-${appearance}.png`,
        );
      });
    }
  });
}
