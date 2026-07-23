---
name: docs
description: >-
  Writing READMEs, API references, changelogs, and ADRs. Use when creating or
  updating documentation, documenting an endpoint or module, or when a change
  makes existing docs stale.
---

# Docs

References:

- [readme-guide.md](readme-guide.md) — README structure that answers the reader's real questions
- [api-docs.md](api-docs.md) — documenting endpoints, functions, and libraries

## Principles

- **Write for the reader's task, not the author's pride.** The reader arrives
  with a job (install this, call this, fix this). Order content by their
  urgency: what it is → how to start → how to go deeper.
- **Every claim runnable.** Code samples are copy-paste-runnable and tested
  (or at least executed once by you, today). A doc with broken examples is
  worse than no doc — it burns trust.
- **Docs live next to code and change in the same PR.** If a diff changes
  behavior that any doc describes, updating that doc is part of the diff.
  Stale docs are the reason people stop reading docs.
- Prefer one source of truth: generate API references from code
  (docstrings/JSDoc/OpenAPI) instead of hand-maintaining parallel prose.
- Record *why*, not just *what*: significant decisions get a short ADR
  (context → decision → consequences, ~half a page, in `docs/adr/`).

## Style

Short sentences. Active voice. Second person ("you"). Concrete nouns over
abstractions. Headings that answer questions. One idea per paragraph. Delete
throat-clearing ("It is worth noting that…"). If a section can't say who needs
it, delete the section.
