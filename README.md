# claude-workflow — LoopKit

**A blueprint repository for agent-ready projects.** Drop this harness into
any repo and every coding agent — Claude Code, Cursor (with any model),
Copilot — arrives with the same contract, guardrails, memory, and skills.

```
.claude/                       main harness
├── CLAUDE.md                  contract / operating rules
├── settings.json              permissions + hooks
├── hooks/                     reflexes
│   ├── pre-tool-use.sh        guard bad calls (rm -rf, force-push, .env reads)
│   ├── post-tool-use.sh       format + log
│   └── stop.sh                clean exit (shift-note nag)
├── agents/
│   └── verifier.md            shift-notes cop — fresh-context verification
└── skills/                    muscle memories · 18 tracks
    ├── agent-llm/             Claude patterns, tool use, caching, agent loops
    ├── angular/               Angular v17–22, signal-first (v22 baseline)
    ├── architecture/          SOLID, clean code, layering, boundaries
    ├── deploy/                Vercel default (MCP) + Netlify + Turborepo monorepos
    ├── frontend-design/       official Anthropic design skill (Apache-2.0, vendored)
    ├── nestjs/                NestJS v11 — DI, validation, guards, testing
    ├── neon/                  Neon Postgres — Data API, Auth+RLS, pgvector
    ├── tailwind/              Tailwind v4 — CSS-first config, patterns
    ├── ml-python/             ML — data prep, sklearn/PyTorch, eval, production
    ├── debug/                 triage + repro + bisect
    ├── security/              audit + threat model + secrets
    ├── frontend/              React + a11y + CSS
    ├── eslint/                ESLint v10 flat config + ESLint MCP lint loop
    ├── testing/               Jest/Vitest + Playwright + coverage
    ├── refactor/              safe rewrites, strangler, codemods
    ├── docs/                  READMEs + API docs
    ├── data/                  pandas + SQL
    └── git-ops/               PRs + rebases
.mcp.json                      MCP servers for Claude Code (github, vercel, netlify, playwright, eslint, context7)
opencode.json                  MCP servers for OpenCode (same set)
.opencode/agent/verifier.md    verifier subagent for OpenCode
AGENTS.md                      the same rules for OpenCode/Cursor/Copilot/any agent
.cursor/rules/loopkit.mdc      Cursor auto-applied pointer rule
CLAUDE.md                      root pointer → .claude/CLAUDE.md
MEMORY.md                      cross-session shift log
run.sh                         the loop runner (bounded agent iterations)
install.sh                     one-line curl bootstrap
```

## Quick start

**Use it in a new project** (from the target repo):

```bash
curl -fsSL https://raw.githubusercontent.com/criscode2022/claude-workflow/main/install.sh | bash
```

Anthropic's official **frontend-design** skill ships vendored in
`.claude/skills/frontend-design/` (Apache-2.0, license included, content
verbatim). Add `--with-official` (run the script directly) to also install
the other official skills — [webapp-testing, skill-creator, docx/pdf/pptx/
xlsx](https://github.com/anthropics/skills) — via
[skills.sh](https://www.skills.sh/): `npx skills add anthropics/skills`.

**Claude Code**: open the repo — settings, hooks, skills, and the `verifier`
subagent load automatically.

**OpenCode (any model)**: open the repo — OpenCode reads `AGENTS.md`,
discovers the skills straight from `.claude/skills/` (it searches that path
natively), loads the `verifier` subagent from `.opencode/agent/`, and reads
MCP servers + permissions from `opencode.json`. Hooks don't run in OpenCode,
so `AGENTS.md` tells the model to uphold the guardrails and shift-note
discipline itself.

**Cursor (any model)**: open the repo — Cursor reads `AGENTS.md` and
`.cursor/rules/loopkit.mdc` automatically. Hooks don't execute in Cursor, so
the rules instruct the model to uphold the same guardrails manually. Mirror
`.mcp.json` into `Cursor Settings → MCP` if you want the same MCP tools.

## How it works

- **Contract** (`.claude/CLAUDE.md`) — session protocol: read `MEMORY.md`,
  work in small verified steps, write a shift note before leaving.
- **Hooks** — deterministic reflexes Claude Code executes around tool calls:
  block dangerous commands, auto-format edits, and refuse to end a session
  with uncommitted work and no shift note.
- **Skills** — each track is a `SKILL.md` entry point plus deeper reference
  files (progressive disclosure, per the
  [Agent Skills spec](https://github.com/anthropics/skills)). Claude Code
  surfaces them by description; other agents follow the routing table in the
  contract.
- **Verifier agent** — a fresh-context subagent that re-checks claimed work
  against the actual diff and test output before "done" is allowed.
- **Loop runner** (`run.sh`) — bounded iterations with `MEMORY.md` as the
  continuity layer: fresh context each pass, `<TASK_COMPLETE>` /
  `<CONTINUE>` / `<BLOCKED>` protocol.

## Branches

- **`main`** — the general-purpose blueprint (18 tracks: web/backend/data/ML
  and the full harness).
- **`cpp-systems`** — a dedicated, deliberately separate blueprint for
  professional **C and C++ systems development**: native apps (Windows &
  Linux), terminal/CLI tools, C++ backend APIs, Unreal Engine videogames,
  kernel/device drivers, and drone/embedded firmware. It is **not merged into
  `main`** — the two are different blueprints for different kinds of project.
  Use it via `git checkout cpp-systems`, or point `install.sh --branch
  cpp-systems` at a C/C++ project.

## Customizing

1. Edit `.claude/CLAUDE.md` — it's the one file every agent reads.
2. Add a track: `mkdir .claude/skills/<name>` + a `SKILL.md` with
   frontmatter (`name`, `description` with clear trigger conditions), then
   register it in the contract's routing table.
3. Tighten/loosen `settings.json` permissions per project.
4. `.mcp.json`: add servers your project needs (e.g. Neon's MCP server for
   database branching from chat).
