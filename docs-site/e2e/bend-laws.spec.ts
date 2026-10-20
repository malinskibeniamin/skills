import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

for (const viewport of [
  { name: "desktop", width: 1440, height: 1000 },
  { name: "mobile", width: 390, height: 844 },
]) {
  test(`bend-laws: discover and read ${viewport.name}`, async ({ page }) => {
    await page.setViewportSize(viewport);
    await installScreenshotVoices(page);
    await page.goto("/");
    await page.getByRole("searchbox").fill("formal proof");
    const skill = page.getByRole("link", { name: /^\/bend-laws\s/ }).last();
    await expect(skill).toBeVisible();
    await skill.click();
    await expect(page).toHaveURL(/\/skills\/bend-laws$/);
    await expect(page.locator("main h1")).toHaveText("/bend-laws");
    await expect(page.locator("main")).toContainText(
      "Call only the functions under test",
    );
    await expect(page.locator("main")).toContainText("bendlang/bend#1328");
    await stabilizeScreenshotDate(page);
    await expect(page).toHaveScreenshot(`bend-laws-${viewport.name}.png`);
  });
}
