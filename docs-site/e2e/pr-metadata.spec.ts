import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

for (const skill of ["commit-push-pr", "stacked-prs"]) {
  for (const locale of ["en", "pl", "zh-CN", "zh-TW"]) {
    for (const viewport of [
      { name: "desktop", width: 1440, height: 1000 },
      { name: "mobile", width: 390, height: 844 },
    ]) {
      test(`visual: PR metadata ${skill} ${locale} ${viewport.name}`, async ({
        page,
      }) => {
        await installScreenshotVoices(page);
        await page.setViewportSize(viewport);
        await page.goto(
          `${locale === "en" ? "" : `/${locale}`}/skills/${skill}`,
        );
        await expect(
          page.getByRole("heading", { name: `/${skill}`, exact: true }),
        ).toBeVisible();
        await stabilizeScreenshotDate(page);
        await expect(page).toHaveScreenshot(
          `pr-metadata-${skill}-${locale}-${viewport.name}.png`,
          { fullPage: true },
        );
      });
    }
  }
}
