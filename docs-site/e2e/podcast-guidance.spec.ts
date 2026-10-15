import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

// Public, localized instruction pages: navigation, shared-contract discovery,
// and complete visual output. These do not evaluate autonomous agent behavior.
const skills = [
  "handoff",
  "diagnosing-bugs",
  "ux-performance",
  "revamp",
  "resolve-pr-feedback",
];

for (const skill of skills) {
  for (const locale of ["en", "pl", "zh-CN", "zh-TW"]) {
    for (const viewport of [
      { name: "desktop", width: 1440, height: 1000 },
      { name: "mobile", width: 390, height: 844 },
    ]) {
      test(`podcast guidance: ${skill} ${locale} ${viewport.name}`, async ({
        page,
      }) => {
        await installScreenshotVoices(page);
        await page.setViewportSize(viewport);
        const errors: string[] = [];
        page.on("pageerror", (error) => errors.push(error.message));
        const prefix = locale === "en" ? "" : `/${locale}`;
        await page.goto(`${prefix}/skills`);
        await page
          .getByRole("link", { name: new RegExp(`^/${skill}`) })
          .last()
          .click();
        await expect(
          page.getByRole("heading", { name: `/${skill}`, exact: true }),
        ).toBeVisible();
        const contract =
          skill === "handoff"
            ? "shared/progress-evidence.md#continuation"
            : skill === "resolve-pr-feedback"
              ? "resolve-pr-feedback/REFERENCE.md"
              : "shared/verification-replay.md";
        await expect(
          page.getByRole("main").locator(`a[href$="${contract}"]`),
        ).toHaveCount(1);
        await stabilizeScreenshotDate(page);
        expect(
          await page.evaluate(
            () => document.documentElement.scrollWidth > window.innerWidth,
          ),
        ).toBe(false);
        expect(errors).toEqual([]);
        await expect(page).toHaveScreenshot(
          `${skill}-${locale}-${viewport.name}.png`,
          { fullPage: true },
        );
      });
    }
  }
}
