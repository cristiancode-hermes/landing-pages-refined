# MANIFEST — 100 landing pages

Each entry defines one fictional brand's landing page: `landings/NNN-slug.html`
(single self-contained file, inline CSS + JS). Fields:

- **tier**: simple (1–2 folds, ~200–400 lines) · medium (4–7 sections) · complex (8+ sections or heavy interactive/three.js)
- **strategy**: restrained · committed · full palette · drenched (per impeccable color strategies)
- **bg**: pure-white `#fff` equivalent · pure-black (oklch ~0.08–0.12, chroma 0) · tinted (chroma 0.015–0.05, only where environment-literal) · color (saturated brand surface)
- **palette**: mood phrase + hue anchors in OKLCH degrees. Compose L/C per mood; primary chroma ≤0.23; ink-vs-bg ≥7:1; accent never muddy mid-tone.
- **type**: Google Fonts pairing (none from the reflex-reject list). Display letter-spacing ≥ −0.04em, clamp max ≤ 6rem.
- **motion**: subtle · medium · strong + the signature move. All with `prefers-reduced-motion` fallback.
- **imagery**: `picsum(<seed>)` = `https://picsum.photos/seed/<seed>/<w>/<h>`; `generative` = CSS/SVG/canvas art; `three.js` = WebGL scene (CDN, verify it loads).
- **copy**: voice + density (sparse / medium / rich). Real UX writing, zero lorem ipsum.

---

## Batch 01 (pages 001–004)

### 001 — ember-oak — Ember & Oak, wood-fired pizzeria
tier: medium · strategy: committed · bg: pure-white
palette: "flour-dusted oak table beside a brick oven at 7pm" — primary ember orange (hue ~40, L ~0.55), ink char-black (hue ~30 deep), accent deep basil green (~150)
type: display Archivo 800 · body Literata
motion: medium — ember glow pulse behind hero headline; menu items slide-in staggered on scroll
imagery: picsum(ember-hero) margherita/oven shot as full-bleed hero, picsum(ember-2..3) interior + dough
copy: warm, direct, medium density — oven hours, the 90-second bake, reservations CTA

### 002 — feral — Feral, natural wine bar
tier: simple · strategy: drenched · bg: color (deep oxblood/grape, hue ~350, L ~0.30)
palette: "candlelit cellar, stained glass of gamay" — ink warm bone on the drench, accent pale pét-nat gold (~85)
type: display Marcellus · body Jost
motion: subtle — slow wine-swirl radial highlight following cursor in hero
imagery: one decisive picsum(feral-cellar) dark-treated hero photo, nothing else
copy: sparse, cheeky — "wine that was alive once" energy; tonight's pours list, address, that's it

### 003 — monsoon — Monsoon, specialty tea house
tier: simple · strategy: restrained · bg: tinted (pale celadon-tinted white, hue ~170, chroma ≤0.02 — literal tea-room environment)
palette: "first flush darjeeling steaming in a porcelain gaiwan" — ink deep teal-green, accent oxidized copper (~50)
type: display Tenor Sans · body Hanken Grotesk
motion: subtle — canvas steam wisps rising from the hero cup illustration
imagery: generative porcelain cup SVG + one picsum(monsoon-leaf) tea field strip
copy: sparse, contemplative — three teas, steeping times, a single reservation link

### 004 — plainchant — Plainchant, monastery-brewed ale
tier: medium · strategy: committed · bg: pure-black (deep walnut-black, hue ~60, chroma ~0.005)
palette: "abbey cellar by candlelight — honey through dark glass" — primary honey gold (~80), ink warm off-white, accent wax-seal red (~25)
type: display Cinzel · body Bitter
motion: subtle — candle-flame flicker on the seal; slow fade-in verses between sections
imagery: picsum(plainchant-1..2) barrels + abbey stone
copy: medium, reverent with dry humor — the monks' brewing rules, three ales with tasting notes

## Batch 02 (pages 005–008)

### 005 — vermouth-hours — Vermouth Hours, aperitivo brand
tier: medium · strategy: full palette · bg: pure-white
palette: "Milan 6pm — orange slice against white tablecloth" — primary bitter orange (~50), accent deep alpine green (~155), third role aperitivo rose (~15) used sparingly
type: display Unbounded · body Archivo
motion: medium — long sundial shadow sweeps the hero as you scroll; bottle label rotates on hover
imagery: picsum(vermouth-1..2) spritz glasses + piazza
copy: medium, playful Italian cadence — the ritual of the hour, serve suggestions, stockists

### 006 — bite — BITE, smash-burger food truck
tier: simple · strategy: drenched · bg: color (ketchup red, hue ~25, L ~0.52, chroma ≤0.22)
palette: "diner napkin dispenser chrome + mustard squeeze bottle" — ink white, accents mustard (~95) and pickle green (~140) as sticker chips
type: display Bungee · body Hanken Grotesk
motion: strong — sticker-peel hover lifts, hero headline does a one-time sizzle-shake on load
imagery: picsum(bite-burger) hero shot in a chunky white border like a polaroid
copy: loud and short — menu of four burgers, truck location ticker, "cash card whatever"

### 007 — copper-kettle — Copper Kettle, ramen shop
tier: medium · strategy: committed · bg: pure-black
palette: "midnight counter seat, steam off tonkotsu" — primary broth amber (~75), ink warm off-white, accent nori green (~150)
type: display Rozha One · body Gabarito
motion: medium — canvas steam particles rise across the hero; noodles-pull line draw on the menu divider
imagery: picsum(ramen-1..2) bowl close-up + counter seats
copy: intimate, medium density — 18 seats, no reservations, the 14-hour broth, last-order time

### 008 — neapolitan — Neapolitan, gelato shop
tier: simple · strategy: full palette · bg: pure-white (pastels live in scoops/chips, not the surface)
palette: "three scoops on a marble slab" — pistachio (~140 pale), strawberry (~10 pale), dark stracciatella ink, accent waffle-cone tan (~70)
type: display Bagel Fat One · body Nunito
motion: medium — scoops drop into the cone hero with squash-and-settle (expo ease); flavor chips flip on hover
imagery: picsum(gelato-1) case of gelato tins
copy: sweet and short — today's 12 flavors, allergen honesty, "closed when we sell out"

## Batch 03 (pages 009–012)

### 009 — marigold — Marigold, modern Indian restaurant
tier: complex · strategy: drenched · bg: color (marigold, hue ~75, L ~0.62, chroma ≤0.20) alternating with deep aubergine (~330, L ~0.25) sections
palette: "marigold garlands against aubergine silk" — ink near-black on marigold, ivory on aubergine, accent raita-mint (~160)
type: display Yeseva One · body Hanken Grotesk
motion: strong — spice-swirl scroll reveals (rotating mask), menu courses cascade, garland SVG sways
imagery: picsum(marigold-1..3) thali, tandoor flames, dining room
copy: rich — chef's story, regional menu sections, private dining, reservation flow

### 010 — smoke-signal — Smoke Signal, Texas BBQ joint
tier: medium · strategy: committed · bg: pure-black (smoke-black) alternating with butcher-paper-white sections
palette: "post oak smoke at 4am, pink butcher paper" — primary ember orange (~40), ink off-white / near-black, accent pickle-jar green
type: display Alfa Slab One · body Bitter
motion: medium — smoke drift canvas over hero; "sold out" stamp slams in when scrolled to
imagery: picsum(bbq-1..2) brisket slice + pit fire
copy: drawl, medium — meat by the half-pound, "until it's gone", pitmaster hours, line etiquette

### 011 — ground-control — Ground Control, coffee subscription
tier: simple · strategy: restrained · bg: pure-white
palette: "mission-control checklist clipped to a portafilter" — ink espresso near-black, single signal-orange accent (~45) ≤10%
type: single family deliberate — Schibsted Grotesk in 3 weights
motion: subtle — roast-date marquee ticker; bean-path SVG dotted line draws on scroll
imagery: picsum(coffee-bag) product shot + generative orbit-line bean diagram
copy: crisp and short — two plans, roast-to-ship promise, skip-anytime honesty

### 012 — gold-leaf — Gold Leaf, artisan chocolatier
tier: medium · strategy: committed · bg: pure-black (cacao, hue ~40, L ~0.14, chroma ~0.02)
palette: "gold leaf pressed onto 85% dark" — primary gold (~85, L ~0.72), ink ivory, accent single-origin crimson (~20)
type: display Prata · body Jost
motion: medium — gold shimmer mask sweeps headings on scroll; truffle grid zooms softly on hover
imagery: picsum(choc-1..2) truffles macro + cacao pods
copy: luxurious, medium — single-origin story, the gilding process, gift-box configurator teaser

## Batch 04 (pages 013–016)

### 013 — hearthstone-bread — Hearthstone, sourdough bakery
tier: medium · strategy: committed · bg: pure-white (warmth carried by accents)
palette: "flour in morning light, crackled crust" — primary crust umber (~50 deep), ink near-black, accent wheat amber (~85)
type: display Bitter 800 · body Hanken Grotesk
motion: subtle — loaves "rise" (scale-y reveal) as sections enter; scoring-slash line draw
imagery: picsum(bread-1..2) crust macro + baker's hands
copy: homey, medium — the 36-hour loaf, bake schedule (Tue/Thu/Sat), wholesale accounts

### 014 — night-market — Night Market, street food festival
tier: complex · strategy: drenched · bg: color (festival night black, hue ~280, L ~0.12)
palette: "lantern light on wet pavement" — primary lantern red (~20), accent neon teal (~185), third role skewer gold (~90)
type: display Zen Dots · body Sora
motion: strong — lantern SVGs sway at different periods, vendor ticker marquee, map pins pop in sequence
imagery: picsum(nightmarket-1..3) stalls, skewers, crowd bokeh
copy: energetic, rich — 40 vendors, dates + hours, entertainment lineup, ticket tiers

### 015 — the-comma — The Comma, literary café
tier: simple · strategy: restrained · bg: pure-white
palette: "red pencil in the margin of a clean manuscript" — ink true near-black, single editor's-red accent (~25) ≤10%
type: single family deliberate — Source Serif 4 (roman + italic, 4 weights)
motion: subtle — blinking cursor after the hero sentence; underline draws on link hover
imagery: generative only — a typeset manuscript page as the hero visual
copy: sparse and witty — "pause here" concept, espresso + short fiction pairing, events night

### 016 — copper-and-ash — Copper & Ash, cocktail bar
tier: medium · strategy: committed · bg: pure-black (charcoal, chroma ~0.005)
palette: "copper still catching bar light" — primary copper (~55, L ~0.60), ink smoke off-white, accent smoked plum (~340)
type: display Bodoni Moda · body Hanken Grotesk
motion: medium — clip-path "pour" fills the hero glass shape; cocktail specs reveal like recipe cards
imagery: picsum(cocktail-1..2) dark cocktails + copper bar top
copy: suave, medium — house classics with one-line stories, reservations, the Tuesday amaro club

## Batch 05 (pages 017–020)

### 017 — lowlands — Lowlands, Scotch distillery
tier: complex · strategy: full palette · bg: pure-black (peat) with barley-gold and mist-gray alternating sections
palette: "warehouse No. 3 — cask ends disappearing into dark" — primary barley gold (~90), accent copper (~55), ink mist off-white, third role peat brown (~50 deep)
type: display Marcellus · body Literata
motion: medium — age-statement odometer counts up, layered mist drifts (translate, low opacity), cask horizontal scroll
imagery: picsum(scotch-1..3) stills, casks, highland glen
copy: rich storytelling — 200-year history timeline, core range with tasting notes, distillery tours booking

### 018 — halcyon-house — Halcyon House, boutique coastal hotel
tier: complex · strategy: committed · bg: pure-white
palette: "Aegean noon — white plaster, one blue" — primary deep Aegean blue (~250, L ~0.45), ink near-black, accent sun-bleached coral (~40) in small doses
type: display Italiana · body Hanken Grotesk
motion: medium — full-bleed hero parallax, room cards reveal with slow zoom-out, tide-table footer animates
imagery: picsum(hotel-1..4) sea-view terrace, room, pool, coast path — image-led, photos are the design
copy: serene editorial, medium — 12 rooms, seasonal restaurant, "do very little" positioning, booking CTA

### 019 — moonshine-motor — Moonshine Motor Court, roadhouse motel
tier: medium · strategy: drenched · bg: color (desert-night indigo, hue ~275, L ~0.18)
palette: "VACANCY neon over Route 66 asphalt" — primary neon red (~15) glow, accent dusty teal (~190), ink off-white
type: display Six Caps · body Cutive Mono (typewriter register — literal motel receipts)
motion: medium — neon flicker on the sign (irregular, not loop-perfect), pool-light shimmer
imagery: picsum(motel-1..2) desert road + neon sign dusk
copy: pulpy, medium — 14 rooms, the ice machine story, rates on a typewritten card, "cash discount"

### 020 — summit-oracle — Summit Oracle, ski resort
tier: complex · strategy: committed · bg: pure-white (alpine snow)
palette: "patrol jacket orange against whiteout" — primary glacier blue (~230), accent safety orange (~55), ink slate
type: display Archivo 900 · body Geologica
motion: strong — snow particle canvas, interactive trail-map with hover lift status, vertical-drop counter
imagery: picsum(ski-1..3) powder, chairlift, summit lodge
copy: crisp alpine, rich — 47 runs, snow report module, lift pass tiers, ski school, webcam teaser

## Batch 06 (pages 021–024)

### 021 — saltline — Saltline, cold-water surf school
tier: medium · strategy: committed · bg: pure-black (deep slate-teal, hue ~200, L ~0.16)
palette: "North Sea dawn — foam on dark water" — primary foam white, accent kelp green (~160), ink pale sea-glass
type: display Wix Madefor Display · body Hanken Grotesk
motion: medium — SVG wave path morphs between sections, wetsuit-dry drip animation on pricing
imagery: picsum(surf-1..2) cold-water lineup + hooded surfer
copy: salty encouragement, medium — 5/4mm provided, water temp honesty, lesson tiers, "you will stand up"

### 022 — terrapin — Terrapin, kayak outfitter
tier: medium · strategy: committed · bg: pure-white with river-green (~165 deep) alternating sections
palette: "cedar-strip hull on a green river" — primary river green, accent paddle yellow (~100), ink slate
type: display Fjalla One · body Gabarito
motion: medium — current-line SVG flows down the page margin tracking scroll; trip cards tilt slightly
imagery: picsum(kayak-1..2) river bend + loading boats
copy: outdoorsy, medium — guided trips by difficulty, rental fleet, river conditions widget, safety credo

### 023 — aurora-ice — Aurora Ice, Icelandic glacier tours
tier: complex (three.js) · strategy: drenched · bg: color (polar night, hue ~260, L ~0.10)
palette: "aurora over black sand" — primary aurora green (~160 glow), accent aurora violet (~300), ink ice white
type: display Unbounded · body Spline Sans
motion: strong — three.js hero: particle aurora ribbons + twinkling starfield reacting to cursor; ice-cave scroll transition
imagery: three.js sky + picsum(glacier-1..2) ice cave + black beach
copy: hushed awe, rich — three expeditions, aurora forecast honesty ("nature decides"), guides' credentials, packing list

### 024 — driftlab — Driftlab, arctic research expedition
tier: medium · strategy: restrained · bg: pure-white (ice)
palette: "telemetry printout pinned to an ice-core crate" — primary abyss navy (~255), accent data orange (~50) ≤10%, ink near-black
type: display Chivo Mono (literal expedition telemetry) · body Archivo
motion: medium — live-feel telemetry tickers (temp, wind, lat/long) updating, frost-border draws around cards
imagery: picsum(arctic-1..2) research station + ice core
copy: precise field-log voice, medium — expedition legs, the science program, join-the-crew application

## Batch 07 (pages 025–028)

### 025 — northmark — Northmark, hiking boots
tier: medium · strategy: committed · bg: pure-white
palette: "waxed leather against trail dust" — primary boot-leather brown (~55 deep), accent blaze orange (~50), ink near-black
type: display Archivo 800 · body Hanken Grotesk
motion: medium — boot-print step-in sequence across hero, resole-process before/after slider
imagery: picsum(boots-1..2) boot on rock + workshop resoling
copy: rugged, medium — one boot done right, the resole-for-life promise, sizing honesty, trail-tested log

### 026 — velvet-circuit — Velvet Circuit, synth-pop album launch
tier: complex · strategy: drenched · bg: color (ultraviolet, hue ~290, L ~0.16)
palette: "chrome bumper under neon at 2am" — primary chrome pink (~340), accent laser cyan (~195), ink pale lilac
type: display Monoton · body Sora
motion: strong — audio-reactive canvas equalizer hero (WebAudio from embedded oscillator, muted by default w/ consent toggle), CRT scanlines, tracklist hover-plays 8-bit previews
imagery: generative chrome + picsum(synth-1) stage lights
copy: fan-zine energy, rich — tracklist, the making-of story, vinyl variants, tour dates, mailing list

### 027 — nocturne-fm — Nocturne FM, late-night jazz radio
tier: medium · strategy: committed · bg: pure-black (midnight blue-black, hue ~260, chroma ~0.01)
palette: "brass bell of a tenor sax in a dark room" — primary brass gold (~85), accent smoky purple (~300 muted), ink warm off-white
type: display Bodoni Moda italic · body Literata
motion: subtle — vinyl rotates slowly, VU needle trembles, schedule crossfades
imagery: picsum(jazz-1..2) smoky club + sax detail
copy: velvet radio voice, medium — nightly programming grid, the host's sign-off, listen-live player mock, pledge drive

### 028 — semitone — Semitone, piano bar
tier: simple · strategy: committed · bg: pure-black (lacquer)
palette: "one red lamp over 88 keys" — ink ivory, single lamp-red accent (~20), key-gray midtone for rules
type: display Marcellus · body Jost
motion: subtle — pressed-key ripple emanates from cursor clicks; soft damper fade between sections
imagery: picsum(piano-1) keys macro, dark-treated
copy: intimate and sparse — sets at 9 and 11, no cover before 8, request policy, the regulars' wall

## Batch 08 (pages 029–032)

### 029 — small-hours — Small Hours, insomnia podcast
tier: simple · strategy: drenched · bg: color (3am indigo, hue ~270, L ~0.16)
palette: "ceiling at 3:47am, one streetlight through blinds" — ink pale moon, accent dim amber (~80) like a night-light
type: display Literata italic · body Hanken Grotesk
motion: subtle — breathing glow behind the play button (6s cycle); episodes drift in slowly
imagery: generative moon + blind-slatted light bars SVG
copy: hushed, sparse — "for the awake", episode list with one-line descriptions, where to listen

### 030 — cold-open — Cold Open, podcast network
tier: medium · strategy: full palette · bg: pure-white
palette: "three shows, three mic flags" — show-red (~15), show-teal (~180), show-mustard (~90) on white with near-black ink
type: display Archivo 900 · body Hanken Grotesk
motion: medium — hover any show card: its waveform animates and card fills with its color; network ticker
imagery: generative waveforms + picsum(mic-1) studio mic
copy: punchy, medium — three flagship shows with premises, cadence honesty, ad-rate card teaser, careers

### 031 — vanishing-point — Vanishing Point, photography magazine
tier: complex · strategy: restrained · bg: pure-white
palette: "gallery wall, one red dot sold sticker" — true black ink, single vermilion accent (~25) ≤5%, paper gray for captions (contrast-checked)
type: display Anton · body Source Serif 4 (literal magazine — editorial lane justified by brief)
motion: medium — full-bleed photo essay with horizontal-scroll section, images sharpen from blur as they enter
imagery: picsum(vp-1..5) treated B&W via CSS filter — photo-led design
copy: long-form rich — feature story excerpt, contributor bios, print issue specs, subscription, stockists map

### 032 — half-light — Half Light, film photography lab
tier: simple · strategy: committed · bg: pure-black (darkroom) with one paper-white pricing section
palette: "safelight amber over developing trays" — primary safelight amber (~70), ink off-white, accent paper white
type: display Cutive Mono · body Hanken Grotesk
motion: subtle — hero image develops: blur + sepia → sharp full color over 3s on load
imagery: picsum(film-1) grainy analog shot (CSS grain overlay)
copy: nerdy-warm, sparse — develop + scan prices by format, turnaround promise, "we push, we pull, we don't judge"

## Batch 09 (pages 033–036)

### 033 — tintype — Tintype, wedding photography
tier: medium · strategy: restrained · bg: pure-white
palette: "linen album, one gold foil initial" — ink soft charcoal, aged-gold hairline accents (~80), gallery-gray only for captions ≥4.5:1
type: display Prata · body Jost
motion: subtle — gentle parallax on portraits, lightbox with crossfade, no entrance spam
imagery: picsum(wed-1..4) ceremony, portrait, detail, dance — image-led
copy: tender, medium — the unposed philosophy, three collections with honest pricing, availability checker teaser

### 034 — prism-break — Prism Break, indie animation studio
tier: complex (three.js) · strategy: full palette · bg: pure-black (ink navy, hue ~250, L ~0.14)
palette: "cel on a lightbox — pink registration marks" — primary cel pink (~340), accent acetate cyan (~200), ink paper white, third role pencil yellow
type: display Unbounded · body Gabarito
motion: strong — three.js cel-shaded mascot head rotating in hero, frame-by-frame walk-cycle strip on scroll, showreel hover-scrub
imagery: generative cels + picsum(anim-1) studio
copy: playful-studio, rich — three productions, the 12-principles credo, jobs board, festival laurels

### 035 — static-bloom — Static Bloom, generative art collective
tier: complex (three.js) · strategy: drenched · bg: pure-black
palette: "phosphor bloom on a dead channel" — primary algorithmic green (~150 glow), accent signal magenta (~330), ink terminal white
type: display Chivo Mono · body Spline Sans
motion: strong — three.js full-hero bloom field (thousands of points pulsing to a slow LFO, reacting to cursor); works grid regenerates pattern on hover
imagery: generative only — every visual is code
copy: manifesto, medium — the collective's rules, exhibited works with edition numbers, print shop, newsletter

### 036 — typecase — Typecase, indie type foundry
tier: complex · strategy: committed · bg: pure-white (paper)
palette: "specimen sheet fresh off the proof press" — ink true black, single process-blue accent (~245), gray scales from the ink
type: display Zilla Slab 700 · body Hanken Grotesk
motion: strong — hero word with user-draggable variable-weight slider, glyph grid fills on scroll, waterfall sizes animate
imagery: generative type specimens only (the fonts are the imagery)
copy: specimen voice, rich — three families with design stories, trial downloads, licensing table, custom work

## Batch 10 (pages 037–040)

### 037 — tidal-press — Tidal Press, letterpress studio
tier: medium · strategy: committed · bg: pure-white
palette: "deep impression of blue ink in cotton paper" — primary impression blue (~255 deep), ink near-black, accent deboss gray
type: display Libre Caslon Text · body Hanken Grotesk
motion: subtle — headings press into the page (inset shadow deepen) on scroll; plate registration marks align
imagery: picsum(letterpress-1..2) press + type cases
copy: craft voice, medium — wedding suites, business cards "worth keeping", the 600dpi promise, quote process

### 038 — folkloric — Folkloric, weaving & textile studio
tier: medium · strategy: full palette · bg: tinted (undyed wool white, chroma ≤0.015 — literal fiber environment)
palette: "madder, indigo and weld drying on a line" — madder red (~30 deep), indigo (~265), weld yellow (~100), ink charcoal
type: display Zilla Slab · body Literata
motion: medium — warp threads draw vertically then weft horizontally as sections enter (weave reveal); swatch hover zooms
imagery: picsum(weave-1..2) loom + dyed yarn
copy: warm artisan, medium — workshop calendar, commission process, the natural-dye library, stockists

### 039 — kiln-and-co — Kiln & Co, ceramics studio
tier: medium · strategy: committed · bg: tinted (clay-dust white, hue ~50, chroma ≤0.02 — literal studio)
palette: "terracotta bisque waiting for celadon" — primary terracotta (~45), accent glaze celadon (~165 pale), ink umber
type: display Bitter · body Gabarito
motion: subtle — studio logo mark rotates at wheel speed; pieces center themselves with a settle ease
imagery: picsum(ceramics-1..2) wheel throwing + shelf of cups
copy: tactile, medium — membership vs classes, the community kiln, seconds sale honesty, glaze glossary teaser

### 040 — brass-and-bone — Brass & Bone, antique restoration
tier: medium · strategy: committed · bg: color (lacquered cabinet green, hue ~160, L ~0.22 — literal workshop interior)
palette: "brass hardware on a green-lacquered cabinet" — primary brass (~85), ink ivory, accent oxblood leather (~20 deep)
type: display Cinzel · body Bitter
motion: subtle — before/after restoration slider; patina crossfade on hover
imagery: picsum(antique-1..2) workshop bench + restored cabinet
copy: provenance voice, medium — what they take on, the assessment visit, conservation vs restoration honesty

## Batch 11 (pages 041–044)

### 041 — second-empire — Second Empire, vintage furniture
tier: medium · strategy: restrained · bg: pure-white
palette: "auction-house catalog — walnut and brass" — ink walnut near-black, brass accent (~80) ≤10%, museum gray for metadata
type: display Marcellus · body Hanken Grotesk
motion: subtle — catalog cards flip to reveal provenance; measurement overlay on hover
imagery: picsum(furniture-1..3) chairs, credenza, lamp
copy: dealer voice, medium — this week's acquisitions, condition honesty scale, delivery + stairs policy

### 042 — cardinal-press — Cardinal Press, poetry small-press
tier: simple · strategy: restrained · bg: pure-white
palette: "one red bird on white paper" — ink near-black, cardinal red accent (~20) ≤8%
type: single family deliberate — Source Serif 4
motion: subtle — stanzas reveal line by line; a red cardinal mark hops down the margin on scroll
imagery: generative only — typographic chapbook covers built in CSS
copy: sparse lyrical — three chapbooks with a poem excerpt each, submissions window, "we answer everyone"

### 043 — the-marionette — The Marionette, puppet theater
tier: complex · strategy: drenched · bg: color (stage velvet crimson, hue ~355, L ~0.24)
palette: "footlights on velvet, gold braid" — primary gold (~85), ink ivory, accent shadow black for depth layers
type: display Rozha One · body Literata
motion: strong — curtain-opens page load (two panels part), marionette hero dangles with pendulum physics on strings, show posters fly in
imagery: picsum(puppet-1..2) stage + puppets
copy: whimsical-dramatic, rich — current production, 80-year theater history, workshop Saturdays, school matinees, box office

### 044 — moss-and-mortar — Moss & Mortar, terrarium shop
tier: simple · strategy: committed · bg: pure-white
palette: "moss under glass, morning condensation" — primary deep moss (~150), accent glass blue (~220 pale), ink slate
type: display Gabarito 700 · body Hanken Grotesk
motion: subtle — jars fog in then clear as you scroll; a snail progress indicator creeps along the page edge
imagery: picsum(terrarium-1..2) jar worlds
copy: gentle, sparse — three sizes, "kill-proof promise", care card philosophy, repotting bar Saturdays

## Batch 12 (pages 045–048)

### 045 — night-blooming — Night Blooming, botanical garden night events
tier: medium · strategy: drenched · bg: color (midnight garden, hue ~230, L ~0.14)
palette: "moonflower opening under bioluminescence" — primary biolume teal (~175 glow), ink moon-flower white, accent night violet (~290)
type: display Bodoni Moda · body Jost
motion: strong — firefly particle field drifts across hero, flowers open (clip-path bloom) as sections enter
imagery: picsum(nightgarden-1..2) moonlit paths + greenhouse
copy: enchanted, medium — the five night-bloom species, event calendar, quiet-rules etiquette, membership

### 046 — pollen — Pollen, urban beekeeping honey
tier: simple · strategy: full palette · bg: pure-white
palette: "rooftop hive against a gray skyline" — hive amber (~80), ink charcoal, accent clover green (~145)
type: display Shrikhand · body Nunito
motion: medium — a bee traces a dotted flight path around the hero jar; neighborhood flavor map zooms
imagery: picsum(honey-1) comb macro + picsum(rooftop-1) rooftop hives
copy: sunny, sparse — three neighborhoods three flavors, adopt-a-hive, "500 bees per jar" honesty

### 047 — inkwell-society — Inkwell Society, fountain pen shop
tier: medium · strategy: committed · bg: pure-white
palette: "iron-gall ink drying on cream-laid paper" — primary blue-black ink (~260 deep), accent oxblood (~15), ink slate
type: display Libre Caslon Text italic · body Hanken Grotesk
motion: subtle — ink-line draws under headings; nib hover shows writing sample crossfade
imagery: picsum(pen-1..2) nib macro + desk scene
copy: epistolary, medium — beginner pen guidance without snobbery, ink library by color, repair service, letter-writing Sundays

### 048 — paper-planes — Paper Planes, stationery subscription
tier: simple · strategy: full palette · bg: pure-white
palette: "three sheets of colored stock fanned out" — sky (~230), coral (~35), leaf (~150) chips on white, ink slate
type: display Fredoka · body Gabarito
motion: medium — paper plane follows cursor with delayed swoop; box contents fan out on hover
imagery: generative folded-paper shapes + picsum(stationery-1)
copy: cheerful, sparse — what's in the monthly box, skip anytime, the paper-nerd sourcing story

## Batch 13 (pages 049–052)

### 049 — little-obelisk — Little Obelisk, children's bookstore
tier: simple · strategy: full palette · bg: pure-white
palette: "storybook primaries on library paste" — story red (~25), story blue (~250), sun yellow (~100) on white, ink near-black
type: display Cherry Bomb One · body Nunito
motion: medium — pop-up-book hero folds open on load; shelf books lean when hovered
imagery: picsum(kidsbooks-1..2) reading corner + picture books
copy: joyful, sparse — storytime Saturdays, staff picks by age, "yes, touch the books"

### 050 — paper-run — Paper Run, independent newspaper
tier: medium · strategy: restrained · bg: tinted (newsprint off-white, chroma ≤0.01 — literal paper)
palette: "above the fold, ink still tacky" — ink true black, stamp red accent (~25) ≤8%, column grays from ink
type: display Ultra · body Literata (literal newspaper — justified lane)
motion: subtle — printing-press roll marquee of headlines; dateline types itself
imagery: picsum(newsroom-1..2) B&W-treated press + newsroom
copy: front-page voice, medium — this week's cover story, masthead, print route map, subscribe vs single-copy honesty

### 051 — brightstack — Brightstack, dev analytics SaaS
tier: complex · strategy: committed · bg: pure-black (ink navy, hue ~250, L ~0.13)
palette: "phosphor dashboard in a dark ops room" — primary phosphor green (~155), accent amber alert (~85) used with restraint, ink off-white
type: display Archivo 800 · body Chivo Mono accents + Archivo body
motion: strong — live-animating dashboard mock (sparklines draw, deploy events tick in), terminal typing loop, scroll-synced feature chapters
imagery: generative product UI (CSS-built dashboard, graphs) — no stock
copy: precise dev voice, rich — pipeline observability story, three features with real-feeling metrics, pricing tiers, docs teaser, SOC2 line

### 052 — gramercy-ai — Gramercy, AI writing tool
tier: complex · strategy: restrained · bg: pure-white
palette: "manuscript with one coral editor's mark" — ink deep slate, single coral accent (~30) ≤10%, annotation grays
type: display Source Serif 4 · body Hanken Grotesk
motion: medium — hero types a sentence, then AI edits appear as tracked-changes diff highlights; tone slider rewrites a paragraph live
imagery: generative editor UI mock
copy: thoughtful, long — the "editor not ghostwriter" positioning, three use cases with before/after, privacy stance, pricing, FAQ

## Batch 14 (pages 053–056)

### 053 — circuit-breaker — Circuit Breaker, cybersecurity firm
tier: medium · strategy: committed · bg: pure-black
palette: "server-room LED in a dark rack aisle" — primary signal red (~25), accent terminal green (~150) for "secure" states only, ink off-white
type: display Chivo Mono · body Archivo
motion: strong — threat-map canvas with pulsing intrusion arcs being severed; stats count up; redacted text reveals on hover
imagery: generative network map + picsum(server-1) rack aisle dark
copy: serious, medium — incident response promise ("on-site in 24h"), the three practice areas, breach-cost honesty, client logos as text

### 054 — wayfind — Wayfind, offline maps app
tier: complex · strategy: committed · bg: tinted (topo-paper white, hue ~70, chroma ≤0.015 — literal map paper)
palette: "ordnance survey sheet — contour brown, trail orange" — primary trail orange (~55), accent contour brown (~60 deep), ink slate; contour-line backgrounds justified (literal map)
type: display Archivo 800 · body Gabarito
motion: strong — SVG route draws itself across a topographic hero, elevation profile fills beneath it, download-size counter
imagery: generative topo map + picsum(trail-1..2)
copy: adventurous, rich — the dead-zone story, map packs by region, battery math honesty, rescue-beacon integration, pricing

### 055 — hush — Hush, sleep app
tier: simple · strategy: drenched · bg: color (dusk-to-night violet-blue, hue ~280, L ~0.20)
palette: "the sky 40 minutes after sunset" — ink pale moon, accent dim sleep-amber (~80), no hard edges anywhere
type: single family deliberate — Jost light through medium
motion: subtle — breathing orb expands/contracts on a 6-second cycle; content fades are long and slow
imagery: generative dusk gradient + moon phases SVG
copy: whisper register, sparse — three soundscapes, the no-streaks philosophy ("sleep isn't a game"), tonight's session

### 056 — sonder — Sonder, travel journal app
tier: medium · strategy: full palette · bg: pure-white
palette: "passport stamps from three trips" — passport navy (~250), stamp red (~20), stamp teal (~185) on white, ink near-black
type: display Sora · body Hanken Grotesk
motion: medium — entries stamp in with an ink-pad press effect; map pins drop along a drawn route
imagery: picsum(travel-1..3) + generative stamp marks
copy: nostalgic, medium — the "everyone is the main character" concept, offline-first honesty, sample journal walkthrough, pricing

## Batch 15 (pages 057–060)

### 057 — wild-type — Wild Type, biotech startup
tier: complex (three.js) · strategy: restrained · bg: pure-white (lab)
palette: "agar plate under a hood light" — primary helix teal (~180), accent agar coral (~35) ≤10%, ink near-black
type: display Sora · body Hanken Grotesk
motion: strong — three.js rotating DNA helix hero (points + connecting rungs), pipeline diagram draws stage by stage
imagery: three.js + picsum(lab-1) hood/pipette
copy: rigorous, rich — platform science explainer, pipeline table, publication links as text, team credentials, careers, no hype adjectives

### 058 — quorum — Quorum, civic engagement platform
tier: medium · strategy: restrained · bg: pure-white
palette: "ballot box and a sharpened pencil" — primary ballot blue (~245), accent seal red (~25) ≤8%, ink near-black
type: display Source Serif 4 · body Hanken Grotesk
motion: subtle — checkmark tallies animate; meeting agenda expands like minutes being taken
imagery: generative UI + picsum(townhall-1)
copy: plain-spoken civic, medium — how a motion becomes a decision, three towns using it (real-feeling numbers), open-data promise, pricing by population

### 059 — bright-verb — Bright Verb, language school
tier: simple · strategy: full palette · bg: pure-white
palette: "flashcards fanned on a desk" — verb red (~25), audio blue (~240), highlight yellow (~100) chips on white, ink slate
type: display Gabarito 800 · body Hanken Grotesk
motion: medium — word cards flip between languages on hover; pronunciation waveform pulses
imagery: generative flashcards + picsum(classroom-1)
copy: encouraging, sparse — five languages, the speak-from-day-one method, level quiz teaser, pricing per month

### 060 — the-forge — The Forge, coding bootcamp
tier: complex · strategy: committed · bg: pure-black (forge)
palette: "molten steel meeting the anvil" — primary molten orange (~45), accent steel gray-blue (~230 muted), ink off-white
type: display Archivo 900 · body Spline Sans
motion: strong — spark particles burst on load, curriculum timeline hammers in section by section, salary counter with honest median
imagery: picsum(coding-1..2) students pairing + generative terminal
copy: grit voice, rich — 16-week syllabus breakdown, the no-experience-required truth, hiring partners, tuition + ISA honesty, outcomes report link

## Batch 16 (pages 061–064)

### 061 — vaporware — Vaporware, retro-futurist game console
tier: complex (three.js) · strategy: drenched · bg: color (VHS black-purple, hue ~300, L ~0.10)
palette: "rental-store carpet under a CRT glow" — primary VHS magenta (~330), accent laser cyan (~190), ink phosphor white; synthwave justified — literal retro console
type: display Zen Dots · body Sono
motion: strong — three.js rotating console hero with laser-grid floor, scanline overlay, cartridge insert animation on click
imagery: three.js product + generative cartridge art
copy: deadpan hype, rich — fake-technical spec sheet with a wink, launch titles, the "it never shipped" backstory, pre-order theater

### 062 — kernel — Kernel, indie game studio
tier: complex (three.js) · strategy: drenched · bg: pure-black (void)
palette: "save-point glow in a dark level" — primary save-point green (~150), accent pixel white, third role damage red (~25) for UI hits
type: display Silkscreen · body Sono
motion: strong — three.js low-poly diorama (floating island, slow orbit), pixel-dissolve transitions between games
imagery: three.js + generative pixel art screenshots
copy: devlog voice, rich — two shipped games with postmortems, the three-person team, open playtest signups, press kit

### 063 — voltage — Voltage, esports team
tier: complex (three.js) · strategy: drenched · bg: pure-black (blackout)
palette: "arena lights before the match starts" — primary electric yellow (~105), accent ozone blue (~250), ink white
type: display Archivo 900 italic · body Sono
motion: strong — three.js lightning arcs crackle across hero, roster cards tilt in 3D, match ticker scrolls results
imagery: three.js + picsum(esports-1) arena crowd
copy: aggressive, rich — five-player roster with roles, season record, the bootcamp grind story, merch drop, watch-parties

### 064 — cassette — Cassette, 80s arcade bar
tier: medium · strategy: drenched · bg: pure-black (arcade)
palette: "token gold and neon pink on sticky carpet" — primary neon pink (~335), accent token gold (~90), ink phosphor green-white
type: display Monoton · body VT323 accents (literal CRT register)
motion: strong — CRT boot sequence on load (power-line flash → raster fill), high-score table updates, joystick glow pulse
imagery: picsum(arcade-1..2) cabinets + neon
copy: rad without irony, medium — 30 working cabinets, token prices, the broken-joystick honesty board, tournament Tuesdays

## Batch 17 (pages 065–068)

### 065 — raptor — Raptor, drone cinematography
tier: complex (three.js) · strategy: committed · bg: pure-white (sky-pale) with carbon-black sections
palette: "carbon props against a pale sky" — primary carbon black, accent record red (~25), ink near-black, sky pale sections
type: display Archivo 800 · body Gabarito
motion: strong — three.js orbitable drone model hero, showreel timeline scrubs on scroll, altitude counter
imagery: three.js + picsum(aerial-1..2) aerial coast + city
copy: cinematic, rich — three showreels by sector (film, sport, survey), the licensed-and-insured credibility block, equipment list, day rates, booking

### 066 — apex-dynamics — Apex Dynamics, electric hyperbike
tier: complex · strategy: committed · bg: pure-black (stealth gray, hue ~240, L ~0.14)
palette: "volt lime stitching on carbon leather" — primary volt lime (~130), accent titanium gray, ink off-white
type: display Archivo 900 · body Spline Sans
motion: strong — speed lines streak past hero on load, torque curve draws on scroll, 0–100 counter with physics ease
imagery: picsum(ebike-1..2) bike studio shots dark-treated + generative spec diagrams
copy: engineering-braggadocio, rich — motor/battery/chassis chapters, range honesty table, the test-ride locator, deposit flow

### 067 — motor-pool — Motor Pool, vintage motorcycle garage
tier: medium · strategy: committed · bg: pure-black (asphalt) with off-white sections
palette: "signal orange on oily concrete" — primary signal orange (~50), accent chrome gray, ink off-white / near-black
type: display Staatliches · body Cutive Mono
motion: medium — odometer miles roll up on scroll; engine-turn swirl texture rotates slowly behind logo
imagery: picsum(moto-1..2) garage + restored tank
copy: grease-under-nails, medium — current restorations with honest condition reports, service menu, the "we don't do choppers" line, parts sourcing

### 068 — alloy — Alloy, custom bicycle frames
tier: medium · strategy: restrained · bg: pure-white
palette: "raw titanium with brass brazing" — ink titanium gray-dark, accent brazed brass (~80) ≤10%
type: display Geologica · body Hanken Grotesk
motion: subtle — frame geometry lines draw and dimension labels tick in; paint-fade hover on gallery
imagery: picsum(frame-1..2) brazing closeup + built bike
copy: builder voice, medium — the fitting process, steel vs ti honesty, 14-week waitlist transparency, three builds with owner stories

## Batch 18 (pages 069–072)

### 069 — sprocket — Sprocket, bike repair co-op
tier: simple · strategy: committed · bg: pure-white with chain-grease black sections
palette: "safety yellow tag on a repaired bike" — primary safety yellow (~105), ink near-black, accent chain gray
type: display Archivo 800 · body Gabarito
motion: subtle — chain-link marquee along section breaks; stand queue updates
imagery: picsum(bikeshop-1) workstand scene
copy: community voice, sparse — fix-it-yourself nights, membership vs walk-in pricing, the no-judgment policy, volunteer board

### 070 — ironroot — Ironroot, powerlifting gym
tier: medium · strategy: drenched · bg: pure-black (iron)
palette: "chalk dust over a loaded bar" — primary blood-plate red (~25), ink chalk white, accent iron gray
type: display Anton · body Archivo
motion: strong — barbell bends under animated plate loading in hero, lift PRs count up, chalk-poof burst on CTA click
imagery: picsum(lift-1..2) deadlift + plates
copy: terse and intense, medium — three lifts one philosophy, coaching tiers, the no-mirrors-no-machines stance, competition calendar

### 071 — pulse — Pulse, boxing gym
tier: medium · strategy: committed · bg: pure-black (ring-navy, hue ~250, L ~0.16) with canvas-white sections
palette: "red gloves on navy canvas" — primary glove red (~25), accent rope white, ink off-white / near-black
type: display Alfa Slab One · body Archivo
motion: strong — speed-bag rhythm pulse behind hero headline (3-2 combo timing), round-timer countdown, combo badges animate
imagery: picsum(boxing-1..2) heavy bag + ring corner
copy: corner-man voice, medium — fundamentals-first program, fight-team vs fitness tracks, first-class-free honesty, coach bios

### 072 — quickstep — Quickstep, swing dance school
tier: simple · strategy: full palette · bg: pure-white
palette: "brass section and teal taffeta" — ballroom teal (~185), brass gold (~85), ink charcoal, ivory accents
type: display Shrikhand · body Jost
motion: medium — footprint step-diagram animates the basic step across the floor; partner cards rotate in
imagery: picsum(swing-1) dancers mid-aerial
copy: jaunty, sparse — six-week series, no-partner-needed promise, social dance Fridays, what-to-shoes guidance

## Batch 19 (pages 073–076)

### 073 — field-dress — Field Dress, hunting & outdoor apparel
tier: medium · strategy: committed · bg: pure-white
palette: "blaze orange over olive drab" — primary field olive (~120 deep), accent blaze orange (~55), ink near-black
type: display Staatliches · body Hanken Grotesk
motion: subtle — fabric swatch texture zoom on hover; layer-system diagram builds up garment by garment
imagery: picsum(hunting-1..2) field + fabric macro
copy: no-nonsense, medium — the layering system, silent-fabric tech explained plainly, lifetime repair policy, size-honesty chart

### 074 — wolf-pack — Wolf Pack, trail running race
tier: medium · strategy: committed · bg: pure-black (night trail) with mountain-blue sections
palette: "headlamp beam cutting the dark" — primary headlamp amber (~85), accent mountain blue (~235), ink off-white
type: display Archivo 900 · body Geologica
motion: strong — elevation profile draws as you scroll with a runner dot climbing it, cutoff-time countdown, lantern-lit course markers fade in
imagery: picsum(trailrun-1..2) ridge runner + night start
copy: howling, medium — three distances with honest DNF rates, mandatory kit list, aid-station menu, the finish-line soup story

### 075 — undercurrent — Undercurrent, scuba diving center
tier: complex (three.js) · strategy: drenched · bg: color (deep ocean gradient, hue ~225, L ~0.12 → 0.25)
palette: "30 meters down — light going blue-green" — primary biolume cyan (~195), accent coral (~35) for highlights, ink foam white
type: display Jost 300 · body Hanken Grotesk
motion: strong — three.js underwater scene (rising bubbles, light rays, drifting particles) reacting to scroll depth; depth gauge fills
imagery: three.js + picsum(reef-1..2) reef + turtle
copy: immersive, rich — certification path, five dive sites with honest difficulty, the safety record block, equipment rental, boat schedule

### 076 — slow-orbit — Slow Orbit, space tourism
tier: complex (three.js) · strategy: drenched · bg: pure-black (void)
palette: "earthglow on a visor" — primary earthglow blue (~235), accent suit white, ink starlight, third role sunrise gold for the CTA only
type: display Unbounded · body Spline Sans
motion: strong — three.js earth with city-lights terminator and starfield, parallax scroll stages (launch → apogee → overview), oxygen-calm pacing
imagery: three.js hero + picsum(space-1) aurora from orbit
copy: transcendent, rich — the 6-hour flight profile, the overview-effect story, training week walkthrough, medical honesty, manifest pricing

## Batch 20 (pages 077–080)

### 077 — apogee — Apogee, rocket launch startup
tier: complex (three.js) · strategy: committed · bg: pure-white
palette: "graphite scorch on a white fairing" — primary flame orange (~45), accent graphite, ink near-black; SpaceX-grade restraint
type: display Archivo 900 · body Spline Sans
motion: strong — three.js rocket ascends tied to scroll (stage separation at section break), launch countdown ticks, telemetry sidebar updates
imagery: three.js + picsum(launch-1) pad at dawn
copy: countdown voice, rich — vehicle specs, three missions flown with anomaly honesty, payload pricing per kg, careers in propulsion, launch manifest

### 078 — the-observatory — The Observatory, stargazing retreat
tier: complex (three.js) · strategy: drenched · bg: pure-black (night sky, hue ~260, L ~0.08)
palette: "milky way over a cabin window" — primary milky-way silver, accent cabin amber (~80), ink starlight white
type: display Marcellus · body Jost
motion: strong — three.js starfield with depth parallax and occasional meteors; constellations connect as sections enter
imagery: three.js sky + picsum(cabin-1..2) cabin + telescope
copy: quiet cosmic, rich — three cabins, the dark-sky certification story, moon-phase booking calendar, what-to-bring honesty, winter rates

### 079 — orbit-anchor — Orbit & Anchor, sailing school
tier: medium · strategy: committed · bg: pure-white with regatta-navy sections
palette: "spinnaker red against deep water" — primary regatta navy (~250), accent spinnaker red (~20), ink near-black / off-white
type: display Italiana · body Hanken Grotesk
motion: medium — wind compass rotates to course headings; knot-tying steps animate as looping SVG
imagery: picsum(sailing-1..2) heeling boat + helm
copy: salty, medium — certification ladder, the capsize-drill honesty, fleet list, crew-match board, season pass

### 080 — helmsman — Helmsman, yacht charter
tier: complex · strategy: restrained · bg: pure-white
palette: "navy blazer, gold buttons, white deck" — primary deep navy (~255), accent champagne gold hairlines (~85), ink near-black
type: display Bodoni Moda · body Jost
motion: medium — fleet scrolls horizontally with wake trails drawing behind; itinerary map animates port to port
imagery: picsum(yacht-1..4) deck, bow, cove, dining — image-led
copy: concierge voice, rich — four yachts with honest capacity, sample week itineraries, crew profiles, provisioning menu, inquiry flow

## Batch 21 (pages 081–084)

### 081 — chroma-drift — Chroma Drift, 3D printing studio
tier: complex (three.js) · strategy: full palette · bg: pure-white with printer-gray sections
palette: "filament spools on a steel shelf" — filament coral (~35), accent process cyan (~210), ink graphite
type: display Geologica · body Spline Sans
motion: strong — three.js model builds layer by layer in hero (sliced geometry rising), print-time estimator ticks, material chips switch colors live
imagery: three.js + picsum(print-1) printer mid-job
copy: maker voice, rich — materials library with honest strength notes, upload-quote flow, the "we failed this print" gallery, turnaround tiers, education nights

### 082 — floodline — Floodline, climate data nonprofit
tier: complex · strategy: committed · bg: pure-white
palette: "flood gauge markings on a white wall" — primary flood blue (~230), accent warning amber (~85), ink near-black; serious data register
type: display Archivo 800 · body Hanken Grotesk
motion: strong — animated tide chart fills to 2050 projection, counters for displaced-people stats, map pins cluster by region
imagery: generative charts + picsum(flood-1..2) flooded street + gauge
copy: urgent and factual, rich — the data methodology, three active programs with budgets, annual-report honesty, donate flow with allocation breakdown, volunteer

### 083 — little-mercies — Little Mercies, animal shelter
tier: medium · strategy: full palette · bg: pure-white
palette: "collar tags on a corkboard" — collar red (~25), paw teal (~180), sunny yellow (~100) chips, ink slate
type: display Fredoka · body Hanken Grotesk
motion: medium — tail-wag hover on animal cards; adoption counter ticks; "foster fail" badge stamps
imagery: picsum(shelter-1..3) dogs + cats
copy: heartfelt, medium — this week's residents with honest bios ("barks at skateboards"), the adoption process, foster program, donation transparency

### 084 — field-notes-ag — Field Notes, regenerative farm CSA
tier: medium · strategy: committed · bg: pure-white
palette: "soil profile cross-section" — primary leaf green (~145), accent soil umber (~55 deep), sky (~230) for weather notes, ink near-black
type: display Bitter · body Hanken Grotesk
motion: subtle — season wheel rotates to current month; harvest rows sprout in sequence
imagery: picsum(farm-1..2) rows + hands with soil
copy: grounded, medium — what's in the box this month, the soil-first philosophy, pickup vs delivery, work-share honesty, farm-visit days

## Batch 22 (pages 085–088)

### 085 — opaline — Opaline, perfume house
tier: medium · strategy: drenched · bg: color (opal pale-violet, hue ~300, L ~0.88, chroma ≤0.03)
palette: "opalescent glass catching window light" — ink deep fig (~330 deep), primary fig-ink for text blocks, accent smoked gold (~80)
type: display Italiana · body Jost
motion: subtle — mist spray reveals the bottle (mask dissolve); notes pyramid builds scent by scent
imagery: picsum(perfume-1..2) bottle macro + raw ingredients
copy: olfactory poetry, medium — three fragrances with note pyramids, the nose's biography, sample-set-first philosophy, refill program

### 086 — petrichor — Petrichor, rain-scent candle brand
tier: simple · strategy: drenched · bg: color (storm gray-blue, hue ~235, L ~0.30)
palette: "wet asphalt under a streetlamp" — ink pale silver, primary wick amber glow (~80), accent rain-glass blue
type: display Literata italic · body Hanken Grotesk
motion: subtle — rain-streak canvas trails down the hero; flame flickers with a gentle sway
imagery: generative rain + picsum(candle-1) lit candle dark-treated
copy: sensory, sparse — one scent done obsessively, the geosmin story, burn-time honesty, subscription pause-anytime

### 087 — ledger-black — Ledger & Black, accounting firm
tier: medium · strategy: restrained · bg: pure-white
palette: "green ledger cloth, red pencil" — primary ledger green (~155 deep), ink true black, accent pencil red (~25) for corrections ≤5%
type: display Source Serif 4 · body Hanken Grotesk
motion: subtle — columns of figures align and balance; tick marks appear beside verified claims
imagery: generative ledger table + picsum(office-1) desk
copy: dry and trustworthy, medium — three practices (tax, audit, advisory), the "we answer in one business day" SLA, partner bios, fee transparency

### 088 — blueprint-bellow — Blueprint & Bellow, blacksmith workshops
tier: medium · strategy: drenched · bg: pure-black (forge coal)
palette: "steel at critical temperature" — primary ember orange (~40), accent steel gray-blue, ink off-white
type: display Alfa Slab One · body Bitter
motion: strong — hammer-strike spark burst on load, blade grinds across a divider line, quench steam rises on section change
imagery: picsum(forge-1..2) anvil strike + tongs
copy: grizzled, medium — weekend workshop curriculum, the burn-and-blister honesty waiver, what you make and keep, gift vouchers

## Batch 23 (pages 089–092)

### 089 — fresco — Fresco, lime paint & plaster maker
tier: medium · strategy: committed · bg: tinted (fresh plaster white, hue ~60, chroma ≤0.015 — literal material)
palette: "wet lime plaster with ochre pigment stirred in" — primary ochre (~75), accent fresco blue (~245 muted), ink umber
type: display Libre Caslon Text · body Gabarito
motion: subtle — trowel strokes texture-sweep section backgrounds; pigment dots disperse into water
imagery: picsum(plaster-1..2) textured walls + pigment jars
copy: artisan-technical, medium — the 12-color mineral palette, breathability science in plain words, applicator directory, sample pot program

### 090 — studio-verte — Studio Verte, landscape architecture
tier: medium · strategy: committed · bg: pure-white
palette: "boxwood parterre on drafting paper" — primary hedge green (~150 deep), accent gravel gray, ink near-black
type: display Geologica · body Literata
motion: medium — plan-to-photo crossfade slider on each project; planting zones fill with color season by season
imagery: picsum(garden-1..3) projects — image-led
copy: precise, medium — three built projects with planting lists, the five-year maturity honesty, process from survey to planting, client fit

### 091 — atlas-thread — Atlas & Thread, bespoke tailoring
tier: complex · strategy: committed · bg: pure-black (midnight suiting navy, hue ~255, L ~0.16)
palette: "chalk marks on midnight wool" — primary chalk white, accent crimson buttonhole (~15), ink off-white, third role flannel gray
type: display Prata · body Jost
motion: medium — measurement lines draw across a silhouette with dimensions ticking in; fabric drapes scroll with parallax weight
imagery: picsum(tailor-1..3) cutting table, fittings, lapel macro
copy: sartorial, rich — the 3-fitting process, cloth library by mill, the honest 10-week timeline, price architecture, alterations-for-life policy

### 092 — touchdown — Touchdown, vintage football shirts
tier: medium · strategy: full palette · bg: pure-white with pitch-green sections
palette: "1994 away kit under stadium floodlights" — pitch green (~150 deep), kit white, retro gold (~90), ink near-black
type: display Archivo 900 · body Gabarito
motion: medium — shirt wall zooms on hover with season tags; era tabs slide like substitution boards
imagery: picsum(shirts-1..3) flat-lay kits + stadium
copy: nostalgic terrace voice, medium — this week's drop, condition grading honesty, the fake-spotting guide, sell-to-us process, wishlist alerts

## Batch 24 (pages 093–096)

### 093 — saturnalia — Saturnalia, masquerade ball
tier: simple · strategy: drenched · bg: color (midnight purple, hue ~285, L ~0.16)
palette: "candlelight on a gold filigree mask" — primary mask gold (~85), accent candle amber (~70), ink ivory
type: display Cinzel Decorative · body Jost
motion: strong — gold confetti and a falling mask reveal on load; candle flames flicker at the viewport edges
imagery: generative mask + picsum(masquerade-1) ballroom
copy: decadent, sparse — one night, the dress code decree, orchestra + midnight toast, tickets vanish at capacity

### 094 — the-catacomb — The Catacomb, escape room
tier: medium · strategy: drenched · bg: pure-black (torch-black)
palette: "torchlight on carved stone" — primary torch amber (~70), accent puzzle teal (~180) for interactive elements, ink bone white
type: display Rozha One · body Cutive Mono
motion: strong — torch flicker lighting on the hero, a 60:00 countdown demo you can start, lock mechanisms click on hover
imagery: picsum(catacomb-1..2) dark corridor + puzzle detail
copy: tense, medium — three rooms with honest escape rates, the no-jump-scares policy (or the opposite), team sizes, booking calendar

### 095 — bright-harbor — Bright Harbor, coworking space
tier: medium · strategy: committed · bg: pure-white
palette: "harbor blue awning in morning sun" — primary harbor blue (~240), accent signal coral (~35), ink near-black
type: display Gabarito 800 · body Hanken Grotesk
motion: medium — interactive floor plan lights up desks on hover; meeting-room availability ticks live-feel
imagery: picsum(cowork-1..2) space + coffee bar
copy: welcoming, medium — three membership tiers, the no-zoom-booths-after-6 rule, community board, day-pass honesty, tour booking

### 096 — the-greenskeeper — The Greenskeeper, historic golf club
tier: medium · strategy: committed · bg: pure-white with fairway-green sections
palette: "tartan and morning dew" — primary fairway green (~150 deep), accent tartan navy (~255), ink near-black
type: display Marcellus · body Literata
motion: subtle — course flyover pans slowly across the 18 holes map; flagstick waves
imagery: picsum(golf-1..2) fairway dawn + clubhouse
copy: clubby, medium — hole-by-hole highlights, the 1892 founding story, visitor tee-time honesty, membership waitlist, the halfway-house menu

## Batch 25 (pages 097–100)

### 097 — opal-coast — Opal Coast, campervan road trips
tier: medium · strategy: full palette · bg: pure-white
palette: "outback dust on a teal van door" — outback rust (~45), ocean teal (~190), sun yellow (~100) chips, ink slate
type: display Tilt Warp · body Hanken Grotesk
motion: medium — route draws itself along a coastal map; van bounces gently at waypoints
imagery: picsum(camper-1..2) van at beach + coastal road
copy: laid-back, medium — three vans with honest quirks, the 7-day route, what's-included honesty, one-way fees explained, availability calendar

### 098 — bright-lattice — Bright Lattice, solar energy startup
tier: medium · strategy: committed · bg: pure-white
palette: "sun-path diagram on an engineer's print" — primary solar amber (~85), accent grid navy (~250), ink near-black
type: display Sora · body Hanken Grotesk
motion: medium — sun arcs across the hero tied to time-of-day; roof-scan animation estimates panels; savings counter
imagery: generative sun-path + picsum(solar-1) rooftop panels
copy: optimistic engineering, medium — the math-first quote process, panel degradation honesty, install day walkthrough, financing without jargon

### 099 — golden-hour — Golden Hour, hot air balloon rides
tier: simple · strategy: drenched · bg: color (dawn gradient — peach ~55 into lavender ~300, L ~0.75)
palette: "the sky ten minutes before sunrise" — ink deep plum (~310 deep), primary burner-flame orange (~50) for CTA, accent basket brown
type: display Jost 300 · body Hanken Grotesk
motion: subtle — balloon drifts with a slow float cycle; clouds parallax at different depths
imagery: picsum(balloon-1..2) balloons at dawn
copy: dreamy, sparse — sunrise flights only, the weather-call honesty ("we cancel, you rebook free"), champagne-landing tradition, gift cards

### 100 — grand-terminal — Grand Terminal, historic train station hotel
tier: complex · strategy: full palette · bg: pure-white with locomotive-black sections
palette: "brass and steam under a vaulted glass roof" — locomotive black, brass gold (~85), ticket-manila accent (~85 pale, low chroma), ink near-black
type: display Marcellus · body Cutive Mono (literal departure-board register)
motion: strong — split-flap departure board animates arrivals/departures as the nav; steam drifts across the hero; platform clock ticks real time
imagery: picsum(station-1..3) vaulted roof, platform, suite
copy: golden-age, rich — the 1912 station story, rooms in the old first-class wing, the restaurant under the clock, platform-side bar, arrival-by-train packages
