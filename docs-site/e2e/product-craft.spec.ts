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
      test(`${locale}: product craft guidance remains readable`, async ({
        page,
      }) => {
        await installScreenshotVoices(page);
        const prefix = locale === "en" ? "" : `/${locale}`;
        await page.goto(`${prefix}/skills/product`);
        const main = page.getByRole("main");
        await expect(
          main.getByRole("heading", { name: "/product", exact: true }),
        ).toBeVisible();
        await stabilizeScreenshotDate(page);
        await page.evaluate(() => document.fonts.ready);
        await expect
          .poll(() =>
            page.evaluate(
              () => document.documentElement.scrollWidth <= window.innerWidth,
            ),
          )
          .toBe(true);
        await expect(main).toHaveScreenshot(
          `product-craft-${locale}-${appearance}.png`,
        );
      });
    }
  });
}
