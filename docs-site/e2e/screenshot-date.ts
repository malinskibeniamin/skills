import { expect, type Page } from "@playwright/test";

export const installScreenshotVoices = async (page: Page): Promise<void> => {
  // Device voice availability is outside the site. Avoid capturing the hidden,
  // pre-initialization player while operating systems load their voice list.
  await page.addInitScript(() => {
    const voices: SpeechSynthesisVoice[] = [
      "en-US",
      "pl-PL",
      "zh-CN",
      "zh-TW",
    ].map((lang) => ({
      default: lang === "en-US",
      lang,
      localService: true,
      name: `Test ${lang}`,
      voiceURI: `test-${lang}`,
    }));
    Object.defineProperty(window.speechSynthesis, "getVoices", {
      value: () => voices,
    });
  });
};

// Dates change when authors commit, not when the layout changes. Keep the
// complete localized stamp visible with a fixed visual fixture; key-free.spec
// independently verifies the unmodified stamp against each source's git date.
export const stabilizeScreenshotDate = async (
  page: Page,
  narratable = true,
): Promise<void> => {
  if (narratable) {
    await expect(page.locator("[data-narration-start]")).toBeVisible();
  }
  await page
    .locator("main p")
    .filter({
      hasText:
        /^(Last updated on|Ostatnia aktualizacja|最后更新于|最後更新於)\s/,
    })
    .evaluateAll((paragraphs) => {
      const date = new Intl.DateTimeFormat(document.documentElement.lang, {
        dateStyle: "long",
        timeZone: "UTC",
      }).format(new Date("2026-01-15T12:00:00Z"));
      for (const paragraph of paragraphs) {
        const prefix = paragraph.textContent.match(
          /^(Last updated on|Ostatnia aktualizacja|最后更新于|最後更新於)/,
        )?.[1];
        if (prefix) paragraph.textContent = `${prefix} ${date}`;
      }
    });
};
