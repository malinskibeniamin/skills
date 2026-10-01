import { expect, test } from "@playwright/test";

test("onboarding keeps the selected agent view and publishes readable Markdown", async ({
  page,
  request,
}) => {
  await page.goto("/");
  await page
    .getByRole("link", { name: "Get started", exact: true })
    .first()
    .click();
  await expect(page).toHaveURL(/\/getting-started\/?$/);
  await expect(
    page.getByRole("heading", { name: "Install in Claude Code" }),
  ).toBeVisible();
  await page
    .getByRole("combobox", { name: "Select view", exact: true })
    .selectOption("Codex");
  await expect(
    page.getByRole("heading", { name: "Install in Codex" }),
  ).toBeVisible();
  await expect(
    page.getByRole("heading", { name: "Install in Claude Code" }),
  ).not.toBeVisible();
  await page.reload();
  await expect(
    page.getByRole("heading", { name: "Install in Codex" }),
  ).toBeVisible();

  const markdown = await request.get("/getting-started.md");
  expect(markdown.ok()).toBe(true);
  const body = await markdown.text();
  expect(body).toContain("/plugin marketplace add malinskibeniamin/skills");
  expect(body).toContain(
    "codex plugin marketplace add malinskibeniamin/skills --ref main",
  );
  expect(body).not.toContain("{{repository-url}}");
  expect(body).not.toContain("{{ref}}");
});

test("directory cards, related pages, and skill filtering reach canonical guidance", async ({
  page,
}) => {
  await page.goto("/skills");
  await expect(
    page.getByRole("heading", { name: "Skill directory", exact: true }),
  ).toBeVisible();
  await page
    .getByRole("link", { name: /^\/tdd/ })
    .last()
    .click();
  await expect(
    page.getByRole("heading", { name: "/tdd", exact: true }),
  ).toBeVisible();
  await expect(
    page.getByRole("heading", { name: "Related pages", exact: true }),
  ).toBeVisible();
  await page
    .getByRole("link", { name: /^\/review/ })
    .last()
    .click();
  await expect(
    page.getByRole("heading", { name: "/review", exact: true }),
  ).toBeVisible();

  await page.goto("/");
  const search = page.getByRole("searchbox", { name: "Search skills" });
  await search.fill("nothing-matches-this-skill");
  await expect(
    page.getByText("No skills found", { exact: true }),
  ).toBeVisible();
  await search.fill("tdd");
  await page
    .getByRole("article")
    .getByRole("link", { name: /^\/tdd\s/ })
    .click();
  await expect(page).toHaveURL(/\/skills\/tdd\/?$/);
});

test("narration controls play, pause, change speed, and stop without an audio provider", async ({
  page,
}) => {
  // Stub only the device speech boundary, not the page or player. This makes
  // playback deterministic on machines without installed system voices.
  await page.addInitScript(() => {
    const voice: SpeechSynthesisVoice = {
      default: true,
      lang: "en-US",
      localService: true,
      name: "Test English",
      voiceURI: "test-english",
    };
    Object.defineProperty(window.speechSynthesis, "getVoices", {
      value: () => [voice],
    });
    Object.defineProperty(SpeechSynthesisUtterance.prototype, "voice", {
      set: () => undefined,
    });
    Object.defineProperty(window.speechSynthesis, "speak", {
      value: (utterance: SpeechSynthesisUtterance) => {
        document.documentElement.dataset.spokenText = utterance.text;
        document.documentElement.dataset.spokenRate = String(utterance.rate);
      },
    });
  });
  const errors: string[] = [];
  page.on("pageerror", (error) => errors.push(error.message));
  await page.goto("/skills/tdd");
  await page.getByRole("button", { name: /Listen to this page/ }).click();
  await expect(page.locator("html")).toHaveAttribute("data-spoken-text", /tdd/);
  await page.getByRole("button", { name: "Pause", exact: true }).click();
  await expect(
    page.getByRole("button", { name: "Play", exact: true }),
  ).toBeVisible();
  await expect(page).toHaveScreenshot("narration-paused.png");
  await page.getByRole("combobox", { name: /speed/i }).selectOption("1.5");
  await page.getByRole("button", { name: "Play", exact: true }).click();
  await expect(page.locator("html")).toHaveAttribute("data-spoken-rate", "1.5");
  await page
    .getByRole("button", { name: "Stop listening", exact: true })
    .click();
  await expect(
    page.getByRole("button", { name: /Listen to this page/ }),
  ).toBeVisible();
  expect(errors).toEqual([]);
  await page.screenshot({ path: "../.context/blume-after.png" });
});

test("mobile onboarding wraps code without overflowing the viewport", async ({
  page,
}) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto("/getting-started?view=Codex");
  await expect(
    page.getByRole("heading", { name: "Install in Codex" }),
  ).toBeVisible();
  expect(
    await page.evaluate(() => document.documentElement.scrollWidth),
  ).toBeLessThanOrEqual(390);
  await page.screenshot({
    path: "../.context/blume-mobile.png",
    fullPage: true,
  });
});

test.describe("browser language", () => {
  test.use({ locale: "pl-PL" });

  test("routes new readers and respects their manual language choice", async ({
    page,
  }) => {
    await page.goto("/");
    await expect(page).toHaveURL(/\/pl\/?$/);
    await page
      .getByRole("link", { name: "Pierwsze kroki", exact: true })
      .first()
      .click();
    await expect(page).toHaveURL(/\/pl\/getting-started\/?$/);
    await expect(
      page.getByRole("heading", { name: "Pierwsze kroki", exact: true }),
    ).toBeVisible();
    await expect(
      page.getByRole("link", { name: "Zgłoś problem", exact: true }),
    ).toBeVisible();
    await page
      .getByRole("banner")
      .getByLabel("Język: Polski", { exact: true })
      .click();
    await page
      .getByRole("banner")
      .getByRole("link", { name: "English", exact: true })
      .click();
    await expect(page).toHaveURL(/\/getting-started\/?$/);
    await page.goto("/");
    await expect(page).toHaveURL("/");
  });
});
