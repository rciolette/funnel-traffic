import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "./e2e",
  timeout: 30_000,
  use: {
    baseURL: "http://localhost:4173",
    headless: true,
    // PW_CHROMIUM aponta para um Chromium já instalado (CI/sandbox); vazio = Playwright baixa o dele.
    launchOptions: process.env.PW_CHROMIUM ? { executablePath: process.env.PW_CHROMIUM } : {},
  },
  webServer: { command: "npm run build && npm run preview -- --port 4173", url: "http://localhost:4173", reuseExistingServer: true, timeout: 120_000 },
});
