# Triage

Goal: in ~10 minutes, know what kind of failure this is, how bad it is, and
where to aim the microscope.

## Classify (run these, don't guess)

```bash
# New code or regression? History of the failing area:
git log --oneline -20 -- src/billing/
git log -p --since="2 weeks ago" -- src/billing/invoice.ts

# Deterministic or flaky? Run it three times:
for i in 1 2 3; do npx vitest run tests/invoice.test.ts || echo "FAIL run $i"; done

# Environment-specific? Diff the environments before the code:
node --version && npm ls --depth=0 | head        # local
# ...vs the versions in the CI log / lockfile / Dockerfile
```

- **Regression** (worked before) → bisect history (bisect.md) instead of
  reading code.
- **Flaky** (fails 1-in-N) → suspect time, ordering, network, shared state,
  or test pollution — not the obvious code path.
- **Environment-specific** (local vs CI) → versions, env vars, OS,
  parallelism, locale/timezone. The code is usually innocent.
- **Data-specific** (one input fails) → capture that exact input into a
  fixture *now*, before anything else:

```python
# drop this at the failure site, run once, remove
import json, pathlib
pathlib.Path("repro_input.json").write_text(json.dumps(payload, default=str))
```

## Locate

1. Exact error string → find the throw site:
   ```bash
   grep -rn "Cannot read properties of undefined" src/ | head
   rg -n "raise InvoiceError" --type py
   ```
2. Read the stack trace bottom-up to the **first frame in your code** —
   framework frames above it are usually noise.
3. First error in the log wins; later errors are usually cascade. In
   concurrent systems, sort by timestamp before concluding order.
4. Verify the inputs at the boundary — log what actually arrives, not what
   you assume arrives:
   ```python
   logger.warning("create_invoice inputs: %r", request.model_dump())  # temp probe
   ```
5. Probe to *disprove* your hypothesis, not confirm it. One well-placed
   assert beats an hour of reading:
   ```python
   assert order.total >= 0, f"negative total arrived: {order!r}"  # temp probe
   ```

## Severity call — before fixing

State explicitly:

- **Who is affected** (all users / one tenant / internal only)?
- **Is data being corrupted?** If yes: stop the bleeding first — feature
  flag off, revert, or block the write path. A revert that ships in 10
  minutes beats a fix that ships in 4 hours.
- **Is there a workaround** you can give people while the fix bakes?

Write the answer in the incident/issue thread — triage that lives only in
your head has to be redone by the next person.
