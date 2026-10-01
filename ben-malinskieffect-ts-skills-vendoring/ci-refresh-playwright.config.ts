import { defineConfig } from '@playwright/test';
export default defineConfig({
  testDir: '.', testIgnore: '**/publish/**', testMatch: 'effect-visual.spec.ts', timeout: 45000, workers: 2,
  outputDir: './test-results/' + (process.env.EFFECT_VISUAL_SIDE ?? 'after'),
  snapshotPathTemplate: '{testDir}/snapshots/stable/' + (process.env.EFFECT_VISUAL_SIDE ?? 'after') + '/{projectName}/{arg}{ext}',
  reporter: [['../../shared/reporters/playwright-llm-reporter.ts'], ['list'], ['html', { outputFolder: './report/' + (process.env.EFFECT_VISUAL_SIDE ?? 'after'), open: 'never' }]],
  expect: { toHaveScreenshot: { animations: 'disabled', maxDiffPixels: 0 } },
  use: { baseURL: process.env.EFFECT_VISUAL_SIDE === 'before' ? 'http://localhost:4407' : 'http://localhost:4408',
    browserName: 'chromium', locale: 'en-US', timezoneId: 'UTC', reducedMotion: 'reduce', deviceScaleFactor: 1 },
  projects: [
    { name: 'desktop-dark', use: { viewport: { width: 1280, height: 900 }, colorScheme: 'dark' } },
    { name: 'mobile-light', use: { viewport: { width: 390, height: 844 }, colorScheme: 'light', isMobile: true, hasTouch: true } },
  ],
});
