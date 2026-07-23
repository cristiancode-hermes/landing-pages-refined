---
name: frontend
description: >-
  React patterns, CSS architecture, and accessibility. Use when building or
  reviewing UI components, pages, styles, forms, or anything the user sees —
  and always when the word "accessibility"/"a11y" appears.
---

# Frontend

References:

- [react-patterns.md](react-patterns.md) — state, effects, data fetching, component design
- [a11y.md](a11y.md) — accessibility as an implementation checklist, not an audit afterthought
- [css.md](css.md) — layout, tokens, dark mode, responsive rules

> Official complement: Anthropic's **frontend-design** skill (visual design
> direction) is vendored in this kit — see `../frontend-design/SKILL.md`.
> Load it alongside this track for any new UI with a visual-identity brief.
> **webapp-testing** installs via `npx skills add anthropics/skills`.

## Defaults

- **Semantic HTML first**: `button`, `a`, `nav`, `label`, `dialog` before any
  `div onClick`. Half of a11y and keyboard support falls out for free.
- **Components take data, not decisions**: fetch/derive at the boundary, render
  pure below it. If a component needs six booleans, it wants to be two
  components or a state machine.
- **States are part of the spec**: every view handles loading, empty, error,
  and success — designed, not defaulted. An unstyled spinner and a silent
  `catch` are bugs.
- **Performance basics** before cleverness: correct `key`s, image dimensions
  set (no layout shift), code-split routes, memoize only measured hot paths.
- Verify in the browser: after a UI change, actually load the page (or run the
  project's browser tests) — snapshots and typechecks don't see a white screen.
