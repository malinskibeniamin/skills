import { readFileSync } from "node:fs";
import { expect, test } from "@playwright/test";

const manifest: unknown = JSON.parse(
  readFileSync(new URL("../../skill-manifest.json", import.meta.url), "utf8"),
);
if (
  !manifest ||
  typeof manifest !== "object" ||
  !("version" in manifest) ||
  typeof manifest.version !== "string" ||
  !/^\d+\.\d+\.\d+$/.test(manifest.version)
) {
  throw new Error("Release metadata must contain a stable semantic version.");
}
const release = `v${manifest.version}`;

test("the current release is selectable and survives reload", async ({
  page,
}) => {
  await page.goto("/");
  const switcher = page.locator('summary[aria-label="Version: main"]').first();
  await switcher.focus();
  await page.keyboard.press("Enter");
  const releaseLink = switcher.locator("..").locator(`a[href="/${release}"]`);
  await expect(releaseLink).toBeVisible();
  await expect(page).toHaveScreenshot("release-options-desktop.png", {
    clip: { x: 820, y: 0, width: 620, height: 450 },
  });
  await releaseLink.click();
  await expect(page).toHaveURL(
    new RegExp(`/${release.replaceAll(".", "\\.")}/?$`),
  );
  await expect(
    page.locator(`summary[aria-label="Version: ${release}"]`).first(),
  ).toBeVisible();
  await page.reload();
  await expect(
    page.locator(`summary[aria-label="Version: ${release}"]`).first(),
  ).toBeVisible();
});

test("the release archive remains readable on mobile", async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto(`/${release}/`);
  await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
  await expect(
    page.getByText(`You're viewing documentation for ${release}.`, {
      exact: false,
    }),
  ).toBeVisible();
  expect(
    await page.evaluate(() => document.documentElement.scrollWidth),
  ).toBeLessThanOrEqual(390);
  await expect(page).toHaveScreenshot("release-archive-mobile.png");
});
