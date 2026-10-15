import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

for (const viewport of [
  { name: "desktop", width: 1440, height: 1000 },
  { name: "mobile", width: 390, height: 844 },
]) {
  test(`launchdarkly: discover and read ${viewport.name}`, async ({ page }) => {
    await page.setViewportSize(viewport);
    await installScreenshotVoices(page);
    await page.goto("/");
    await page.getByRole("searchbox").fill("launchdarkly");
    const skill = page.getByRole("link", { name: /^\/launchdarkly\s/ }).last();
    await expect(skill).toBeVisible();
    await skill.click();
    await expect(page).toHaveURL(/\/skills\/launchdarkly$/);
    await expect(page.locator("main h1")).toHaveText("/launchdarkly");
    await expect(page.locator("main")).toContainText(
      "Integration (integration) and Production (production)",
    );
    await expect(page.locator("main")).toContainText(
      "Audit requests are read-only",
    );
    await stabilizeScreenshotDate(page);
    await expect(page).toHaveScreenshot(`launchdarkly-${viewport.name}.png`);
  });
}
