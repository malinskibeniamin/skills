import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

// development-lifecycle already owns desktop/mobile screenshots in matt-v1-3.
// These changed skill pages had no visual coverage of their rendered guidance.
for (const skill of [
  "frontend-invariants",
  "improve",
  "lie-detector",
  "writing-for-agents",
]) {
  for (const locale of ["en", "pl", "zh-CN", "zh-TW"]) {
    for (const viewport of [
      { name: "desktop", width: 1440, height: 1000 },
      { name: "mobile", width: 390, height: 844 },
    ]) {
      test(`agent check loop: ${skill} ${locale} ${viewport.name}`, async ({
        page,
      }) => {
        await installScreenshotVoices(page);
        await page.setViewportSize(viewport);
        const prefix = locale === "en" ? "" : `/${locale}`;
        await page.goto(`${prefix}/`);
        await page.getByRole("main").getByRole("searchbox").fill(skill);
        await page
          .getByRole("main")
          .getByRole("link", { name: new RegExp(`^/${skill}\\s`) })
          .click();
        await expect(page).toHaveURL(
          new RegExp(`${prefix}/skills/${skill}/?$`),
        );
        await expect(
          page.getByRole("heading", { name: `/${skill}`, exact: true }),
        ).toBeVisible();
        await stabilizeScreenshotDate(page);
        await expect(page).toHaveScreenshot(
          `${skill}-${locale}-${viewport.name}.png`,
          { fullPage: true },
        );
        expect(
          await page.evaluate(() => document.documentElement.scrollWidth),
        ).toBeLessThanOrEqual(viewport.width);
      });
    }
  }
}
