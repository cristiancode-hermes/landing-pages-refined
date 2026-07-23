# MEMORY.md — cross-session shift log

This file is how agent sessions hand off to each other. **Read the newest
entry before working. Append an entry before ending a session with meaningful
changes.** Newest entry on top. Keep entries under ~15 lines; when the file
exceeds ~300 lines, compress the oldest half into a short "archive summary"
section at the bottom.

## Entry format

```markdown
## YYYY-MM-DD — <agent/model> — <branch>
**Did:** what actually got done (not what was attempted).
**State:** green/red — tests passing? deployed? anything half-finished?
**Decisions:** choices made that the next session shouldn't re-litigate, and why.
**Next:** the single most useful thing to pick up, plus known landmines.
```

---

## 2026-07-23 — Grok — main (2)
**Did:** Built root `index.html` gallery dashboard for the collection: dark
archive aesthetic (Bricolage Grotesque + Source Sans 3 + JetBrains Mono,
amber-on-indigo), sticky search/filters (tier + strategy), grid/list views,
100 cards from MANIFEST (95 live, 5 planned), Picsum seed thumbs + lazy
scaled iframe live previews, modal full preview, Open links to
`landings/*.html`. Verified desktop/mobile + modal in browser.
**State:** green — open via `npx serve .` → http://localhost:…/
**Decisions:** Data embedded in page (no build step for visitors); iframes
mount on IntersectionObserver and unload off-screen.
**Next:** Optional favicon; fill the 5 planned pages (052, 055, 069, 070, 087).

## 2026-07-23 — Grok — main
**Did:** Fixed header CTA contrast + mobile wrap across all landing pages with
header buttons (~42 CTAs). Root contrast bug: `.site-nav a` / `.main-nav a` /
`.nav a` color rules (spec 0,1,1) overrode `.btn` / `.nav-cta` text color
(0,1,0), washing labels to near-invisible muted ink. Scoped those selectors
with `:not(.btn):not(.nav-cta):not(.head-cta)` on 47 files. Added
`white-space: nowrap` + `flex-shrink: 0`, mobile font/padding clamp
(`header-cta-mobile` ≤480px), and mobile hide of non-CTA nav links on crowded
headers. Fixed hover contrast on gold-leaf, saltline, brightstack, saturnalia,
prism-break, etc. Northmark long label → dual “Meriden · $385” on mobile.
Verified 43 CTAs at 390px: nowrap, no overflow, ΔL ≥ 0.35.
**State:** green — browser-checked sample + full CTA audit; landings/ still
untracked in git (pre-existing).
**Decisions:** Scope nav color rules with `:not()` rather than `!important` on
buttons; shorten only Northmark’s extreme-length label on mobile.
**Next:** Commit `landings/` if/when ready; optional pass for non-header hero
CTAs with the same nav-specificity pattern if any inherit muted link color.

## 2026-07-15 — Claude Code — main (10)
**Did:** Added animation references to two tracks (verified against
angular.dev + tailwindcss.com via context7). angular/animations.md:
`@angular/animations` is DEPRECATED since v20.2 — modern path is native
CSS + `animate.enter`/`animate.leave` (class, array, and event-binding
forms; `event.animationComplete()` required for JS-driven leave, e.g.
GSAP), @starting-style for transition entries, signal+class swap for state
changes, router View Transitions (`withViewTransitions`,
`::view-transition-old/new`, view-transition-name), reduced-motion and
transform/opacity-only rules. tailwind/animations.md: transition scoping +
variants (data-/aria-/group-), `starting:` + `transition-discrete` for
popover/dialog entry-exit, built-in animate-* table, custom `--animate-*`
@theme tokens + keyframes, arbitrary animate-[...], stagger pattern,
motion-reduce as a review finding, Angular interop. Both SKILL.md routers +
descriptions updated.
**State:** green — frontmatter validated; docs-only change.
**Decisions:** animations live as reference files inside the existing
angular/tailwind tracks, not new top-level tracks (same trigger surface).
**Next:** nothing outstanding.

## 2026-07-14 — Claude Code — main (9)
**Did:** Added the `eslint/` track (18 tracks now): SKILL.md (v10 baseline —
flat config only, eslintrc removed, file-based config lookup, typed linting
via projectService), flat-config.md (base JS + typed TS recipes with
house-style rules — prefer-readonly, explicit-member-accessibility,
prefer-const, no-param-reassign, no-floating-promises; Angular layer with
prefer-signals/prefer-inject/template a11y; NestJS layer; migrate-config),
mcp-server.md (ESLint MCP: `npx @eslint/mcp` / `eslint --mcp`, agent
lint→fix→re-lint loop, no-disable discipline, CI `--max-warnings 0`).
Registered the eslint MCP server in .mcp.json + opencode.json; allowlisted
`npx eslint`; contract/AGENTS.md/cursor rule/README updated.
**State:** green — JSON + frontmatter validated; same skill being adapted
to the other four branches next.
**Decisions:** MCP server via npx `@eslint/mcp@latest` (works without a
local ESLint pin); lint rules mirror the angular house style so lint and
skill guidance agree.
**Next:** adapt eslint track to js-automation/python/cpp-systems/
csharp-dotnet (per-branch flat-config flavors).

## 2026-07-14 — Claude Code — main (8)
**Did:** Added the binding Angular house style to the `angular/` track:
new `style-standards.md` (signals first / RxJS only for genuinely complex
streams, restrictive visibility — private/protected + readonly everywhere
possible, `const` locals, spread-only array/object updates incl. toSorted/
toSpliced, early-return guard clauses, modern-API always/never table:
httpResource, inject(), input()/output()/model(), Signal Forms, @if/@for,
standalone) plus a review checklist. SKILL.md routes to it and summarizes
the five rules; frontmatter description and contract routing table updated.
**State:** green — skill frontmatter validated; docs-only change, nothing
to run.
**Decisions:** house style is a separate reference file (not inlined in
signals.md) so it reads as binding review rules, not background material.
**Next:** mirror the same house-style pattern (visibility/const/spread/
early-return) into the nestjs track if desired; js-automation branch (created
2026-07-13) is live and separate.

## 2026-07-05 — Claude Code — main (7)
**Did:** Adapted main for OpenCode (mirrors the adaptation already on
cpp-systems, with main-appropriate content). OpenCode reads AGENTS.md and
discovers skills from `.claude/skills/` natively, so no skill duplication.
Added `opencode.json` (full MCP set matching .mcp.json: github/vercel remote,
netlify/playwright local npx, context7 remote) and `.opencode/agent/
verifier.md` (main's general verifier — vitest/pytest examples — in OpenCode
frontmatter: mode subagent, write/edit off). AGENTS.md: OpenCode named in the
intro and non-Claude section; tooling notes cover opencode.json/.opencode and
AGENTS.md-wins precedence. install.sh copies both; README documents the
OpenCode path + tree entries.
**State:** green — opencode.json valid; install.sh passes bash -n.
**Decisions:** same as cpp-systems — skills live only in .claude/skills/ (no
.opencode/skill copies, no drift); MCP mirrored because OpenCode reads its
own config, not .mcp.json.
**Next:** dogfood install.sh; shellcheck+JSON CI workflow still pending.

## 2026-07-05 — Claude Code — main (6)
**Did:** Split the C/C++ work onto its own branch. Pushed `cpp-systems`
(at 44221f2) carrying the full `cpp` track (native/terminal/backend/unreal/
drivers/embedded-drones, 13 files). Then removed the `cpp` track from `main`
so the two branches are deliberately different blueprints — `main` is the
general-purpose kit (17 tracks, 65 files), `cpp-systems` is the C/C++
specialist. Registries on main updated + a pointer note added to CLAUDE.md/
AGENTS.md/README/Cursor rule directing C/C++ work to the branch.
**State:** green — `cpp-systems` pushed; `main` cpp removal committed here.
**Decisions:** per the user, `cpp-systems` must NOT be merged into `main`.
The Unreal content lives only on `cpp-systems` now (as `cpp/unreal/`).
Follow-up C/C++ changes go to `cpp-systems`, general-kit changes to `main`.
**Next:** dogfood install.sh (`--branch cpp-systems` on a C/C++ project);
shellcheck+JSON CI workflow still pending.

## 2026-07-05 — Claude Code — main (5)
**Did:** Replaced the narrow `unreal-cpp` track with a broad `cpp` track for
professional C/C++ systems development (still 18 tracks; unreal-cpp removed,
cpp added). Moved the 5 Unreal files verbatim into `cpp/unreal/` (unreal.md
is now a sub-entry, frontmatter stripped since it's no longer a top-level
skill). New files: SKILL.md (router + C++20/RAII/sanitizer baseline),
fundamentals.md (ownership, move, expected/exceptions, UB list, C interop,
concurrency), toolchain.md (target-based CMake, ASan/UBSan/TSan, vcpkg,
Win/Linux portability), native-apps.md (Qt-default desktop), terminal-apps.md
(CLI/TUI, exit codes, signals), backend-apis.md (Drogon/Asio coroutines,
backpressure), drivers.md (Linux kmod goto-cleanup + Windows KMDF),
embedded-drones.md (no-heap/RTOS + PX4/ArduPilot/MAVLink/MAVSDK/SITL).
Updated contract table, AGENTS.md, Cursor rule, README.
**State:** green — file counts: cpp has 12 files (7 top + 5 unreal). Total
skill files 77 across 18 tracks.
**Decisions:** kept Unreal as a sub-domain of cpp rather than deleting its
content — user said "remove the unreal skill" meaning the standalone track,
but the material is valuable under the new systems track. Each domain file
ends with a concrete "definition of done".
**Next:** dogfood install.sh; shellcheck+JSON CI workflow still pending.

## 2026-07-05 — Claude Code — main (4)
**Did:** Added Netlify MCP (@netlify/mcp) to .mcp.json alongside Vercel's.
New `architecture` track (SKILL.md + solid.md with violation/fix pairs +
clean-code.md + app-architecture.md: dependency rule, vertical slices,
modular monolith guidance). Added testing/test-design.md (what to test,
double taxonomy, fake-over-mock, TDD pragmatics, flake policy) and
deploy/turborepo.md (v2 tasks syntax, remote caching, per-app Vercel
projects + turbo-ignore, turbo prune Docker flow for the Nest backend,
shared zod contract package). Now 18 tracks, 70 files; registries updated.
**State:** green — .mcp.json validated. Note: Vercel MCP requires OAuth on
first interactive use; can't be exercised from this non-interactive session.
**Decisions:** architecture is its own track (not folded into refactor)
because it triggers on design/review, not just restructuring; Turborepo doc
lives under deploy/ since its trigger is "fullstack repo needs shipping".
**Next:** dogfood install.sh; shellcheck+JSON CI workflow still pending.

## 2026-07-05 — Claude Code — main (3)
**Did:** Added the `deploy` track (17 tracks, 64 files): SKILL.md encodes the
policy (Vercel = default target, driven via the Vercel MCP; Netlify = the
deliberate manual alternative, used often), vercel.md (MCP-first workflow,
git-integration deploy model, CLI, vercel.json, verify-a-deploy checklist),
netlify.md (CLI draft→prod loop, full netlify.toml exemplar, modern .mts
function format incl. background/scheduled — validated against Netlify's own
coding context via their MCP). Registered Vercel MCP (https://mcp.vercel.com)
in .mcp.json; added §4 Deployment policy to the contract (renumbered
Verification→5, Communication→6); updated AGENTS.md, Cursor rule, README.
**State:** green — .mcp.json validated; Vercel MCP needs OAuth on first use.
**Decisions:** platform detection (vercel.json/netlify.toml) beats the
default; production deploys require preview-first verification and a
confirmation on the session's first prod push.
**Next:** dogfood install.sh; shellcheck+JSON CI workflow still pending.

## 2026-07-05 — Claude Code — main (2)
**Did:** Vendored Anthropic's official `frontend-design` skill verbatim into
`.claude/skills/frontend-design/` (SKILL.md + its Apache-2.0 LICENSE.txt,
fetched from anthropics/skills@main). Registered in the contract table,
AGENTS.md, Cursor rule, README (16 tracks, 61 files); frontend track now
points at the vendored copy. Also optimized the verifier agent earlier today
(token-discipline rules, ~15-line report cap, model: sonnet).
**State:** green — skill auto-surfaced by Claude Code on write; content
unmodified from upstream.
**Decisions:** frontend-design is Apache-2.0 so vendoring with license is
clean; other official skills (webapp-testing, docx/pdf/pptx/xlsx) stay
installer-based — document skills are source-available, not open source.
**Next:** unchanged — dogfood install.sh on a real project; shellcheck+JSON
CI workflow.

## 2026-07-05 — Claude Code — main
**Did:** Deep-detail pass over the skill reference files (user request):
expanded ~35 files across all 15 tracks with runnable wrong-vs-right code
examples — full tool-loop and caching layouts (agent-llm), ddmin shrinker and
bisect run scripts (debug), exploit/fix pairs (security), race-safe fetch and
accessible dialog patterns (frontend), msw/fake-timer/Playwright storage-state
recipes (testing), shadow-run strangler and jscodeshift codemods (refactor),
endpoint-doc exemplar (docs), merge-validate and window-function idioms
(data), conflict-resolution walkthrough (git-ops), full signal-store/Signal
Forms/route examples (angular), guards/filters/config-validation (nestjs),
RPC/RLS-test/hybrid-search/CI-branch workflows (neon), cva/dark-token
patterns (tailwind), bounded training loops/bootstrap-CI/PSI monitors
(ml-python), complete Actor + pooling + UE::Tasks examples (unreal-cpp).
**State:** green — SKILL.md routers unchanged (progressive disclosure
preserved); file count still 59; no structural changes.
**Decisions:** depth lives in reference files, not SKILL.md entry points, to
keep trigger-time context small.
**Next:** same as before — dogfood install.sh on a real project; CI workflow
(shellcheck + JSON validation) still pending.

## 2026-07-04 — Claude Code — main
**Did:** Added two skill tracks directly on main (user-requested): `ml-python`
(data-prep/leakage, sklearn+PyTorch training, evaluation, production/drift —
5 files) and `unreal-cpp` (UE 5.8 baseline: gameplay framework, UPROPERTY/GC
and type system, Blueprint interop, performance — 5 files). Registered both
in the contract routing table, AGENTS.md, .cursor rule, and README (now
15 tracks, 59 skill files).
**State:** green — docs-only change; file counts verified against the tree.
**Decisions:** UE track targets 5.5+/5.8 idioms (TObjectPtr, Enhanced Input,
subsystems); ML track is framework-thin on purpose (patterns over API dumps).
**Next:** dogfood the installer on a real project; consider a shellcheck +
JSON-validation CI workflow.

## 2026-07-04 — Claude Code — claude/blueprint-repo-agent-setup-9wlwn2
**Did:** Bootstrapped the LoopKit blueprint: operating contract
(`.claude/CLAUDE.md` + root pointer), settings with permissions,
pre/post/stop hooks, verifier subagent, 13 skill tracks (49 files) including
angular (v22 signal-first), nestjs (v11), neon (Data API/Auth+RLS/pgvector),
tailwind (v4), `.mcp.json` (github, playwright, context7), Cursor layer
(`AGENTS.md`, `.cursor/rules/loopkit.mdc`), `run.sh` loop runner, `install.sh`
bootstrap, README.
**State:** green — hooks smoke-tested locally; nothing deployed.
**Decisions:** `.mcp.json` lives at repo root (Claude Code requirement),
not in `.claude/` as the original sketch showed. Official Anthropic skills
(frontend-design, webapp-testing, skill-creator) are installed via
`npx skills add anthropics/skills` (see install.sh) instead of vendored —
the document skills are source-available, not open source.
**Next:** Run `./install.sh --into <target-repo>` on a real project and
dogfood; consider adding an `.env.example` convention and a CI workflow that
lints hooks with shellcheck.
