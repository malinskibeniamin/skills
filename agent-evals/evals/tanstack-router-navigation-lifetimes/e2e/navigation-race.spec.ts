import { expect, test } from "@playwright/test";

test("latest navigation wins", async ({ page }) => {
  await page.getByRole("link", { name: "Slow account" }).click();
  await page.waitForTimeout(100);
  await page.getByRole("link", { name: "Settings" }).click();
  await page.waitForURL("/settings");
  expect(page.url()).toContain("/settings");
});

test("redirect wins over a stale loader error", async ({ page }) => {
  await page.getByRole("link", { name: "Broken report" }).click();
  await page.waitForTimeout(100);
  await page.getByRole("link", { name: "Protected account" }).click();
  await page.waitForURL("/login");
  expect(page.url()).toContain("/login");
});
