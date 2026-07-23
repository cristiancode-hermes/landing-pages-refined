---
name: testing
description: >-
  Test strategy, Jest/Vitest unit testing, browser E2E with Playwright, and
  meaningful coverage. Use when writing tests, fixing failing or flaky tests,
  setting up a test suite, or deciding what to test.
---

# Testing

References:

- [jest.md](jest.md) — unit/integration patterns for Jest & Vitest
- [browser-testing.md](browser-testing.md) — Playwright E2E that doesn't flake
- [coverage.md](coverage.md) — what coverage means and what to aim at

> Official complement: `anthropics/skills` ships **webapp-testing** for driving
> real browsers — `npx skills add anthropics/skills`.

## Strategy

- **Test behavior through public interfaces**, not implementation details.
  A good test survives a refactor; a mock-everything test fails when you
  rename a private method and passes when the app is broken.
- Shape: many fast unit/integration tests, a thin layer of E2E over the money
  paths (signup, checkout, the core loop). Inverted pyramids are slow and flaky.
- Every bug fix carries the regression test that would have caught it —
  written *first*, watched failing (red → green is the proof).
- Test names state behavior: `rejects expired tokens`, not `test auth 2`.
- One logical assertion per test; table-driven/parameterized for input matrices.

## For agents

- Run the test suite before *and* after your change; report the real output.
- Never delete, skip, or weaken an existing assertion to make your change
  pass — surface the conflict instead.
- A test you didn't run is a test that doesn't pass; "should work" is not a
  test result.
