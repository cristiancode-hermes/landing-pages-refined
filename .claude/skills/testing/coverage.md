# Coverage that means something

Coverage measures what your tests *execute*, not what they *verify*. 100%
coverage with weak assertions is a green dashboard over a broken app.

## Use it as a search tool, not a score

```bash
npx vitest run --coverage                 # then read the HTML report,
open coverage/index.html                  # not just the summary line
```

Read the **uncovered lines in files you're changing**: each red region is a
question — "what breaks if this is wrong, and would we know?" Cover the ones
with a real answer (error paths, boundaries, branching logic); ignore the
ones without (log lines, trivial getters).

Branch coverage matters more than line coverage:

```ts
function shippingCost(order: Order): number {
  if (order.total > 100 && order.region === "EU") return 0;   // 4 branch outcomes
  return order.weight * RATE;
}
// 100% LINE coverage needs one test through each return.
// 100% BRANCH coverage needs total>100/EU, total>100/non-EU, total<=100 —
// and the "free shipping for heavy EU orders" bug lives in the combination.
```

Coverage of a `catch` block means the error path executed at least once —
if your report shows red `catch` blocks, your error handling has never run.

## Sensible enforcement

```ts
// vitest.config.ts — enforce on what you control
coverage: {
  provider: "v8",
  reporter: ["text", "html", "lcov"],
  exclude: ["**/*.gen.ts", "**/migrations/**", "**/*.config.*"],  // keep the number honest
  thresholds: { lines: 80, branches: 75 },
}
```

```bash
# Python: enforce on the diff, not the repo — no filler-test incentive
pytest --cov=src --cov-report=xml
diff-cover coverage.xml --compare-branch=origin/main --fail-under=90
```

- New/changed code: aim high (~90% on the diff) — cheap while context is
  loaded. Whole-repo retroactive targets cause assertion-free filler tests.
- Exclude generated code, migrations, and config from metrics.

## Beyond line coverage

**Mutation testing** — the strongest check: it flips your code and sees if
tests notice. Run occasionally on the money modules, not every CI pass:

```bash
npx stryker run --mutate "src/billing/**/*.ts"    # JS/TS
mutmut run --paths-to-mutate src/billing/          # Python
```

A surviving mutant like `>` → `>=` in `shippingCost` above is a missing
boundary test, found mechanically.

**Property-based tests** cover input *space* instead of lines — parsers,
serializers, anything with an invariant:

```ts
import fc from "fast-check";
test("encode∘decode is identity", () => {
  fc.assert(fc.property(fc.string(), s => decode(encode(s)) === s));
});
```
