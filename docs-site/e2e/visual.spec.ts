import { expect, test } from "@playwright/test";

// Keep these captures comparable: the preview contains the same checked-in
// skills, Chromium uses reduced motion, and each case gets a fresh context.
for (const scenario of [
  { name: "homepage", path: "/", heading: "Agent skills" },
  { name: "directory", path: "/skills", heading: "Skill directory" },
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
    await expect(page).toHaveScreenshot(`${scenario.name}.png`);
  });
}

test("visual: dark homepage and directory", async ({ page }) => {
  await page.emulateMedia({ colorScheme: "dark" });
  await page.goto("/");
  await expect(
    page.getByRole("searchbox", { name: "Search skills" }),
  ).toBeVisible();
  await expect(page).toHaveScreenshot("homepage-dark.png");
  await page.goto("/skills");
  await expect(
    page.getByRole("heading", { name: "Skill directory", exact: true }),
  ).toBeVisible();
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
  await expect(page).toHaveScreenshot("filter-empty.png");
  await page.goto("/skills/tdd");
  await page
    .getByRole("heading", { name: "Related pages", exact: true })
    .scrollIntoViewIfNeeded();
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
  await expect(page).toHaveScreenshot("global-search.png");
  // Chromium's native search input consumes the first Escape to clear text;
  // the next Escape dismisses the modal dialog.
  await page.getByRole("combobox", { name: "Search docs" }).press("Escape");
  await expect(page.getByRole("combobox", { name: "Search docs" })).toHaveValue("");
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
  await expect(page).toHaveScreenshot("onboarding-mobile.png", {
    fullPage: true,
  });
  await page.goto("/skills");
  await expect(
    page.getByRole("heading", { name: "Skill directory", exact: true }),
  ).toBeVisible();
  await expect(page).toHaveScreenshot("directory-mobile.png");
});
