# Tailwind animations & transitions (v4)

Two distinct tools: **transitions** (state A → state B on hover/focus/state
change) and **animations** (`animate-*`, keyframe-driven, possibly looping).
Pick transition first; animation only when there are keyframes to run.

## Transitions — the 90% case

```html
<button class="rounded-lg bg-indigo-600 px-4 py-2 text-white
               transition hover:scale-105 hover:bg-indigo-500
               active:scale-95 duration-200 ease-out">
  Save
</button>
```

- `transition` covers the sane default set (colors, opacity, shadow,
  transform); scope tighter with `transition-colors`, `transition-opacity`,
  `transition-transform` — cheaper and no surprise property animating.
- Timing: `duration-*` (ms), `ease-out` for entrances / `ease-in` for exits
  / `ease-in-out` for loops; `delay-*` for stagger.
- Drive from any variant, not just hover: `data-[state=open]:rotate-180`,
  `aria-expanded:rotate-180`, `group-hover:translate-x-1`,
  `peer-checked:opacity-100` — state lives in attributes, motion in CSS.

## Entry transitions — `starting:` (@starting-style)

Transitioning something that just appeared (popover, dialog, dropdown)
needs a "before" state — that's the `starting:` variant:

```html
<div popover id="menu"
     class="opacity-100 scale-100 transition-all duration-200
            starting:opacity-0 starting:scale-95
            transition-discrete">
  …
</div>
```

- `starting:` = CSS `@starting-style`: the state the element transitions
  *from* on first render / when leaving `display: none`.
- `transition-discrete` (`transition-behavior: allow-discrete`) makes
  `display`/`overlay` participate — required for popovers/dialogs to
  animate closed instead of vanishing.

## Built-in animations

| Utility          | Use for                                  |
|------------------|-------------------------------------------|
| `animate-spin`   | loading spinners (on the SVG, not the button) |
| `animate-pulse`  | skeleton screens while data loads          |
| `animate-ping`   | attention dots/badges (on a twin element)  |
| `animate-bounce` | "scroll down" hints                        |
| `animate-none`   | turning any of it off per-variant          |

```html
<button disabled class="…">
  <svg class="mr-2 size-5 animate-spin" viewBox="0 0 24 24"><!-- … --></svg>
  Processing…
</button>

<div class="h-4 w-3/4 animate-pulse rounded bg-gray-200"></div>  <!-- skeleton -->
```

## Custom animations — `@theme` tokens (CSS-first, no JS config)

Define once, get a first-class `animate-*` utility everywhere:

```css
/* app.css */
@import "tailwindcss";

@theme {
  --animate-fade-in-up: fade-in-up 250ms ease-out;
  --animate-wiggle: wiggle 1s ease-in-out infinite;

  @keyframes fade-in-up {
    from { opacity: 0; transform: translateY(8px); }
    to   { opacity: 1; transform: translateY(0); }
  }
  @keyframes wiggle {
    0%, 100% { transform: rotate(-3deg); }
    50%      { transform: rotate(3deg); }
  }
}
```

```html
<div class="animate-fade-in-up">appears smoothly</div>
<img class="hover:animate-wiggle" … />
```

One-off without a token: `animate-[wiggle_1s_ease-in-out_infinite]`
(keyframes still defined in CSS). ☠ Repos with three ad-hoc
`animate-[...]` of the same thing — promote it to an `--animate-*` token.

## Staggered lists

```html
@for (item of items(); track item.id; let i = $index) {
  <li class="animate-fade-in-up" [style.animation-delay.ms]="i * 50">…</li>
}
```

(Or `style="animation-delay: calc(var(--i) * 50ms)"` with a CSS var —
utilities handle the animation, inline style carries the per-item index.)

## Accessibility & performance — review findings, not suggestions

- **`motion-reduce` on everything decorative**:

```html
<div class="animate-fade-in-up motion-reduce:animate-none
            transition hover:-translate-y-1
            motion-reduce:transition-none motion-reduce:hover:transform-none">
```

  (Or invert: apply motion only under `motion-safe:`.) Looping animation
  with no reduced-motion story fails review.
- Animate **transform/opacity only** — `transition-all` on layout-affecting
  properties (width, height, padding) causes reflow jank; scope the
  transition property instead.
- Infinite animations (`animate-spin`, custom `infinite`) keep the
  compositor awake — remove them from the DOM when idle (`@if (loading())`),
  don't just hide them with `opacity-0`.

## With Angular (this kit's default frontend)

`animate.enter` / `animate.leave` class values are just CSS classes — feed
them Tailwind animations, including the DOM-removal-safe leave:

```html
<div animate.enter="animate-fade-in-up"
     animate.leave="animate-[fade-out-down_200ms_ease-in_forwards]">…</div>
```

See `angular/animations.md` for the enter/leave semantics.
