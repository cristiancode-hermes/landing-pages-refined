# Test design — what to test and how to structure it

The mechanics live in jest.md / browser-testing.md; this file is about
choosing the right tests and keeping them trustworthy.

## What to test, in priority order

1. **Business rules & calculations** — pure logic, highest bug cost,
   cheapest to test. Every rule gets: the happy path, each boundary
   (`>= 100`? test 99/100/101), and each failure mode.
2. **Contracts at boundaries** — the HTTP surface (status codes, error
   shapes, authz denials), published events, public library APIs. These are
   promises to others; breaking them silently is the worst failure class.
3. **Integration seams** — your queries actually run against a real
   database (testcontainers/Neon branch), your client actually parses the
   provider's payloads (recorded fixtures).
4. **One thin E2E path per money flow** — proves the wiring, nothing else.

What NOT to test: framework behavior (the router routes), trivial
delegation, private functions (test through the public surface — if a
private function begs for its own tests, extract it into a module).

## Test doubles — a taxonomy, used sparingly

| Double | What it does | Use for |
|---|---|---|
| **Fake** | real logic, simplified (in-memory repo) | the default — behaves like production |
| **Stub** | canned answers | forcing a branch ("gateway returns declined") |
| **Spy/Mock** | records calls for assertion | *outgoing* commands where the call IS the outcome (email sent) |

```ts
// ✔ fake repo: tests survive refactors because behavior, not calls, is asserted
class InMemoryOrders implements OrderRepository {
  private rows = new Map<string, Order>();
  async save(o: Order) { this.rows.set(o.id, o); }
  async findById(id: string) { return this.rows.get(id) ?? null; }
}

// assert OUTCOME via the fake…
await placeOrder(cmd);
expect(await orders.findById(id)).toMatchObject({ status: "placed" });

// ☠ …not conversation with mocks (breaks on every internal refactor)
expect(mockRepo.save).toHaveBeenCalledTimes(1);
expect(mockTax.calculate).toHaveBeenCalledBefore(mockRepo.save);
```

Rule of thumb: **mock commands you send to the outside; fake state you
own; never mock what you're testing.** A test file whose setup is longer
than its assertions is testing the mocks.

## Structure & naming

- Name = behavior + condition: `rejects refunds after 180 days`,
  `charges shipping for non-EU orders under 100€` — a failing test's name
  should tell you what broke without opening the file.
- One behavior per test; multiple *assertions* about that one behavior are
  fine.
- Tests follow the same clean-code rules as production code — builders over
  copy-pasted 30-line setup objects (see jest.md), no logic in tests (a
  test with an `if` needs two tests).

## TDD, pragmatically

Red → green → refactor shines when the behavior is specifiable up front:
business rules, parsers, bug fixes (write the failing repro first — debug
track). Exploration/UI work can test-after — but the bar stays: **watch
every test fail once** (comment out the fix or `it.fails`) so you know it
can fail. A test you never saw red proves nothing.

## Keeping suites trustworthy

- A flaky test is a P1 on the suite: quarantine (`it.skip` + ticket) same
  day, fix or delete within the week. A suite people retry until green is
  dead — it gates nothing.
- Speed budget: unit suite fast enough to run on save (<10s), integration
  under a few minutes in CI, E2E only on the money paths. Slow suites stop
  being run, then stop being true.
- Coverage/mutation mechanics: coverage.md.
