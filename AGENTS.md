# AGENTS.md — instructions for ALL coding agents

This file is read natively by OpenCode, Cursor, GitHub Copilot, Codex, Gemini
CLI, and most other agents. Claude Code reads the same rules via `CLAUDE.md`.
The content is tool-agnostic: **any model in any editor follows the same
contract.**

## Read this first

1. **The contract**: read [`.claude/CLAUDE.md`](.claude/CLAUDE.md) — session
   protocol, hard rules, verification standard. It applies to you regardless
   of which model or editor you are.
2. **The shift log**: read [`MEMORY.md`](MEMORY.md) before working; append a
   shift note before finishing (format documented at the top of that file).
3. **Skills**: `.claude/skills/` holds 18 tracks of distilled practice
   (architecture, angular, nestjs, neon, tailwind, deploy, ml-python,
   testing, eslint, debug, security, frontend, frontend-design, refactor,
   docs, data, git-ops, agent-llm). Each track has a `SKILL.md` entry point. For design and frontend tasks, prioritize and use carefully all files of /impeccable skill.
   **C/C++ systems development** (native, terminal, backend, Unreal, drivers,
   drones/embedded) is a separate blueprint on the `cpp-systems` branch —
   not on `main`.
4. **Deployment**: Vercel is the default target (via the Vercel MCP when
   available); Netlify is the deliberate alternative — see
   `.claude/skills/deploy/`. An existing project's platform always wins. **Open and follow the matching track before starting
   specialized work** — the routing table is in `.claude/CLAUDE.md` §3.

## If you are NOT running inside Claude Code (OpenCode, Cursor, Copilot, …)

Claude Code automates some of this repo's conventions with hooks that other
tools don't execute. **OpenCode and Cursor do NOT run `.claude/hooks/`** — so
uphold their guarantees yourself:

- **Guardrails** (`.claude/hooks/pre-tool-use.sh` enforces these in Claude
  Code): never `rm -rf` outside the workspace, never force-push to
  main/master, never read `.env*` files, never `chmod 777`, never pipe
  curl/wget into a shell.
- **Formatting** (`post-tool-use.sh`): run the project formatter (prettier /
  ruff / gofmt) on files you edit, when the project uses one.
- **Clean exit** (`stop.sh`): don't end a session with uncommitted changes
  and no shift note in `MEMORY.md`.
- **Verification**: before declaring work done, run the verifier checklist
  yourself — re-read the diff, run the tests, report honestly. OpenCode can
  also invoke the `verifier` subagent directly (defined in both
  `.opencode/agent/` and `.claude/agents/`).

## Tooling notes

- **OpenCode** reads this `AGENTS.md`, discovers skills from `.claude/skills/`
  natively (no copying needed), loads the `verifier` agent from
  `.opencode/agent/`, and reads MCP servers + permissions from
  `opencode.json`. If both `AGENTS.md` and `CLAUDE.md` exist, OpenCode uses
  `AGENTS.md` — so this file is the source of truth there.
- **Claude Code** reads `.claude/` (contract, hooks, agents, skills) and MCP
  servers from `.mcp.json` automatically.
- **Cursor** reads `AGENTS.md` + `.cursor/rules/loopkit.mdc`; mirror
  `.mcp.json` into `Cursor Settings → MCP` for the same tools.
- One source of truth for the rules: `.cursor/rules/`, `opencode.json`, and
  `.mcp.json` all point back at the contract and this file — no divergent
  copies.
