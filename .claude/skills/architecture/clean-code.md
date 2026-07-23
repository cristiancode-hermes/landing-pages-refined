# Clean code — the daily rules

Optimize for the reader. Code is read 10× more than it's written, and the
next reader has none of your current context.

## Naming

```ts
// ☠ names that require archaeology
const d = getD(u.l);
function proc(data: any[]): any[] { ... }
let flag = false;

// ✔ names that carry the domain
const daysSinceLastLogin = getDaysSince(user.lastLoginAt);
function withdrawExpiredHolds(holds: InventoryHold[]): InventoryHold[] { ... }
let hasUnsavedChanges = false;
```

- Booleans read as predicates: `isExpired`, `hasAccess`, `canRetry`.
- Functions are verbs; the name states effect or answer — a `getX()` that
  mutates state is a lie, and lies in names cause bugs downstream.
- One word per concept per codebase: pick `fetch` | `get` | `retrieve` and
  stick to it; `Customer` and `Client` must not both exist for one concept.
- Name by intent, not implementation: `retryDelay`, not `sleepTime2`.
  Unabbreviated beats short: `ctx`/`req`/`i` only where convention is
  universal.

## Functions

- Small, one job, one abstraction level per body — a function that checks,
  computes, saves, and notifies is four functions and a coordinator:

```ts
// ✔ the body reads as a table of contents
async function placeOrder(cmd: PlaceOrderCmd): Promise<OrderId> {
  const order = buildOrder(cmd);
  assertWithinCredit(order, cmd.customer);
  const id = await orders.save(order);
  await events.publish(orderPlaced(id));
  return id;
}
```

- **Guard clauses over nesting** — handle edge cases first, return early;
  the happy path stays at indentation level one:

```ts
// ☠ arrow anti-pattern            // ✔ flat
if (user) {                        if (!user) throw new NotFound();
  if (user.active) {               if (!user.active) throw new Inactive();
    if (quota.ok) { ...work }      if (!quota.ok) throw new QuotaExceeded();
  }                                ...work
}
```

- ≤3 params; more wants an options object with named fields. Boolean
  parameters split the function: `render(true)` tells the reader nothing —
  `renderCompact()` / `renderFull()` do.
- No output arguments; return the result. No hidden temporal coupling
  (`init()` must be called before `run()`) — make invalid orders
  unrepresentable (constructor does init, or a builder returns a ready
  object).

## Errors

- Throw/return **specific** error types carrying context; never swallow:

```ts
// ☠ catch-and-continue — the bug is now invisible
try { await sync(user); } catch (e) { console.log(e); }

// ✔ handle what you can, enrich and rethrow what you can't
try {
  await sync(user);
} catch (err) {
  throw new SyncFailedError(`user ${user.id} sync failed`, { cause: err });
}
```

- Exceptions for exceptional paths; expected outcomes are return values
  (`Result`/discriminated unions where the language supports them well).
- Fail fast at boundaries (validate input at the edge — see nestjs/security
  tracks); trust internal invariants after the boundary.

## Comments & structure

- Comments explain **why**, never what — the code says what:

```ts
// ☠ // increment retry counter
retries++;
// ✔ Stripe idempotency keys expire after 24h; past that we must regenerate
if (olderThan(key, HOURS_24)) key = newIdempotencyKey();
```

- Dead code is deleted, not commented out — git remembers.
- No magic values: `if (attempts > 3)` → `const MAX_LOGIN_ATTEMPTS = 3`.
- Duplication of **knowledge** (a business rule in two places) is the real
  DRY target. Similar-looking code with different reasons to change may
  stay duplicated (see architecture/SKILL.md — what changes together).
- Delete speculative flexibility: unused params "for later", config nobody
  sets, interfaces with one implementation and no test seam need.

## The boy-scout rule, bounded

Leave touched code slightly better (a rename, a guard clause, a dead-code
deletion) — but keep it in the same commit only when trivial, and never let
cleanup balloon a feature diff (hard rule §2: minimal diffs). Bigger cleanup
= separate refactor PR.
