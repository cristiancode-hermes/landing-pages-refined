# Netlify — manual deploy workflow

Used when the user chooses Netlify (or the repo has `netlify.toml`). The
flow below is CLI-first; Netlify also ships an official MCP (`@netlify/mcp`)
you can add to `.mcp.json` for a project that lives on Netlify.

## CLI essentials

```bash
npm i -g netlify-cli
netlify login                       # once per machine
netlify init                        # create & link a new site (or: netlify link)
netlify status                      # which site/account this repo is bound to

# THE core loop — draft first, verify, then promote:
netlify deploy --build              # runs the build, deploys a DRAFT with a unique URL
#   → open the draft URL, actually verify it works
netlify deploy --build --prod       # production — outward-facing: confirm first

netlify open                        # dashboard for this site
netlify logs:function hello         # tail a function's runtime logs
netlify dev                         # local dev with functions/redirects emulated
netlify env:set STRIPE_KEY sk_live_… --context production
netlify env:list                    # per-context env audit
```

- `netlify deploy` without `--build` uploads a prebuilt `--dir` — use
  `--build` so the deploy matches CI behavior.
- Rollback = dashboard → Deploys → pick a previous deploy → "Publish
  deploy" (instant, atomic). There's no CLI one-liner; say so instead of
  improvising.
- The `.netlify/` folder is tool state, not user code — keep it in
  `.gitignore`.

## netlify.toml — the whole contract in one file

```toml
[build]
  command = "npm run build"
  publish = "dist"                      # Angular: dist/<app>/browser  Vite: dist  Next: use the Next runtime

[build.environment]
  NODE_VERSION = "22"

[functions]
  directory = "netlify/functions"

# contexts: different behavior per deploy type
[context.production.environment]
  PUBLIC_API_BASE = "https://api.acme.com"
[context.deploy-preview.environment]
  PUBLIC_API_BASE = "https://staging-api.acme.com"

# SPA fallback — Angular/React/Vue routers need this or deep links 404
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

# proxy an API path to avoid CORS entirely
[[redirects]]
  from = "/api/*"
  to = "https://api.acme.com/:splat"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    Referrer-Policy = "strict-origin-when-cross-origin"
```

Order matters in redirects (first match wins) — the SPA fallback goes
**last**. `netlify.toml` overrides UI settings; prefer it so config is
reviewable.

## Functions (current format — don't generate the legacy handler style)

```ts
// netlify/functions/hello.mts — .mts enables modern ES modules
import type { Context, Config } from "@netlify/functions";

export default async (req: Request, context: Context) => {
  const name = new URL(req.url).searchParams.get("name") ?? "world";
  return Response.json({ hello: name });
};

export const config: Config = {
  path: "/api/hello",        // friendly route instead of /.netlify/functions/hello
};
```

- Web-platform `Request`/`Response`, default export, in-code `config` for
  routing — the old `exports.handler = async (event, context)` style is
  legacy; don't write it in new code.
- Env vars in functions: `Netlify.env.get("KEY")` (a global — no import).
- **Background functions**: same shape, file suffixed `-background`
  (`sync-crm-background.mts`), 15-min budget, returns 202 immediately —
  results go to Blobs/DB, not the response.
- **Scheduled functions**: `export const config = { schedule: "@hourly" }` —
  UTC cron, 30s limit, runs only on **published** deploys; test locally with
  `netlify functions:invoke <name>`.
- Platform primitives: Netlify Blobs for object/state storage, Image CDN for
  on-demand image optimization. Don't add CORS headers unless explicitly
  asked — same-origin via redirects (above) is the default posture.

## Verify a deploy (definition of done)

1. Draft deploy URL loads and one key flow works (real check — curl or the
   playwright MCP, not assumption).
2. Deep-link a route directly (SPA fallback proof) and hit one function
   endpoint.
3. Then `--prod`, re-verify the production URL, and record URL + SHA in the
   shift note.
