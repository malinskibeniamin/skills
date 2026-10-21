import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

const locales = [
  { code: "en", design: "Caller-first sketch", explore: "2. Explore mode" },
  {
    code: "pl",
    design: "Szkic od strony wywołującego",
    explore: "2. Tryb eksploracji",
  },
  { code: "zh-CN", design: "从调用方开始的草图", explore: "2. 探索模式" },
  { code: "zh-TW", design: "從呼叫端開始的草圖", explore: "2. 探索模式" },
];

for (const mobile of [false, true]) {
  test.describe(mobile ? "mobile-dark" : "desktop-light", () => {
    test.use({
      viewport: mobile
        ? { width: 390, height: 844 }
        : { width: 1440, height: 1000 },
      colorScheme: mobile ? "dark" : "light",
    });

    for (const locale of locales) {
      test(`${locale.code}: navigate native Poteto guidance`, async ({
        page,
      }) => {
        await installScreenshotVoices(page);
        const prefix = locale.code === "en" ? "" : `/${locale.code}`;
        for (const section of [
          {
            skill: "codebase-design",
            heading: locale.design,
            anchor: "caller-first-sketch",
          },
          {
            skill: "grilling",
            heading: locale.explore,
            anchor: "2-explore-mode",
          },
        ]) {
          await page.goto(`${prefix}/skills/${section.skill}`);
          const heading = page.getByRole("heading", {
            name: new RegExp(`^${section.heading}`),
          });
          await expect(heading).toBeVisible();
          await heading.getByRole("link").click();
          await expect(page).toHaveURL(new RegExp(`#${section.anchor}$`));
          await expect(heading).toBeInViewport();
          if (section.skill === "codebase-design") {
            await expect(
              page
                .getByRole("main")
                .locator(
                  'a[href$="POTETO-ENGINEERING.md#probe-the-shortest-wrong-edit"]',
                ),
            ).toHaveCount(1);
          } else {
            await expect(
              page
                .getByRole("main")
                .getByText(/codebase-design/)
                .first(),
            ).toBeVisible();
          }
          await stabilizeScreenshotDate(page);
          await page.mouse.move(0, 0);
          await expect(page).toHaveScreenshot(
            `${locale.code}-${section.skill}-${mobile ? "mobile" : "desktop"}.png`,
          );
        }
      });
    }
  });
}
