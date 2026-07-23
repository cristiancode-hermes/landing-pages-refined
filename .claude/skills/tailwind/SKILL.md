---
name: tailwind
description: >-
  Tailwind CSS (v4 baseline) — CSS-first configuration, design tokens via
  @theme, component patterns, dark mode, animations/transitions, and keeping
  utility markup maintainable. Use when styling with Tailwind, setting it up
  in a project, migrating v3 → v4, animating with utility classes, or
  reviewing templates full of utility classes.
---

# Tailwind CSS (v4 baseline)

References:

- [v4-setup.md](v4-setup.md) — installation, CSS-first config, `@theme` tokens, v3→v4 migration
- [patterns.md](patterns.md) — component extraction, dark mode, responsive/state variants, anti-patterns
- [animations.md](animations.md) — transitions, `starting:` entry effects, built-in + custom `--animate-*` keyframes, motion-reduce

## v4 essentials (don't write v3 idioms in new projects)

- Setup is CSS-first: `@import "tailwindcss";` in one CSS file + the Vite
  plugin (`@tailwindcss/vite`) or PostCSS plugin. **No `tailwind.config.js`**,
  no `content` array — v4 auto-detects sources (respecting `.gitignore`).
- Design tokens live in CSS via `@theme` — colors, spacing, fonts become
  both utilities *and* native CSS variables (`var(--color-brand-500)`).
- Modern CSS underneath: container queries built in (`@container`, `@sm:`),
  `color-mix()` powering opacity modifiers, cascade layers — no plugins
  needed for these anymore.
- Arbitrary values `w-[137px]` exist for one-offs; if the same arbitrary
  value appears twice, it's a token — add it to `@theme`.

## House style

- **Utilities in markup, tokens in CSS, components in the framework.**
  Repeated class strings get extracted into an Angular/React component (or a
  `cva`-style variant helper) — not into `@apply` soup. Use `@apply`
  sparingly, for small primitives (buttons, inputs) at most.
- Class order: layout → spacing → typography → color → states. Install
  `prettier-plugin-tailwindcss` and let it sort; humans stop debating.
- Never build class names dynamically by string concatenation
  (`bg-${color}-500`) — the compiler can't see them. Map full class strings:
  `{ red: 'bg-red-500', ... }[color]`.
- Accessibility isn't optional because styling moved to utilities: focus
  states (`focus-visible:ring-2 …`) on every interactive element, and the
  frontend/a11y skill still applies in full.
