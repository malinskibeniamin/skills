import { defineConfig } from '@playwright/test';
import config from '../docs-site/playwright.config';
const port = 4594;
export default defineConfig({
 ...config,
 testDir: new URL('../docs-site/e2e/', import.meta.url).pathname,
 outputDir: new URL('./poteto-followup-browser-results/', import.meta.url).pathname,
 use: {...config.use, baseURL: `http://127.0.0.1:${port}`},
 webServer: {
  command: `python3 ${new URL('./poteto-static-server.py', import.meta.url).pathname} ${port} ${new URL('../docs-site/dist/', import.meta.url).pathname}`,
  url: `http://127.0.0.1:${port}`,
  reuseExistingServer: false,
 },
});
