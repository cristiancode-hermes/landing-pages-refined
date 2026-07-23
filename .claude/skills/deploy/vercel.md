# Vercel — the default target, driven via MCP

## The Vercel MCP (preferred interface)

`.mcp.json` registers Vercel's official MCP server (`https://mcp.vercel.com`,
OAuth on first use). Prefer its tools over guessing:

- **Before deploying**: list projects/teams to find the right project;
  confirm which git branch maps to production.
- **After pushing**: check deployment status and read **build logs** through
  MCP instead of polling the dashboard; on failure, fetch the log, fix,
  push again.
- **Debugging prod issues**: fetch runtime logs for the failing
  function/route; search Vercel docs via the MCP when config questions come
  up.

In Cursor/other agents without this MCP: the `vercel` CLI below covers the
same ground (`vercel list`, `vercel inspect <url> --logs`).

## Deploy model: git integration first

The healthy setup is **push-to-deploy** — Vercel builds every push:

- Every push to any branch → **preview deployment** with a unique URL
  (posted on the PR when the GitHub app is installed).
- Push/merge to the production branch (usually `main`) → **production**.

So "deploy" usually means: commit, push, then verify the resulting
deployment via MCP. Manual CLI deploys are for repos without git
integration or for quick experiments:

```bash
npm i -g vercel
vercel link                    # bind this dir to a Vercel project (once)
vercel                         # preview deploy of the working tree
vercel --prod                  # production deploy — outward-facing: confirm first
vercel inspect <deploy-url> --logs   # build log of a specific deployment
vercel rollback                # instant: re-points prod to a previous deployment
vercel env pull .env.local     # sync project envs for local dev (gitignored!)
```

## Configuration

Framework presets are auto-detected (Next.js, Angular, Vite, Astro…) —
add `vercel.json` only for what the preset can't infer:

```jsonc
// vercel.json — keep minimal; empty is the best vercel.json
{
  "redirects": [{ "source": "/old-docs/:path*", "destination": "/docs/:path*" }],
  "headers": [{
    "source": "/(.*)",
    "headers": [{ "key": "X-Frame-Options", "value": "DENY" }]
  }],
  "crons": [{ "path": "/api/cleanup", "schedule": "0 3 * * *" }]
}
```

- **SPA fallback** (non-Next SPAs like Angular/Vite):
  `{ "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }] }`
- **Monorepo**: set the project's Root Directory in project settings (or per
  project via MCP) — not with path gymnastics in build commands.
- Env vars: three scopes (Production / Preview / Development). Set via
  dashboard/MCP or `vercel env add KEY production`. A secret that only
  exists in Production is the classic "works in preview, 500s in prod".

## Serverless & edge

```ts
// app/api/route.ts (Next) or api/hello.ts (other frameworks)
export async function GET(req: Request) {
  return Response.json({ ok: true });
}
```

- Default Node runtime for anything using SDKs/DB drivers; Edge runtime only
  for latency-critical, dependency-light handlers.
- Function limits (duration/memory) are plan-dependent — long work belongs
  in a queue or cron, not a request handler.
- Pair with Neon (see the neon track): pooled connection string or the
  serverless driver from Vercel functions; the Vercel×Neon integration
  injects `DATABASE_URL` per environment and can create a **Neon branch per
  preview deployment**.

## Verify a deploy (definition of done)

1. Build succeeded (MCP: deployment status = READY).
2. Open the deployment URL — the page actually renders (use the playwright
   MCP for a real check, or at minimum `curl -sSf -o /dev/null -w '%{http_code}' <url>`).
3. One key flow exercised (login page loads, API health endpoint 200s).
4. Shift note updated with deploy URL + commit SHA.
