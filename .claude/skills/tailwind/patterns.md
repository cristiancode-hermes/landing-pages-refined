# Tailwind patterns & anti-patterns

## Responsive & container queries

Mobile-first: unprefixed = smallest screen; add `sm: md: lg:` upward.

```html
<!-- ☠ designed desktop-first, patched down -->
<div class="grid-cols-4 md:grid-cols-2 grid-cols-1 grid">…</div>

<!-- ✔ base = mobile, enhance upward -->
<div class="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">…</div>
```

**Container queries over viewport queries for components** (built into v4) —
a card reused in a sidebar and a main column must respond to its *slot*:

```html
<div class="@container">
  <article class="grid gap-3 @md:grid-cols-[8rem_1fr] @xl:gap-6">
    <img class="aspect-square w-full rounded-card object-cover" … />
    <div>…</div>
  </article>
</div>
```

## State & structure variants

```html
<!-- keyboard parity: hover pairs with focus-visible; disabled handled -->
<button class="rounded-md bg-brand-500 px-4 py-2 text-white
               hover:bg-brand-600 focus-visible:ring-2 focus-visible:ring-brand-500/50
               disabled:pointer-events-none disabled:opacity-50">
  Save
</button>

<!-- pure-CSS form error state via peer -->
<input type="email" required class="peer …" />
<p class="invisible text-sm text-red-600 peer-invalid:visible" role="alert">
  Enter a valid email.
</p>

<!-- parent-driven styles via group; headless-UI state via data-* -->
<a class="group flex items-center gap-2">
  <span class="opacity-0 transition group-hover:opacity-100">→</span> Details
</a>
<div data-state="open" class="hidden data-[state=open]:block">…</div>
```

## Dark mode: semantic tokens, not dark: on 500 elements

```css
/* styles.css — flip the tokens once */
@theme { --color-surface: oklch(0.98 0 0); --color-ink: oklch(0.2 0 0); }
@custom-variant dark (&:where(.dark, .dark *));   /* manual toggle: .dark on <html> */
.dark { --color-surface: oklch(0.18 0 0); --color-ink: oklch(0.93 0 0); }
```

```html
<!-- ☠ every element carries the theme -->
<div class="bg-white text-zinc-900 dark:bg-zinc-900 dark:text-zinc-100">…

<!-- ✔ markup names the ROLE; the theme decides the value -->
<div class="bg-surface text-ink">…
```

## Keeping markup maintainable

**Extract components, not class strings.** Button-like things with props →
a variant map (`cva`):

```ts
import { cva, type VariantProps } from "class-variance-authority";

export const button = cva(
  "inline-flex items-center justify-center rounded-md font-medium transition " +
  "focus-visible:ring-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      intent: {
        primary: "bg-brand-500 text-white hover:bg-brand-600",
        ghost:   "bg-transparent text-ink hover:bg-surface",
        danger:  "bg-red-600 text-white hover:bg-red-700",
      },
      size: { sm: "h-8 px-3 text-sm", md: "h-10 px-4" },
    },
    defaultVariants: { intent: "primary", size: "md" },
  },
);
// <button className={button({ intent: "danger", size: "sm" })}>
```

Conditional classes: **complete literals per branch** — never interpolated
fragments (invisible to the compiler):

```tsx
// ☠ compiler can't see these classes — they get purged
<div className={`bg-${color}-500 p-${size}`} />

// ✔ full class strings in a map
const tone = { ok: "bg-green-100 text-green-900",
               warn: "bg-amber-100 text-amber-900",
               err: "bg-red-100 text-red-900" }[status];
<div className={clsx("rounded-md p-3", tone)} />
```

- Class order (layout → box → type → color → states) via
  `prettier-plugin-tailwindcss`, non-negotiable in CI — humans stop debating.
- `@apply` only inside small `@layer components` primitives when a framework
  component isn't possible (CMS/markdown output). A file that's 80% `@apply`
  has rebuilt Bootstrap — use components.

## Anti-patterns (review flags)

- `bg-${color}-500` string building → class map object (above).
- The same arbitrary value twice (`text-[13px]`) → `@theme` token.
- `!important` modifiers (`mt-4!`) papering over specificity fights → fix
  the layer/source order.
- Fixed heights + `overflow-hidden` hiding real content → intrinsic sizing.
- Rebuilding focus traps/menus in utilities → headless primitives (Radix,
  Angular ARIA) + Tailwind for the skin.
