# Strangler-fig migrations

For anything too big to rewrite in one PR (framework swaps, API v2,
extracting a service, replacing a core module): grow the new alongside the
old, route traffic over gradually, delete the old when it's dead.

## 1. Seam first

Put an interface in front of the old implementation so callers stop
depending on it directly:

```ts
// the seam — callers know only this
export interface PaymentGateway {
  charge(order: Order): Promise<ChargeResult>;
  refund(chargeId: string, cents: number): Promise<RefundResult>;
}

export class LegacyGateway implements PaymentGateway { /* wraps the old code */ }
export class StripeGateway implements PaymentGateway { /* the new world */ }
```

## 2. Route incrementally, behind a flag

```ts
export function makeGateway(flags: Flags, tenant: Tenant): PaymentGateway {
  // per-slice cutover: rollback is a flag flip, not a revert war
  if (flags.isEnabled("payments-v2", tenant)) return new StripeGateway();
  return new LegacyGateway();
}
```

Move one endpoint/module/tenant-cohort at a time. Never a big-bang cutover
of all slices at once.

## 3. Verify per slice — shadow before switching

```ts
// dual-run: new path computes, old path decides — log divergence
async charge(order: Order) {
  const legacy = await this.legacy.charge(order);
  this.shadow(async () => {
    const next = await this.stripe.simulateCharge(order);   // no side effects!
    if (!resultsMatch(legacy, next)) {
      metrics.increment("payments_v2.divergence");
      logger.warn("shadow divergence", { orderId: order.id, legacy, next });
    }
  });
  return legacy;
}
```

Only after divergence is ~zero for a representative window does the new path
become the source of truth. For **writes**, shadow means simulate/dry-run —
never double-charge.

## 4. Delete aggressively

A strangler that never removes the old path is just two systems. Each
slice's PR ends with dead-code removal or a dated TODO with an owner:

```ts
// TODO(2026-09-01, @cristian): delete LegacyGateway once payments-v2 is 100%
```

## Ground rules

- The migration has a **map** — a checklist of every call site/slice with
  status, in MEMORY.md or a tracking issue. Sessions pick up the next
  unchecked item; this is exactly what the shift log is for:

```markdown
## payments-v2 migration map
- [x] POST /orders/:id/charge   (flag ON 100%)
- [x] POST /orders/:id/refund   (flag ON 20%, watching divergence)
- [ ] subscription renewals     (shadow only)
- [ ] admin manual charges
```

- Freeze feature work on the old path, or every feature lands twice.
- Data migrations: **expand → dual-write/backfill → switch reads →
  contract.** Never a one-shot destructive migration on a live schema:

```sql
-- expand (deploy 1): new column, nullable
ALTER TABLE orders ADD COLUMN currency text;
-- dual-write (deploy 2): app writes both; backfill job fills history
UPDATE orders SET currency = 'EUR' WHERE currency IS NULL;  -- batched!
-- switch reads (deploy 3), then contract (deploy 4):
ALTER TABLE orders ALTER COLUMN currency SET NOT NULL;
```

- Timebox coexistence. If the migration stalls past its budget, re-commit
  resources or roll back to one system — indefinite duality is the worst
  outcome.
