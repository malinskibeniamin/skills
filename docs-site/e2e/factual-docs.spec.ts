import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

test.beforeEach(async ({ page }) => {
  await installScreenshotVoices(page);
});

test("factual docs: canonical directory includes docs", async ({ page }) => {
  await page.goto("/skills");
  const card = page.locator("main").getByRole("link", { name: /^\/docs\s/ });
  await expect(card).toBeVisible();
  await expect(card).toHaveScreenshot("docs-directory-card.png");
  await card.click();
  await expect(page).toHaveURL(/\/skills\/docs\/?$/);
});

for (const viewport of [
  { name: "desktop", width: 1440, height: 1000 },
  { name: "mobile", width: 390, height: 844 },
]) {
  test(`factual docs: discover and read ${viewport.name}`, async ({ page }) => {
    await page.setViewportSize(viewport);
    const errors: string[] = [];
    page.on("pageerror", (error) => errors.push(error.message));
    await page.goto("/");
    const search = page.getByRole("searchbox", { name: "Search skills" });
    await search.fill("docs");
    const card = page
      .getByRole("article")
      .getByRole("link", { name: /^\/docs\s/ });
    await expect(card).toBeVisible();
    await card.scrollIntoViewIfNeeded();
    await stabilizeScreenshotDate(page, false);
    await expect(page).toHaveScreenshot(`docs-search-${viewport.name}.png`);
    await card.focus();
    await page.keyboard.press("Tab");
    await page.keyboard.press("Shift+Tab");
    await expect(card).toBeFocused();
    await card.press("Enter");
    await expect(page).toHaveURL(/\/skills\/docs\/?$/);
    await expect(
      page.getByRole("heading", { name: "/docs", exact: true }),
    ).toBeVisible();
    const diagram = page.getByRole("img", {
      name: "Diagram of the /docs skill",
    });
    await expect(diagram).toBeVisible();
    expect(
      await diagram.evaluate(
        (image: HTMLImageElement) => image.complete && image.naturalWidth > 0,
      ),
    ).toBe(true);
    await expect(
      page.getByRole("heading", { name: /Load guidance/ }),
    ).toBeVisible();
    await stabilizeScreenshotDate(page);
    await expect(page).toHaveScreenshot(`docs-page-${viewport.name}.png`, {
      fullPage: true,
    });
    await page.keyboard.press("Space");
    await page.keyboard.press("Escape");
    expect(
      await page.evaluate(() => document.documentElement.scrollWidth),
    ).toBeLessThanOrEqual(viewport.width);
    await page.reload();
    await expect(
      page.getByRole("heading", { name: "/docs", exact: true }),
    ).toBeVisible();
    expect(errors).toEqual([]);
  });
}

for (const { locale, searchLabel, heading } of [
  {
    locale: "pl",
    searchLabel: "Wyszukaj umiejętności",
    heading: "Pisz lub recenzuj",
  },
  { locale: "zh-CN", searchLabel: "搜索技能", heading: "撰写或审查" },
  { locale: "zh-TW", searchLabel: "搜尋技能", heading: "撰寫或審查" },
]) {
  test(`factual docs: localized discovery and reading ${locale}`, async ({
    page,
  }) => {
    await page.goto(`/${locale}`);
    await page.getByRole("searchbox", { name: searchLabel }).fill("docs");
    await stabilizeScreenshotDate(page, false);
    await expect(page).toHaveScreenshot(`docs-search-${locale}.png`);
    await page
      .getByRole("article")
      .getByRole("link", { name: /^\/docs\s/ })
      .click();
    await expect(page).toHaveURL(new RegExp(`/${locale}/skills/docs/?$`));
    await expect(
      page.getByRole("heading", { name: "/docs", exact: true }),
    ).toBeVisible();
    await expect(
      page.getByRole("heading", { name: new RegExp(`^${heading}#?$`) }),
    ).toBeVisible();
    await expect(page.locator("html")).toHaveAttribute("lang", locale);
    await stabilizeScreenshotDate(page);
    await expect(page).toHaveScreenshot(`docs-page-${locale}.png`, {
      fullPage: true,
    });
    await page.goto(`/${locale}/skills/ask-ben`);
    const catalogRow = page.getByRole("row", { name: /^\/docs\s/ });
    await expect(catalogRow).toBeVisible();
    await expect(catalogRow).toHaveScreenshot(`docs-catalog-${locale}.png`);
  });
}
