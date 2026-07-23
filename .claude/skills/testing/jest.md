# Jest / Vitest patterns

(Applies to both; Vitest swaps `jest.` for `vi.`.)

## Structure: Arrange-Act-Assert, visibly

```ts
describe("createOrder", () => {
  it("rejects quantities below 1", async () => {
    // Arrange
    const repo = fakeRepo();
    // Act
    const result = createOrder(repo, anOrder({ qty: 0 }));
    // Assert
    await expect(result).rejects.toThrow(/quantity/i);
  });
});
```

Shared setup lives in small **builder functions**, not sprawling `beforeEach`
state that couples every test in the file:

```ts
// test/builders.ts — every field has a sane default; tests override only what matters
export const anOrder = (over: Partial<Order> = {}): Order => ({
  id: "ord_1", qty: 2, status: "pending", items: [anItem()],
  createdAt: new Date("2026-01-15T10:00:00Z"),
  ...over,
});

export const fakeRepo = (orders: Order[] = []) => ({
  findById: vi.fn(async (id: string) => orders.find(o => o.id === id) ?? null),
  save: vi.fn(async (o: Order) => o),
});
```

- Precise matchers: `toEqual` for values, `toBe` for identity,
  `toMatchObject`/`objectContaining` for partials, `rejects/resolves` for
  promises.
- Avoid snapshot tests for logic — they assert "whatever it did yesterday".
- Table-driven for input matrices:

```ts
it.each([
  { input: "", expected: "empty" },
  { input: "a".repeat(256), expected: "too_long" },
  { input: "valid-slug", expected: "ok" },
])("validateSlug($input) → $expected", ({ input, expected }) => {
  expect(validateSlug(input).code).toBe(expected);
});
```

## Mocking — mock the boundary, not your own modules

```ts
// ✔ HTTP boundary with msw: tests real fetch/parse/error code paths
import { setupServer } from "msw/node";
import { http, HttpResponse } from "msw";

const server = setupServer(
  http.get("https://api.stripe.com/v1/charges/:id", ({ params }) =>
    HttpResponse.json({ id: params.id, status: "succeeded" })),
);
beforeAll(() => server.listen({ onUnhandledRequest: "error" }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

it("surfaces a declined charge", async () => {
  server.use(http.get("https://api.stripe.com/v1/charges/:id", () =>
    HttpResponse.json({ error: { code: "card_declined" } }, { status: 402 })));
  await expect(getCharge("ch_1")).rejects.toThrow(CardDeclinedError);
});
```

```ts
// ✔ clock boundary — deterministic time, restored afterwards
beforeEach(() => { vi.useFakeTimers({ now: new Date("2026-01-15T10:00:00Z") }); });
afterEach(() => { vi.useRealTimers(); vi.restoreAllMocks(); });

it("expires the session after 30 minutes", () => {
  const session = createSession();
  vi.advanceTimersByTime(30 * 60_000 + 1);
  expect(session.isExpired()).toBe(true);
});
```

If you need `vi.mock()` on half your imports, the code under test wants
dependency injection. Leaked mocks are the top source of order-dependent
tests — set `restoreMocks: true` in config.

## Async & flake control

```ts
// ☠ floating promise — passes even when the assertion throws
it("saves", () => { service.save(order).then(r => expect(r.ok).toBe(true)); });

// ✔ always await; enable @typescript-eslint/no-floating-promises in tests too
it("saves", async () => {
  const r = await service.save(order);
  expect(r.ok).toBe(true);
});
```

- No `setTimeout`-and-hope: wait for the condition (`await waitFor(...)`) or
  control the clock.
- Fails only in CI → suspect parallel workers sharing state (ports, temp
  files, DB rows). Randomize/isolate per test:
  `const port = 3000 + Number(process.env.VITEST_WORKER_ID ?? 0);`
- Reproduce order dependence: `vitest --sequence.shuffle --sequence.seed=123`
  (Jest: `--runInBand` + seed).

## React components — Testing Library

```tsx
it("submits the form with entered values", async () => {
  const user = userEvent.setup();
  const onSubmit = vi.fn();
  render(<CheckoutForm onSubmit={onSubmit} />);

  await user.type(screen.getByRole("textbox", { name: /email/i }), "a@b.co");
  await user.click(screen.getByRole("button", { name: /pay now/i }));

  expect(onSubmit).toHaveBeenCalledWith(expect.objectContaining({ email: "a@b.co" }));
});
```

Query by role/label (what users perceive), interact via `userEvent`, assert
visible outcome. `getByRole` doubles as an a11y check — if it has no role,
users can't find it either.
