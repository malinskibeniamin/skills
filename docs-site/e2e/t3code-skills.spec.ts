import { expect, test } from "@playwright/test";
import { installScreenshotVoices } from "./screenshot-date";

const skills = [
  "ai-docs",
  "bundle-analysis",
  "changesets",
  "ci-maintenance",
  "contribution-triage",
  "dependency-maintenance",
  "effect-development",
  "jsdocs",
  "migration-guidance",
  "package-development",
  "performance-analysis",
  "test-development",
  "test-t3-app",
  "test-t3-mobile",
  "vendored-assets",
];
const routes = [
  ["commit-push-pr", "changesets"],
  ["create-verification-skill", "test-t3-app", "test-t3-mobile"],
  ["docs", "jsdocs"],
  ["dogfood", "test-t3-app", "test-t3-mobile"],
  ["effect-ts", "effect-development"],
  ["quantify-impact", "performance-analysis"],
  ["tdd", "test-development"],
  ["triage", "contribution-triage"],
  ["upgrade-dependency", "dependency-maintenance"],
  ["ux-performance", "bundle-analysis"],
];

for (const locale of ["en", "pl", "zh-CN", "zh-TW"]) {
  for (const viewport of [
    { name: "desktop", width: 1440, height: 1000 },
    { name: "mobile", width: 390, height: 844 },
  ]) {
    test(`T3 skills: ${locale} ${viewport.name}`, async ({ page }) => {
      await page.setViewportSize(viewport);
      await installScreenshotVoices(page);
      const prefix = locale === "en" ? "" : `/${locale}`;
      const errors: string[] = [];
      page.on("pageerror", (error) => errors.push(error.message));
      for (const [route, ...targets] of routes) {
        const response = await page.goto(`${prefix}/skills/${route}`);
        expect(response?.status()).toBe(200);
        const main = page.getByRole("main");
        for (const target of targets) {
          const link = main.locator(
            `a[href$="/t3code-skills/${target}/SKILL.md"]`,
          );
          await expect(link).toHaveCount(1);
          await link.scrollIntoViewIfNeeded();
          await link.focus();
          await expect(link).toBeFocused();
          // Capture the new routing paragraph, not unrelated historical page prose.
          await expect(link.locator("..")).toHaveScreenshot(
            `${route}-${target}-${locale}-${viewport.name}.png`,
          );
        }
        expect(
          await page.evaluate(() => document.documentElement.scrollWidth),
        ).toBeLessThanOrEqual(viewport.width);
      }
      await page.goto(`${prefix}/skills/ask-ben`);
      for (const skill of skills) {
        await expect(
          page.getByRole("cell", { name: `/${skill}`, exact: true }),
        ).toHaveCount(1);
      }
      const row = page.getByRole("row").filter({
        has: page.getByRole("cell", { name: "/ci-maintenance", exact: true }),
      });
      await page.evaluate(() => document.fonts.ready);
      await row.evaluate((element) =>
        element.scrollIntoView({ block: "center", behavior: "instant" }),
      );
      await expect(row).toHaveScreenshot(
        `catalog-${locale}-${viewport.name}.png`,
      );
      expect(errors).toEqual([]);
    });
  }
}
