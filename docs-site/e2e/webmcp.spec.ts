import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

const locales = [
  {
    code: "en",
    description: "communicate or edit through its MCP or WebMCP tools",
  },
  {
    code: "pl",
    description: "edytować dane przez jej narzędzia MCP lub WebMCP",
  },
  {
    code: "zh-CN",
    description: "通过该页面的 MCP 或 WebMCP 工具进行交互或编辑",
  },
  {
    code: "zh-TW",
    description: "透過該頁面的 MCP 或 WebMCP 工具進行互動或編輯",
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
        await expect(
          page.locator(
            'main a[href$="vendor/builder-webmcp/skills/webmcp/SKILL.md"]',
          ),
        ).toHaveCount(1);
        await stabilizeScreenshotDate(page, false);
        await expect(page).toHaveScreenshot(`webmcp-page-${name}.png`);
        expect(
          await page.evaluate(() => document.documentElement.scrollWidth),
        ).toBeLessThanOrEqual(viewport.width);

        await page.goto(`${prefix}/skills/ask-ben`);
        const row = page.getByRole("row").filter({ hasText: "/webmcp" });
        await expect(row).toHaveCount(1);
        await expect(row).toContainText(/MCP.*WebMCP/);
        await expect(row).toHaveScreenshot(`webmcp-catalog-${name}.png`);
      });
    }
  }
}
