# API documentation

## Per endpoint / function — the contract, completely

Every documented operation answers all of these; a missing row is a support
ticket:

| Element | Detail |
|---|---|
| Signature | method + path / function signature, with types |
| Purpose | one sentence, task-oriented ("Cancels an order that hasn't shipped") |
| Parameters | each: type, required?, default, constraints, example value |
| Success response | shape + a **real** example payload |
| Errors | each failure mode: condition → status/exception → example body |
| Auth & limits | required scope/role; rate limits; idempotency behavior |
| Side effects | what changes, what events fire, is it retryable |

A complete example — this is the bar:

````markdown
### POST /v1/orders/{id}/cancel

Cancels an order that has not shipped. Refunds are issued asynchronously.

**Auth**: bearer token with `orders:write`. **Idempotent**: yes, by order state.

| Param | In | Type | Required | Notes |
|---|---|---|---|---|
| `id` | path | uuid | yes | the order to cancel |
| `reason` | body | string enum: `customer_request` \| `fraud` \| `stock` | yes | recorded on the audit trail |

**Success — 200**
```json
{ "id": "ord_9f2c", "status": "cancelled", "refund": { "state": "pending", "cents": 4200 } }
```

**Errors**
| Condition | Status | Body `code` |
|---|---|---|
| order already shipped | 409 | `order_already_shipped` |
| order not found / not yours | 404 | `not_found` |
| already cancelled | 200 | (idempotent no-op — returns current state) |

**Side effects**: emits `order.cancelled` webhook; refund job enqueued.
````

Document the **edge behavior** people get bitten by: `null` vs missing
field, pagination scheme, eventual consistency, timezones, duplicate
submission.

## Generate from source — handwritten copies go stale

```ts
/**
 * Cancels an order that has not shipped.
 *
 * @param orderId - the order to cancel
 * @param reason  - recorded on the audit trail
 * @returns the updated order with refund state
 * @throws {OrderAlreadyShippedError} when fulfillment has started
 * @example
 * const order = await cancelOrder("ord_9f2c", "customer_request");
 */
export async function cancelOrder(orderId: string, reason: CancelReason): Promise<Order>
```

- HTTP: OpenAPI (spec-first, or from annotations — NestJS `@nestjs/swagger`,
  FastAPI automatic). Lint the spec in CI:
  ```bash
  npx @stoplight/spectral-cli lint openapi.yaml
  ```
- TS: TypeDoc from JSDoc. Python: mkdocstrings/Sphinx from docstrings.
- Validate examples in CI — run doc snippets as tests:
  ```python
  def add(a: int, b: int) -> int:
      """
      >>> add(2, 2)
      4
      """
  # pytest --doctest-modules
  ```

## Changelogs — Keep-a-Changelog style

```markdown
## [2.1.0] - 2026-07-01
### Added
- `POST /v1/orders/{id}/cancel` accepts a `reason` field.
### Deprecated
- `DELETE /v1/orders/{id}` — use `POST .../cancel`. Removal in 3.0.
### Fixed
- Refund amounts for split-payment orders no longer lose a cent (#1234).
```

Every breaking change gets a migration note with before/after code:

```markdown
### Migrating from v2

// before
await client.orders.delete(id);
// after — reason is now required
await client.orders.cancel(id, { reason: "customer_request" });
```

Errors are part of the API: document them with the same care as success —
most integration time is spent in the error paths.
