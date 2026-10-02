import { defineConfig } from "@playwright/test";

const port = Number(process.env.BLUME_PREVIEW_PORT ?? 4322);
if (!Number.isInteger(port) || port < 1 || port > 65535) {
  throw new Error("BLUME_PREVIEW_PORT must be an integer from 1 to 65535.");
}
const baseURL = `http://127.0.0.1:${port}`;

export default defineConfig({
  testDir: "./e2e",
  outputDir: "../.context/docs-browser-results",
  reporter: "list",
  workers: 1,
  use: {
    baseURL,
    browserName: "chromium",
    locale: "en-US",
    contextOptions: { reducedMotion: "reduce" },
    viewport: { width: 1440, height: 1000 },
    trace: "retain-on-failure",
  },
  webServer: {
    command: `bun run blume preview --host 127.0.0.1 --port ${port}`,
    url: baseURL,
    reuseExistingServer: false,
  },
});
