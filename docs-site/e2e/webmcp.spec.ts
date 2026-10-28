import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

const locales = [
  {
    code: "en",
    contract: "Chrome page API",
    description: "designing, implementing, testing, or auditing WebMCP tools",
    catalog: "Operate page tools or build and audit WebMCP interfaces",
  },
  {
    code: "pl",
    contract: "API strony w Chrome",
    description:
      "projektowania, implementowania, testowania lub audytowania narzędzi WebMCP",
    catalog:
      "Obsługa narzędzi strony oraz tworzenie i audyt interfejsów WebMCP.",
  },
  {
    code: "zh-CN",
    contract: "Chrome 页面 API",
    description: "设计、实现、测试和审查网站公开的 WebMCP 工具",
    catalog: "操作页面工具，或构建和审查 WebMCP 接口。",
  },
  {
    code: "zh-TW",
    contract: "Chrome 頁面 API",
    description: "設計、實作、測試與稽核網站公開的 WebMCP 工具",
    catalog: "操作頁面工具，或建置與稽核 WebMCP 介面。",
  },
];

for (const locale of locales) {
  for (const viewport of [
    { name: "desktop", width: 1440, height: 1000 },
    { name: "mobile", width: 390, height: 844 },
  ]) {
    for (const theme of locale.code === "en"
      ? (["light", "dark"] as const)
      : (["light"] as const)) {
      test(`webmcp discovery: ${locale.code} ${viewport.name} ${theme}`, async ({
        page,
      }) => {
        await installScreenshotVoices(page);
        await page.setViewportSize(viewport);
        await page.emulateMedia({ colorScheme: theme });
        const prefix = locale.code === "en" ? "" : `/${locale.code}`;
        const name = `${locale.code}-${viewport.name}-${theme}`;

        await page.goto(`${prefix}/`);
        await page.getByRole("main").getByRole("searchbox").fill("webmcp");
        const card = page
          .getByRole("main")
          .getByRole("link", { name: /^\/webmcp\s/ });
        await expect(card).toHaveCount(1);
        await expect(card).toContainText(locale.description);
        await expect(card).toHaveScreenshot(`webmcp-card-${name}.png`);
        await card.click();
        await expect(page).toHaveURL(new RegExp(`${prefix}/skills/webmcp/?$`));
        await expect(
          page.getByRole("heading", { name: "/webmcp", exact: true }),
        ).toBeVisible();
        const diagram = page.locator('main img[src$="webmcp.svg"]');
        await expect(diagram).toBeVisible();
        await expect
          .poll(() =>
            diagram.evaluate((image: HTMLImageElement) => image.naturalWidth),
          )
          .toBeGreaterThan(0);
        expect(
          (await page.request.get("/diagrams/skills/webmcp.excalidraw")).ok(),
        ).toBe(true);
        for (const path of [
          "vendor/builder-webmcp/skills/webmcp/SKILL.md",
          "vendor/chrome-webmcp/webmcp-skills/skills/build-webmcp-tools/SKILL.md",
          "webmcp/references/tool-authoring.md",
        ]) {
          await expect(page.locator(`main a[href$="${path}"]`)).toHaveCount(1);
        }
        await stabilizeScreenshotDate(page, false);
        await expect(page).toHaveScreenshot(`webmcp-page-${name}.png`);
        const contract = page.getByRole("heading", {
          name: locale.contract,
        });
        await expect(contract).toBeAttached();
        await contract.evaluate((element) => {
          window.scrollTo(
            0,
            window.scrollY + element.getBoundingClientRect().top - 96,
          );
        });
        await expect(page).toHaveScreenshot(`webmcp-chrome-api-${name}.png`);
        expect(
          await page.evaluate(() => document.documentElement.scrollWidth),
        ).toBeLessThanOrEqual(viewport.width);

        await page.goto(`${prefix}/skills/ask-ben`);
        const row = page.getByRole("row").filter({ hasText: "/webmcp" });
        await expect(row).toHaveCount(1);
        await expect(row).toContainText(locale.catalog);
        await expect(row).toHaveScreenshot(`webmcp-catalog-${name}.png`);
      });
    }
  }
}
