import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  timeout: 30_000,
  expect: { timeout: 10_000 },
  fullyParallel: false, // tests share state (auth), keep sequential
  retries: 1,
  reporter: [['html', { open: 'never' }], ['list']],

  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'on-first-retry',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
  ],

  // Optionally start dev servers automatically
  // webServer: [
  //   {
  //     command: 'cd ../src/back && python manage.py runserver 8000',
  //     port: 8000,
  //     reuseExistingServer: true,
  //   },
  //   {
  //     command: 'cd ../src/front && flutter run -d web-server --web-port=8080',
  //     port: 8080,
  //     reuseExistingServer: true,
  //     timeout: 60_000,
  //   },
  // ],
});
