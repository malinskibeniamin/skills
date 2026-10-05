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
    correct: "Poteto: Make repeated agent mistakes impossible by design.",
  },
  {
    code: "pl",
    benny:
      "Poteto: Skonfiguruj pakiet Benny do klasyfikacji i odtwarzania zgłoszeń.",
    correct:
      "Poteto: Wyeliminuj powtarzające się błędy agentów przez projektowanie.",
  },
  {
    code: "zh-CN",
    benny: "Poteto：配置 Benny 问题分类与复现工具包。",
    correct: "Poteto：通过设计消除代理反复犯的错误。",
  },
  {
    code: "zh-TW",
    benny: "Poteto：設定 Benny 問題分類與重現工具包。",
    correct: "Poteto：透過設計消除代理反覆犯的錯誤。",
  },
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
      ).toHaveCount(53);
      for (const name of [
        "/poteto-setup-benny",
        "/poteto-triage-issue-reports",
        "/poteto-reproduce-and-fix-issues",
        "/poteto-benchmark-checklist",
        "/poteto-correct",
        "/poteto-principle-explain-the-number",
      ]) {
        await expect(page.getByRole("cell", { name, exact: true })).toHaveCount(
          1,
        );
      }
      await expect(
        page.getByRole("cell", { name: locale.benny, exact: true }),
      ).toHaveCount(1);
      await expect(
        page.getByRole("cell", { name: locale.correct, exact: true }),
      ).toHaveCount(1);
      // Chinese router pages do not offer narration; tables are not narrated.
      await stabilizeScreenshotDate(page, !locale.code.startsWith("zh-"));
      await page
        .getByRole("row")
        .filter({ hasText: "/poteto-bro" })
        .scrollIntoViewIfNeeded();
      const suffix = locale.code === "en" ? "" : `-${locale.code}`;
      await expect(page).toHaveScreenshot(
        `poteto-catalog${suffix}-${scenario.name}.png`,
      );
      await page
        .getByRole("row")
        .filter({ hasText: "/poteto-principle-experience-first" })
        .scrollIntoViewIfNeeded();
      await expect(page).toHaveScreenshot(
        `poteto-measurement${suffix}-${scenario.name}.png`,
      );
    });
  }
}
