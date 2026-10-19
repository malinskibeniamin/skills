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

    test.beforeEach(async ({ page }) => {
      await installScreenshotVoices(page);
    });

    for (const skill of [
      "animate",
      "animation-performance",
      "animation-vocabulary",
      "mobile-native",
      "break-ui",
      "ask-sonner",
    ]) {
      test(`find and read ${skill}`, async ({ page }) => {
        await test.step("Find the skill in the public directory", async () => {
          await page.goto("/");
          await page
            .getByRole("searchbox", { name: "Search skills" })
            .fill(skill);
          const link = page
            .getByRole("article")
            .getByRole("link", { name: new RegExp(`^/${skill}\\s`) });
          await expect(link).toHaveCount(1);
          await link.click();
        });

        await test.step("Read its canonical guidance", async () => {
          await expect(page).toHaveURL(new RegExp(`/skills/${skill}/?$`));
          await expect(
            page.getByRole("heading", { name: `/${skill}`, exact: true }),
          ).toBeVisible();
          const diagram = page.getByRole("img", {
            name: `Diagram of the /${skill} skill`,
            exact: true,
          });
          await expect
            .poll(() =>
              diagram.evaluate((image) =>
                image instanceof HTMLImageElement ? image.naturalWidth : 0,
              ),
            )
            .toBeGreaterThan(0);
          await stabilizeScreenshotDate(page);
          await expect(page).toHaveScreenshot(`${skill}-${appearance}.png`, {
            fullPage: true,
          });
        });
      });
    }
  });
}
