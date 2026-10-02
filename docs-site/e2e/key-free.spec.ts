import { expect, test } from "@playwright/test";
import { execFileSync } from "node:child_process";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

test.beforeEach(async ({ page }) => {
  await installScreenshotVoices(page);
});

const repository = "https://github.com/malinskibeniamin/skills";

test("exports the current page through browser print and a valid EPUB download", async ({
  page,
}, testInfo) => {
  await page.addInitScript(() => {
    window.print = () => {
      document.documentElement.dataset.printed = "true";
    };
  });
  await page.goto("/skills/tdd");

  await page.getByText("Export", { exact: true }).click();
  await page
    .getByRole("button", { name: "Export to PDF", exact: true })
    .click();
  await expect(page.locator("html")).toHaveAttribute("data-printed", "true");

  // Printing leaves the export menu open; EPUB is available in the same menu.
  const downloaded = page.waitForEvent("download");
  await page
    .getByRole("button", { name: "Export to EPUB", exact: true })
    .click();
  const download = await downloaded;
  expect(download.suggestedFilename()).toMatch(/\.epub$/);
  const path = testInfo.outputPath("tdd.epub");
  await download.saveAs(path);
  execFileSync("unzip", ["-t", path]);
  expect(
    execFileSync("unzip", ["-p", path, "mimetype"], { encoding: "utf8" }),
  ).toBe("application/epub+zip");
  const contents = execFileSync("unzip", ["-p", path], { encoding: "utf8" });
  expect(contents).toContain("/tdd");
  expect(contents).toContain("RED");
  expect(contents).not.toContain("<SkillSearch");
});

test("shows update dates and source-edit links for current, translated, and archived pages", async ({
  page,
}) => {
  for (const [route, source] of [
    ["/skills/tdd", "tdd/SKILL.md"],
    ["/pl/skills/tdd", "docs-site/content/pl/skills/tdd.md"],
    ["/v4.39.0/skills/tdd", "docs-site/content/v4.39.0/skills/tdd.md"],
  ] as const) {
    await page.goto(route);
    await expect(
      page.locator(`a[href="${repository}/edit/main/${source}"]`),
    ).toBeVisible();
    const gitDate = execFileSync(
      "git",
      ["log", "-1", "--format=%cI", "--", source],
      { cwd: new URL("../..", import.meta.url), encoding: "utf8" },
    ).trim();
    const date = new Intl.DateTimeFormat(
      route.startsWith("/pl/") ? "pl" : "en",
      {
        dateStyle: "long",
        timeZone: "UTC",
      },
    ).format(new Date(gitDate));
    await expect(
      page.locator("main p").filter({
        hasText: /(?:Last updated on|Ostatnia aktualizacja).*20\d{2}/,
      }),
    ).toContainText(date);
  }
  // Wide landing pages have no actions sidebar, but still show their date.
  await page.goto("/");
  await expect(
    page.locator("main p").filter({ hasText: /Last updated on.*20\d{2}/ }),
  ).toBeVisible();
});

test("visual: export actions and source update date", async ({ page }) => {
  await page.goto("/skills/tdd");
  await stabilizeScreenshotDate(page);
  const exportAction = page.getByText("Export", { exact: true });
  await exportAction.focus();
  await exportAction.press("Enter");
  await expect(
    page.getByRole("button", { name: "Export to EPUB", exact: true }),
  ).toBeVisible();
  await expect(page).toHaveScreenshot("exports.png");
  await exportAction.press("Enter");
  await page.getByText(/Last updated on.*20\d{2}/).scrollIntoViewIfNeeded();
  await expect(page).toHaveScreenshot("source-update-date.png");
  await page.emulateMedia({ colorScheme: "dark" });
  await page.goto("/skills/tdd");
  await stabilizeScreenshotDate(page);
  await exportAction.focus();
  await exportAction.press("Enter");
  await expect(page).toHaveScreenshot("exports-dark.png");
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto("/skills/tdd");
  await stabilizeScreenshotDate(page);
  await page.getByText(/Last updated on.*20\d{2}/).scrollIntoViewIfNeeded();
  await expect(page).toHaveScreenshot("source-update-date-mobile-dark.png");
});
