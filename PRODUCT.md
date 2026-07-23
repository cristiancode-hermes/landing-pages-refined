# Product

## Register

brand

## Users

Designers, developers, and the project owner browsing a curated collection of
100 landing-page designs — each a standalone, self-contained HTML file
(CSS + JS inline). Visitors open pages individually or through the gallery
index to study layout, palette, motion, and copy craft.

## Product Purpose

A showcase of 100 distinct fictional brands, one landing page each, built to
production-grade frontend standards. The collection demonstrates range:
simple single-fold pages through complex multi-section experiences with
three.js. Success = every page has a committed personality, a complete
OKLCH palette, modern UX/UI, intentional motion (subtle to strong), strong
UX writing, and real imagery or credible generative art — and no two pages
feel like the same template.

## Brand Personality

Each of the 100 pages has its own 3-word personality (defined in
`landings/MANIFEST.md`). The collection itself: eclectic, crafted,
uncompromising.

## Anti-references

- The saturated AI landing-page template (eyebrow kicker + hero metric +
  identical icon-card grid + gradient text).
- Claude-beige / cream-sand body backgrounds, forest-green-on-cream,
  AI-purple-on-white, navy-cream-with-orange-accent monocultures.
- Editorial-typographic lane (display serif + italic + ruled columns)
  applied to briefs that aren't literal magazines/newspapers.
- Reflex fonts: Fraunces, Newsreader, Lora, Crimson, Playfair, Cormorant,
  Syne, IBM Plex family, Space Mono/Grotesk, Inter, DM Sans/Serif, Outfit,
  Plus Jakarta Sans, Instrument Sans/Serif.

## Design Principles

- Distinctiveness over safety: a visitor should ask "how was this made?"
- Palette IS voice: every page names a real reference and commits to a
  color strategy (restrained / committed / full palette / drenched).
- No convergence across pages: neighboring pages never share palette
  mechanics, type pairing, or layout grammar.
- Motion is part of the build, with `prefers-reduced-motion` alternatives
  everywhere.
- Imagery is mandatory where the brief implies it: hotlinked seeded stock
  photos (Picsum) or verified Unsplash, never colored-div placeholders;
  generative CSS/SVG/canvas/three.js scenes where the brand calls for it.

## Accessibility & Inclusion

WCAG AA minimum: body text ≥4.5:1 contrast (ink ≥7:1 vs bg target),
large text ≥3:1; `prefers-reduced-motion` fallbacks for all animation;
semantic HTML; descriptive in-voice alt text; responsive 360px → 1440px+.
