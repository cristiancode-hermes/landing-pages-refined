---
name: deploy
description: >-
  Deployment policy and platform workflows — Vercel (the default target,
  driven through the Vercel MCP) and Netlify (manual deploys, netlify.toml,
  functions). Use when deploying, configuring hosting, debugging a failed
  deploy/build on either platform, or setting up previews and rollbacks.
---

# Deploy

References:

- [vercel.md](vercel.md) — the **default** target: Vercel via MCP + git integration
- [netlify.md](netlify.md) — manual Netlify deploys: CLI, netlify.toml, functions
- [turborepo.md](turborepo.md) — monorepos with frontend + dedicated backend (Turborepo on Vercel)

## Policy (this kit's default)

1. **Vercel is the default deploy target.** Unless the user names another
   platform, deploy to Vercel — and drive it through the **Vercel MCP**
   (registered in `.mcp.json`): inspect projects, read build/runtime logs,
   check deployment status, and manage envs through MCP tools instead of
   guessing from CLI output.
2. **Netlify is the deliberate alternative** — used often in this kit's
   projects, always as an explicit choice. When the user says "deploy to
   Netlify" (or the repo has a `netlify.toml`), load netlify.md and follow
   the manual CLI workflow.
3. An existing project's platform wins over the default: `vercel.json` /
   `.vercel/` → Vercel; `netlify.toml` / `.netlify/` → Netlify. Never
   migrate platforms as a side effect of a deploy task.
4. **Frontend + dedicated backend in one repo → Turborepo** (turborepo.md):
   shared contract package, per-app Vercel projects with `turbo-ignore`,
   backend pruned into a container via `turbo prune`.

## Rules for any deploy (both platforms)

- **Production deploys are outward-facing**: preview/draft first, verify the
  preview URL actually works (load it — don't assume), then promote to
  production. Ask before the first production deploy of a session unless the
  user already said "ship it".
- Secrets go in the platform's env settings, never in the repo or build
  logs. `*_URL`, `*_KEY` values differ per environment (preview vs prod) —
  set both deliberately.
- A failed build is debugged from the **platform's build log** (via MCP for
  Vercel, `netlify logs` / deploy log URL for Netlify), not by re-running
  blind.
- Record what was deployed in the shift note: platform, project, deploy URL,
  and the commit SHA.
