# Tailwind v4 setup & configuration

## Install (Vite-based projects; Angular ≥17 works via the same plugins)

```bash
npm install tailwindcss @tailwindcss/vite        # Vite plugin path
# or: npm install tailwindcss @tailwindcss/postcss
```

```ts
// vite.config.ts
import tailwindcss from '@tailwindcss/vite';
export default defineConfig({ plugins: [tailwindcss()] });
```

```css
/* src/styles.css — this is the whole setup */
@import "tailwindcss";
```

No config file, no `content` globs — v4 scans the project automatically
(respecting `.gitignore`). Explicit sources only for odd locations:

```css
@source "../../packages/ui";        /* monorepo sibling */
@source not "../legacy";            /* exclude a scanned dir */
```

## Design tokens: @theme

```css
@import "tailwindcss";

@theme {
  /* brand palette — generates bg-brand-500, text-brand-600, etc. */
  --color-brand-50:  oklch(0.97 0.02 260);
  --color-brand-500: oklch(0.65 0.20 260);
  --color-brand-600: oklch(0.55 0.20 260);

  /* semantic tokens — components reference THESE (see patterns.md) */
  --color-surface: var(--color-zinc-50);
  --color-ink:     var(--color-zinc-900);

  --font-display: "Satoshi", ui-sans-serif, sans-serif;
  --spacing-18: 4.5rem;               /* p-18, gap-18, w-18… */
  --radius-card: 1rem;                /* rounded-card */
  --breakpoint-3xl: 120rem;           /* 3xl: variant */
}
```

- Each token generates utilities **and** a plain CSS variable usable
  anywhere — including non-Tailwind CSS and JS:

```tsx
<div style={{ boxShadow: `0 0 0 4px var(--color-brand-500)` }} />
```

- Force the design system by clearing a default scale first:

```css
@theme {
  --color-*: initial;                 /* no default palette escapes review */
  --color-brand-500: oklch(0.65 0.2 260);
  --color-surface:   oklch(0.98 0 0);
  /* … only your tokens exist now */
}
```

- One-off component styles: normal CSS with tokens, in the components layer:

```css
@layer components {
  .prose-card {
    border-radius: var(--radius-card);
    background: var(--color-surface);
    padding: calc(var(--spacing) * 6);
  }
}
```

## v3 → v4 migration

```bash
npx @tailwindcss/upgrade              # codemod: config → CSS, renames, PostCSS setup
```

Then review the diff for the breaking renames it flags:

| v3 | v4 |
|---|---|
| `shadow-sm` / `shadow` | `shadow-xs` / `shadow-sm` (same for `blur`, `rounded`) |
| `outline-none` | `outline-hidden` |
| `ring` | now 1px (was 3px) — use `ring-3` for the old look |
| `border` default color | now `currentColor` (was gray-200) |
| `bg-opacity-50` | `bg-black/50` opacity modifiers |

- A kept `tailwind.config.js` works temporarily via
  `@config "./tailwind.config.js";` — treat it as a migration crutch with a
  removal date.
- Browser floor: Safari 16.4+ / Chrome 111+ / Firefox 128+ — check the
  project's support matrix **before** upgrading.
- Verify visually (run the app, diff key screens) — class renames typecheck
  nothing; only eyes catch a ring that got thinner.
