---
name: architecture
description: >-
  Code quality and application architecture for any app — SOLID principles,
  clean code rules, layering, dependency direction, and module boundaries.
  Use when designing a new feature/service, reviewing structure, deciding
  where code should live, or when code feels tangled, untestable, or too
  coupled to change safely.
---

# Architecture & Clean Code

References:

- [solid.md](solid.md) — the five principles with concrete violations and fixes
- [clean-code.md](clean-code.md) — naming, functions, errors, comments — the daily rules
- [app-architecture.md](app-architecture.md) — layers, dependency direction, boundaries, when to split

## The three questions that decide most designs

1. **Which direction do dependencies point?** Business logic depends on
   nothing framework-shaped. Frameworks, DBs, and transports depend on (or
   adapt to) the domain — never the reverse. If the domain imports the ORM,
   the design is inverted.
2. **What changes together?** Code that changes for the same reason lives
   together (feature folders, vertical slices); code that changes for
   different reasons is separated — even if it looks similar today.
3. **Can I test the core without the world?** If exercising a business rule
   requires a DB, an HTTP server, or a mock-everything setup, the boundaries
   are in the wrong place.

## Defaults

- **Simple first, structure on evidence.** Start with the fewest moving
  parts (a module, not a microservice; a function, not a class hierarchy).
  Add abstraction on the *second or third* occurrence of real variation —
  speculative generality is how frameworks-within-frameworks are born.
- **Boundaries are explicit**: a module's public API is its exported
  surface; everything else is private. Cross-module imports of internals
  fail review (enforce with ESLint `no-restricted-imports` /
  `boundaries` plugin, or module systems like Nest's `exports`).
- **Composition over inheritance** — inheritance for true is-a with stable
  contracts (rare); composition for everything else.
- Consistency beats local elegance: match the existing architecture of the
  repo. Improving the pattern is a deliberate, separate proposal — not a
  side effect of a feature PR (see the refactor track).

## For agents

Before adding a file, state (to yourself) which layer it belongs to and
what may import it. If the answer is "everything can import everything",
propose the boundary first. When a change forces edits in 5+ unrelated
files, that's architectural feedback — surface it, don't just push through.
