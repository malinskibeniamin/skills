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
      for (const workflow of ["diagnosing-bugs", "dogfood", "visual-review"]) {
        test(`${locale === "en" ? "" : `${locale}: `}read ${workflow} content stress handoff`, async ({
          page,
        }) => {
          await installScreenshotVoices(page);
          const prefix = locale === "en" ? "" : `/${locale}`;
          await page.goto(`${prefix}/skills/${workflow}`);
          await expect(
            page.getByRole("heading", { name: `/${workflow}`, exact: true }),
          ).toBeVisible();
          const handoff = page
            .getByRole("main")
            .getByText(/Skill.*[“"]break-ui[”"]/);
          await expect(handoff).toBeVisible();
          await stabilizeScreenshotDate(page);
          await handoff.scrollIntoViewIfNeeded();
          await expect(page).toHaveScreenshot(
            `${locale === "en" ? "" : `${locale}-`}${workflow}-${appearance}.png`,
          );
        });
      }
    }
  });
}
