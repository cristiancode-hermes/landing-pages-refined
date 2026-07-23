# Bisection

When "it used to work", do not read code — binary search history.

## git bisect

```bash
git bisect start
git bisect bad                  # current commit is broken
git bisect good v1.4.0          # last known good ref
# git checks out midpoints; test each and mark:
git bisect good                 # or: git bisect bad
git bisect reset                # when done — returns to where you started
```

Automate it whenever the failure is scriptable — this is the difference
between 10 minutes and an afternoon:

```bash
# repro.sh — exit 0 = good, 1 = bad, 125 = can't test this commit
#!/usr/bin/env bash
set -e
npm ci --silent || exit 125            # broken install ≠ the bug → skip
npx vitest run tests/invoice.test.ts --reporter=dot
```

```bash
git bisect start HEAD v1.4.0
git bisect run ./repro.sh              # walks the midpoints unattended
```

Rules:

- The test script must be **fast** and **deterministic** — flaky tests poison
  the search. If flakiness is suspected, run the check 3× inside repro.sh and
  fail on any failure.
- Build/install failures at a midpoint → exit `125` (skip), don't guess.
- Bisect the *smallest observable symptom*, not the full e2e flow — a unit
  test bisects 10× faster than a browser test.
- The culprit commit is where understanding **starts**: read its diff and
  explain the mechanism before writing the fix.
  ```bash
  git show <culprit-sha> --stat
  git show <culprit-sha> -- src/billing/   # just the relevant part
  ```
  Reverting without understanding re-breaks later.

## Bisect other dimensions

The same halving works on anything, not just commits:

```bash
# Dependencies: which upgrade in the lockfile diff broke it?
git diff v1.4.0..HEAD -- package-lock.json | grep '"version"' | head -40
# pin half the upgraded packages at old versions, retest, recurse

# Config/flags: start from known-good config, flip half the diff at a time
diff config.good.yaml config.bad.yaml
```

- **Data**: feed half the failing dataset; recurse into the failing half
  (the `shrink()` helper in repro.md is exactly this).
- **Code path**: comment out / early-return halves of a pipeline to find the
  failing stage — crude, fast, effective.
- **Time**: for external-service bugs with no code change on your side,
  bisect *when* it broke via logs/metrics, then ask what changed in the
  world at that moment (their deploy, a cert expiry, a quota reset).
