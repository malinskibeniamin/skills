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

    for (const workflow of ["diagnosing-bugs", "dogfood", "visual-review"]) {
      test(`read ${workflow} content stress handoff`, async ({ page }) => {
        await installScreenshotVoices(page);
        await page.goto(`/skills/${workflow}`);
        await expect(
          page.getByRole("heading", { name: `/${workflow}`, exact: true }),
        ).toBeVisible();
        const handoff = page
          .getByRole("main")
          .getByText(/Call the Skill tool with [“"]break-ui[”"]/);
        await expect(handoff).toBeVisible();
        await stabilizeScreenshotDate(page);
        await handoff.scrollIntoViewIfNeeded();
        await expect(page).toHaveScreenshot(`${workflow}-${appearance}.png`);
      });
    }
  });
}
