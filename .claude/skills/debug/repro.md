# Minimal reproduction

A minimal repro is the fix's down payment: it proves you understand the bug
and becomes the regression test for free.

## Build it

1. **Capture the failing state** — exact input, config, env, versions, seed:

```bash
# HTTP bugs: save the raw failing request once, replay forever
curl -v -X POST https://api.local/orders \
  -H "content-type: application/json" \
  --data @captured_payload.json 2>&1 | tee repro_http.log
```

2. **Shrink by halves.** Delete half the input/steps; still fails? Keep
   deleting. Passes? Restore that half, delete the other. Binary search on
   the repro converges in log₂(n) steps:

```python
def shrink(items, still_fails):
    """Generic ddmin-style input shrinker."""
    step = len(items) // 2
    while step >= 1:
        i = 0
        while i < len(items):
            candidate = items[:i] + items[i + step:]
            if still_fails(candidate):
                items = candidate          # keep the smaller failing input
            else:
                i += step
        step //= 2
    return items                           # minimal failing input
```

3. **Remove the stack.** Replace the DB with a fixture, HTTP with a recorded
   response, the UI with a direct function call — until the repro is one
   function + one input, or you discover the bug *lives* in the layer you
   couldn't remove (which is the answer).

4. **Make it one command**, checked in next to the fix:

```python
# tests/regressions/test_issue_1234.py
def test_refund_rounding_issue_1234():
    """Repro for #1234: refunds of 3-way split orders lost a cent."""
    order = order_fixture(total_cents=100, splits=3)
    refund = compute_refund(order)
    assert sum(r.cents for r in refund.parts) == 100   # was 99
```

If it needs six manual steps, it will never be run again — script them.

## When you can't reproduce

- **Instrument, then wait**: add targeted logging at the suspected boundary
  and ship it — turn the production incident into data.

```python
if total < 0:   # the "impossible" state — log everything when it happens
    logger.error("IMPOSSIBLE negative total", extra={
        "order_id": order.id, "items": order.items, "trace": traceback.format_stack(),
    })
```

- **Widen race windows** instead of hoping: run with `pytest -p no:randomly`
  off / on, `go test -race`, or inject sleeps at suspected interleavings.
  A race that reproduces 1-in-1000 reproduces 1-in-3 with a 10ms sleep in
  the window.
- **Suspect the classics**: timezone/DST boundaries, locale ("1,5" vs "1.5"),
  dict/set iteration order, cache state, retry side effects (the request
  succeeded twice), clock skew.
- **Reproduce the class, not the instance** — property-based testing often
  finds the concrete input for you:

```python
from hypothesis import given, strategies as st

@given(st.decimals(min_value=0, max_value=10**6, places=2), st.integers(1, 12))
def test_split_conserves_total(total, ways):
    parts = split_payment(total, ways)
    assert sum(parts) == total            # hypothesis hunts the counterexample
```
