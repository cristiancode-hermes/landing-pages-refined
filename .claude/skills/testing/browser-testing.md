# Browser testing (Playwright)

## Config that prevents pain later

```ts
// playwright.config.ts
export default defineConfig({
  testDir: "e2e",
  fullyParallel: true,
  retries: process.env.CI ? 1 : 0,          // 1 retry surfaces flakes without hiding them
  use: {
    baseURL: process.env.E2E_BASE_URL ?? "http://localhost:3000",
    trace: "retain-on-failure",             // the debugging goldmine
    screenshot: "only-on-failure",
    video: "retain-on-failure",
  },
  webServer: {                              // starts the app for you, reuses locally
    command: "npm run start:test",
    url: "http://localhost:3000",
    reuseExistingServer: !process.env.CI,
  },
});
```

## Selectors — the flake hierarchy

```ts
page.getByRole("button", { name: "Save" })      // 1. user-visible + a11y-checked
page.getByLabel("Email")                        // 2. form fields by label
page.getByText(/order confirmed/i)              // 3. visible text
page.getByTestId("checkout-total")              // 4. no accessible identity? testid
page.locator(".sidebar > div:nth-child(3)")     // 5. ☠ breaks on every refactor
```

## No manual waits, ever

Playwright auto-waits on actions, and `expect(locator)` assertions retry:

```ts
// ☠ how flakes are made
await page.waitForTimeout(3000);

// ✔ wait for the actual condition
await page.getByRole("button", { name: "Save" }).click();
await expect(page.getByText("Saved")).toBeVisible();
await page.waitForResponse(r => r.url().includes("/api/save") && r.ok());
await expect(page.getByRole("row")).toHaveCount(3);
```

## Isolation & speed

Log in **once** via API/storage state, not through the UI in every test:

```ts
// e2e/auth.setup.ts — runs once as a setup "project"
setup("authenticate", async ({ request }) => {
  const res = await request.post("/api/auth/login",
    { data: { email: E2E_USER, password: E2E_PASS } });
  expect(res.ok()).toBeTruthy();
  await request.storageState({ path: "e2e/.auth/user.json" });
});

// playwright.config.ts
projects: [
  { name: "setup", testMatch: /auth\.setup\.ts/ },
  { name: "chromium", dependencies: ["setup"],
    use: { storageState: "e2e/.auth/user.json" } },
]
```

- Each test creates its own data (unique per test — parallel workers WILL
  interleave you):
  ```ts
  const email = `e2e-${testInfo.testId}@example.test`;
  ```
- Stub third-party noise — test *your* app, not Stripe's sandbox uptime:
  ```ts
  await page.route("**/js.stripe.com/**", r => r.fulfill({ body: stripeStub }));
  await page.route("**/analytics.example.com/**", r => r.abort());
  ```
- E2E only the money paths (signup, checkout, the core loop); push everything
  else down to component/integration tests.

## Debugging failures

```bash
npx playwright test --trace on          # record everything
npx playwright show-trace trace.zip     # DOM snapshots + network + console per step
npx playwright test --ui                # watch mode with time travel
npx playwright codegen localhost:3000   # record selectors for a new flow
```

The trace answers most "why did CI fail" questions without reproducing
locally.

In this kit, the `playwright` MCP server (`.mcp.json`) additionally lets the
agent drive a real browser interactively to verify UI changes — use it after
visual work instead of claiming "should render correctly".
