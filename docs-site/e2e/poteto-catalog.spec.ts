import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

test.beforeEach(async ({ page }) => {
  await installScreenshotVoices(page);
});

for (const locale of [
  {
    code: "en",
    benny: "Poteto: Configure the Benny triage and reproduction pack.",
  },
  {
    code: "pl",
    benny:
      "Poteto: Skonfiguruj pakiet Benny do klasyfikacji i odtwarzania zgłoszeń.",
  },
  { code: "zh-CN", benny: "Poteto：配置 Benny 问题分类与复现工具包。" },
  { code: "zh-TW", benny: "Poteto：設定 Benny 問題分類與重現工具包。" },
]) {
  for (const scenario of [
    { name: "desktop", width: 1440, height: 1000, dark: false },
    { name: "dark", width: 1440, height: 1000, dark: true },
    { name: "mobile", width: 390, height: 844, dark: false },
  ]) {
    test(`visual: complete Poteto catalog ${locale.code} ${scenario.name}`, async ({
      page,
    }) => {
      await page.setViewportSize({
        width: scenario.width,
        height: scenario.height,
      });
      await page.emulateMedia({
        colorScheme: scenario.dark ? "dark" : "light",
      });
      const prefix = locale.code === "en" ? "" : `/${locale.code}`;
      await page.goto(`${prefix}/skills/ask-ben`);
      await expect(
        page.getByRole("heading", { name: "/ask-ben", exact: true }).first(),
      ).toBeVisible();
      await expect(
        page.getByRole("row").filter({ hasText: /\/poteto-/ }),
      ).toHaveCount(50);
      for (const name of [
        "/poteto-setup-benny",
        "/poteto-triage-issue-reports",
        "/poteto-reproduce-and-fix-issues",
      ]) {
        await expect(page.getByRole("cell", { name, exact: true })).toHaveCount(
          1,
        );
      }
      await expect(
        page.getByRole("cell", { name: locale.benny, exact: true }),
      ).toHaveCount(1);
      // Chinese router pages do not offer narration; tables are not narrated.
      await stabilizeScreenshotDate(page, !locale.code.startsWith("zh-"));
      await page
        .getByRole("row")
        .filter({ hasText: "/postgresql" })
        .scrollIntoViewIfNeeded();
      const suffix = locale.code === "en" ? "" : `-${locale.code}`;
      await expect(page).toHaveScreenshot(
        `poteto-catalog${suffix}-${scenario.name}.png`,
      );
    });
  }
}
