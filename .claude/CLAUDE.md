# LoopKit — Operating Contract

This repository is a **blueprint**: a ready-to-copy agent harness for any project.
These rules apply to every agent working in a repo that uses this kit — Claude Code,
Cursor, or any other coding agent. Follow them exactly.

## 1. Session protocol (the loop)

1. **Clock in** — read `MEMORY.md` (repo root) before touching anything. It is the
   cross-session shift log: the last entry tells you what the previous session did,
   what is in flight, and what to pick up.
2. **Work** — pick the smallest next step that moves the task forward. Load the
   relevant skill from `.claude/skills/` before starting specialized work (see §3).
3. **Verify** — never claim something works without running it. Prefer the
   `verifier` subagent (`.claude/agents/verifier.md`) for a fresh-context check
   of your own work before calling a task done.
4. **Clock out** — before ending a session with meaningful changes, append a shift
   note to `MEMORY.md` (format is documented at the top of that file). The Stop
   hook will nag you if you forget; in Cursor there is no hook, so do it yourself.

## 2. Hard rules

- **Never** commit secrets, tokens, or `.env` files. Never read `.env*` unless the
  user explicitly asks — use `.env.example` to learn variable names.
- **Never** force-push to `main`/`master`, rewrite published history, or delete
  branches you did not create this session.
- **Never** run destructive commands (`rm -rf` outside the workspace, `git reset --hard`
  on shared branches, dropping DB tables) without explicit user confirmation.
- Do not disable, bypass, or edit the hooks in `.claude/hooks/` to get a command
  through. If a hook blocks you, the block is the feedback — change the command.
- Keep diffs minimal. No drive-by reformatting, no unrelated "cleanup" in the same
  commit as a feature or fix.

## 3. Skills = muscle memory

`.claude/skills/` contains 18 tracks. Each track folder has a `SKILL.md` (the entry
point) plus deeper reference files. Claude Code auto-surfaces them; **other agents
must open the track's `SKILL.md` manually** when the work matches:

| Track        | Load when the task involves…                        |
|--------------|-----------------------------------------------------|
| `agent-llm/` | Claude API, prompts, tool use, agent loops          |
| `architecture/` | SOLID, clean code, layering, module boundaries   |
| `angular/`   | Angular (v17–22): signals, zoneless, signal forms, house style |
| `debug/`     | a bug, a failing test, a crash, "why doesn't X work"|
| `security/`  | auth, secrets, input handling, security review      |
| `frontend/`  | React, components, CSS, accessibility               |
| `frontend-design/` | visual design direction: aesthetics, typography, layout (official Anthropic skill) |
| `tailwind/`  | Tailwind v4 setup, tokens, utility patterns         |
| `nestjs/`    | NestJS modules, DI, validation, guards, testing     |
| `neon/`      | Neon Postgres: Data API, Auth+RLS, pgvector, branches|
| `eslint/`    | lint setup/errors, eslint.config.*, ESLint MCP      |
| `testing/`   | writing or fixing tests, coverage, browser E2E      |
| `refactor/`  | restructuring code without changing behavior        |
| `docs/`      | READMEs, API docs, changelogs                       |
| `data/`      | pandas, SQL, ETL, data analysis                     |
| `ml-python/` | training, evaluating, or deploying ML models        |
| `deploy/`    | deploying/hosting: Vercel (default), Netlify        |
| `git-ops/`   | branches, PRs, rebases, merge conflicts             |

> **C/C++ systems development** (native Win/Linux apps, terminal tools, C++
> backends, Unreal games, drivers, drone/embedded firmware) lives on its own
> dedicated branch, `cpp-systems` — a deliberately separate blueprint, not
> merged into `main`. Check that branch out for C/C++ projects.

## 4. Deployment policy

**Vercel is the default deploy target**, driven through the Vercel MCP
(registered in `.mcp.json`) — use its tools for deploy status, build/runtime
logs, and env management instead of guessing. **Netlify** is the deliberate
alternative for projects that choose it (or that carry a `netlify.toml`) —
follow the manual workflow in `.claude/skills/deploy/netlify.md`. An existing
project's platform always wins over the default; never switch platforms as a
side effect. Production deploys are outward-facing: draft/preview first,
verify the URL actually works, confirm before the first production deploy of
a session.

## 5. Verification standard

"Done" means: the change is exercised end-to-end (run the code, not just the type
checker), existing tests pass, new behavior has a test when the project has a test
suite, and the diff has been re-read top to bottom. If you cannot verify (missing
env, no test runner), say so explicitly instead of implying success.

## 6. Communication

- Lead with the outcome; details after.
- Report failures faithfully — a red test reported honestly is worth more than a
  green claim that doesn't hold.
- When blocked on a decision only the user can make, ask one precise question
  instead of guessing.
