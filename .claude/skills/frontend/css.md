# CSS architecture

## Layout

```css
/* Flexbox for rows/columns; gap over sibling margins */
.toolbar { display: flex; align-items: center; gap: var(--space-2); }

/* Grid for 2D; intrinsic responsiveness without breakpoints */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(16rem, 1fr));
  gap: var(--space-4);
}

/* Fluid type without media queries */
h1 { font-size: clamp(1.5rem, 1.1rem + 2vw, 2.5rem); }
```

- Avoid fixed heights; let content size things (`min-height` when needed).
  Fixed heights are where overflow bugs are born.
- Wide content (tables, code) scrolls in its own container; the page never
  scrolls horizontally:

```css
.table-wrap { overflow-x: auto; }
```

- Build mobile-first (`min-width` breakpoints upward). Container queries for
  components reused in different-width slots:

```css
.card-host { container-type: inline-size; }
@container (min-width: 28rem) {
  .card { grid-template-columns: 8rem 1fr; }   /* responds to its slot, not the viewport */
}
```

## Tokens & theming

All colors, spacing, radii, and type come from custom properties — never
hardcoded hex in components:

```css
:root {
  /* semantic tokens — components use THESE names */
  --color-bg: #ffffff;
  --color-surface: #f6f6f7;
  --color-ink: #17181c;
  --color-ink-muted: #5c6066;
  --color-accent: #4053d6;
  --space-1: 0.25rem; --space-2: 0.5rem; --space-3: 0.75rem;
  --space-4: 1rem;    --space-6: 1.5rem; --space-8: 2rem;
  --radius-card: 0.75rem;
}

/* dark mode = redefining tokens, once — not per-component overrides */
@media (prefers-color-scheme: dark) {
  :root { --color-bg: #131417; --color-surface: #1c1d21;
          --color-ink: #ececee; --color-ink-muted: #9a9ea6; }
}
/* manual toggle must win in both directions */
:root[data-theme="dark"]  { --color-bg: #131417; --color-ink: #ececee; }
:root[data-theme="light"] { --color-bg: #ffffff; --color-ink: #17181c; }
```

Spacing and type on a scale (4/8px steps); off-scale values need a comment
justifying them.

## Discipline

```css
/* ✔ flat specificity: single class selectors */
.order-row { ... }
.order-row--selected { ... }

/* ☠ specificity arms race — unmaintainable */
#app .content div.table tr.row td .cell span { ... }
```

- Pick the project's existing convention (BEM, CSS Modules, Tailwind,
  vanilla-extract) and match it — don't introduce a second system.
- `!important` is a bug report against your own architecture; fix the
  cascade/layer instead:

```css
@layer reset, base, components, utilities;   /* explicit cascade order */
```

- z-index from a token scale, not a 9999 arms race:

```css
:root { --z-dropdown: 10; --z-sticky: 20; --z-modal: 100; --z-toast: 110; }
```

- Units: `rem` for type/spacing, `px` only for borders/hairlines.
- Animate only `transform` and `opacity` (compositor-friendly); anything
  else janks:

```css
.sheet { transition: transform 200ms ease, opacity 200ms ease; }
.sheet[data-closed] { transform: translateY(8px); opacity: 0; }
```
