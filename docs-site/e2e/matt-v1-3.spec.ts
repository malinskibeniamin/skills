import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

// Current pages only. Released snapshots deliberately retain their old vocabulary.
const releaseSkills = [
  "domain-modeling",
  "grilling",
  "improve-codebase-architecture",
  "pr",
  "prime",
  "wait-what",
  "work-automation-kit",
  "triage",
  "development-lifecycle",
  "commit-push-pr",
  "resolve-pr-feedback",
  "implement-spec",
  "retro",
  "diagnosing-bugs",
  "ask-ben",
  "review",
  "tdd",
  "to-spec",
  "to-tickets",
  "wayfinder",
  "codebase-design",
  "wizard",
  "handoff",
];
const routes = [
  "/skills",
  ...releaseSkills.map((skill) => `/skills/${skill}`),
  ...["pl", "zh-CN", "zh-TW"].flatMap((locale) => [
    `/${locale}`,
    ...releaseSkills.map((skill) => `/${locale}/skills/${skill}`),
  ]),
];

for (const route of routes) {
  for (const viewport of [
    { name: "desktop", width: 1440, height: 1000 },
    { name: "mobile", width: 390, height: 844 },
  ]) {
    test(`matt v1.3: ${route} ${viewport.name}`, async ({ page }) => {
      await page.setViewportSize(viewport);
      await installScreenshotVoices(page);
      await page.goto(route);
      await expect(page.locator("main h1")).toBeVisible();
      if (route === "/skills") {
        await expect(
          page
            .locator("main")
            .getByRole("link", { name: /^\/tdd/ })
            .last(),
        ).toBeVisible();
      }
      // Directory cards and table-only/short Chinese pages have no narratable body;
      // preserve their hidden playback state instead of forcing controls.
      const narratable =
        route !== "/skills" &&
        !/^\/zh-(CN|TW)\/skills\/(wait-what|ask-ben)$/.test(route);
      await stabilizeScreenshotDate(page, narratable);
      await expect(page).toHaveScreenshot(
        `${route.slice(1).replaceAll("/", "-")}-${viewport.name}.png`,
        { fullPage: true },
      );
    });
  }
}
