import { expect, test } from "@playwright/test";
import { installScreenshotVoices } from "./screenshot-date";

for (const locale of ["en", "pl", "zh-CN", "zh-TW"]) {
  for (const viewport of [
    { name: "desktop", width: 1440, height: 1000 },
    { name: "mobile", width: 390, height: 844 },
  ]) {
    test(`Native T3 entrypoints: ${locale} ${viewport.name}`, async ({
      page,
    }) => {
      await page.setViewportSize(viewport);
      await installScreenshotVoices(page);
      const prefix = locale === "en" ? "" : `/${locale}`;
      const errors: string[] = [];
      page.on("pageerror", (error) => errors.push(error.message));
      for (const skill of [
        "development-lifecycle",
        "tdd",
        "dogfood",
        "full-send",
      ]) {
        const response = await page.goto(`${prefix}/skills/${skill}`);
        expect(response?.status()).toBe(200);
        const link = page
          .getByRole("main")
          .locator('a[href$="/shared/T3CODE-NATIVE.md#resolve-context"]');
        await expect(link).toHaveAttribute(
          "href",
          /\/shared\/T3CODE-NATIVE\.md#resolve-context$/,
        );
        await link.scrollIntoViewIfNeeded();
        await link.focus();
        await expect(link).toBeFocused();
        await expect(link.locator("..")).toHaveScreenshot(
          `${skill}-${locale}-${viewport.name}.png`,
        );
        expect(
          await page.evaluate(() => document.documentElement.scrollWidth),
        ).toBeLessThanOrEqual(viewport.width);
      }
      expect(errors).toEqual([]);
    });
  }
}
