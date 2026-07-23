---
name: debug
description: >-
  Systematic debugging — triage, minimal reproduction, and bisection. Use when
  investigating a bug, a failing test, a crash, a regression, or any
  "why doesn't X work" question, before proposing a fix.
---

# Debug

References:

- [triage.md](triage.md) — classify the failure and find the blast radius fast
- [repro.md](repro.md) — build the minimal reproduction before touching a fix
- [bisect.md](bisect.md) — `git bisect` and input bisection for regressions

## The method (in order, no skipping)

1. **Reproduce first.** No fix is trusted without a red → green transition you
   ran yourself. If you can't reproduce, that's the task now (see repro.md).
2. **Read the actual error.** The bottom-most cause in the stack trace, the
   first error in the log (later ones are usually cascade). Copy the exact
   message into your notes — paraphrased errors lose the searchable detail.
3. **Form one hypothesis and test it cheaply.** A print/log/debugger probe that
   can *disprove* the hypothesis beats reading code for an hour. If the probe
   result surprises you, your model of the system is wrong — update it before
   proceeding.
4. **Fix the cause, not the symptom.** A `try/except` around the crash site or
   an `if x is not None` guard is symptom paint unless you can say *why* the
   bad state arises.
5. **Lock it in.** Add the regression test that would have caught this, then
   re-run the full suite for the touched area.

## Anti-patterns

- Changing multiple things at once ("shotgun debugging") — you learn nothing
  from the outcome.
- Debugging on top of a dirty working tree — stash first, reproduce clean.
- Trusting "it works on my machine" — pin the environment difference instead.
- Deleting the failing test.
