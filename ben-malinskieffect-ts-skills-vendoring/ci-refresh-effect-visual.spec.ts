import { test, expect } from '@playwright/test';
import { mkdir } from 'node:fs/promises';
import path from 'node:path';
const before = process.env.EFFECT_VISUAL_SIDE === 'before';
const side = before ? 'before' : 'after';
for (const locale of ['en', 'pl', 'zh-CN', 'zh-TW']) {
  const prefix = locale === 'en' ? '' : `/${locale}`;
  for (const surface of ['catalog', 'migration-catalog', 'setup', 'migration', 'router', 'router-intro']) {
    test(`${locale} ${surface}`, async ({ page }, testInfo) => {
      const skill = surface.startsWith('migration') ? 'effect-v3-to-v4' : 'effect-ts';
      const router = surface.startsWith('router');
      const catalog = surface.endsWith('catalog') || (before && !router);
      const route = catalog ? (prefix || `/`) : `${prefix}/skills/${router ? 'ask-ben' : skill}`;
      const errors: string[] = [];
      page.on('pageerror', error => errors.push(error.message));
      const response = await page.goto(route);
      expect(response?.status()).toBe(200);
      await expect(page.locator('main h1')).toBeVisible();
      // Short Chinese router prose is below Blume's 280-character narration threshold.
      if (!before && router && locale.startsWith('zh-')) {
        await expect(page.locator('[data-narration-start]')).toBeHidden();
      } else {
        await expect(page.locator('[data-narration-start]')).toBeVisible();
        await expect(page.locator('[data-narration-duration]')).toContainText(/\d/);
      }
      await page.evaluate(() => document.fonts.ready);
      if (catalog) {
        await expect(page.locator('astro-island[ssr]')).toHaveCount(0);
        const input = page.locator('main input[type="search"]');
        await input.fill(skill);
        if (testInfo.project.name === 'mobile-light') await input.evaluate(el => window.scrollTo({ top: el.getBoundingClientRect().top + window.scrollY - 140, behavior: 'instant' }));
        const effectLinks = page.locator(`main a[href="${prefix}/skills/${skill}"]`);
        await expect(effectLinks).toHaveCount(before ? 0 : 1);
        if (!before) await expect(page.locator('main')).toContainText(`/${skill}`);
      } else if (surface === 'router') {
        const anchor = page.locator('main tr').filter({ hasText: '/e2e-testing' });
        await anchor.scrollIntoViewIfNeeded();
        await expect(page.locator('main tr').filter({ hasText: '/effect-ts' })).toHaveCount(before ? 0 : 1);
        await expect(page.locator('main tr').filter({ hasText: '/effect-v3-to-v4' })).toHaveCount(before ? 0 : 1);
      } else if (surface === 'router-intro') {
        const intro = page.locator('main p').filter({ has: page.locator('a[href*="PHASE-BOUNDARIES.md"]') });
        await expect(intro).toHaveCount(1);
        await expect(intro).toContainText('/work');
        await expect(intro).toContainText('/to-tickets');
        if (!before) await expect(intro).not.toContainText('/visual-plan');
        await intro.scrollIntoViewIfNeeded();
        await page.evaluate(() => Promise.all([...document.images].map(img => img.decode().catch(() => {}))));
      } else {
        await expect(page.locator('main h1')).toHaveText(`/${skill}`);
        await expect(page.locator(`main img[src*="${skill}.svg"]`)).toBeVisible();
        await page.evaluate(() => Promise.all([...document.images].map(img => img.decode().catch(() => {}))));
        await expect(page.locator('main a[href*=".excalidraw"]')).toBeVisible();
      }
      expect(errors).toEqual([]);
      const dir = path.join(testInfo.config.rootDir, 'captures', side, testInfo.project.name);
      await mkdir(dir, { recursive: true });
      await page.screenshot({ path: path.join(dir, `${locale}-${surface}.png`), animations: 'disabled' });
      await expect(page).toHaveScreenshot(`${locale}-${surface}.png`);
    });
  }
}

test('README provenance', async ({ page }, testInfo) => {
  const sha = before ? 'a666713cdba0326f758cb04270e6fbce3d75f443' : '58076855';
  await page.goto(`https://github.com/malinskibeniamin/skills/blob/${sha}/README.md`, { waitUntil: 'domcontentloaded' });
  const paragraph = page.locator('article p').filter({ hasText: '/test-audit' }).last();
  await expect(paragraph).toBeVisible();
  await page.evaluate(() => document.fonts.ready);
  await paragraph.scrollIntoViewIfNeeded();
  await expect(paragraph).toBeInViewport();
  const effect = page.locator('article p').filter({ hasText: 'Effect-TS/skills' });
  await expect(effect).toHaveCount(before ? 0 : 1);
  const dir = path.join(testInfo.config.rootDir, 'captures', side, testInfo.project.name);
  await mkdir(dir, { recursive: true });
  await page.screenshot({ path: path.join(dir, 'readme.png'), animations: 'disabled' });
  await expect(page).toHaveScreenshot('readme.png');
});
