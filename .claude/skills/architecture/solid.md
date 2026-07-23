# SOLID — with violations and fixes

Principles are diagnostic tools, not commandments: apply them where change
pressure is real; don't pre-abstract stable code.

## S — Single Responsibility

A module has one reason to change (one *actor* who demands changes).

```ts
// ☠ three actors: finance (tax rules), ops (persistence), marketing (email)
class OrderService {
  calculateTax(order: Order) { ... }
  saveOrder(order: Order) { ... }
  sendConfirmationEmail(order: Order) { ... }
}

// ✔ split by reason-to-change; a coordinator composes them
class TaxCalculator     { calculate(order: Order): Tax { ... } }
class OrderRepository   { save(order: Order): Promise<void> { ... } }
class OrderNotifier     { confirm(order: Order): Promise<void> { ... } }

class PlaceOrder {      // use-case: orchestration only
  constructor(private tax: TaxCalculator, private repo: OrderRepository,
              private notify: OrderNotifier) {}
  async execute(order: Order) {
    order.applyTax(this.tax.calculate(order));
    await this.repo.save(order);
    await this.notify.confirm(order);
  }
}
```

Smell: a class you must open for unrelated tickets; test files that mock
half the world to test one method.

## O — Open/Closed

Add behavior by adding code, not by editing a growing conditional.

```ts
// ☠ every new payment method edits this function (and its tests, and its bugs)
function processPayment(order: Order) {
  switch (order.method) {
    case "card":   ...
    case "paypal": ...
    case "crypto": ...   // 4th edit this quarter
  }
}

// ✔ a registry of strategies — new method = new file, zero edits here
interface PaymentHandler { supports(m: Method): boolean; pay(o: Order): Promise<Receipt>; }
class PaymentProcessor {
  constructor(private handlers: PaymentHandler[]) {}
  pay(order: Order) {
    const h = this.handlers.find(h => h.supports(order.method));
    if (!h) throw new UnsupportedMethodError(order.method);
    return h.pay(order);
  }
}
```

Apply on the **second** variant, not speculatively — one `if` is fine.

## L — Liskov Substitution

Subtypes must honor the base type's contract: no strengthened
preconditions, no weakened postconditions, no surprise exceptions.

```ts
// ☠ classic: Square extends Rectangle breaks callers that set width freely
// ☠ subtler & more common:
class ReadonlyRepo extends Repository {
  save() { throw new Error("not supported"); }   // violates the contract
}

// ✔ model the actual capability split
interface Reader<T> { findById(id: string): Promise<T | null>; }
interface Writer<T> { save(entity: T): Promise<void>; }
class SqlRepo implements Reader<Order>, Writer<Order> { ... }
class ReplicaRepo implements Reader<Order> { ... }        // honestly read-only
```

Smell: `instanceof` checks or "does nothing/throws" overrides downstream.

## I — Interface Segregation

Clients depend only on what they use. Fat interfaces force fat mocks.

```ts
// ☠ the god port — every consumer mocks 9 methods to use 1
interface UserService { create; delete; resetPassword; exportGdpr; ban; ... }

// ✔ role interfaces, named for the consumer's need
interface UserCreator  { create(data: NewUser): Promise<User>; }
interface UserBanner   { ban(id: string, reason: string): Promise<void>; }
// SqlUserService implements both; each consumer asks for its role only
```

## D — Dependency Inversion

High-level policy defines the interface; low-level detail implements it.
The domain owns its ports; adapters live at the edge.

```ts
// domain/ports.ts — owned by the DOMAIN, named in domain language
export interface OrderRepository { save(o: Order): Promise<void>; }
export interface Clock { now(): Date; }

// domain/place-order.ts — pure business logic, framework-free
export class PlaceOrder {
  constructor(private repo: OrderRepository, private clock: Clock) {}
}

// infra/typeorm-order-repo.ts — the detail depends on the abstraction
export class TypeOrmOrderRepo implements OrderRepository { ... }
```

Test impact is the point: `PlaceOrder` tests run with in-memory fakes, no
DB, in milliseconds. If tests need infrastructure, D is being violated
somewhere.

## Review heuristics

- New `switch` on a type/enum that already exists elsewhere → O violation
  brewing; consider polymorphism/strategy.
- A mock with 6+ stubbed methods for one test → I violation.
- `import { PrismaClient } from '@prisma/client'` inside `domain/` → D
  violation.
- "Manager", "Helper", "Util" classes accreting methods → S violation.
