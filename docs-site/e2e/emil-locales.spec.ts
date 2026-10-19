import { expect, test } from "@playwright/test";
import {
  installScreenshotVoices,
  stabilizeScreenshotDate,
} from "./screenshot-date";

const skills = [
  "animate",
  "animation-performance",
  "animation-vocabulary",
  "mobile-native",
  "break-ui",
  "ask-sonner",
];

for (const locale of [
  {
    code: "pl",
    search: "Wyszukaj umiejętności",
    intro: "Zacznij od",
    endpoint: "Zakres działania",
    loop: "Pętla",
    mobile: "Diagnoza i zakres",
    sonner: "Integracja",
  },
  {
    code: "zh-CN",
    search: "搜索技能",
    intro: "先给出",
    endpoint: "执行边界",
    loop: "循环",
    mobile: "诊断与范围",
    sonner: "集成",
  },
  {
    code: "zh-TW",
    search: "搜尋技能",
    intro: "先給出",
    endpoint: "執行邊界",
    loop: "迴圈",
    mobile: "診斷與範圍",
    sonner: "整合",
  },
]) {
  for (const appearance of [
    { name: "desktop-light", width: 1440, height: 1000, dark: false },
    { name: "mobile-dark", width: 390, height: 844, dark: true },
  ]) {
    for (const skill of skills) {
      test(`${locale.code} ${appearance.name}: find and read ${skill}`, async ({
        page,
      }) => {
        const pageErrors: string[] = [];
        page.on("pageerror", (error) => pageErrors.push(error.message));
        await installScreenshotVoices(page);
        await page.setViewportSize({
          width: appearance.width,
          height: appearance.height,
        });
        await page.emulateMedia({
          colorScheme: appearance.dark ? "dark" : "light",
        });
        await page.goto(`/${locale.code}`);
        await page.getByRole("searchbox", { name: locale.search }).fill(skill);
        const link = page
          .getByRole("article")
          .getByRole("link", { name: new RegExp(`^/${skill}\\s`) });
        await expect(link).toHaveCount(1);
        await link.click();
        await expect(page).toHaveURL(
          new RegExp(`/${locale.code}/skills/${skill}/?$`),
        );
        const main = page.getByRole("main");
        await expect(
          main.getByRole("heading", { name: `/${skill}`, exact: true }),
        ).toBeVisible();
        if (skill === "animation-vocabulary") {
          await expect(main.getByText(new RegExp(locale.intro))).toBeVisible();
        } else {
          const heading =
            skill === "animation-performance"
              ? locale.loop
              : skill === "mobile-native"
                ? locale.mobile
                : skill === "ask-sonner"
                  ? locale.sonner
                  : locale.endpoint;
          await expect(
            main.getByRole("heading", {
              name: new RegExp(`^${heading}`),
              level: 2,
            }),
          ).toBeVisible();
        }
        const diagram = main.getByRole("img");
        await expect
          .poll(() =>
            diagram.evaluate((image) =>
              image instanceof HTMLImageElement ? image.naturalWidth : 0,
            ),
          )
          .toBeGreaterThan(0);
        await stabilizeScreenshotDate(page);
        expect(pageErrors).toEqual([]);
        expect(
          await page.evaluate(
            () => document.documentElement.scrollWidth <= window.innerWidth,
          ),
        ).toBe(true);
        await expect(page).toHaveScreenshot(
          `${locale.code}-${skill}-${appearance.name}.png`,
          { fullPage: true },
        );
      });
    }
  }
}
