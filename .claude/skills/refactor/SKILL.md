---
name: refactor
description: >-
  Safe, behavior-preserving code restructuring. Use when asked to refactor,
  clean up, simplify, extract, rename at scale, migrate patterns/APIs, or pay
  down tech debt — anything where behavior must not change.
---

# Refactor

References:

- [strangler.md](strangler.md) — incremental migration of things too big to rewrite
- [codemods.md](codemods.md) — mechanical changes at scale (codemods, structural search)

## The contract

A refactor changes structure, **never behavior**. If you find a bug mid-refactor,
stop, fix it in a separate commit (with a test), then resume. Mixed
fix-and-restructure diffs are unreviewable and unbisectable.

## Procedure

1. **Safety net first.** Run the tests for the area; if coverage is thin,
   write characterization tests that pin *current* behavior (including current
   quirks) before moving anything.
2. **Small, compiling steps.** Extract function → run tests → rename → run
   tests → move file → run tests. Each commit is green and reversible. The
   IDE/LSP rename beats regex; codemods beat hand-editing 40 call sites.
3. **Keep the diff explainable.** No drive-by reformatting or "while I'm here"
   changes — every hunk should trace to the stated goal.
4. **Verify equivalence** at the end: full test run, typecheck, and (for hot
   paths) a quick benchmark — "cleaner" code that's 10× slower is a regression.

## When NOT to refactor

- Right before a release, inside an unrelated feature PR, or on code with no
  tests and no time to add them.
- Code that works, changes never, and no one needs to read — leave it.
- To an abstraction with only one caller ("speculative generality"). Duplicate
  once; abstract on the third occurrence.
