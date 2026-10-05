import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

test.beforeEach(async ({ page }) => {
  await installScreenshotVoices(page);
});

for (const locale of ["en", "pl", "zh-CN", "zh-TW"]) {
  test(`visual: status-update-${locale}`, async ({ page }) => {
    await page.goto(`${locale === "en" ? "" : `/${locale}`}/skills`);
    await page
      .getByRole("link", { name: /^\/what-did-i-get-done/ })
      .last()
      .click();
    await expect(
      page.getByRole("heading", { name: "/what-did-i-get-done", exact: true }),
    ).toBeVisible();
    await expect(
      page.getByText("What did you work on since the last update?", {
        exact: true,
      }),
    ).toBeVisible();
    await expect(
      page.getByText("What are you going to work on next?", { exact: true }),
    ).toBeVisible();
    await expect(page.getByRole("main")).toContainText(
      "Next work not specified.",
    );
    await page.evaluate(() => document.fonts.ready);
    await page.evaluate(() => window.scrollTo(0, 0));
    await expect(page).toHaveScreenshot(`status-update-${locale}.png`, {
      fullPage: true,
    });
  });
}

// Keep these captures comparable: the preview contains the same checked-in
// skills, Chromium uses reduced motion, and each case gets a fresh context.
for (const scenario of [
  {
    name: "communication-en-development-lifecycle",
    path: "/skills/development-lifecycle",
    heading: "/development-lifecycle",
  },
  {
    name: "communication-en-efficient-frontier",
    path: "/skills/efficient-frontier",
    heading: "/efficient-frontier",
  },
  {
    name: "communication-en-grilling",
    path: "/skills/grilling",
    heading: "/grilling",
  },
  { name: "communication-en-pr", path: "/skills/pr", heading: "/pr" },
  {
    name: "communication-en-review",
    path: "/skills/review",
    heading: "/review",
  },
  {
    name: "communication-pl-development-lifecycle",
    path: "/pl/skills/development-lifecycle",
    heading: "/development-lifecycle",
  },
  {
    name: "communication-pl-efficient-frontier",
    path: "/pl/skills/efficient-frontier",
    heading: "/efficient-frontier",
  },
  {
    name: "communication-pl-grilling",
    path: "/pl/skills/grilling",
    heading: "/grilling",
  },
  { name: "communication-pl-pr", path: "/pl/skills/pr", heading: "/pr" },
  {
    name: "communication-pl-review",
    path: "/pl/skills/review",
    heading: "/review",
  },
  {
    name: "communication-zh-CN-development-lifecycle",
    path: "/zh-CN/skills/development-lifecycle",
    heading: "/development-lifecycle",
  },
  {
    name: "communication-zh-CN-efficient-frontier",
    path: "/zh-CN/skills/efficient-frontier",
    heading: "/efficient-frontier",
  },
  {
    name: "communication-zh-CN-grilling",
    path: "/zh-CN/skills/grilling",
    heading: "/grilling",
  },
  { name: "communication-zh-CN-pr", path: "/zh-CN/skills/pr", heading: "/pr" },
  {
    name: "communication-zh-CN-review",
    path: "/zh-CN/skills/review",
    heading: "/review",
  },
  {
    name: "communication-zh-TW-development-lifecycle",
    path: "/zh-TW/skills/development-lifecycle",
    heading: "/development-lifecycle",
  },
  {
    name: "communication-zh-TW-efficient-frontier",
    path: "/zh-TW/skills/efficient-frontier",
    heading: "/efficient-frontier",
  },
  {
    name: "communication-zh-TW-grilling",
    path: "/zh-TW/skills/grilling",
    heading: "/grilling",
  },
  { name: "communication-zh-TW-pr", path: "/zh-TW/skills/pr", heading: "/pr" },
  {
    name: "communication-zh-TW-review",
    path: "/zh-TW/skills/review",
    heading: "/review",
  },
  { name: "homepage", path: "/", heading: "Agent skills" },
  { name: "directory", path: "/skills", heading: "Skill directory" },
  {
    name: "directory-polish",
    path: "/pl/skills",
    heading: "Katalog umiejętności",
  },
  {
    name: "directory-simplified-chinese",
    path: "/zh-CN/skills",
    heading: "技能目录",
  },
  {
    name: "directory-traditional-chinese",
    path: "/zh-TW/skills",
    heading: "技能目錄",
  },
  {
    name: "onboarding-claude",
    path: "/getting-started",
    heading: "Install in Claude Code",
  },
  {
    name: "onboarding-codex",
    path: "/getting-started?view=Codex",
    heading: "Install in Codex",
  },
  {
    name: "onboarding-polish",
    path: "/pl/getting-started",
    heading: "Pierwsze kroki",
  },
  {
    name: "onboarding-simplified-chinese",
    path: "/zh-CN/getting-started",
    heading: "开始使用",
  },
  {
    name: "onboarding-traditional-chinese",
    path: "/zh-TW/getting-started",
    heading: "開始使用",
  },
  { name: "skill", path: "/skills/tdd", heading: "/tdd" },
  { name: "archived-skill", path: "/v4.39.0/skills/tdd", heading: "/tdd" },
]) {
  test(`visual: ${scenario.name}`, async ({ page }) => {
    await page.goto(scenario.path);
    await expect(
      page.getByRole("heading", { name: scenario.heading }).first(),
    ).toBeVisible();
    if (scenario.name.startsWith("directory-")) {
      await expect(
        page.getByRole("link", { name: /^\/tdd/ }).last(),
      ).toHaveAttribute("href", `${scenario.path}/tdd`);
    }
    await stabilizeScreenshotDate(page, !scenario.name.startsWith("directory"));
    await expect(page).toHaveScreenshot(`${scenario.name}.png`, {
      fullPage: scenario.name.startsWith("communication-"),
    });
  });
}

for (const scenario of [
  { locale: "en", heading: "Completion" },
  { locale: "pl", heading: "Zakończenie" },
  { locale: "zh-CN", heading: "完成" },
  { locale: "zh-TW", heading: "完成作業" },
]) {
  for (const viewport of [
    { name: "desktop", width: 1440, height: 1000 },
    { name: "mobile", width: 390, height: 844 },
  ]) {
    test(`visual: delivery completion ${scenario.locale} ${viewport.name}`, async ({
      page,
    }) => {
      await page.setViewportSize({
        width: viewport.width,
        height: viewport.height,
      });
      await page.goto(
        `${scenario.locale === "en" ? "" : `/${scenario.locale}`}/skills/commit-push-pr`,
      );
      const completion = page.getByRole("heading", {
        name: `${scenario.heading}#`,
        exact: true,
      });
      await completion.scrollIntoViewIfNeeded();
      await expect(completion).toBeVisible();
      await expect(page).toHaveScreenshot(
        `delivery-completion-${scenario.locale}-${viewport.name}.png`,
      );
    });
  }
}

test("visual: dark homepage and directory", async ({ page }) => {
  await page.emulateMedia({ colorScheme: "dark" });
  await page.goto("/");
  await expect(
    page.getByRole("searchbox", { name: "Search skills" }),
  ).toBeVisible();
  await stabilizeScreenshotDate(page);
  await expect(page).toHaveScreenshot("homepage-dark.png");
  await page.goto("/skills");
  await expect(
    page.getByRole("heading", { name: "Skill directory", exact: true }),
  ).toBeVisible();
  await stabilizeScreenshotDate(page, false);
  await expect(page).toHaveScreenshot("directory-dark.png");
});

test("visual: filter miss and related-page recovery", async ({ page }) => {
  await page.goto("/");
  await page
    .getByRole("searchbox", { name: "Search skills" })
    .fill("no-such-skill");
  await expect(
    page.getByText("No skills found", { exact: true }),
  ).toBeVisible();
  await stabilizeScreenshotDate(page);
  await expect(page).toHaveScreenshot("filter-empty.png");
  await page.goto("/skills/tdd");
  await page
    .getByRole("heading", { name: "Related pages", exact: true })
    .scrollIntoViewIfNeeded();
  await stabilizeScreenshotDate(page);
  await expect(page).toHaveScreenshot("related-and-footer.png");
  await page
    .getByRole("link", { name: "Report an issue", exact: true })
    .scrollIntoViewIfNeeded();
  await expect(page).toHaveScreenshot("footer.png");
});

test("visual: global search opens, finds guidance, and dismisses", async ({
  page,
}) => {
  await page.goto("/");
  await page.getByRole("button", { name: "Search", exact: true }).click();
  await page.getByRole("combobox", { name: "Search docs" }).fill("tdd");
  await expect(
    page.getByRole("option").filter({ hasText: "/tdd" }).first(),
  ).toBeVisible();
  await stabilizeScreenshotDate(page);
  await expect(page).toHaveScreenshot("global-search.png");
  // Chromium's native search input consumes the first Escape to clear text;
  // the next Escape dismisses the modal dialog.
  await page.getByRole("combobox", { name: "Search docs" }).press("Escape");
  await expect(page.getByRole("combobox", { name: "Search docs" })).toHaveValue(
    "",
  );
  await page.getByRole("combobox", { name: "Search docs" }).press("Escape");
  await expect(
    page.getByRole("dialog", { name: "Search docs" }),
  ).not.toBeVisible();
});

test("visual: mobile onboarding and directory", async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto("/getting-started?view=Codex");
  await expect(
    page.getByRole("heading", { name: "Install in Codex" }),
  ).toBeVisible();
  await stabilizeScreenshotDate(page);
  await expect(page).toHaveScreenshot("onboarding-mobile.png", {
    fullPage: true,
  });
  await page.goto("/skills");
  await expect(
    page.getByRole("heading", { name: "Skill directory", exact: true }),
  ).toBeVisible();
  await stabilizeScreenshotDate(page, false);
  await expect(page).toHaveScreenshot("directory-mobile.png");
});
