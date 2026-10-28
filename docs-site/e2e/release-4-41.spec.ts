import { expect, test } from "@playwright/test";
import { installScreenshotVoices } from "./screenshot-date";

for (const viewport of [
  { name: "desktop", width: 1440, height: 1000 },
  { name: "mobile", width: 390, height: 844 },
]) {
  test(`4.41 release archive: ${viewport.name}`, async ({ page }) => {
    await installScreenshotVoices(page);
    await page.setViewportSize(viewport);
    await page.goto("/skills/skeleton-loaders");
    const navigation =
      viewport.name === "mobile"
        ? page.getByRole("complementary", { name: "Primary" })
        : page.getByRole("banner");
    if (viewport.name === "mobile") {
      await page.getByRole("button", { name: "Toggle navigation" }).click();
    }
    await navigation.locator('summary[aria-label="Version: main"]').click();
    const menu = navigation.locator("details[open]");
    const release = menu.getByRole("link", { name: "v4.41.0", exact: true });
    await expect(release).toBeVisible();
    await expect(menu.locator(":scope > div")).toHaveScreenshot(
      `version-menu-${viewport.name}.png`,
    );
    await release.click();
    await expect(page).toHaveURL(/\/v4\.41\.0\/skills\/skeleton-loaders\/?$/);
    await expect(
      page.getByRole("heading", { name: "/skeleton-loaders", exact: true }),
    ).toBeVisible();
    await expect(page.getByRole("main").locator("pre")).toHaveCount(2);
    if (viewport.name === "mobile") {
      await page.getByRole("button", { name: "Toggle navigation" }).click();
    }
    await expect(
      navigation.locator('summary[aria-label^="Version:"]'),
    ).toHaveAttribute("aria-label", "Version: v4.41.0");
    expect(
      await page.evaluate(() => document.documentElement.scrollWidth),
    ).toBeLessThanOrEqual(viewport.width);
  });
}
