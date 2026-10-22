import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

for (const viewport of [
  { name: "desktop", width: 1440, height: 1000 },
  { name: "mobile", width: 390, height: 844 },
]) {
  test(`software factory: discovery and planning guidance ${viewport.name}`, async ({
    page,
  }) => {
    await page.setViewportSize(viewport);
    await installScreenshotVoices(page);
    await page.goto("/");
    await page
      .getByRole("searchbox", { name: "Search skills" })
      .fill("software-factory");
    const skill = page.getByRole("link", { name: /^\/software-factory/ });
    await expect(skill).toHaveCount(1);
    await skill.scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot(`factory-search-${viewport.name}.png`);
    await skill.click();
    await expect(
      page.getByRole("heading", { name: "/software-factory", exact: true }),
    ).toBeVisible();
    await stabilizeScreenshotDate(page);
    const diagram = page.getByRole("main").getByRole("img");
    await expect(diagram).toBeVisible();
    expect(
      await diagram.evaluate(
        (element) =>
          element instanceof HTMLImageElement && element.naturalWidth > 0,
      ),
    ).toBe(true);
    await expect(
      page.getByRole("link", { name: "Orchestrators", exact: true }),
    ).toHaveCount(1);
    await expect(page).toHaveScreenshot(`factory-guide-${viewport.name}.png`);
    await page.goto("/skills/ask-ben");
    const catalogRow = page.getByRole("row").filter({
      has: page.getByRole("cell", { name: "/software-factory", exact: true }),
    });
    await expect(catalogRow).toHaveCount(1);
    await catalogRow.scrollIntoViewIfNeeded();
    await expect(catalogRow).toHaveScreenshot(
      `factory-catalog-${viewport.name}.png`,
    );
    expect(
      await page.evaluate(() => document.documentElement.scrollWidth),
    ).toBeLessThanOrEqual(viewport.width);
  });
}
