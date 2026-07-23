# Turborepo — frontend + dedicated backend in one repo

Use this layout when a project has both a frontend (Angular/Next/Vite) and a
dedicated backend (NestJS etc.). Turborepo orchestrates builds with caching;
Vercel hosts the frontend (and knows Turborepo natively); the backend
deploys wherever it fits (Vercel functions, Fly/Railway/containers).

## Layout

```
.
├── apps/
│   ├── web/                 # frontend (Next/Angular/Vite)
│   └── api/                 # NestJS backend
├── packages/
│   ├── shared/              # types + validation shared by web & api
│   │   └── src/index.ts     #   e.g. zod schemas → both sides validate identically
│   ├── ui/                  # component library (frontend-only)
│   └── typescript-config/   # shared tsconfig bases
├── package.json             # workspaces: ["apps/*", "packages/*"]
├── turbo.json
└── pnpm-workspace.yaml      # pnpm recommended for monorepos
```

The killer feature of the shared package — one source of truth for the
API contract:

```ts
// packages/shared/src/orders.ts
export const CreateOrderSchema = z.object({
  productId: z.string().uuid(),
  quantity: z.number().int().min(1).max(100),
});
export type CreateOrder = z.infer<typeof CreateOrderSchema>;
// apps/api validates requests with it; apps/web types its client with it —
// the contract cannot drift.
```

## turbo.json (v2 syntax — `tasks`, not `pipeline`)

```jsonc
{
  "$schema": "https://turborepo.com/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],          // build my workspace deps first
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"]
    },
    "test":      { "dependsOn": ["^build"] },
    "lint":      {},
    "typecheck": { "dependsOn": ["^build"] },
    "dev":       { "cache": false, "persistent": true }
  },
  "globalEnv": ["NODE_ENV"],            // env vars that affect ALL task hashes
  "globalDependencies": ["tsconfig.base.json"]
}
```

```bash
turbo build                      # builds everything, cached
turbo test --filter=api          # just the backend (+ its deps)
turbo build --filter=...shared   # everything that depends on shared
turbo run lint typecheck test    # what CI runs — one command, full cache
```

- **Caching is the point**: unchanged packages replay from cache in
  milliseconds. Declare `outputs` truthfully or you'll replay stale builds;
  list env vars a task reads in `env`/`globalEnv` or cache hits will ignore
  config changes — the classic Turborepo footgun.
- **Remote caching on Vercel** shares the cache between CI and every dev:
  `npx turbo login && npx turbo link` (CI: `TURBO_TOKEN` + `TURBO_TEAM`).

## Deploying the frontend on Vercel

One Vercel project per app, same git repo:

- Project **web** → Root Directory `apps/web`. Vercel detects Turborepo and
  builds with the repo-level cache; the default build command
  (`turbo build --filter=web...`) usually needs no override.
- **Skip unaffected deploys** so a backend-only commit doesn't redeploy the
  frontend — project setting "Root Directory: include files outside" plus:

```bash
# Vercel project → Settings → Git → Ignored Build Step
npx turbo-ignore web
```

`turbo-ignore` diffs the task graph: it cancels the build when neither
`apps/web` nor anything it depends on (`packages/ui`, `packages/shared`)
changed.

## Deploying the NestJS backend

Nest is a long-lived server — its natural home is a container host
(Fly/Railway/Render/K8s), keeping Vercel for the frontend:

```bash
# turbo prune produces a minimal repo slice for Docker — small, cache-friendly
turbo prune api --docker
```

```dockerfile
FROM node:22-alpine AS builder
WORKDIR /repo
COPY out/json/ .                      # pruned manifests only → cached npm ci
RUN corepack enable && pnpm install --frozen-lockfile
COPY out/full/ .                      # pruned source
RUN pnpm turbo build --filter=api

FROM node:22-alpine
WORKDIR /app
COPY --from=builder /repo/apps/api/dist ./dist
COPY --from=builder /repo/node_modules ./node_modules
CMD ["node", "dist/main.js"]
```

Alternative when the API is small and Vercel-native is preferred: expose it
as Vercel functions (second Vercel project rooted at `apps/api` with a
serverless adapter) — fine for low-traffic CRUD; long-running work still
needs a queue (see nestjs track).

## CI wiring

```yaml
# .github/workflows/ci.yml — one job, full graph, remote cache
- run: pnpm install --frozen-lockfile
- run: npx turbo run lint typecheck test build
  env:
    TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
    TURBO_TEAM: ${{ vars.TURBO_TEAM }}
```

Rules of the road: apps never import other apps (only packages); packages
declare real `dependencies` on each other (that's what `^build` walks);
env-specific URLs (`web` → `api` base URL) come from each platform's env
settings per environment, never hardcoded.
