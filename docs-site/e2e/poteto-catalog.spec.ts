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
      ).toHaveCount(55);
      for (const name of [
        "/poteto-help",
        "/poteto-ketchup",
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

for (const locale of [
  {
    code: "pl",
    generate: "Wygeneruj",
    prove: "Udowodnij działanie wygenerowanej umiejętności",
    readiness:
      "Sam nasłuchujący port lub sprawna baza danych nie oznaczają gotowości.",
    seeds: "Brak wymaganych danych początkowych oznacza niepowodzenie ścieżki",
    standIn:
      "Pozostają niezweryfikowane do czasu odtworzenia ich w rzeczywistym środowisku docelowym.",
  },
  {
    code: "zh-CN",
    generate: "生成",
    prove: "验证生成的技能",
    readiness: "仅有端口监听或数据库正常并不代表应用已就绪。",
    seeds: "缺少所需种子数据时，该用户流程必须判为失败",
    standIn: "在真实目标环境中重新执行前，这些步骤仍未经过验证。",
  },
  {
    code: "zh-TW",
    generate: "產生",
    prove: "證明產生的技能可用",
    readiness: "僅有連接埠監聽或資料庫正常不代表應用程式已就緒。",
    seeds: "缺少所需種子資料時，該使用者流程必須判定為失敗",
    standIn: "在實際目標環境重新執行前，這些步驟仍未經驗證。",
  },
]) {
  for (const viewport of [
    { name: "desktop", width: 1440, height: 1000 },
    { name: "mobile", width: 390, height: 844 },
  ]) {
    test(`visual: verifier translation ${locale.code} ${viewport.name}`, async ({
      page,
    }) => {
      await page.setViewportSize({
        width: viewport.width,
        height: viewport.height,
      });
      await page.goto(`/${locale.code}/skills/create-verification-skill`);
      await stabilizeScreenshotDate(page, false);
      await page
        .getByRole("link", { name: `${locale.generate}#`, exact: true })
        .click();
      await expect(page).toHaveURL(/#generate$/);
      await expect(page.getByRole("main")).toContainText(locale.readiness);
      await expect(page.getByRole("main")).toContainText(locale.seeds);
      await expect(page).toHaveScreenshot(
        `poteto-verifier-readiness-${locale.code}-${viewport.name}.png`,
      );
      await page
        .getByRole("link", { name: `${locale.prove}#`, exact: true })
        .click();
      await expect(page).toHaveURL(/#prove-the-generated-skill$/);
      await expect(page.getByRole("main")).toContainText(locale.standIn);
      await expect(page).toHaveScreenshot(
        `poteto-verifier-proof-${locale.code}-${viewport.name}.png`,
      );
    });
  }
}
