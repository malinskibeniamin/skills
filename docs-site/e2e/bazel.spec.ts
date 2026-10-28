import { expect, test } from "@playwright/test";

for (const locale of ["en", "pl", "zh-CN", "zh-TW"]) {
  for (const viewport of [
    { name: "desktop", width: 1440, height: 1000 },
    { name: "mobile", width: 390, height: 844 },
  ]) {
    test(`bazel release guidance: ${locale} ${viewport.name}`, async ({
      page,
    }) => {
      await page.setViewportSize(viewport);
      await page.emulateMedia({ colorScheme: "light" });
      const prefix = locale === "en" ? "" : `/${locale}`;
      await page.goto(`${prefix}/skills/bazel`);
      const guidance = page.locator(
        'main a[href="https://github.com/malinskibeniamin/skills/blob/main/bazel/references/releases.md"]',
      );
      await expect(guidance).toHaveCount(1);
      await guidance.scrollIntoViewIfNeeded();
      await expect(guidance).toBeVisible();
      await expect(guidance.locator("..")).toHaveScreenshot(
        `bazel-release-routing-${locale}-${viewport.name}.png`,
      );
      expect(
        await page.evaluate(() => document.documentElement.scrollWidth),
      ).toBeLessThanOrEqual(viewport.width);
    });
  }
}
