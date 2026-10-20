import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

const locales = [
  {
    code: "en",
    countPrefix: "Browse all",
    description: "Build, test, and diagnose Bazel monorepos",
    loop: "Choose the incremental loop",
    catalog: "Build, test, and diagnose Bazel monorepo changes.",
  },
  {
    code: "pl",
    countPrefix: "Przeglądaj wszystkie",
    description: "Buduj, testuj i diagnozuj monorepo Bazel",
    loop: "Wybierz pętlę przyrostową",
    catalog: "Budowanie, testowanie i diagnozowanie zmian w monorepo Bazel.",
  },
  {
    code: "zh-CN",
    countPrefix: "浏览全部",
    description: "构建、测试和诊断涵盖 Go、C++、TypeScript 与 React",
    loop: "选择增量循环",
    catalog: "构建、测试和诊断 Bazel 单体仓库的变更。",
  },
  {
    code: "zh-TW",
    countPrefix: "瀏覽全部",
    description: "建置、測試與診斷涵蓋 Go、C++、TypeScript 和 React",
    loop: "選擇增量循環",
    catalog: "建置、測試與診斷 Bazel 單一儲存庫的變更。",
  },
];

for (const locale of locales) {
  for (const viewport of [
    { name: "desktop", width: 1440, height: 1000 },
    { name: "mobile", width: 390, height: 844 },
  ]) {
    test(`bazel discovery stays localized: ${locale.code} ${viewport.name}`, async ({
      page,
    }) => {
      await installScreenshotVoices(page);
      await page.setViewportSize(viewport);
      const prefix = locale.code === "en" ? "" : `/${locale.code}`;
      const name = `${locale.code}-${viewport.name}`;

      await page.goto(`${prefix}/`);
      const search = page.getByRole("main").getByRole("searchbox");
      const resultsId = await search.getAttribute("aria-controls");
      if (!resultsId)
        throw new Error("Search results relationship is missing.");
      const total = await page
        .locator(`[id=${JSON.stringify(resultsId)}]`)
        .getByRole("link")
        .count();
      await expect(
        page
          .getByRole("main")
          .getByText(new RegExp(`^${locale.countPrefix} ${total} `)),
      ).toBeVisible();
      await search.fill("bazel");
      const card = page
        .getByRole("main")
        .getByRole("link", { name: /^\/bazel\s/ });
      await expect(card).toHaveCount(1);
      await expect(card).toContainText(locale.description);
      await expect(card).toHaveScreenshot(`bazel-card-${name}.png`);
      await card.click();
      await expect(page).toHaveURL(new RegExp(`${prefix}/skills/bazel/?$`));
      await expect(
        page.getByRole("heading", { name: "/bazel", exact: true }),
      ).toBeVisible();
      await expect(
        page.getByRole("main").getByRole("heading", {
          name: locale.loop,
        }),
      ).toBeAttached();
      const diagram = page.locator('main img[src$="bazel.svg"]');
      await expect(diagram).toBeVisible();
      await expect
        .poll(() =>
          diagram.evaluate((image: HTMLImageElement) => image.naturalWidth),
        )
        .toBeGreaterThan(0);
      const editable = await page.request.get(
        "/diagrams/skills/bazel.excalidraw",
      );
      expect(editable.ok()).toBe(true);
      await expect(
        page.locator('main a[href$="bazel/references/typescript-react.md"]'),
      ).toHaveCount(1);
      await stabilizeScreenshotDate(page, !locale.code.startsWith("zh-"));
      await expect(page).toHaveScreenshot(`bazel-page-${name}.png`);
      expect(
        await page.evaluate(() => document.documentElement.scrollWidth),
      ).toBeLessThanOrEqual(viewport.width);

      await page.goto(`${prefix}/skills/ask-ben`);
      const row = page.getByRole("row").filter({ hasText: "/bazel" });
      await expect(row).toHaveCount(1);
      await expect(row).toContainText(locale.catalog);
      await expect(row).toHaveScreenshot(`bazel-catalog-${name}.png`);
    });
  }
}
