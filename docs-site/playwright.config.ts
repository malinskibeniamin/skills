import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "./e2e",
  outputDir: "../.context/docs-browser-results",
  reporter: "list",
  workers: 1,
  use: {
    baseURL: "http://127.0.0.1:4322",
    browserName: "chromium",
    locale: "en-US",
    contextOptions: { reducedMotion: "reduce" },
    viewport: { width: 1440, height: 1000 },
    trace: "retain-on-failure",
  },
  webServer: {
    command: "bun run blume preview --host 127.0.0.1 --port 4322",
    url: "http://127.0.0.1:4322",
    reuseExistingServer: false,
  },
});
