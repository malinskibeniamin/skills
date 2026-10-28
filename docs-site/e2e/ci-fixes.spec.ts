import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

// One article capture per locale: desktop diagram/readability, then the three
// translated mobile layouts. No duplicate card/catalog snapshots or agent evals.
for (const locale of ["en", "pl", "zh-CN", "zh-TW"]) {
  test(`ci fixes: ${locale}`, async ({ page }) => {
    const width = locale === "en" ? 1440 : 390;
    await installScreenshotVoices(page);
    await page.setViewportSize({ width, height: 1000 });
    const errors: string[] = [];
    page.on("pageerror", (error) => errors.push(error.message));
    const prefix = locale === "en" ? "" : `/${locale}`;
    const main = page.getByRole("main");
    if (locale === "en") {
      await page.goto("/");
      await main.getByRole("searchbox").fill("ci-fixes");
      await main.getByRole("link", { name: /^\/ci-fixes\s/ }).click();
    } else {
      await page.goto(`${prefix}/skills/ci-fixes`);
    }
    await expect(
      main.getByRole("heading", { name: "/ci-fixes", exact: true }),
    ).toBeVisible();
    await expect(main.locator('a[href$="/ci-fixes/REFERENCE.md"]')).toHaveCount(
      1,
    );
    const diagram = main.locator('img[src$="/ci-fixes.svg"]');
    await expect(diagram).toBeVisible();
    await expect
      .poll(() =>
        diagram.evaluate((image: HTMLImageElement) => image.naturalWidth),
      )
      .toBeGreaterThan(0);
    await stabilizeScreenshotDate(page);
    await expect(main).toHaveScreenshot(`article-${locale}.png`);
    expect(
      await page.evaluate(() => document.documentElement.scrollWidth),
    ).toBeLessThanOrEqual(width);
    expect(errors).toEqual([]);
  });
}
