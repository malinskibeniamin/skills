import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

for (const locale of [
  { code: "en", search: "Search skills", orchestrators: "Orchestrators" },
  {
    code: "pl",
    search: "Wyszukaj umiejętności",
    orchestrators: "Orkiestratory",
  },
  { code: "zh-CN", search: "搜索技能", orchestrators: "编排器" },
  { code: "zh-TW", search: "搜尋技能", orchestrators: "協調器" },
]) {
  const prefix = locale.code === "en" ? "" : `/${locale.code}`;
  const snapshotLocale = locale.code === "en" ? "" : `-${locale.code}`;
  for (const viewport of [
    { name: "desktop", width: 1440, height: 1000 },
    { name: "mobile", width: 390, height: 844 },
  ]) {
    test(`software factory: discovery and planning guidance ${locale.code} ${viewport.name}`, async ({
      page,
    }) => {
      await page.setViewportSize(viewport);
      await installScreenshotVoices(page);
      await page.goto(`${prefix}/`);
      await page
        .getByRole("searchbox", { name: locale.search })
        .fill("software-factory");
      const skill = page.getByRole("link", { name: /^\/software-factory/ });
      await expect(skill).toHaveCount(1);
      await skill.scrollIntoViewIfNeeded();
      await expect(page).toHaveScreenshot(
        `factory-search${snapshotLocale}-${viewport.name}.png`,
      );
      await skill.click();
      await expect(
        page.getByRole("heading", { name: "/software-factory", exact: true }),
      ).toBeVisible();
      await expect(page).toHaveURL(
        new RegExp(`${prefix}/skills/software-factory/?$`),
      );
      await expect(page.locator("html")).toHaveAttribute("lang", locale.code);
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
        page.getByRole("link", { name: locale.orchestrators, exact: true }),
      ).toHaveCount(1);
      await expect(page).toHaveScreenshot(
        `factory-guide${snapshotLocale}-${viewport.name}.png`,
      );
      await page.goto(`${prefix}/skills/ask-ben`);
      const catalogRow = page.getByRole("row").filter({
        has: page.getByRole("cell", { name: "/software-factory", exact: true }),
      });
      await expect(catalogRow).toHaveCount(1);
      await catalogRow.scrollIntoViewIfNeeded();
      await expect(catalogRow).toHaveScreenshot(
        `factory-catalog${snapshotLocale}-${viewport.name}.png`,
      );
      expect(
        await page.evaluate(() => document.documentElement.scrollWidth),
      ).toBeLessThanOrEqual(viewport.width);
    });
  }
}
